// ignore_for_file: unnecessary_type_check, unnecessary_null_comparison, avoid_print

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_packing/data/wms_packing_repository.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';

part 'wms_packing_event.dart';
part 'wms_packing_state.dart';

class WmsPackingBloc extends Bloc<WmsPackingEvent, WmsPackingState> {
  //*lista de batchs para packing
  List<BatchPackingModel> listOfBatchs = [];
  List<BatchPackingModel> listOfBatchsDB = [];
  List<BatchPackingModel> listOfBatchsDoneDB = [];

  //*listad de pedido de un batch
  List<PedidoPacking> listOfPedidos = [];

  //*lista de productos de un pedido
  List<PorductoPedido> listOfProductos = [];
  List<PorductoPedido> listOfProductosProgress = [];
  List<PorductoPedido> productsDone = [];
  //*lista de todos los productos a empacar
  List<PorductoPedido> productsPacking = [];
  //*lista de paquetes
  List<Paquete> packages = [];

  PorductoPedido currentProduct = PorductoPedido();

  //*lista de todas las pocisiones de los productos del batchs
  List<String> positions = [];

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  WmsPackingRepository wmsPackingRepository = WmsPackingRepository();

  //*isSticker
  bool isSticker = false;

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  String oldLocation = '';

  // //*validaciones de campos del estado de la vista
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;

  int completedProducts = 0;

  int quantitySelected = 0;

  //*numero de paquetes

  int index = 0;

  DataBaseSqlite db = DataBaseSqlite();

  //*batch con productos
  BatchWithProducts batchWithProducts = BatchWithProducts();

  WmsPackingBloc() : super(WmsPackingInitial()) {
    //*obtener todos los batchs para packing de odoo
    on<LoadAllPackingEvent>(_onLoadAllPackingEvent);
    //*obtener todos los batchs para packing de la base de datos
    on<LoadBatchPackingFromDBEvent>(_onLoadBatchsFromDBEvent);
    //*obtener todos los pedidos de un batch
    on<LoadAllPedidosFromBatchEvent>(_onLoadAllPedidosFromBatchEvent);
    //*obtener todos los productos de un pedido
    on<LoadAllProductsFromPedidoEvent>(_onLoadAllProductsFromPedidoEvent);

    on<FetchProductEvent>(_onFetchProductEvent);

    //*buscar un batch
    on<SearchBatchPackingEvent>(_onSearchBacthEvent);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeLocationDestIsOkEvent>(_onChangeLocationDestIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    //*cantidad
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);
    on<AddQuantitySeparate>(_onAddQuantitySeparateEvent);

    //*agregar un producto a nuevo empaque
    on<AddProductPackingEvent>(_onAddProductPackingEvent);

    on<ValidateFieldsPackingEvent>(_onValidateFieldsPacking);

    //*evento para cambiar la cantidad seleccionada
    on<ChangeQuantitySeparate>(_onChangeQuantitySelectedEvent);

    //*Picking
    on<SetPickingsEvent>(_onSetPickingsEvent);

    //*packing
    on<SetPackingsEvent>(_onSetPackingsEvent);

    //*confirmar el sticker
    on<ChangeStickerEvent>(_onChangeStickerEvent);

    //*filtrar por estado los batchs desde SQLite
    on<FilterBatchPackingStatusEvent>(_onFilterBatchesBStatusEvent);
  }

  void _onFilterBatchesBStatusEvent(FilterBatchPackingStatusEvent event,
      Emitter<WmsPackingState> emit) async {
    if (event.status == '') {
      final batchsFromDB = await db.getAllBatchsPacking();
      listOfBatchsDB = batchsFromDB;
      listOfBatchsDB = listOfBatchsDB
          .where((element) => element.isSeparate == null)
          .toList();
      emit(WmsPackingLoaded());

      return;
    } else if (event.status == 'done') {
      listOfBatchsDB = listOfBatchsDoneDB;
      emit(WmsPackingLoaded());

      return;
    }
  }

