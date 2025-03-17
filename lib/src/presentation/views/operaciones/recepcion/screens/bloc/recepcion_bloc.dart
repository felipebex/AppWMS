// ignore_for_file: unused_field, unnecessary_null_comparison, unnecessary_type_check

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/data/recepcion_repository.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'recepcion_event.dart';
part 'recepcion_state.dart';

class RecepcionBloc extends Bloc<RecepcionEvent, RecepcionState> {
  //*listado de entradas
  List<ResultEntrada> listOrdenesCompra = [];
  List<ResultEntrada> listFiltersOrdenesCompra = [];

  //*listado de productos de una entrada
  List<LineasRecepcion> listProductsEntrada = [];

  //*lista de productos de un una entrada
  List<LineasRecepcion> listOfProductsName = [];

  //*lista de barcodes
  List<Barcodes> listOfBarcodes = [];

  //*producto acutal

  LineasRecepcion currentProduct = LineasRecepcion();

  //*valores de scanvalue

  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';

  String oldLocation = '';

  //*repositorio
  final RecepcionRepository _recepcionRepository = RecepcionRepository();
  //*controller de busqueda
  TextEditingController searchControllerOrderC = TextEditingController();

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  bool isKeyboardVisible = false;
  bool viewQuantity = false;

  // //*validaciones de campos del estado de la vista
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;

  int quantitySelected = 0;

//*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  //*configuracion del usuario //permisos
  Configurations configurations = Configurations();

  RecepcionBloc() : super(RecepcionInitial()) {
    on<RecepcionEvent>((event, emit) {});
    //*obtener todas las ordenes de compra
    on<FetchOrdenesCompra>(_onFetchOrdenesCompra);
    //*activar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);
    //* buscar una orden de compra
    on<SearchOrdenCompraEvent>(_onSearchOrderEvent);
    //*obtener las ordenes de compra de la bd
    on<FetchOrdenesCompraOfBd>(_onFetchOrdenesCompraOfBd);

    //*asignar un usuario a una orden de compra
    on<AssignUserToOrder>(_onAssignUserToOrder);
    //*obtener las configuraciones y permisos del usuario desde la bd
    on<LoadConfigurationsUserOrder>(_onLoadConfigurationsUserEvent);
    //*obtener todos los productos de una entrada
    on<GetPorductsToEntrada>(_onGetProductsToEntrada);

    //*evento para cargar la info del producto
    on<FetchPorductOrder>(_onFetchPorductOrder);

    //*evento para validar los campos de la vista
    on<ValidateFieldsOrderEvent>(_onValidateFieldsOrder);
    //*evento para limpiar el valor escaneado
    on<ClearScannedValueOrderEvent>(_onClearScannedValueEvent);

    //*evento para actualizar el valor del scan
    on<UpdateScannedValueOrderEvent>(_onUpdateScannedValueEvent);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    on<ChangeLocationDestIsOkEvent>(_onChangeLocationDestIsOkEvent);

    //*cantidad
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);

    //*evento para cambiar la cantidad seleccionada
    on<ChangeQuantitySeparate>(_onChangeQuantitySelectedEvent);

