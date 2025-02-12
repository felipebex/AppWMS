// ignore_for_file: unnecessary_type_check, unnecessary_null_comparison, avoid_print, collection_methods_unrelated_type, use_build_context_synchronously

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_packing/data/wms_packing_repository.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/sen_packing_request.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/un_packing_request.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/utils/formats.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'wms_packing_event.dart';
part 'wms_packing_state.dart';

class WmsPackingBloc extends Bloc<WmsPackingEvent, WmsPackingState> {
  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';

  //*lista de batchs para packing
  List<BatchPackingModel> listOfBatchs = [];
  List<BatchPackingModel> listOfBatchsDB = [];
  List<BatchPackingModel> listOfBatchsDoneDB = [];

  //*listad de pedido de un batch
  List<PedidoPacking> listOfPedidos = [];
  List<PedidoPacking> listOfPedidosFilters = [];

  //*lista de productos de un pedido
  List<PorductoPedido> listOfProductos = []; //lista de productos de un pedido
  List<PorductoPedido> listOfProductosProgress =
      []; //lista de productos sin certificar
  List<PorductoPedido> productsDone = []; //lista de productos ya certificados
  List<PorductoPedido> productsDonePacking =
      []; //lista de productos ya certificados
  List<PorductoPedido> listOfProductsForPacking =
      []; //lista de productos sin certificar seleccionados para empacar

  //*lista de todos los productos a empacar
  List<PorductoPedido> productsPacking = [];
  //*lista de productos de un pedido
  List<PorductoPedido> listOfProductsName = [];

  //*lista de paquetes
  List<Paquete> packages = [];
  //*lista de barcodes
  List<Barcodes> listOfBarcodes = [];
  //*producto actual
  PorductoPedido currentProduct = PorductoPedido();

  //*lista de todas las pocisiones de los productos del batchs
  List<String> positions = [];

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();
  TextEditingController searchControllerPedido = TextEditingController();
  TextEditingController searchControllerProduct = TextEditingController();
  //*repositorio
  WmsPackingRepository wmsPackingRepository = WmsPackingRepository();

  //*isSticker
  bool isSticker = false;
  // //*validaciones de campos del estado de la vista
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;
  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  bool isKeyboardVisible = false;
  bool viewQuantity = false;

  //* ultima ubicacion
  String oldLocation = '';

  int completedProducts = 0;
  int quantitySelected = 0;
  //*numero de paquetes
  int index = 0;

//*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  //*batch con productos
  BatchWithProducts batchWithProducts = BatchWithProducts();

  //configuracion del usuario //permisos
  Configurations configurations = Configurations();

  //*lista de novedades
  List<Novedad> novedades = [];

  WmsPackingBloc() : super(WmsPackingInitial()) {
    //obtener las configuraciones y permisos del usuario desde la bd
    on<LoadConfigurationsUserPack>(_onLoadConfigurationsUserEvent);
    //*obtener todos los batchs para packing de odoo
    on<LoadAllPackingEvent>(_onLoadAllPackingEvent);
    //*obtener todos los batchs para packing de la base de datos
    on<LoadBatchPackingFromDBEvent>(_onLoadBatchsFromDBEvent);
    //*obtener todos los pedidos de un batch
    on<LoadAllPedidosFromBatchEvent>(_onLoadAllPedidosFromBatchEvent);
    //*obtener todos los productos de un pedido
    on<LoadAllProductsFromPedidoEvent>(_onLoadAllProductsFromPedidoEvent);

    //*cargamos el producto a certificar
    on<FetchProductEvent>(_onFetchProductEvent);

    //*buscar un batch
    on<SearchBatchPackingEvent>(_onSearchBacthEvent);
    //*buscar un pedido
    on<SearchPedidoPackingEvent>(_onSearchPedidoEvent);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeLocationDestIsOkEvent>(_onChangeLocationDestIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);

    //*cantidad
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);
    on<AddQuantitySeparate>(_onAddQuantitySeparateEvent);

