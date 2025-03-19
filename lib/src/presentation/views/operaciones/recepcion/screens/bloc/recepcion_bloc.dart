// ignore_for_file: unused_field, unnecessary_null_comparison, unnecessary_type_check, use_build_context_synchronously

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/data/recepcion_repository.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/repcion_requets_model.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/response_lotes_product_model.dart';
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

  //*lista de novedades
  List<Novedad> novedades = [];

  //*producto acutal

  LineasRecepcion currentProduct = LineasRecepcion();

  //lista de lotes de un producto
  List<LotesProduct> listLotesProduct = [];

  //*valores de scanvalue

  String scannedValue2 = ''; //producto
  String scannedValue3 = ''; //cantidad
  String scannedValue4 = ''; //lote

  String selectLote = '';
  String dateLote = '';

  //*repositorio
  final RecepcionRepository _recepcionRepository = RecepcionRepository();
  //*controller de busqueda
  TextEditingController searchControllerOrderC = TextEditingController();
  TextEditingController newLoteController = TextEditingController();
  TextEditingController dateLoteController = TextEditingController();

  //*variables para validar
  bool productIsOk = false;
  bool loteIsOk = false;
  bool quantityIsOk = false;
  bool isKeyboardVisible = false;
  bool viewQuantity = false;

  // //*validaciones de campos del estado de la vista
  bool isProductOk = true;
  bool isQuantityOk = true;
  bool isLoteOk = true;
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
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    on<SelectecLoteEvent>(_onChangeLoteIsOkEvent);

    //*cantidad
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);

    //*evento para cambiar la cantidad seleccionada
    on<ChangeQuantitySeparate>(_onChangeQuantitySelectedEvent);

    //*evento para ver la cantidad
    on<ShowQuantityOrderEvent>(_onShowQuantityEvent);
    on<AddQuantitySeparate>(_onAddQuantitySeparateEvent);

    //*evento para obtener las novedades
    on<LoadAllNovedadesOrderEvent>(_onLoadAllNovedadesEvent);
    add(LoadAllNovedadesOrderEvent());

    //*finalizarRececpcionProducto
    on<FinalizarRecepcionProducto>(_onFinalizarRecepcionProducto);

    //*finalizarRececpcionProductoSplit
    on<FinalizarRecepcionProductoSplit>(_onFinalizarRecepcionProductoSplit);

    //*metodo para obtener todos los lotes de un producto
    on<GetLotesProduct>(_onGetLotesProduct);

    //*metodo para enviar el producto a wms
    on<SendProductToOrder>(_onSendProductToOrder);

    //*metodo para crear un lote a un producto
    on<CreateLoteProduct>(_onCreateLoteProduct);
  }

  //metodo pea crar un lote a un producto
  void _onCreateLoteProduct(
      CreateLoteProduct event, Emitter<RecepcionState> emit) async {
    try {
      emit(CreateLoteProductLoading());
      final response = await _recepcionRepository.createLote(
          false,
          int.parse(currentProduct.productId),
          event.nameLote,
          event.fechaCaducidad,
          event.context);

      if (response != null) {
        //agregamos el nuevo lote a la lista de lotes
        listLotesProduct.add(response.result?.result ?? LotesProduct());
        selectLote = response.result?.result?.name ?? '';
        dateLote = response.result?.result?.expirationDate ?? '';

        await db.productEntradaRepository.setFieldTableProductEntrada(
          currentProduct.idRecepcion,
          int.parse(currentProduct.productId),
          "lote_id",
          response.result?.result?.id ?? 0,
          currentProduct.idMove,
        );
        //actualizamos el lote name
        await db.productEntradaRepository.setFieldTableProductEntrada(
          currentProduct.idRecepcion,
          int.parse(currentProduct.productId),
          "lote_name",
          response.result?.result?.name ?? '',
          currentProduct.idMove,
        );

        loteIsOk = true;

        dateLoteController.clear();
        newLoteController.clear();

        emit(CreateLoteProductSuccess());
      } else {
        emit(CreateLoteProductFailure('Error al crear el lote'));
      }
    } catch (e, s) {
      emit(CreateLoteProductFailure('Error al crear el lote'));
      print('Error en el _onCreateLoteProduct: $e, $s');
    }
  }

  //metodo para enviar el producto a wms
  void _onSendProductToOrder(
      SendProductToOrder event, Emitter<RecepcionState> emit) async {
    try {
      emit(SendProductToOrderLoading());

      final userid = await PrefUtils.getUserId();

      final productBD = await db.productEntradaRepository.getProductById(
        int.parse(currentProduct.productId),
        currentProduct.idMove,
        currentProduct.idRecepcion,
      );

      final response = await _recepcionRepository.sendProductRecepcion(
        RecepcionRequest(
          idRecepcion: productBD?.idRecepcion ?? 0,
          listItems: [
            ListItem(
              idProducto: int.parse(productBD?.productId),
              idMove: productBD?.idMove ?? 0,
              loteProducto: productBD?.loteId ?? 0,
              ubicacionDestino: productBD?.locationDestId ?? 0,
              cantidadSeparada: productBD?.quantitySeparate ?? 0,
              observacion: productBD?.observation ?? '',
              idOperario: userid,
              timeLine: 30,

              fechaTransaccion: DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(DateTime.now()), // Formato de la fecha
            )
          ],
        ),
        false,
        event.context,
      );

      // if (response) {
      //   emit(SendProductToOrderSuccess());
      // } else {
      //   emit(SendProductToOrderFailure('Error al enviar el producto'));
      // }
    } catch (e, s) {
      emit(SendProductToOrderFailure('Error al enviar el producto'));
      print('Error en el _onSendProductToOrder: $e, $s');
    }
  }

  getProduct() async {
    final productBD = await db.productEntradaRepository.getProductById(
      int.parse(currentProduct.productId),
      currentProduct.idMove,
      currentProduct.idRecepcion,
    );

    print('productBD: ${productBD?.toMap()}');
  }

  //*metodo para obtener todos los lotes de un producto
  void _onGetLotesProduct(
      GetLotesProduct event, Emitter<RecepcionState> emit) async {
    try {
      emit(GetLotesProductLoading());
      final response = await _recepcionRepository.fetchAllLotesProduct(
          false, event.context, int.parse(currentProduct.productId));

      if (response != null && response is List) {
        listLotesProduct = response;
        emit(GetLotesProductSuccess(response));
      } else {
        emit(GetLotesProductFailure('Error al obtener los lotes del producto'));
      }
    } catch (e, s) {
      emit(GetLotesProductFailure('Error al obtener los lotes del producto'));
      print('Error en el _onGetLotesProduct: $e, $s');
    }
  }

  //*Metodo para finalizar un producto Split
  void _onFinalizarRecepcionProductoSplit(FinalizarRecepcionProductoSplit event,
      Emitter<RecepcionState> emit) async {
    try {
      emit(FinalizarRecepcionProductoSplitLoading());

      //actualizamso el estado del producto como separado
      await db.productEntradaRepository.setFieldTableProductEntrada(
          currentProduct.idRecepcion,
          int.parse(currentProduct.productId),
          "is_separate",
          1,
          currentProduct.idMove);

      //marcamos el producto como split
      await db.productEntradaRepository.setFieldTableProductEntrada(
          currentProduct.idRecepcion,
          int.parse(currentProduct.productId),
          "is_product_split",
          1,
          currentProduct.idMove);

      await db.productEntradaRepository.setFieldTableProductEntrada(
          currentProduct.idRecepcion,
          int.parse(currentProduct.productId),
          "date_separate",
          DateTime.now().toString(),
          currentProduct.idMove);

      //calculamos la cantidad pendiente del producto
      var pendingQuantity = (currentProduct.quantityOrdered - event.quantity);

      //creamos un nuevo producto (duplicado) con la cantidad separada
      await db.productEntradaRepository
          .insertDuplicateProducto(currentProduct, pendingQuantity);

      add(GetPorductsToEntrada(currentProduct.idRecepcion ?? 0));
      emit(FinalizarRecepcionProductoSplitSuccess());
    } catch (e, s) {
      print('Error al finalizar la recepcion del producto split: $e, $s');
    }
  }

  //*Metodo pra finalizar un producto de se recepcion
  void _onFinalizarRecepcionProducto(
      FinalizarRecepcionProducto event, Emitter<RecepcionState> emit) async {
    try {
      emit(FinalizarRecepcionProductoLoading());
      //marcamos el producto como terminado
      await db.productEntradaRepository.setFieldTableProductEntrada(
          currentProduct.idRecepcion,
          int.parse(currentProduct.productId),
          "is_separate",
          1,
          currentProduct.idMove);
      //marcamos la fecha de separacion
      await db.productEntradaRepository.setFieldTableProductEntrada(
          currentProduct.idRecepcion,
          int.parse(currentProduct.productId),
          "date_separate",
          DateTime.now().toString(),
          currentProduct.idMove);
    } catch (e, s) {
      emit(FinalizarRecepcionProductoFailure(
          'Error al finalizar la recepcion del producto'));
      print('Error en el _onFinalizarRecepcionProducto: $e, $s');
    }
  }