    //*evento para ver la cantidad
    on<ShowQuantityOrderEvent>(_onShowQuantityEvent);
    on<AddQuantitySeparate>(_onAddQuantitySeparateEvent);
  }

  //*evento para aumentar la cantidad
  void _onAddQuantitySeparateEvent(
      AddQuantitySeparate event, Emitter<RecepcionState> emit) async {
    try {
      if (quantitySelected > (currentProduct.quantityOrdered ?? 0)) {
        return;
      } else {
        quantitySelected = quantitySelected + event.quantity;
        await db.productEntradaRepository.incremenQtytProductSeparatePacking(
            event.idRecepcion, event.productId, event.idMove, event.quantity);
        emit(ChangeQuantitySeparateOrder(quantitySelected));
      }
    } catch (e, s) {
      emit(ChangeQuantitySeparateErrorOrder('Error al aumentar cantidad'));
      print("❌ Error en el AddQuantitySeparate $e ->$s");
    }
  }

  //*evento para ver la cantidad
  void _onShowQuantityEvent(
      ShowQuantityOrderEvent event, Emitter<RecepcionState> emit) {
    try {
      viewQuantity = !viewQuantity;
      emit(ShowQuantityOrderState(viewQuantity));
    } catch (e, s) {
      print("❌ Error en _onShowQuantityEvent: $e, $s");
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<RecepcionState> emit) async {
    if (event.isOk) {
      await db.productEntradaRepository.setFieldTableProductEntrada(
          event.idEntrada,
          event.productId,
          "is_quantity_is_ok",
          1,
          event.idMove);
    }
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      quantityIsOk,
    ));
  }

  void _onChangeQuantitySelectedEvent(
      ChangeQuantitySeparate event, Emitter<RecepcionState> emit) async {
    try {
      if (event.quantity > 0) {
        quantitySelected = event.quantity;
        await db.productEntradaRepository.setFieldTableProductEntrada(
            event.idRecepcion,
            event.productId,
            "quantity_separate",
            event.quantity,
            event.idMove);
      }
      emit(ChangeQuantitySeparateState(quantitySelected));
    } catch (e, s) {
      print('Error en _onChangeQuantitySelectedEvent: $e, $s');
    }
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<RecepcionState> emit) async {
    if (isLocationOk) {
      //actualizamos el valor de la orden de entrada como seleccionada

      // actualizamo el valor de que he seleccionado el producto
      await db.productEntradaRepository.setFieldTableProductEntrada(
          event.idEntrada,
          event.productId,
          "is_selected",
          1,
          currentProduct.idMove ?? 0);
      //*actualizamos la ubicacion del producto a true
      await db.productEntradaRepository.setFieldTableProductEntrada(
          event.idEntrada,
          event.productId,
          "is_location_is_ok",
          1,
          currentProduct.idMove ?? 0);

      locationIsOk = true;
      emit(ChangeLocationOrderIsOkState(
        locationIsOk,
      ));
    }
  }

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<RecepcionState> emit) async {
    if (event.productIsOk) {
      //actualizamos el producto a true
      await db.productEntradaRepository.setFieldTableProductEntrada(
        event.idEntrada,
        event.productId,
        "product_is_ok",
        1,
        event.idMove,
      );
      //actualizamos la cantidad separada
      await db.productEntradaRepository.setFieldTableProductEntrada(
        event.idEntrada,
        event.productId,
        "quantity_separate",
        event.quantity,
        event.idMove,
      );
    }
    productIsOk = event.productIsOk;
    emit(ChangeLocationOrderIsOkState(
      productIsOk,
    ));
  }

  void _onChangeLocationDestIsOkEvent(
      ChangeLocationDestIsOkEvent event, Emitter<RecepcionState> emit) async {
    if (event.locationDestIsOk) {
      await db.productEntradaRepository.setFieldTableProductEntrada(
        event.idEntrada,
        event.productId,
        "location_dest_is_ok",
        1,
        event.idMove,
      );
    }
    locationDestIsOk = event.locationDestIsOk;
    emit(ChangeIsOkState(
      locationDestIsOk,
    ));
  }