    //*agregar un producto a nuevo empaque
    on<AddProductPackingEvent>(_onAddProductPackingEvent);

    //*evento para validar los campos de la vista
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

    //evento para buscar un producto en la lista de productos de pedidos
    on<SearchProductPackingEvent>(_onSearchProductPackingEvent);

    //evento para mostrar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);
    //*evento para seleccionar productos sin certificar
    on<SelectProductPackingEvent>(_onSelectProductPackingEvent);
    //*evento para desseleccionar productos sin certificar
    on<UnSelectProductPackingEvent>(_onUnSelectProductPackingEvent);
    //*evento para obtener las novedades
    on<LoadAllNovedadesPackingEvent>(_onLoadAllNovedadesEvent);
    add(LoadAllNovedadesPackingEvent());

    //*metodo para dividir el producto en varios paquetes
    on<SetPickingSplitEvent>(_onSetPickingsSplitEvent);

    //*metodo para desempacar productos
    on<UnPackingEvent>(_onUnPackingEvent);
    //*evento para actualizar el valor del scan
    on<UpdateScannedValuePackEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValuePackEvent>(_onClearScannedValueEvent);
    //*evento para ver la cantidad
    on<ShowQuantityPackEvent>(_onShowQuantityEvent);

  }


  //*evento para ver la cantidad
  void _onShowQuantityEvent(ShowQuantityPackEvent event, Emitter<WmsPackingState> emit) {
    try {
      viewQuantity = !viewQuantity;
      emit(ShowQuantityPackState(viewQuantity));
    } catch (e, s) {
      print("❌ Error en _onShowQuantityEvent: $e, $s");
    }
  }