  //metodo para buscar un batch de packing
  void _onSearchBacthEvent(
      SearchBatchPackingEvent event, Emitter<WmsPackingState> emit) async {
    final query = event.query.toLowerCase();
    final batchsFromDB = await db.getAllBatchsPacking();

    if (event.indexMenu == 0) {
      if (query.isEmpty) {
        listOfBatchsDB = batchsFromDB;
        listOfBatchsDB = listOfBatchsDB
            .where((element) => element.isSeparate == null)
            .toList();
      } else {
        listOfBatchsDB = batchsFromDB.where((batch) {
          return batch.name?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
      // Emitir la lista filtrada
    } else {
      if (query.isEmpty) {
        listOfBatchsDB = listOfBatchsDoneDB;
      } else {
        listOfBatchsDB = listOfBatchsDoneDB.where((batch) {
          return batch.name?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
    }
    emit(WmsPackingLoaded());
  }

  ///*metodo para cambiar el estado del sticker
  void _onChangeStickerEvent(
      ChangeStickerEvent event, Emitter<WmsPackingState> emit) {
    isSticker = event.isSticker;
    emit(ChangeStickerState(isSticker));
  }

  //*metodo para realizar el empacado
  void _onSetPackingsEvent(
      SetPackingsEvent event, Emitter<WmsPackingState> emit) async {
    try {
      print('event.productos: ${event.productos.length}');
      if (event.productos.isNotEmpty) {
        //creamos un numero de paquete con la cantidad de productos y fecha actual
        int index = packages.length + DateTime.now().millisecondsSinceEpoch;

        print('index: $index');

        //creamos un paquete
        packages.add(Paquete(
          id: index,
          name: 'PACK-$index',
          batchId: event.productos[0].batchId,
          pedidoId: event.productos[0].pedidoId,
          cantidadProductos: event.productos.length,
          listaProductos: event.productos,
          isSticker: event.isSticker,
        ));

        await db.insertPackage(Paquete(
          id: index,
          name: 'PACK-$index',
          batchId: event.productos[0].batchId,
          pedidoId: event.productos[0].pedidoId,
          cantidadProductos: event.productos.length,
          isSticker: event.isSticker,
        ));

        for (var product in event.productos) {
          //verificamos si el empaquetado esta certificado
          if (!event.isCertificate) {
            await db.setFieldTableBatchPacking(event.productos[0].batchId ?? 0,
                 "is_selected", "true");

            await db.setFieldTablePedidosPacking(event.productos[0].batchId ?? 0,
                product.pedidoId ?? 0, "is_selected", "true");

            await db.setFieldTableProductosPedidos(product.pedidoId ?? 0,
                product.productId ?? 0, "is_separate", "true");

            await db.setFieldTableProductosPedidos(product.pedidoId ?? 0,
                product.productId ?? 0, "is_certificate", "false");
          } else {
            await db.setFieldTableProductosPedidos(product.pedidoId ?? 0,
                product.productId ?? 0, "is_certificate", "true");
          }

          //actualizamos el estado del producto como empacado
          await db.setFieldTableProductosPedidos(product.pedidoId ?? 0,
              product.productId ?? 0, "is_packing", "true");

          await db.setFieldTableProductosPedidos(product.pedidoId ?? 0,
              product.productId ?? 0, "id_package", index);
        }

        add(LoadAllProductsFromPedidoEvent(event.productos[0].pedidoId ?? 0));

        productsDone.clear();

        await db.setFieldTablePedidosPacking(event.productos[0].batchId ?? 0,
            event.productos[0].pedidoId ?? 0, "is_packing", "true");

        emit(WmsPackingLoaded());
      }
    } catch (e, s) {
      print('Error en el  _onSetPackingsEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  //*metodo que se encarga de hacer el picking
  void _onSetPickingsEvent(
      SetPickingsEvent event, Emitter<WmsPackingState> emit) async {
    try {
      //actualizamos el estado del producto como separado
      await db.setFieldTableProductosPedidos(
          event.pedidoId, event.productId, "is_separate", "true");
      //actualizamos la cantidad separada
      quantitySelected = 0;
    } catch (e, s) {
      print('Error en el  _onSetPickingsEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  //*metodo para cambiar la cantidad seleccionada
  void _onChangeQuantitySelectedEvent(
      ChangeQuantitySeparate event, Emitter<WmsPackingState> emit) async {
    print('event.quantity: ${event.quantity}');
    if (event.quantity > 0) {
      quantitySelected = event.quantity;
      await db.setFieldTableProductosPedidos(
          event.pedidoId, event.productId, "quantity_separate", event.quantity);
    }
    emit(ChangeQuantitySeparateState(quantitySelected));
  }

  void _onValidateFieldsPacking(
      ValidateFieldsPackingEvent event, Emitter<WmsPackingState> emit) {
    switch (event.field) {
      case 'location':
        isLocationOk = event.isOk;
        break;
      case 'product':
        isProductOk = event.isOk;
        break;
      case 'locationDest':
        isLocationDestOk = event.isOk;
        break;
      case 'quantity':
        isQuantityOk = event.isOk;
        break;
    }
    emit(ValidateFieldsPackingState(event.isOk));
  }

  void _onFetchProductEvent(
      FetchProductEvent event, Emitter<WmsPackingState> emit) async {
    try {
      emit(WmsProductInfoLoading());
      currentProduct = PorductoPedido();
      currentProduct = event.pedido;

      isLocationOk = true;
      isProductOk = true;
      isLocationDestOk = true;
      isQuantityOk = true;

      locationIsOk = currentProduct.isLocationIsOk == 1 ? true : false;
      productIsOk = currentProduct.productIsOk == 1 ? true : false;
      locationDestIsOk = currentProduct.locationDestIsOk == 1 ? true : false;
      quantityIsOk = currentProduct.isQuantityIsOk == 1 ? true : false;
      quantitySelected = currentProduct.quantitySeparate ?? 0;
      emit(WmsProductInfoLoaded());
    } catch (e, s) {
      print('Error en el  _onFetchProductEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onLoadAllProductsFromPedidoEvent(LoadAllProductsFromPedidoEvent event,
      Emitter<WmsPackingState> emit) async {
    try {
      emit(WmsPackingLoading());

      final response =
          await DataBaseSqlite().getProductosPedido(event.pedidoId);

      if (response != null && response is List) {
        print('response lista de productos: ${response.length}');
        listOfProductos.clear();
        listOfProductos.addAll(response);

        //filtramos y creamos la lista de productos listo a empacar
        productsDone = listOfProductos
            .where(
                (product) => product.isSeparate == 1 && product.isPacking != 1)
            .toList();

        //filtramos y creamos la lista de productos listo a separar para empaque
        listOfProductosProgress = listOfProductos
            .where((product) => product.isSeparate == null)
            .toList();

        //traemos todos los paquetes de la base de datos del pedido en cuesiton
        final packagesDB = await db.getPackagesPedido(event.pedidoId);
        packages.clear();
        packages.addAll(packagesDB);
        print('packagesDB: ${packagesDB.length}');

        //obtenemos las posiciones de los productos
        getPosicions();

        emit(WmsPackingLoaded());
      } else {
        print('Error _onLoadAllProductsFromPedidoEvent: response is null');
      }
    } catch (e, s) {
      print('Error en el  _onLoadAllProductsFromPedidoEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onLoadAllPedidosFromBatchEvent(
      LoadAllPedidosFromBatchEvent event, Emitter<WmsPackingState> emit) async {
    try {
      emit(WmsPackingLoading());
      final response = await DataBaseSqlite().getPedidosPacking(event.batchId);
      if (response != null && response is List) {
        print('response pedidos: ${response.length}');
        listOfPedidos.clear();
        listOfPedidos.addAll(response);
        print('pedidosToInsert: ${response.length}');
        emit(WmsPackingLoaded());
      } else {
        print('Error resPedidos: response is null');
      }
    } catch (e, s) {
      print('Error en el  _onLoadAllPedidosFromBatchEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void getPosicions() {
    positions.clear(); // Limpia la lista antes de agregar nuevas posiciones
    for (var product in listOfProductos) {
      if (product.locationId != null) {
        // Verifica si la posición ya existe en la lista
        if (!positions.contains(product.locationId!)) {
          positions
              .add(product.locationId!); // Solo agrega si no está en la lista
        }
      }
    }
    print('positions: ${positions.length}');
  }

  void _onAddProductPackingEvent(
      AddProductPackingEvent event, Emitter<WmsPackingState> emit) async {
    try {} catch (e, s) {
      print('Error en el  _onAddProductPackingEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onLoadAllPackingEvent(
      LoadAllPackingEvent event, Emitter<WmsPackingState> emit) async {
    emit(WmsPackingLoading());
    try {
      final response = await wmsPackingRepository.resBatchsPacking();

      if (response != null && response is List) {
        print('response batchs: ${response.length}');
        listOfBatchs.clear();
        listOfBatchs.addAll(response);

        for (var batch in listOfBatchs) {
          try {
            if (batch.id != null && batch.name != null) {
              await DataBaseSqlite().insertBatchPacking(BatchPackingModel(
                id: batch.id!,
                name: batch.name ?? '',
                scheduleddate: batch.scheduleddate ?? DateTime.now(),
                pickingTypeId: batch.pickingTypeId,
                state: batch.state,
                userId: batch.userId.toString(),
              ));
            }
          } catch (dbError, stackTrace) {
            print('Error insertBatchPacking: $dbError  $stackTrace');
          }
        }

        // Convertir el mapa en una lista de pedido unicos del batch para packing
        List<PedidoPacking> pedidosToInsert =
            listOfBatchs.expand((batch) => batch.listaPedidos!).toList();

        print('pedidosToInsert: ${pedidosToInsert.length}');

        // Enviar la lista agrupada de productos de un batch para packing
        await DataBaseSqlite().insertPedidosBatchPacking(pedidosToInsert);

        //convertir el mapa en una lista de productos unicos del pedido para packing
        List<ListaProducto> productsToInsert =
            pedidosToInsert.expand((pedido) => pedido.listaProductos!).toList();

        print('productsToInsert: ${productsToInsert.length}');
        // Enviar la lista agrupada de productos de un pedido para packing
        await DataBaseSqlite().insertProductosPedidos(productsToInsert);

        // //* Carga los batches desde la base de datos
        add(LoadBatchPackingFromDBEvent());
        emit(WmsPackingLoaded());
      } else {
        print('Error resBatchs: response is null');
      }
    } catch (e, s) {
      print('Error en el  _onLoadAllPackingEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onLoadBatchsFromDBEvent(
      LoadBatchPackingFromDBEvent event, Emitter<WmsPackingState> emit) async {
    try {
      emit(BatchsPackingLoadingState());
      final batchsFromDB = await db.getAllBatchsPacking();
      listOfBatchsDB.clear();
      listOfBatchsDB.addAll(batchsFromDB);
      print('batchsFromDB: ${batchsFromDB.length}');
      emit(WmsPackingLoaded());
    } catch (e, s) {
      print('Error en el  _onLoadBatchsFromDBEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<WmsPackingState> emit) async {
    if (event.isOk) {
      //actualizamos la cantidad del producto a true
      await db.setFieldTableProductosPedidos(
          event.pedidoId, event.productId, "is_quantity_is_ok", "true");
    }
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      quantityIsOk,
    ));
  }

  void _onAddQuantitySeparateEvent(
      AddQuantitySeparate event, Emitter<WmsPackingState> emit) async {
    quantitySelected = quantitySelected + event.quantity;
    if (event.quantity > 0) {
      quantitySelected = quantitySelected + event.quantity;
      await db.incremenQtytProductSeparatePacking(
          event.pedidoId, event.productId);
    }
    emit(ChangeQuantitySeparateState(quantitySelected));
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<WmsPackingState> emit) async {
    if (event.locationIsOk) {
      //actualizamos el estado del pedido como seleccionado
      await db.setFieldTablePedidosPacking(
          currentProduct.batchId ?? 0, event.pedidoId, "is_selected", "true");

      //actualizamos el estado de seleccion de un batch
       await db.setFieldTableBatchPacking(currentProduct.batchId ?? 0,
                 "is_selected", "true");
      //actualizamos la ubicacion del producto a true
      await db.setFieldTableProductosPedidos(
          event.pedidoId, event.productId, "is_location_is_ok", "true");
      //todo: actualiar al pedido de comenzado

      // actualizamo el valor de que he seleccionado el producto
      await db.setFieldTableProductosPedidos(
          event.pedidoId, event.productId, "is_selected", "true");
      locationIsOk = event.locationIsOk;
      emit(ChangeIsOkState(
        locationIsOk,
      ));
    }
  }

  void _onChangeLocationDestIsOkEvent(
      ChangeLocationDestIsOkEvent event, Emitter<WmsPackingState> emit) {
    locationDestIsOk = event.locationDestIsOk;
    emit(ChangeIsOkState(
      locationDestIsOk,
    ));
  }

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<WmsPackingState> emit) async {
    if (event.productIsOk) {
      //actualizamos el producto a true
      await db.setFieldTableProductosPedidos(
          event.pedidoId, event.productId, "product_is_ok", "true");
      //actualizamos la cantidad separada
      await db.setFieldTableProductosPedidos(
          event.pedidoId, event.productId, "quantity_separate", event.quantity);
    }
    productIsOk = event.productIsOk;
    emit(ChangeIsOkState(
      productIsOk,
    ));
  }
}