//*meotod para cargar todas las novedades
  void _onLoadAllNovedadesEvent(
      LoadAllNovedadesOrderEvent event, Emitter<RecepcionState> emit) async {
    try {
      emit(NovedadesOrderLoadingState());
      final response = await db.novedadesRepository.getAllNovedades();
      if (response != null) {
        novedades.clear();
        novedades = response;
        print("novedades: ${novedades.length}");
        emit(NovedadesOrderLoadedState(listOfNovedades: novedades));
      }
    } catch (e, s) {
      print("Error en __onLoadAllNovedadesEvent: $e, $s");
      emit(NovedadesOrderErrorState(e.toString()));
    }
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
        emit(ChangeQuantitySeparateState(quantitySelected));
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

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<RecepcionState> emit) async {
    if (event.productIsOk) {
      await db.productEntradaRepository.setFieldTableProductEntrada(
          event.idEntrada,
          event.productId,
          "is_selected",
          1,
          currentProduct.idMove ?? 0);
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
    emit(ChangeProductOrderIsOkState(
      productIsOk,
    ));
  }

  void _onChangeLoteIsOkEvent(
      SelectecLoteEvent event, Emitter<RecepcionState> emit) async {
    //agregamos el lote al producto

    selectLote = event.lote.name ?? '';
    dateLote = event.lote.expirationDate ?? '';
    //actualizamos el lote id
    await db.productEntradaRepository.setFieldTableProductEntrada(
      currentProduct.idRecepcion,
      int.parse(currentProduct.productId),
      "lote_id",
      event.lote.id,
      currentProduct.idMove,
    );
    //actualizamos el lote name
    await db.productEntradaRepository.setFieldTableProductEntrada(
      currentProduct.idRecepcion,
      int.parse(currentProduct.productId),
      "lote_name",
      event.lote.name,
      currentProduct.idMove,
    );

    loteIsOk = true;

    emit(ChangeLoteOrderIsOkState(
      loteIsOk,
    ));
  }

//*evento para limpiar el valor del scan
  void _onClearScannedValueEvent(
      ClearScannedValueOrderEvent event, Emitter<RecepcionState> emit) {
    try {
      switch (event.scan) {
        case 'product':
          scannedValue2 = '';
          emit(ClearScannedValueOrderState());
          break;
        case 'quantity':
          scannedValue3 = '';
          emit(ClearScannedValueOrderState());
          break;
        case 'lote':
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
        case 'lote':
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
      case 'product':
        isProductOk = event.isOk;
        break;
      case 'lote':
        isLoteOk = event.isOk;
        break;
      case 'quantity':
        isQuantityOk = event.isOk;
        break;
    }
    print(' Product: $isProductOk, lote: $isLoteOk, Quantity: $isQuantityOk');
    emit(ValidateFieldsOrderState(isOk: event.isOk));
  }

  //*metodo para cargar la informacion del producto actual
  void _onFetchPorductOrder(
      FetchPorductOrder event, Emitter<RecepcionState> emit) async {
    try {
      isProductOk = true;
      isQuantityOk = true;
      isLoteOk = true;
      viewQuantity = false;

      emit(FetchPorductOrderLoading());

      // traemos toda la lista de barcodes
      listOfBarcodes.clear();
      print('listOfBarcodes: ${listOfBarcodes.length}');
      currentProduct = LineasRecepcion();
      currentProduct = event.product;
      listOfBarcodes = await db.barcodesPackagesRepository.getBarcodesProduct(
        currentProduct.idRecepcion ?? 0,
        int.parse(currentProduct.productId),
        currentProduct.idMove ?? 0,
      );

      //validamos si el prodcuto tiene lote, si es asi llamamos los lotes de ese producto
      if (currentProduct.productTracking == 'lot') {
        add(GetLotesProduct(event.context));
      }

      //cargamos la informacion de las variables de validacion
      productIsOk = currentProduct.productIsOk == 1 ? true : false;
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

    // filtramos la lista a productos que no esten separados
    listProductsEntrada = listProductsEntrada
        .where(
            (element) => element.isSeparate == 0 || element.isSeparate == null)
        .toList();

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
    try {
      int userId = await PrefUtils.getUserId();
      emit(AssignUserToOrderLoading());
      final response = await _recepcionRepository.assignUserToOrder(
          true, userId, event.idOrder, event.context);

      if (response) {
        emit(AssignUserToOrderSuccess());
      } else {
        emit(AssignUserToOrderFailure(
            "La recepción ya tiene un responsable asignado"));
      }
    } catch (e, s) {
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
          await _recepcionRepository.resBatchsPacking(true, event.context);
      if (response != null && response is List) {
        await db.entradasRepository.insertEntrada(response);

        // Convertir el mapa en una lista de productos únicos con cantidades sumadas
        List<LineasRecepcion> productsToInsert =
            response.expand((batch) => batch.lineasRecepcion!).toList();

        //Convertir el mapa en una lista los barcodes unicos de cada producto
        List<Barcodes> barcodesToInsert = productsToInsert
            .expand((product) => product.otherBarcodes!)
            .toList();

        //convertir el mapap en una lsita de los otros barcodes de cada producto
        List<Barcodes> otherBarcodesToInsert = productsToInsert
            .expand((product) => product.productPacking!)
            .toList();

        print('order productsToInsert: ${productsToInsert.length}');
        print('order barcodesToInsert: ${barcodesToInsert.length}');
        print('order otherBarcodesToInsert: ${otherBarcodesToInsert.length}');

        // Enviar la lista agrupada a insertBatchProducts
        await db.productEntradaRepository
            .insertarProductoEntrada(productsToInsert);

        // Enviar la lista agrupada de barcodes de un producto para packing
        await DataBaseSqlite()
            .barcodesPackagesRepository
            .insertOrUpdateBarcodes(barcodesToInsert);
        // Enviar la lista agrupada de otros barcodes de un producto para packing
        await DataBaseSqlite()
            .barcodesPackagesRepository
            .insertOrUpdateBarcodes(otherBarcodesToInsert);

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