//*evento para limpiar el valor del scan
  void _onClearScannedValueEvent(
      ClearScannedValuePackEvent event, Emitter<WmsPackingState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          scannedValue1 = '';
          emit(ClearScannedValuePackState());
          break;
        case 'product':
          scannedValue2 = '';
          emit(ClearScannedValuePackState());
          break;
        case 'quantity':
          scannedValue3 = '';
          emit(ClearScannedValuePackState());
          break;
        case 'muelle':
          scannedValue4 = '';
          emit(ClearScannedValuePackState());
          break;
        default:
          print('Scan type not recognized: ${event.scan}');
      }
      emit(ClearScannedValuePackState());
    } catch (e, s) {
      print("❌ Error en _onClearScannedValueEvent: $e, $s");
    }
  }

  //*evento para actualizar el valor del scan
  void _onUpdateScannedValueEvent(
      UpdateScannedValuePackEvent event, Emitter<WmsPackingState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          // Acumulador de valores escaneados
          scannedValue1 += event.scannedValue;
          print('scannedValue1: $scannedValue1');
          emit(UpdateScannedValuePackState(scannedValue1, event.scan));
          break;
        case 'product':
          scannedValue2 += event.scannedValue;
          print('scannedValue2: $scannedValue2');
          emit(UpdateScannedValuePackState(scannedValue2, event.scan));
          break;
        case 'quantity':
          scannedValue3 += event.scannedValue;
          print('scannedValue3: $scannedValue3');
          emit(UpdateScannedValuePackState(scannedValue3, event.scan));
          break;
        case 'muelle':
          print('scannedValue4: $scannedValue4');
          scannedValue4 += event.scannedValue;
          emit(UpdateScannedValuePackState(scannedValue4, event.scan));
          break;
        default:
          print('Scan type not recognized: ${event.scan}');
      }
    } catch (e, s) {
      print("❌ Error en _onUpdateScannedValueEvent: $e, $s");
    }
  }

  //metodo para desempacar productos
  void _onUnPackingEvent(
      UnPackingEvent event, Emitter<WmsPackingState> emit) async {
    try {
      emit(UnPackingLoading());

      final responseUnPacking = await wmsPackingRepository.unPacking(
        event.request,
        event.context,
      );

      if (responseUnPacking.result?.code == 200) {
        //si es exitoso procedemos a desemapcar los productos
        //recorremos todo los productos del request
        for (var product in event.request.listItem) {
          //actualizamos el estado del producto como no separado
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "is_separate",
              null,
              product.idMove,
              event.request.idPaquete);
          //actualizamso el estado del producto como no empaquetado
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "is_package",
              null,
              product.idMove,
              event.request.idPaquete);

          //actualizamos el estado del producto como no dividido
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "is_product_split",
              null,
              product.idMove,
              event.request.idPaquete);
          //actualizamos el estado del producto como no certificado
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "is_certificate",
              null,
              product.idMove,
              event.request.idPaquete);

          //actualizamos el valor de is_location
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "is_location_is_ok",
              null,
              product.idMove,
              event.request.idPaquete);

          //actualizamos el valor de quantity_separate
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "quantity_separate",
              null,
              product.idMove,
              event.request.idPaquete);

          //actualizamos el valor de is_selected
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "is_selected",
              null,
              product.idMove,
              event.request.idPaquete);

          //actualizamos el valor de product_is_ok
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "product_is_ok",
              null,
              product.idMove,
              event.request.idPaquete);

          //actualzamos el valor de is_quantity_is_ok
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "is_quantity_is_ok",
              null,
              product.idMove,
              event.request.idPaquete);

          //actualizamos el valor de package_name
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "package_name",
              null,
              product.idMove,
              event.request.idPaquete);

          //acrtualizamos el valor del id_paquete en el producto
          await db.setFieldTableProductosPedidosUnPacking(
              event.pedidoId,
              product.productId,
              "id_package",
              null,
              product.idMove,
              event.request.idPaquete);
        }

        //restamos la cantidad de productos desempacados a un paquete
        await db.updatePackageCantidad(
          event.request.idPaquete,
          event.request.listItem.length,
        );

        //VERIFICAMOS CUANTOS PRODUCTOS TIENE EL PAQUETE
        final response = await db.getPackageById(event.request.idPaquete);
        if (response != null) {
          if (response.cantidadProductos == 0) {
            //si la cantidad de productos es 0 eliminamos el paquete
            await db.deletePackageById(event.request.idPaquete);
          }
        }

        //actualizamos la lista de productos
        add(LoadAllProductsFromPedidoEvent(event.pedidoId));
        emit(UnPackignSuccess("Desempaquetado del producto exitoso"));
      } else {
        emit(UnPackignError('Error al desempacar los productos'));
      }
    } catch (e, s) {
      print('Error en el  _onUnPackingEvent: $e, $s');
      emit(UnPackignError(e.toString()));
    }
  }

  //*metdo para dividir el producto
  void _onSetPickingsSplitEvent(
      SetPickingSplitEvent event, Emitter<WmsPackingState> emit) async {
    try {
      emit(SplitProductLoading());
      //actualizamos el estado del producto como separado
      await db.setFieldTableProductosPedidos3(
          event.pedidoId, event.productId, "is_separate", "true", event.idMove);

      //marcamos el producto como producto split
      await db.setFieldTableProductosPedidos3(event.pedidoId, event.productId,
          "is_product_split", "true", event.idMove);

      await db.setFieldTableProductosPedidos3(
          event.pedidoId, event.productId, "is_package", "false", event.idMove);
      // actualizamos el estado del producto como certificado
      await db.setFieldTableProductosPedidos3(event.pedidoId, event.productId,
          "is_certificate", "true", event.idMove);

//calculamos la cantidad pendiente del producto
      var pendingQuantity = (event.producto.quantity - event.quantity);
      //creamos un nuevo producto (duplicado) con la cantidad separada
      await db.insertDuplicateProductoPedido(event.producto, pendingQuantity);

      //actualizamos la cantidad separada
      quantitySelected = 0;
      //actualizamos la lista de productos
      add(LoadAllProductsFromPedidoEvent(event.pedidoId));
      emit(SplitProductSuccess());
    } catch (e, s) {
      print('Error en el  _onSetPickingsSplitEvent: $e, $s');
      emit(SplitProductError(e.toString()));
    }
  }

