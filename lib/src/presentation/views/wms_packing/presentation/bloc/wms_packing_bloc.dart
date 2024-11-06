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

  //*listad de pedido de un batch
  List<PedidoPacking> listOfPedidos = [];

  //*lista de productos de un pedido
  List<PorductoPedido> listOfProductos = [];
  List<PorductoPedido> listOfProductosRecomendados = [];

  PorductoPedido currentProduct = PorductoPedido();

  //*lista de todas las pocisiones de los productos del batchs
  List<String> positions = [];

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  WmsPackingRepository wmsPackingRepository = WmsPackingRepository();

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
  int numPackages = 0;

  //Lista de paquetes
  List<String> packages = [];

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
  }

  //*metodo para cambiar la cantidad seleccionada
  void _onChangeQuantitySelectedEvent(
      ChangeQuantitySeparate event, Emitter<WmsPackingState> emit) async {
    if (event.quantity > 0) {
      quantitySelected = event.quantity;
      await db.getFieldTableProductosPedidos(event.pedidoId, event.productId,
          "quantity_separate", quantitySelected);
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
      final batchsFromDB = await DataBaseSqlite().getAllBatchsPacking();
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
      await db.getFieldTableProductosPedidos(
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
          event.pedidoId , event.productId);
    }
    emit(ChangeQuantitySeparateState(quantitySelected));
  }







  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<WmsPackingState> emit) async {
    if (event.locationIsOk) {
      //actualizamos la ubicacion del producto a true
      await db.getFieldTableProductosPedidos(
          event.pedidoId, event.productId, "is_location_is_ok", "true");
      //todo: actualiar al pedido de comenzado

      // actualizamo el valor de que he seleccionado el producto
      await db.getFieldTableProductosPedidos(
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
      await db.getFieldTableProductosPedidos(
          event.pedidoId, event.productId, "product_is_ok", "true");
      //actualizamos la cantidad separada
      await db.getFieldTableProductosPedidos(
          event.pedidoId, event.productId, "quantity_separate", event.quantity);
    }
    productIsOk = event.productIsOk;
    emit(ChangeIsOkState(
      productIsOk,
    ));
  }
}