//*evento para limpiar el valor del scan
  void _onClearScannedValueEvent(
      ClearScannedValueOrderEvent event, Emitter<RecepcionState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          scannedValue1 = '';
          emit(ClearScannedValueOrderState());
          break;
        case 'product':
          scannedValue2 = '';
          emit(ClearScannedValueOrderState());
          break;
        case 'quantity':
          scannedValue3 = '';
          emit(ClearScannedValueOrderState());
          break;
        case 'muelle':
          scannedValue4 = '';
          emit(ClearScannedValueOrderState());
          break;

        default:
          print('Scan type not recognized: ${event.scan}');
      }
      emit(ClearScannedValueOrderState());
    } catch (e, s) {
      print("❌ Error en _onClearScannedValueEvent: $e, $s");
    }
  }

  //*evento para actualizar el valor del scan
  void _onUpdateScannedValueEvent(
      UpdateScannedValueOrderEvent event, Emitter<RecepcionState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          // Acumulador de valores escaneados
          scannedValue1 += event.scannedValue;
          print('scannedValue1: $scannedValue1');
          emit(UpdateScannedValueOrderState(scannedValue1, event.scan));
          break;
        case 'product':
          scannedValue2 += event.scannedValue;
          print('scannedValue2: $scannedValue2');
          emit(UpdateScannedValueOrderState(scannedValue2, event.scan));
          break;
        case 'quantity':
          scannedValue3 += event.scannedValue;
          print('scannedValue3: $scannedValue3');
          emit(UpdateScannedValueOrderState(scannedValue3, event.scan));
          break;
        case 'muelle':
          print('scannedValue4: $scannedValue4');
          scannedValue4 += event.scannedValue;
          emit(UpdateScannedValueOrderState(scannedValue4, event.scan));
          break;

        default:
          print('Scan type not recognized: ${event.scan}');
      }
    } catch (e, s) {
      print("❌ Error en _onUpdateScannedValueEvent: $e, $s");
    }
  }

  //*metodo para validar los campos de la vista
  void _onValidateFieldsOrder(
      ValidateFieldsOrderEvent event, Emitter<RecepcionState> emit) {
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
    emit(ValidateFieldsOrderState(isOk: event.isOk));
  }

  //*metodo para cargar la informacion del producto actual
  void _onFetchPorductOrder(
      FetchPorductOrder event, Emitter<RecepcionState> emit) async {
    try {
      isLocationOk = true;
      isProductOk = true;
      isLocationDestOk = true;
      isQuantityOk = true;

      emit(FetchPorductOrderLoading());

      //traemos toda la lista de barcodes
      //    listOfBarcodes.clear();
      // listOfBarcodes = await db.barcodesPackagesRepository.getBarcodesProduct(
      //   currentProduct.batchId ?? 0,
      //   currentProduct.idProduct,
      //   currentProduct.idMove ?? 0,
      // );

      currentProduct = LineasRecepcion();
      currentProduct = event.product;

      //cargamos la informacion de las variables de validacion
      locationIsOk = currentProduct.isLocationIsOk == 1 ? true : false;
      productIsOk = currentProduct.productIsOk == 1 ? true : false;
      locationDestIsOk = currentProduct.locationDestIsOk == 1 ? true : false;
      quantityIsOk = currentProduct.isQuantityIsOk == 1 ? true : false;
      quantitySelected = currentProduct.isProductSplit == 1
          ? 0
          : currentProduct.quantitySeparate ?? 0;
      //llamamos los productos de esa entrada
      products();
      //cargamos la configuracion del usuario

      emit(FetchPorductOrderSuccess(currentProduct));
    } catch (e, s) {
      emit(FetchPorductOrderFailure('Error al obtener el producto'));
      print('Error en el _onFetchPorductOrder: $e, $s');
    }
  }

  products() {
    listOfProductsName.clear();
    // Recorremos los productos del batch
    for (var i = 0; i < listProductsEntrada.length; i++) {
      var product = listProductsEntrada[i];

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

  //*metodo para obtener los productos de una entrada por id
  void _onGetProductsToEntrada(
      GetPorductsToEntrada event, Emitter<RecepcionState> emit) async {
    try {
      emit(GetProductsToEntradaLoading());
      final response = await db.productEntradaRepository
          .getProductsByRecepcionId(event.idEntrada);

      if (response != null && response is List) {
        listProductsEntrada = [];
        listProductsEntrada = response;
        emit(GetProductsToEntradaSuccess(response));
      } else {
        emit(GetProductsToEntradaFailure(
            'Error al obtener los productos de la entrada'));
      }
    } catch (e, s) {
      emit(GetProductsToEntradaFailure(
          'Error al obtener los productos de la entrada'));
      print('Error en el _onGetProductsToEntrada: $e, $s');
    }
  }

//*metodo para obtener los permisos del usuario
  void _onAssignUserToOrder(
      AssignUserToOrder event, Emitter<RecepcionState> emit) async {
    try {} catch (e, s) {
      emit(AssignUserToOrderFailure('Error al asignar el usuario'));
      print('Error en el _onAssignUserToOrder: $e, $s');
    }
  }

  //*metodo para buscar una entrada
  void _onSearchOrderEvent(
      SearchOrdenCompraEvent event, Emitter<RecepcionState> emit) async {
    try {
      listFiltersOrdenesCompra = [];
      listFiltersOrdenesCompra = listOrdenesCompra;

      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        listFiltersOrdenesCompra = listOrdenesCompra;
      } else {
        listFiltersOrdenesCompra = listFiltersOrdenesCompra
            .where((element) => element.name!.contains(query))
            .toList();
      }
      emit(SearchOrdenCompraSuccess(listFiltersOrdenesCompra));
    } catch (e, s) {
      emit(SearchOrdenCompraFailure('Error al buscar la orden de compra'));
      print('Error en el _onSearchPedidoEvent: $e, $s');
    }
  }

  //*metodo para obtener las entradas desde wms
  void _onFetchOrdenesCompra(
      FetchOrdenesCompra event, Emitter<RecepcionState> emit) async {
    try {
      emit(FetchOrdenesCompraLoading());
      final response =
          await _recepcionRepository.resBatchsPacking(false, event.context);
      if (response != null && response is List) {
        //todo: agregamos la lista de entradas a la bd
        await db.entradasRepository.insertEntrada(response);
        // Convertir el mapa en una lista de productos únicos con cantidades sumadas
        List<LineasRecepcion> productsToInsert =
            response.expand((batch) => batch.lineasRecepcion!).toList();

        print('productsToInsert: ${productsToInsert.length}');

        // Enviar la lista agrupada a insertBatchProducts
        await db.productEntradaRepository
            .insertarProductoEntrada(productsToInsert);

        print('ordenesCompra: ${response.length}');
        emit(FetchOrdenesCompraSuccess(response));
      } else {
        emit(FetchOrdenesCompraFailure(
            'Error al obtener las ordenes de compra'));
      }
    } catch (e, s) {
      print('Error en RecepcionBloc: $e, $s');
    }
  }

  //*metodo para obtener las entradas desde la bd
  void _onFetchOrdenesCompraOfBd(
      FetchOrdenesCompraOfBd event, Emitter<RecepcionState> emit) async {
    try {
      emit(FetchOrdenesCompraOfBdLoading());
      final listbd = await db.entradasRepository.getAllEntradas();
      if (listbd != null && listbd.isNotEmpty) {
        listOrdenesCompra = listbd;
        listFiltersOrdenesCompra = listbd;
      } else {
        emit(FetchOrdenesCompraOfBdFailure(
            'No hay ordenes de compra en la base de datos'));
      }

      emit(FetchOrdenesCompraOfBdSuccess(listFiltersOrdenesCompra));
    } catch (e, s) {
      emit(FetchOrdenesCompraOfBdFailure(
          'Error al obtener las ordenes de compra'));
      print('Error en el _onFetchOrdenesCompraOfBd: $e, $s');
    }
  }

  //*metodo para ocultar y mostrar el teclado
  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<RecepcionState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  //*metodo para cargar la configuracion del usuario
  void _onLoadConfigurationsUserEvent(
      LoadConfigurationsUserOrder event, Emitter<RecepcionState> emit) async {
    try {
      emit(AssignUserToOrderLoading());
      int userId = await PrefUtils.getUserId();
      final response =
          await db.configurationsRepository.getConfiguration(userId);

      if (response != null) {
        configurations = response;
        emit(ConfigurationLoadedOrder(response));
      } else {
        emit(ConfigurationErrorOrder('Error al cargar configuraciones'));
      }
    } catch (e, s) {
      emit(ConfigurationErrorOrder(e.toString()));
      print('Error en LoadConfigurationsUserPack.dart: $e =>$s');
    }
  }
}