//*metodo para cargar la configuracion del usuario
  void _onLoadConfigurationsUserEvent(
      LoadConfigurationsUserPack event, Emitter<WmsPackingState> emit) async {
    try {
      emit(ConfigurationLoadingPack());
      int userId = await PrefUtils.getUserId();
      final response = await db.getConfiguration(userId);

      if (response != null) {
        configurations = response;
        emit(ConfigurationLoadedPack(response));
      } else {
        emit(ConfigurationErrorPack('Error al cargar configuraciones'));
      }
    } catch (e, s) {
      emit(ConfigurationErrorPack(e.toString()));
      print('Error en GetConfigurations.dart: $e =>$s');
    }
  }

//*meotod para cargar todas las novedades
  void _onLoadAllNovedadesEvent(
      LoadAllNovedadesPackingEvent event, Emitter<WmsPackingState> emit) async {
    try {
      emit(NovedadesPackingLoadingState());
      final response = await db.getAllNovedades();
      if (response != null) {
        novedades.clear();
        novedades = response;
        print("novedades: ${novedades.length}");
        emit(NovedadesPackingLoadedState(listOfNovedades: novedades));
      }
    } catch (e, s) {
      print("Error en __onLoadAllNovedadesEvent: $e, $s");
      emit(NovedadesPackingErrorState(e.toString()));
    }
  }

  //*metodo para seleccionar un producto sin certificar
  void _onSelectProductPackingEvent(
      SelectProductPackingEvent event, Emitter<WmsPackingState> emit) async {
    try {
      // Verificar si el producto ya está en la lista de productos seleccionados
      if (!listOfProductsForPacking.contains(event.producto)) {
        // Agregar el producto a la lista si no está ya presente
        listOfProductsForPacking.add(event.producto);
        // Emitir un nuevo estado con la lista actualizada
        emit(ListOfProductsForPackingState(listOfProductsForPacking));
      }
    } catch (e, s) {
      print('Error en el _onSelectProductPackingEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  //*metodo para deseleccionar un producto sin certificar
  void _onUnSelectProductPackingEvent(
      UnSelectProductPackingEvent event, Emitter<WmsPackingState> emit) async {
    try {
      // Verificar si el producto está en la lista antes de intentar eliminarlo
      if (listOfProductsForPacking.contains(event.producto)) {
        // Eliminar el producto de la lista
        listOfProductsForPacking.remove(event.producto);
        // Emitir un nuevo estado con la lista actualizada
        emit(ListOfProductsForPackingState(listOfProductsForPacking));
      }
    } catch (e, s) {
      print('Error en el _onUnSelectProductPackingEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<WmsPackingState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  //metodo para buscar un producto de un pedido
  void _onSearchProductPackingEvent(
      SearchProductPackingEvent event, Emitter<WmsPackingState> emit) async {
    final query = event.query.toLowerCase();
    if (query.isEmpty) {
      listOfProductosProgress = listOfProductos.where((product) {
        return product.isSeparate == null || product.isSeparate == 0;
      }).toList();
      emit(WmsPackingLoaded());
    } else {
      listOfProductosProgress = listOfProductos.where((product) {
        return product.productId?.toLowerCase().contains(query) ?? false;
      }).toList();
      emit(WmsPackingLoaded());
    }
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

  //metodo para buscar un pedido de packing
  void _onSearchPedidoEvent(
      SearchPedidoPackingEvent event, Emitter<WmsPackingState> emit) async {
    try {
      listOfPedidosFilters = [];
      listOfPedidosFilters = listOfPedidos;

      final query = event.query.toLowerCase();
      final pedidosFromDB = await db.getAllPedidosBatch(event.idBatch);
      if (query.isEmpty) {
        listOfPedidosFilters = pedidosFromDB;
      } else {
        listOfPedidosFilters = pedidosFromDB.where((pedido) {
          return pedido.referencia?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
      emit(WmsPackingLoaded());
    } catch (e, s) {
      print('Error en el _onSearchPedidoEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  ///*metodo para cambiar el estado del sticker
  void _onChangeStickerEvent(
      ChangeStickerEvent event, Emitter<WmsPackingState> emit) {
    isSticker = event.isSticker;
    emit(ChangeStickerState(isSticker));
  }

  void _onSetPackingsEvent(
      SetPackingsEvent event, Emitter<WmsPackingState> emit) async {
    try {
      // Verificar que haya productos para empaquetar
      if (event.productos.isNotEmpty) {
        //obtenemos el id del usuario

        final idOperario = await PrefUtils.getUserId();
        // 1. Intentar crear el paquete
        emit(
            WmsPackingLoadingState()); // Estado de carga mientras creas el paquete

        // if (packageId != null) {
        DateTime fechaTransaccion = DateTime.now();
        String fechaFormateada = formatoFecha(fechaTransaccion);
        // 3. Empaquetar los productos en el paquete recién creado
        // Crear la lista de ListItem a partir de los productos
        List<ListItem> listItems = event.productos.map((producto) {
          return ListItem(
            idMove: producto.idMove ??
                0, // O el campo correspondiente en tu producto
            productId:
                producto.idProduct, // Suponiendo que `id` es el ID del producto
            lote: producto.loteId
                .toString(), // Suponiendo que `loteId` es el lote del producto
            locationId: int.parse(producto.idLocation
                .toString()), // Asegúrate de tener este campo
            cantidadSeparada: event.isCertificate
                ? producto.quantitySeparate ?? 0
                : producto.quantity ?? 0, // Cantidad a empaquetar
            observacion: producto.observation ??
                'Sin novedad', // Observación del producto (si existe)
            unidadMedida:
                producto.unidades ?? '', // La unidad de medida del producto
            idOperario: idOperario,
            fechaTransaccion: fechaFormateada,
          );
        }).toList();

        // 4. Crear el PackingRequest
        final packingRequest = PackingRequest(
          idBatch: event.productos[0].batchId ??
              0, // Usamos el ID del paquete recién creado
          // idPaquete: packageId, // Suponemos que es el mismo ID
          isSticker: event.isSticker, // Puede variar según tu lógica
          isCertificate: event.isCertificate, // Puede variar según tu lógica
          pesoTotalPaquete: 34.0, // Calcular el peso total de los productos
          listItem: listItems, // Lista de productos a empaquetar
        );

        // Llamamos al servicio para enviar el empaquetado
        final responsePacking = await wmsPackingRepository.sendPackingRequest(
          packingRequest,
          true, // Muestra un diálogo de carga si es necesario
          event.context,
        );

        if (responsePacking.result?.code == 200) {
          //creamos el paquete en la bd local
          packages.add(Paquete(
            id: responsePacking.result?.result?[0].idPaquete ?? 0,
            name: responsePacking.result?.result?[0].namePaquete ?? '',
            batchId: event.productos[0].batchId,
            pedidoId: event.productos[0].pedidoId,
            cantidadProductos: event.productos.length,
            listaProductos: event.productos,
            isSticker: event.isSticker,
          ));

          await db.insertPackage(Paquete(
            id: responsePacking.result?.result?[0].idPaquete ?? 0,
            name: responsePacking.result?.result?[0].namePaquete ?? '',
            batchId: event.productos[0].batchId,
            pedidoId: event.productos[0].pedidoId,
            cantidadProductos: event.productos.length,
            listaProductos: event.productos,
            isSticker: event.isSticker,
          ));

          //actualizamos el estado del pedido como seleccionado
          await db.setFieldTablePedidosPacking(
            event.productos[0].batchId ?? 0,
            event.productos[0].pedidoId ?? 0,
            "is_selected",
            "true",
          );

          //actualizamos el estado del batch como seleccionado
          await db.setFieldTableBatchPacking(
            event.productos[0].batchId ?? 0,
            "is_selected",
            "true",
          );

          if (event.isCertificate == true) {
            for (var product in event.productos) {
              //actualizamos el valor del packageName al producto
              await db.setFieldTableProductosPedidos2String(
                  product.pedidoId ?? 0,
                  product.idProduct ?? 0,
                  "package_name",
                  responsePacking.result?.result?[0].namePaquete ?? '',
                  product.idMove ?? 0);
              //actualizamos el estado del producto como separado
              await db.setFieldTableProductosPedidos2(
                  product.pedidoId ?? 0,
                  product.idProduct ?? 0,
                  "is_separate",
                  "true",
                  product.idMove ?? 0);

              await db.setFieldTableProductosPedidos2(
                  product.pedidoId ?? 0,
                  product.idProduct ?? 0,
                  "id_package",
                  responsePacking.result?.result?[0].idPaquete ?? 0,
                  product.idMove ?? 0);

              await db.setFieldTableProductosPedidos2(
                  product.pedidoId ?? 0,
                  product.idProduct ?? 0,
                  "is_package",
                  "true",
                  product.idMove ?? 0);
            }
          } else if (event.isCertificate == false) {
            for (var product in event.productos) {
              await db.setFieldTableProductosPedidos3String(
                  product.pedidoId ?? 0,
                  product.idProduct ?? 0,
                  "package_name",
                  responsePacking.result?.result?[0].namePaquete ?? '',
                  product.idMove ?? 0);
              //actualizamos el estado del producto como separado
              await db.setFieldTableProductosPedidos3(
                  product.pedidoId ?? 0,
                  product.idProduct ?? 0,
                  "is_separate",
                  "true",
                  product.idMove ?? 0);

              //actualizamos el valor de que si tiene un paquete
              await db.setFieldTableProductosPedidos3(product.pedidoId ?? 0,
                  product.idProduct ?? 0, "is_package", 1, product.idMove ?? 0);

              // actualizamos el id del paquete en el producto
              await db.setFieldTableProductosPedidos3(
                  product.pedidoId ?? 0,
                  product.idProduct ?? 0,
                  "id_package",
                  responsePacking.result?.result?[0].idPaquete ?? 0,
                  product.idMove ?? 0);
              await db.setFieldTableProductosPedidos3(
                  product.pedidoId ?? 0,
                  product.idProduct ?? 0,
                  "is_certificate",
                  "false",
                  product.idMove ?? 0);
            }
            listOfProductsForPacking = [];
          }

          add(LoadAllProductsFromPedidoEvent(event.productos[0].pedidoId ?? 0));

          // Si todo salió bien, podemos notificar a la UI que el empaquetado fue exitoso
          emit(WmsPackingSuccessState('Empaquetado exitoso'));
        } else {
          emit(WmsPackingErrorState(
              'Error: No se pudo empaquetar los productos'));
        }
      }
    } catch (e, s) {
      // Manejo de excepciones genéricas
      print('Error en _onSetPackingsEvent: $e, $s');
      emit(WmsPackingErrorState('Ocurrió un error inesperado'));
    }
  }

  //*metodo que se encarga de hacer el picking
  void _onSetPickingsEvent(
      SetPickingsEvent event, Emitter<WmsPackingState> emit) async {
    try {

      emit(SetPickingPackingLoadingState());

      //actualizamos el estado del producto como separado
      await db.setFieldTableProductosPedidos3(
          event.pedidoId, event.productId, "is_separate", "true", event.idMove);
      await db.setFieldTableProductosPedidos3(
          event.pedidoId, event.productId, "is_package", "false", event.idMove);
      await db.setFieldTableProductosPedidos3(event.pedidoId, event.productId,
          "is_certificate", "true", event.idMove);

      //actualizamos la cantidad se mparada
      quantitySelected = 0;
      viewQuantity = false;
      add(LoadAllProductsFromPedidoEvent(event.pedidoId));
      emit(SetPickingPackingOkState());

    } catch (e, s) {
      print('Error en el  _onSetPickingsEvent: $e, $s');
      emit(SetPickingPackingErrorState(e.toString()));
    }
  }

  //*metodo para cambiar la cantidad seleccionada
  void _onChangeQuantitySelectedEvent(
      ChangeQuantitySeparate event, Emitter<WmsPackingState> emit) async {
    print('event.quantity: ${event.quantity}');
    if (event.quantity > 0) {
      quantitySelected = event.quantity;
      await db.setFieldTableProductosPedidos3(event.pedidoId, event.productId,
          "quantity_separate", event.quantity, event.idMove);
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
    print(
        'Location: $isLocationOk, Product: $isProductOk, LocationDest: $isLocationDestOk, Quantity: $isQuantityOk');
    emit(ValidateFieldsPackingState(event.isOk));
  }

  void _onFetchProductEvent(
      FetchProductEvent event, Emitter<WmsPackingState> emit) async {
    try {
      isLocationOk = true;
      isProductOk = true;
      isLocationDestOk = true;
      isQuantityOk = true;

      emit(WmsProductInfoLoading());
      listOfBarcodes.clear();
      currentProduct = PorductoPedido();
      currentProduct = event.pedido;
      listOfBarcodes = await db.getBarcodesProduct(
        currentProduct.batchId ?? 0,
        currentProduct.idProduct,
        currentProduct.idMove ?? 0,
      );
      locationIsOk = currentProduct.isLocationIsOk == 1 ? true : false;
      productIsOk = currentProduct.productIsOk == 1 ? true : false;
      locationDestIsOk = currentProduct.locationDestIsOk == 1 ? true : false;
      quantityIsOk = currentProduct.isQuantityIsOk == 1 ? true : false;
      quantitySelected = currentProduct.isProductSplit == 1
          ? 0
          : currentProduct.quantitySeparate ?? 0;
      products();

      print(
          "variables : locationIsOk: $locationIsOk, productIsOk: $productIsOk, :locationDestIsOk $locationDestIsOk, quantityIsOk: $quantityIsOk");

      print(
          "vairbales de vista: isLocationOk: $isLocationOk , isProductOk: $isProductOk, isLocationDestOk: $isLocationDestOk, isQuantityOk: $isQuantityOk");

      print("currentProduct: ${currentProduct.toMap()}");
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
        productsDonePacking.clear();

        //filtramos y creamos la lista de productos listo a empacar
        productsDone = listOfProductos
            .where((product) =>
                product.isSeparate == 1 &&
                product.isCertificate == 1 &&
                product.isPackage == 0)
            .toList();

        productsDonePacking = listOfProductos
            .where(
                (product) => product.isSeparate == 1 && product.isPackage == 1)
            .toList();

        print('productsDonePacking: ${productsDonePacking.length}');

        //filtramos y creamos la lista de productos listo a separar para empaque
        listOfProductosProgress = listOfProductos.where((product) {
          return product.isSeparate == null || product.isSeparate == 0;
        }).toList();

        print(listOfProductosProgress);

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
        listOfPedidosFilters.clear();
        listOfPedidosFilters.addAll(response);
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

  void products() {
    // Limpiamos la lista 'listOfProductsName' para asegurarnos que no haya duplicados de iteraciones anteriores
    listOfProductsName.clear();

    // Recorremos los productos del batch
    for (var i = 0; i < listOfProductosProgress.length; i++) {
      var product = listOfProductosProgress[i];

      // Aseguramos que productId no sea nulo antes de intentar agregarlo
      if (product != null && product != null) {
        // Validamos si el productId ya existe en la lista 'positions'
        if (!listOfProductsName.contains(product.idMove)) {
          listOfProductsName.add(
              product); // Agregamos el productId a la lista 'listOfProductsName'
        }
      }
    }
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
      final response = await wmsPackingRepository.resBatchsPacking(
          event.isLoadinDialog, event.context);

      if (response != null && response is List) {
        print('response batchs packing: ${response.length}');
        listOfBatchs.clear();
        listOfBatchs.addAll(response);

        for (var batch in listOfBatchs) {
          try {
            if (batch.id != null && batch.name != null) {
              await DataBaseSqlite().insertBatchPacking(BatchPackingModel(
                id: batch.id!,
                name: batch.name ?? '',
                scheduleddate: batch.scheduleddate.toString(),
                pickingTypeId: batch.pickingTypeId,
                state: batch.state,
                userId: batch.userId.toString(),
                userName: batch.userName,
                cantidadPedidos: batch.cantidadPedidos,
              ));
            }
          } catch (dbError, stackTrace) {
            print('Error insertBatchPacking: $dbError  $stackTrace');
          }
        }

        // Convertir el mapa en una lista de pedido unicos del batch para packing
        List<PedidoPacking> pedidosToInsert =
            listOfBatchs.expand((batch) => batch.listaPedidos!).toList();

        //convertir el mapa en una lista de productos unicos del pedido para packing
        List<PorductoPedido> productsToInsert =
            pedidosToInsert.expand((pedido) => pedido.listaProductos!).toList();

        //Convertir el mapa en una lista los barcodes unicos de cada producto
        List<Barcodes> barcodesToInsert = productsToInsert
            .expand((product) => product.productPacking!)
            .toList();

        //convertir el mapap en una lsita de los otros barcodes de cada producto
        List<Barcodes> otherBarcodesToInsert = productsToInsert
            .expand((product) => product.otherBarcode!)
            .toList();
        print('pedidosToInsert Packing : ${pedidosToInsert.length}');
        print('productsToInsert Packing : ${productsToInsert.length}');
        print('barcodesToInsert Packing : ${barcodesToInsert.length}');
        print('otherBarcodes    Packing : ${otherBarcodesToInsert.length}');

        // Enviar la lista agrupada de productos de un batch para packing
        await DataBaseSqlite().insertPedidosBatchPacking(pedidosToInsert);
        // Enviar la lista agrupada de productos de un pedido para packing
        await DataBaseSqlite().insertProductosPedidos(productsToInsert);
        // Enviar la lista agrupada de barcodes de un producto para packing
        await DataBaseSqlite().insertBarcodesPackageProduct(barcodesToInsert);
        // Enviar la lista agrupada de otros barcodes de un producto para packing
        await DataBaseSqlite()
            .insertBarcodesPackageProduct(otherBarcodesToInsert);

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
      await db.setFieldTableProductosPedidos(event.pedidoId, event.productId,
          "is_quantity_is_ok", "true", event.idMove);
    }
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      quantityIsOk,
    ));
  }

  void _onAddQuantitySeparateEvent(
      AddQuantitySeparate event, Emitter<WmsPackingState> emit) async {
    quantitySelected = quantitySelected + event.quantity;
    await db.incremenQtytProductSeparatePacking(
        event.pedidoId, event.productId, event.idMove, event.quantity);
    emit(ChangeQuantitySeparateState(quantitySelected));
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<WmsPackingState> emit) async {
    if (isLocationOk) {
      //*actualizamos la seleccion del batch, pedido y producto
      //actualizamos el estado de seleccion de un batch
      await db.setFieldTableBatchPacking(
          currentProduct.batchId ?? 0, "is_selected", "true");
      //actualizamos el estado del pedido como seleccionado
      await db.setFieldTablePedidosPacking(
          currentProduct.batchId ?? 0, event.pedidoId, "is_selected", "true");
      // actualizamo el valor de que he seleccionado el producto
      await db.setFieldTableProductosPedidos(event.pedidoId, event.productId,
          "is_selected", "true", currentProduct.idMove ?? 0);
      //*actualizamos la ubicacion del producto a true
      await db.setFieldTableProductosPedidos(event.pedidoId, event.productId,
          "is_location_is_ok", "true", currentProduct.idMove ?? 0);

      locationIsOk = true;
      emit(ChangeLocationPackingIsOkState(
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
      await db.setFieldTableProductosPedidos(event.pedidoId, event.productId,
          "product_is_ok", "true", event.idMove);
      //actualizamos la cantidad separada
      await db.setFieldTableProductosPedidos3(event.pedidoId, event.productId,
          "quantity_separate", event.quantity, event.idMove);
    }
    productIsOk = event.productIsOk;
    emit(ChangeProductPackingIsOkState(
      productIsOk,
    ));
  }
}
