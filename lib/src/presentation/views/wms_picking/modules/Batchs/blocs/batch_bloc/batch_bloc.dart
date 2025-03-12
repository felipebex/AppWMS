// ignore_for_file: unnecessary_null_comparison, unnecessary_type_check, avoid_print, prefer_is_empty, use_build_context_synchronously, prefer_if_null_operators

import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_picking_repository.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/item_picking_request.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/submeuelle_model.dart';
import 'package:wms_app/src/utils/formats.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'batch_event.dart';
part 'batch_state.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  List<ProductsBatch> listOfProductsBatch = [];
  List<ProductsBatch> filteredProducts = [];
  List<ProductsBatch> listOfProductsBatchDB = [];
  List<Barcodes> listOfBarcodes = [];

  //*valores de scanvalue

  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';

  // //*validaciones de campos del estado de la vista
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;

  bool _isProcessing = false; // Bandera para controlar el estado del proceso
  bool isProcessing = false; // Bandera para controlar el estado del proceso

  //variable de apoyo
  bool isSearch = true;

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  //*controller para editarProducto
  TextEditingController editProductController = TextEditingController();

  //*batch con productos
  BatchWithProducts batchWithProducts = BatchWithProducts();

  //*producto en posicion actual
  ProductsBatch currentProduct = ProductsBatch();

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;

  String oldLocation = '';

  DataBaseSqlite db = DataBaseSqlite();
  WmsPickingRepository repository = WmsPickingRepository();

  //*lista de novedades de separacion

  String selectedNovedad = '';

  //configuracion del usuario //permisos
  Configurations configurations = Configurations();

  int quantitySelected = 0;

  //*lista de todas las pocisiones de los productos del batchs
  List<String> positionsOrigen = [];

  //*lista de muelles
  List<String> muelles = [];
  List<String> listOfProductsName = [];
  List<Muelles> submuelles = [];

  Muelles subMuelleSelected = Muelles();

  //*lista de novedades
  List<Novedad> novedades = [];

  bool isPdaZebra = false;
  bool isKeyboardVisible = false;

  bool viewQuantity = false;

  //*indice del producto actual
  int index = 0;

  BatchBloc() : super(BatchInitial()) {
    on<LoadConfigurationsUser>(_onLoadConfigurationsUserEvent);

    //* empezar el tiempo de separacion
    on<StartTimePick>(_onStartTimePickEvent);
    //* terminar el tiempo de separacion
    on<EndTimePick>(_onEndTimePickEvent);

    // //* Buscar un producto en un lote en SQLite
    on<SearchProductsBatchEvent>(_onSearchBacthEvent);
    // //* Limpiar la búsqueda
    on<ClearSearchProudctsBatchEvent>(_onClearSearchEvent);
    // //* Cargar los productos de un batch desde SQLite
    on<FetchBatchWithProductsEvent>(_onFetchBatchWithProductsEvent);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeLocationDestIsOkEvent>(_onChangeLocationDestIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);
    //*cambiar el producto actual
    on<ChangeCurrentProduct>(_onChangeCurrentProduct);

    on<SelectNovedadEvent>(_onSelectNovedadEvent);

    on<ValidateFieldsEvent>(_onValidateFields);

    on<LoadDataInfoEvent>(_onLoadDataInfoEvent);

    //*evento para cambiar la cantidad seleccionada
    on<ChangeQuantitySeparate>(_onChangeQuantitySelectedEvent);
    on<AddQuantitySeparate>(_onAddQuantitySeparateEvent);
    //*evento para finalizar la separacion
    on<PickingOkEvent>(_onPickingOkEvent);
    //*evento para dejar pendiente la separacion
    on<ProductPendingEvent>(_onPickingPendingEvent);

    //*evento para actualizar los datos del producto desde odoo
    //*evento para editar un producto
    on<LoadProductEditEvent>(_onEditProductEvent);
    //*evento para enviar un producto a odoo editado
    on<SendProductEditOdooEvent>(_onSendProductEditOdooEvent);

    //*evento para asignar el submuelle
    on<AssignSubmuelleEvent>(_onAssignSubmuelleEvent);

    //*evento para obtener la informacion del dispositivo
    on<LoadInfoDeviceEvent>(_onLoadInfoDevicesEvent);
    //*evento para mostrar el teclado
    on<ShowKeyboard>(_onShowKeyboardEvent);
    //*evento para obtener todas las novedades
    on<LoadAllNovedadesEvent>(_onLoadAllNovedadesEvent);
    add(LoadAllNovedadesEvent());
    //*evento para seleccionar un submuelle
    on<SelectedSubMuelleEvent>(_onSelectecSubMuelle);
    //*evento para obtener los barcodes de un producto por paquete
    on<FetchBarcodesProductEvent>(_onFetchBarcodesProductEvent);
    //*evento para reiniciar los valores
    on<ResetValuesEvent>(_onResetValuesEvent);
    //*evento para enviar un producto a odoo
    on<SendProductOdooEvent>(_onSendProductOdooEvent);
    //*evento para actualizar el valor del scan
    on<UpdateScannedValueEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValueEvent>(_onClearScannedValueEvent);
    //*metodo para establecer un proceso en ejecucion
    on<SetIsProcessingEvent>(_onSetIsProcessingEvent);

    //*evento para ver la cantidad
    on<ShowQuantityEvent>(_onShowQuantityEvent);
  }

  //*evento para empezar el tiempo de separacion
  void _onStartTimePickEvent(
      StartTimePick event, Emitter<BatchState> emit) async {
    try {
      DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String formattedDate = formatter.format(event.time);
      final userid = await PrefUtils.getUserId();

      await repository.timePickingUser(
        event.batchId,
        event.context,
        formattedDate,
        'start_time_batch_user',
        'start_time',
        userid,
      );
      final responseTimeBatch = await repository.timePickingBatch(
          event.batchId,
          event.context,
          formattedDate,
          'update_start_time',
          'start_time_pick',
          'start_time');

      if (responseTimeBatch) {
        await db.batchPickingRepository
            .startStopwatchBatch(event.batchId, formattedDate);
        emit(TimeSeparateSuccess(formattedDate));
      } else {
        emit(TimeSeparateError('Error al iniciar el tiempo de separacion'));
      }
    } catch (e, s) {
      print("❌ Error en _onStartTimePickEvent: $e, $s");
    }
  }

  void _onEndTimePickEvent(EndTimePick event, Emitter<BatchState> emit) async {
    try {
      DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String formattedDate = formatter.format(event.time);
      final userid = await PrefUtils.getUserId();

      await repository.timePickingUser(
        event.batchId,
        event.context,
        formattedDate,
        'end_time_batch_user',
        'end_time',
        userid,
      );

      final responseTimeBatch = await repository.timePickingBatch(
          event.batchId,
          event.context,
          formattedDate,
          'update_end_time',
          'end_time_pick',
          'end_time');

      if (responseTimeBatch) {
        await db.batchPickingRepository
            .endStopwatchBatch(event.batchId, formattedDate);
        emit(TimeSeparateSuccess(formattedDate));
      } else {
        emit(TimeSeparateError('Error al terminar el tiempo de separacion'));
      }
    } catch (e, s) {
      print("❌ Error en _onStartTimePickEvent: $e, $s");
    }
  }

  //*evento para establecer un proceso en ejecucion
  void _onSetIsProcessingEvent(
      SetIsProcessingEvent event, Emitter<BatchState> emit) {
    try {
      isProcessing = event.isProcessing;
      emit(SetIsProcessingState(isProcessing));
    } catch (e, s) {
      print("❌ Error en _onSetIsProcessingEvent: $e, $s");
    }
  }

  //*evento para ver la cantidad
  void _onShowQuantityEvent(ShowQuantityEvent event, Emitter<BatchState> emit) {
    try {
      viewQuantity = !viewQuantity;
      emit(ShowQuantityState(viewQuantity));
    } catch (e, s) {
      print("❌ Error en _onShowQuantityEvent: $e, $s");
    }
  }

//*evento para limpiar el valor del scan
  void _onClearScannedValueEvent(
      ClearScannedValueEvent event, Emitter<BatchState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          scannedValue1 = '';
          emit(ClearScannedValueState());
          break;
        case 'product':
          scannedValue2 = '';
          emit(ClearScannedValueState());
          break;
        case 'quantity':
          scannedValue3 = '';
          emit(ClearScannedValueState());
          break;
        case 'muelle':
          scannedValue4 = '';
          emit(ClearScannedValueState());
          break;
        default:
          print('Scan type not recognized: ${event.scan}');
      }
      emit(ClearScannedValueState());
    } catch (e, s) {
      print("❌ Error en _onClearScannedValueEvent: $e, $s");
    }
  }

  //*evento para actualizar el valor del scan
  void _onUpdateScannedValueEvent(
      UpdateScannedValueEvent event, Emitter<BatchState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          // Acumulador de valores escaneados
          scannedValue1 += event.scannedValue;
          print('scannedValue1: $scannedValue1');
          emit(UpdateScannedValueState(scannedValue1, event.scan));
          break;
        case 'product':
          scannedValue2 += event.scannedValue;
          print('scannedValue2: $scannedValue2');
          emit(UpdateScannedValueState(scannedValue2, event.scan));
          break;
        case 'quantity':
          scannedValue3 += event.scannedValue;
          print('scannedValue3: $scannedValue3');
          emit(UpdateScannedValueState(scannedValue3, event.scan));
          break;
        case 'muelle':
          print('scannedValue4: $scannedValue4');
          scannedValue4 += event.scannedValue;
          emit(UpdateScannedValueState(scannedValue4, event.scan));
          break;
        default:
          print('Scan type not recognized: ${event.scan}');
      }
    } catch (e, s) {
      print("❌ Error en _onUpdateScannedValueEvent: $e, $s");
    }
  }

  void _onSendProductOdooEvent(
      SendProductOdooEvent event, Emitter<BatchState> emit) async {
    if (_isProcessing) {
      // Si ya está en proceso, no ejecutamos nada
      return;
    }

    try {
      _isProcessing = true; // Activar la bandera para evitar duplicados
      emit(SendProductOdooLoading());

      DateTime dateTimeActuality = DateTime.parse(DateTime.now().toString());
      double secondsDifference = 0.0;

      try {
        // Calcular la diferencia en segundos
        Duration difference = dateTimeActuality.difference(DateTime.now());
        secondsDifference = difference.inMilliseconds / 1000.0;
        print("Diferencia en segundos: $secondsDifference");
      } catch (e) {
        print("❌ Error al parsear la fecha: $e");
      }

      final userid = await PrefUtils.getUserId();
      final response = await repository.sendPicking(
        context: event.context,
        idBatch: event.product.batchId ?? 0,
        timeTotal: secondsDifference,
        cantItemsSeparados: batchWithProducts.batch?.productSeparateQty ?? 0,
        listItem: [
          Item(
            idMove: event.product.idMove ?? 0,
            productId: event.product.idProduct ?? 0,
            lote: event.product.lotId ?? '',
            cantidad: event.product.quantitySeparate ?? 0,
            novedad: event.product.observation ?? 'Sin novedad',
            timeLine: event.product.timeSeparate == null
                ? 30.0
                : event.product.timeSeparate.toDouble(),
            muelle: event.product.muelleId ?? 0,
            idOperario: userid,
            fechaTransaccion: event.product.fechaTransaccion ?? '',
          ),
        ],
      );

      if (response.result?.code == 200) {
        // Recorrer todos los resultados de la respuesta
        await db.setFieldTableBatchProducts(
          event.product.batchId ?? 0,
          event.product.idProduct ?? 0,
          'is_send_odoo',
          1,
          event.product.idMove ?? 0,
        );

        final response = await DataBaseSqlite()
            .getBatchWithProducts(batchWithProducts.batch?.id ?? 0);
        final List<ProductsBatch> products = response!.products!
            .where((product) =>
                product.quantitySeparate != product.quantity ||
                product.isSendOdoo == 0)
            .toList();
        batchWithProducts.products = response.products;
        filteredProducts.clear();
        filteredProducts.addAll(products);

        emit(SendProductOdooSuccess());
      } else {
        // Elementos que no se pudieron enviar a Odoo
        await db.setFieldTableBatchProducts(
          event.product.batchId ?? 0,
          event.product.idProduct ?? 0,
          'is_send_odoo',
          0,
          event.product.idMove ?? 0,
        );
        emit(SendProductOdooError());
      }
    } catch (e, s) {
      emit(SendProductOdooError());
      print("❌ Error en el SendProductOdooEvent: $e ->$s");
    } finally {
      _isProcessing =
          false; // Resetear la bandera una vez que el proceso termine
    }
  }

  //*evento para reiniciar los valores
  void _onResetValuesEvent(ResetValuesEvent event, Emitter<BatchState> emit) {
    listOfProductsBatch.clear();
    filteredProducts.clear();
    listOfProductsBatchDB.clear();
    listOfBarcodes.clear();
    currentProduct = ProductsBatch();
    oldLocation = '';
    searchController.clear();
    editProductController.clear();
    batchWithProducts = BatchWithProducts();
    positionsOrigen.clear();
    muelles.clear();
    listOfProductsName.clear();
    submuelles.clear();
    subMuelleSelected = Muelles();
    selectedNovedad = '';
    quantitySelected = 0;
    isSearch = true;
    isKeyboardVisible = false;

    index = 0;
    scannedValue1 = '';
    scannedValue2 = '';
    scannedValue3 = '';
    scannedValue4 = '';
    viewQuantity = false;
    isProcessing = false;
    _isProcessing = false;

    isLocationOk = true;
    isProductOk = true;
    isLocationDestOk = true;
    isQuantityOk = true;

    emit(BatchInitial());
  }

  //*evento para obtener los barcodes de un producto por paquete
  void _onFetchBarcodesProductEvent(
      FetchBarcodesProductEvent event, Emitter<BatchState> emit) async {
    try {
      listOfBarcodes.clear();

      final responseList = await db.barcodesPackagesRepository.getAllBarcodes();

      print("responseList: ${responseList.length}");

      listOfBarcodes = await db.barcodesPackagesRepository.getBarcodesProduct(
        batchWithProducts.batch?.id ?? 0,
        currentProduct.idProduct ?? 0,
        currentProduct.idMove ?? 0,
      );
      print("listOfBarcodes: ${listOfBarcodes.length}");
    } catch (e, s) {
      print("❌ Error en _onFetchBarcodesProductEvent: $e, $s");
    }
    emit(BarcodesProductLoadedState(listOfBarcodes: listOfBarcodes));
  }

//*evento para seleccionar un submuelle
  void _onSelectecSubMuelle(
      SelectedSubMuelleEvent event, Emitter<BatchState> emit) {
    try {
      subMuelleSelected = Muelles();
      subMuelleSelected = event.subMuelleSlected;
      emit(SelectSubMuelle(subMuelleSelected));
    } catch (e, s) {
      print("❌ Error bloc selectedSubMuelle $e -> $s");
    }
  }

//*evento para obtener todas las novedades
  void _onLoadAllNovedadesEvent(
      LoadAllNovedadesEvent event, Emitter<BatchState> emit) async {
    try {
      final response = await db.novedadesRepository.getAllNovedades();
      novedades.clear();
      if (response != null) {
        novedades = response;

        print("novedades: ${novedades.length}");
      }
      emit(NovedadesLoadedState(listOfNovedades: novedades));
    } catch (e, s) {
      print("❌ Error en __onLoadAllNovedadesEvent: $e, $s");
    }
  }

//*evento para mostrar el teclado
  void _onShowKeyboardEvent(ShowKeyboard event, Emitter<BatchState> emit) {
    try {
      isKeyboardVisible = event.showKeyboard;
      emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
    } catch (e, s) {
      print("❌ Error en _onShowKeyboardEvent: $e, $s");
    }
  }

  //*evento para obtener la informacion del dispositivo
  void _onLoadInfoDevicesEvent(
      LoadInfoDeviceEvent event, Emitter<BatchState> emit) async {
    emit(BatchInitial());
    try {
      //cargamos la informacion del dispositivo
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      isPdaZebra = androidInfo.manufacturer.contains('Zebra');
      emit(InfoDeviceLoadedState());
    } catch (e, s) {
      print('❌ Error en LoadInfoDeviceEvent : $e =>$s');
    }
  }

  //* evento para cargar la configuracion del usuario
  void _onLoadConfigurationsUserEvent(
      LoadConfigurationsUser event, Emitter<BatchState> emit) async {
    try {
      int userId = await PrefUtils.getUserId();
      final response =
          await db.configurationsRepository.getConfiguration(userId);

      if (response != null) {
        emit(ConfigurationPickingLoaded(response));
        configurations = response;
      } else {
        emit(ConfigurationError('Error al cargar LoadConfigurationsUser'));
      }
    } catch (e, s) {
      print('❌ Error en LoadConfigurationsUser $e =>$s');
    }
  }

  void _onAssignSubmuelleEvent(
      AssignSubmuelleEvent event, Emitter<BatchState> emit) async {
    try {
      // Primero, actualizamos la base de datos para todos los productos
      for (var product in event.productsSeparate) {
        await db.setFieldTableBatchProducts(product.batchId ?? 0,
            product.idProduct ?? 0, 'is_muelle', 1, product.idMove ?? 0);

        // Actualizamos el muelle del producto
        await db.setFieldTableBatchProducts(
            product.batchId ?? 0,
            product.idProduct ?? 0,
            'muelle_id',
            event.muelle.id ?? 0,
            product.idMove ?? 0);

        // Actualizamos el nombre del muelle del producto
        await db.setFieldStringTableBatchProducts(
            product.batchId ?? 0,
            product.idProduct ?? 0,
            'location_dest_id',
            event.muelle.completeName ?? '',
            product.idMove ?? 0);
        //Actualizamos el barcode del muelle del producto
        await db.setFieldStringTableBatchProducts(
            product.batchId ?? 0,
            product.idProduct ?? 0,
            'barcode_location_dest',
            event.muelle.barcode ?? '',
            product.idMove ?? 0);
      }

      // Después, enviamos la petición a Odoo con todos los productos en una sola vez

      List<Item> itemsToSend = [];
      for (var product in event.productsSeparate) {
        // Traemos el tiempo de inicio de separación del producto desde la base de datos

        final userid = await PrefUtils.getUserId();

        // Creamos los Item a enviar
        itemsToSend.add(Item(
          idMove: product.idMove ?? 0,
          productId: product.idProduct ?? 0,
          lote: product.lotId ?? '',
          cantidad: (product.quantitySeparate ?? 0) > (product.quantity)
              ? product.quantity
              : product.quantitySeparate ?? 0,
          novedad: product.observation ?? 'Sin novedad',
          timeLine: product.timeSeparate ?? 0,
          muelle: event.muelle.id ?? 0,
          idOperario: userid,
          fechaTransaccion: product.fechaTransaccion ?? '',
        ));
      }

      // Enviamos la lista completa de items
      final response = await repository.sendPicking(
        context: event.context,
        idBatch: event.productsSeparate[0].batchId ?? 0,
        timeTotal: 0,
        cantItemsSeparados: batchWithProducts.batch?.productSeparateQty ?? 0,
        listItem: itemsToSend, // Enviamos todos los productos
      );

      if (response.result?.code == 200) {
        add(FetchBatchWithProductsEvent(
            event.productsSeparate[0].batchId ?? 0));
        emit(SubMuelleEditSusses('Submuelle asignado correctamente'));
      } else {
        emit(SubMuelleEditFail('Error al asignar el submuelle'));
      }
    } catch (e, s) {
      emit(SubMuelleEditFail('Error al asignar el submuelle'));
      print("❌ Error en el AssignSubmuelleEvent :$s ->$s");
    }
  }

  //*evento para enviar un producto a odoo editado
  void _onSendProductEditOdooEvent(
      SendProductEditOdooEvent event, Emitter<BatchState> emit) async {
    try {
      emit(LoadingSendProductEdit());
      bool responseEdit = await sendProuctEditOdoo(
          event.product, event.cantidad, event.context);
      if (responseEdit) {
        final response = await DataBaseSqlite()
            .getBatchWithProducts(batchWithProducts.batch?.id ?? 0);
        final List<ProductsBatch> products = response!.products!
            .where((product) => product.quantitySeparate != product.quantity)
            .toList();
        batchWithProducts.products = response.products;
        filteredProducts.clear();
        filteredProducts.addAll(products);
        emit(ProductEditOk());
      } else {
        emit(ProductEditError());
      }
    } catch (e, s) {
      print("❌ Error en el SendProductEditOdooEvent :$e->$s");
    }
  }

  //*evento para editar un producto
  void _onEditProductEvent(
      LoadProductEditEvent event, Emitter<BatchState> emit) async {
    try {
      final response = await DataBaseSqlite()
          .getBatchWithProducts(batchWithProducts.batch?.id ?? 0);
      if (response?.products?.isEmpty == true) {
        emit(ProductEditError());
        return;
      }
      final List<ProductsBatch> products = response!.products!
          .where((product) =>
              product.quantitySeparate != product.quantity ||
              product.isSendOdoo == 0)
          .toList();
      filteredProducts.clear();
      filteredProducts.addAll(products);
      emit(LoadProductsBatchSuccesStateBD(
          listOfProductsBatch: filteredProducts));
    } catch (e, s) {
      print("❌ Error en el _onEditProductEvent: $e -> $s");
    }
  }

  //*evento para dejar pendiente la separacion
  void _onPickingPendingEvent(
      ProductPendingEvent event, Emitter<BatchState> emit) async {
    try {
      emit(ProductPendingLoading());
      if (filteredProducts.isEmpty) {
        return;
      }
      //cambiamos el estado del producto a pendiente
      await db.setFieldTableBatchProducts(
          batchWithProducts.batch?.id ?? 0,
          event.product.idProduct ?? 0,
          'is_pending',
          1,
          event.product.idMove ?? 0);

      //deseleccionamos el producto actual
      if (event.product.productIsOk == 1) {
        await db.setFieldTableBatchProducts(
            batchWithProducts.batch?.id ?? 0,
            event.product.idProduct ?? 0,
            'product_is_ok',
            0,
            event.product.idMove ?? 0);
      }

      //ordenamos los productos por ubicacion
      await sortProductsByLocationId();
      add(FetchBatchWithProductsEvent(batchWithProducts.batch?.id ?? 0));
      emit(ProductPendingSuccess());
    } catch (e, s) {
      emit(ProductPendingError());
      print('❌ Error _onPickingPendingEvent: $e, $s');
    }
  }

  ///* evento para finalizar la separacion
  void _onPickingOkEvent(PickingOkEvent event, Emitter<BatchState> emit) async {
    try {
      emit(PickingOkLoading());
      await db.batchPickingRepository
          .setFieldTableBatch(event.batchId, 'is_separate', 1);

      emit(PickingOkState());
    } catch (e, s) {
      emit(PickingOkError());
      print("❌ Error en PickingOkEvent $e -> $s");
    }
  }

  //*metodo para cambiar la cantidad seleccionada
  void _onChangeQuantitySelectedEvent(
      ChangeQuantitySeparate event, Emitter<BatchState> emit) async {
    try {
      if (event.quantity > 0) {
        quantitySelected = event.quantity;
        await db.setFieldTableBatchProducts(batchWithProducts.batch?.id ?? 0,
            event.productId, 'quantity_separate', event.quantity, event.idMove);
      }
      emit(ChangeQuantitySeparateStateSuccess(quantitySelected));
    } catch (e, s) {
      emit(ChangeQuantitySeparateStateError('Error al separar cantidad'));
      print('❌ Error en ChangeQuantitySeparate: $e -> $s ');
    }
  }

  //*evento para aumentar la cantidad
  void _onAddQuantitySeparateEvent(
      AddQuantitySeparate event, Emitter<BatchState> emit) async {
    try {
      if (quantitySelected > (currentProduct.quantity ?? 0)) {
        return;
      } else {
        quantitySelected = quantitySelected + event.quantity;
        await db.incremenQtytProductSeparate(batchWithProducts.batch?.id ?? 0,
            event.productId, event.idMove, event.quantity);
        emit(ChangeQuantitySeparateStateSuccess(quantitySelected));
      }
    } catch (e, s) {
      emit(ChangeQuantitySeparateStateError('Error al aumentar cantidad'));
      print("❌ Error en el AddQuantitySeparate $e ->$s");
    }
  }

//* metodo para cargar las variables de la vista dependiendo del estado de los productos y del batch
  void _onLoadDataInfoEvent(LoadDataInfoEvent event, Emitter<BatchState> emit) {
    try {
      emit(LoadDataInfoLoading());
      if (filteredProducts.length == 1) {
        currentProduct = filteredProducts[0];
      } else {
        currentProduct =
            filteredProducts[batchWithProducts.batch?.indexList ?? 0];
      }
      if (currentProduct.locationId == oldLocation) {
        locationIsOk = true;
      } else {
        locationIsOk = currentProduct.isLocationIsOk == 1 ? true : false;
      }
      productIsOk = currentProduct.productIsOk == false
          ? false
          : currentProduct.productIsOk == 1
              ? true
              : false;
      locationDestIsOk = currentProduct.locationDestIsOk == 1 ? true : false;
      quantityIsOk = currentProduct.isQuantityIsOk == 1 ? true : false;
      index = (batchWithProducts.batch?.indexList ?? 0);
      quantitySelected = currentProduct.quantitySeparate ?? 0;
      _isProcessing = false;
      emit(LoadDataInfoSuccess());
    } catch (e, s) {
      emit(LoadDataInfoError("Error al cargar las variables de estado"));
      print("❌ Error en  LoadDataInfoEvent $e ->$s");
    }
  }

//*metodo para enviar al wms
  void sendProuctOdoo(BuildContext context) async {
    try {
      DateTime dateTimeActuality = DateTime.parse(DateTime.now().toString());
      //traemos un producto de la base de datos  ya anteriormente guardado
      final product = await db.getProductBatch(batchWithProducts.batch?.id ?? 0,
          currentProduct.idProduct ?? 0, currentProduct.idMove ?? 0);

      double secondsDifference = 0.0;
// Verificación si la fecha de inicio es nula o vacía
      // Si `startTime` tiene un valor, continúa con el cálculo
      try {
        // Calcular la diferencia entre la fecha actual y la fecha de inicio
        Duration difference = dateTimeActuality.difference(DateTime.now());
        // Obtener la diferencia en segundos
        secondsDifference = difference.inMilliseconds / 1000.0;
        print("Diferencia en segundos: $secondsDifference");
      } catch (e) {
        // Si ocurre algún error durante el parseo (por ejemplo, formato incorrecto)
        print("❌ Error al parsear la fecha: $e");
      }

      final userid = await PrefUtils.getUserId();

      //enviamos el producto a odoo
      final response = await repository.sendPicking(
          context: context,
          idBatch: product?.batchId ?? 0,
          timeTotal: secondsDifference,
          cantItemsSeparados: batchWithProducts.batch?.productSeparateQty ?? 0,
          listItem: [
            Item(
                idMove: product?.idMove ?? 0,
                productId: product?.idProduct ?? 0,
                lote: product?.lotId ?? '',
                cantidad: (product?.quantitySeparate ?? 0) > (product?.quantity)
                    ? product?.quantity
                    : product?.quantitySeparate ?? 0,
                novedad: product?.observation ?? 'Sin novedad',
                timeLine: product?.timeSeparate ?? 0.0,
                muelle: product?.muelleId ?? 0,
                idOperario: userid,
                fechaTransaccion: product?.fechaTransaccion ?? ''),
          ]);

      if (response.result?.code == 200) {
        //recorremos todos los resultados de la respuesta
        for (var resultProduct in response.result!.result!) {
          await db.setFieldTableBatchProducts(
            resultProduct.idBatch ?? 0,
            resultProduct.idProduct ?? 0,
            'is_send_odoo',
            1,
            resultProduct.idMove ?? 0,
          );
        }
      } else {
        //elementos que no se pudieron enviar a odoo
        await db.setFieldTableBatchProducts(
          product?.batchId ?? 0,
          product?.idProduct ?? 0,
          'is_send_odoo',
          0,
          product?.idMove ?? 0,
        );
      }
    } catch (e, s) {
      print("❌ Error en el sendProuctOdoo $e ->$s ");
    }
  }

  Future<bool> sendProuctEditOdoo(
      ProductsBatch productEdit, int cantidad, BuildContext context) async {
    DateTime dateTimeActuality = DateTime.parse(DateTime.now().toString());
    //traemos un producto de la base de datos  ya anteriormente guardado
    final product = await db.getProductBatch(productEdit.batchId ?? 0,
        productEdit.idProduct ?? 0, productEdit.idMove ?? 0);

    //todo: tiempor por batch
    //tiempo de separacion del producto, lo traemos de la bd
    final starTime = await db.batchPickingRepository
        .getFieldTableBatch(productEdit.batchId ?? 0, 'start_time_pick');
    DateTime dateTimeStart = starTime == "null" || starTime.isEmpty
        ? DateTime.now()
        : DateTime.parse(starTime);
    // Calcular la diferencia
    Duration difference = dateTimeActuality.difference(dateTimeStart);
    // Obtener la diferencia en segundos
    double secondsDifference = difference.inMilliseconds / 1000.0;
    final userid = await PrefUtils.getUserId();

    //asignamos timepo total si esta en null
    if (product?.timeSeparate == null) {
      await db.setFieldTableBatchProducts(
          productEdit.batchId ?? 0,
          productEdit.idProduct ?? 0,
          'time_separate',
          30,
          productEdit.idMove ?? 0);
    }

    DateTime fechaTransaccion = DateTime.now();
    String fechaFormateada = formatoFecha(fechaTransaccion);

    //enviamos el producto a odoo
    final response = await repository.sendPicking(
        context: context,
        idBatch: product?.batchId ?? 0,
        timeTotal: secondsDifference,
        cantItemsSeparados: batchWithProducts.batch?.productSeparateQty ?? 0,
        listItem: [
          Item(
              idMove: product?.idMove ?? 0,
              productId: product?.idProduct ?? 0,
              lote: product?.lotId ?? '',
              cantidad: cantidad,
              novedad: (cantidad == product?.quantity)
                  ? 'Sin novedad'
                  : product?.observation ?? 'Sin novedad',
              timeLine:
                  product?.timeSeparate == null ? 30.0 : product?.timeSeparate,
              muelle: product?.muelleId ?? 0,
              idOperario: userid,
              fechaTransaccion: product?.fechaTransaccion ?? fechaFormateada),
        ]);

    if (response.result?.code == 200) {
      //recorremos todos los resultados de la respuesta
      for (var resultProduct in response.result!.result!) {
        await db.setFieldTableBatchProducts(
          resultProduct.idBatch ?? 0,
          resultProduct.idProduct ?? 0,
          'is_send_odoo',
          1,
          resultProduct.idMove ?? 0,
        );
      }

      return true;
    } else {
      //elementos que no se pudieron enviar a odoo
      await db.setFieldTableBatchProducts(
        product?.batchId ?? 0,
        product?.idProduct ?? 0,
        'is_send_odoo',
        0,
        product?.idMove ?? 0,
      );
      return false;
    }
  }

  void _onValidateFields(ValidateFieldsEvent event, Emitter<BatchState> emit) {
    try {
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
      emit(ValidateFieldsStateSuccess(event.isOk));
    } catch (e, s) {
      emit(ValidateFieldsStateError('Error al validar campos'));
      print("❌ Error en el ValidateFieldsEvent $e ->$s");
    }
  }

  void _onSelectNovedadEvent(
      SelectNovedadEvent event, Emitter<BatchState> emit) {
    try {
      selectedNovedad = event.novedad;
      emit(SelectNovedadStateSuccess(event.novedad));
    } catch (e, s) {
      emit(SelectNovedadStateError('Errror al seleccionar novedad'));
      print('❌ Error en el SelectNovedadEvent $e ->$s');
    }
  }

  void getPosicions() {
    try {
      // Usar un Set para evitar duplicados automáticamente
      Set<String> positionsSet = {};
      // Usamos un filtro para no tener que comprobar locationId en cada iteración
      for (var product in filteredProducts) {
        // Solo añadimos locationId si no es nulo ni vacío
        String locationId = product.locationId ?? '';
        if (locationId.isNotEmpty) {
          positionsSet.add(locationId);
        }
      }

      // Convertimos el Set a lista si es necesario
      positionsOrigen = positionsSet.toList();
    } catch (e, s) {
      print("❌ Error en getPosicions: $e -> $s");
    }
  }

  void getMuelles() {
    try {
      muelles.clear();
      if (batchWithProducts.batch?.muelle?.isNotEmpty == true) {
        muelles.add(batchWithProducts.batch?.muelle ?? '');
      }
    } catch (e, s) {
      print("❌ Error en el getMuelles $e ->$s");
    }
  }

  void getSubmuelles() async {
    try {
      submuelles.clear();
      final muellesdb =
          //todo cambiar al id de idMuelle
          await db.submuellesRepository.getSubmuellesByLocationId(
        batchWithProducts.batch?.idMuelle == ""
            ? 0
            : int.parse(batchWithProducts.batch?.idMuelle.toString() ?? '0'),
      );
      if (muellesdb.isNotEmpty) {
        submuelles.addAll(muellesdb);
      }
    } catch (e, s) {
      print("❌ Error en el getSubmuelles $e ->$s");
    }
  }

  void products() {
    try {
      // Usamos un Set para evitar duplicados y mejorar el rendimiento de búsqueda
      Set<String> productIdsSet = {};
      // Recorremos los productos del batch
      for (var product in filteredProducts) {
        // Validamos que el productId no sea nulo y lo convertimos a String
        if (product.productId != null) {
          productIdsSet.add(product.productId.toString());
        }
      }
      // Asignamos el Set a la lista, si es necesario
      listOfProductsName = productIdsSet.toList();
    } catch (e, s) {
      print("❌ Error en el products $e ->$s");
    }
  }

  void _onChangeCurrentProduct(
      ChangeCurrentProduct event, Emitter<BatchState> emit) async {
    try {
      viewQuantity = false;
      emit(CurrentProductChangedStateLoading());

      // Desseleccionamos el producto ya separado
      await db.setFieldTableBatchProducts(
          batchWithProducts.batch?.id ?? 0,
          event.currentProduct.idProduct ?? 0,
          'is_selected',
          0,
          currentProduct.idMove ?? 0);

      DateTime dateTimeActuality = DateTime.parse(DateTime.now().toString());

      // Actualizamos el tiempo total del producto ya separado
      await db.endStopwatchProduct(
          batchWithProducts.batch?.id ?? 0,
          dateTimeActuality.toString(),
          currentProduct.idProduct ?? 0,
          currentProduct.idMove ?? 0);

      final starTimeProduct = await db.getFieldTableProducts(
          currentProduct.batchId ?? 0,
          currentProduct.idProduct ?? 0,
          currentProduct.idMove ?? 0,
          "time_separate_start");

      DateTime dateTimeStartProduct =
          starTimeProduct == "null" || starTimeProduct.isEmpty
              ? DateTime.parse(DateTime.now().toString())
              : DateTime.parse(starTimeProduct);

      // Calcular la diferencia del producto ya separado
      Duration differenceProduct =
          dateTimeActuality.difference(dateTimeStartProduct);

      // Obtener la diferencia en segundos
      double secondsDifferenceProduct =
          differenceProduct.inMilliseconds / 1000.0;

      await db.totalStopwatchProduct(
          batchWithProducts.batch?.id ?? 0,
          currentProduct.idProduct ?? 0,
          currentProduct.idMove ?? 0,
          secondsDifferenceProduct);

      sendProuctOdoo(event.context);

      // Validamos si es el último producto
      if (filteredProducts.length == index + 1) {
        // Actualizamos el index de la lista de productos
        await db.batchPickingRepository.setFieldTableBatch(
            batchWithProducts.batch?.id ?? 0, 'index_list', index);

        if (currentProduct.locationId == oldLocation) {
          locationIsOk = true;
        } else {
          locationIsOk = false;
        }
        // Emitimos el estado de productos completados
        emit(CurrentProductChangedState(
            currentProduct: currentProduct, index: index));
        return;
      } else {
        // Validamos la última ubicación
        productIsOk = false;
        quantityIsOk = false;

        // Solo incrementamos el índice si no ha sido incrementado previamente
        index = (batchWithProducts.batch?.indexList ?? 0) + 1;

        if (index != (batchWithProducts.batch?.indexList ?? 1) + 1) {
          print('El index ES DIFERENTE A INDEXLIST 🍓');
          index = (batchWithProducts.batch?.indexList ?? 0) + 1;
        }

        // Actualizamos el index de la lista de productos
        await db.batchPickingRepository.setFieldTableBatch(
            batchWithProducts.batch?.id ?? 0, 'index_list', index);

        currentProduct = filteredProducts[index];

        if (currentProduct.locationId == oldLocation) {
          print('La ubicación es igual');
          locationIsOk = true;
        } else {
          locationIsOk = false;
          print('La ubicación es diferente');
        }

        await db.startStopwatch(
          batchWithProducts.batch?.id ?? 0,
          currentProduct.idProduct ?? 0,
          currentProduct.idMove ?? 0,
          DateTime.now().toString(),
        );

        emit(CurrentProductChangedState(
            currentProduct: currentProduct, index: index));

        add(FetchBatchWithProductsEvent(batchWithProducts.batch?.id ?? 0));

        //mostramos todas las variables

        return;
      }
    } catch (e, s) {
      emit(CurrentProductChangedStateError('Error al cambiar de producto'));
      print("❌ Error en el ChangeCurrentProduct $e ->$s");
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<BatchState> emit) async {
    try {
      if (event.isOk) {
        await db.setFieldTableBatchProducts(event.batchId, event.productId,
            'is_quantity_is_ok', 1, event.idMove);
      }
      quantityIsOk = event.isOk;
      emit(ChangeQuantityIsOkState(
        quantityIsOk,
      ));
    } catch (e, s) {
      print("❌ Error en el ChangeIsOkQuantity $e ->$s");
    }
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<BatchState> emit) async {
    try {
      if (isLocationOk) {
        await db.setFieldTableBatchProducts(
          event.batchId,
          event.productId,
          'is_location_is_ok',
          1,
          event.idMove,
        );

        //cuando se lea la ubicacion se selecciona el batch
        await db.batchPickingRepository
            .setFieldTableBatch(event.batchId, 'is_selected', 1);
        locationIsOk = true;
        emit(ChangeLocationIsOkState(
          locationIsOk,
        ));
      }
    } catch (e, s) {
      print("❌ Error en el ChangeLocationIsOkEvent $e ->$s");
    }
  }

  void _onChangeLocationDestIsOkEvent(
      ChangeLocationDestIsOkEvent event, Emitter<BatchState> emit) async {
    try {
      if (event.locationDestIsOk) {
        await db.setFieldTableBatchProducts(event.batchId, event.productId,
            'location_dest_is_ok', 1, event.idMove);
      }
      locationDestIsOk = event.locationDestIsOk;
      emit(ChangeLocationDestIsOkState(
        locationDestIsOk,
      ));
    } catch (e, s) {
      print("❌ Error en el ChangeLocationDestIsOkEvent $e ->$s");
    }
  }

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<BatchState> emit) async {
    try {
      if (event.productIsOk) {
        //empezamos el tiempo de separacion del batch y del producto
        await db.startStopwatch(
          event.batchId,
          event.productId,
          event.idMove,
          DateTime.now().toString(),
        );

        //calculamos la fecha de transaccion
        DateTime fechaTransaccion = DateTime.now();
        String fechaFormateada = formatoFecha(fechaTransaccion);
        //agregamos la fecha de transaccion
        await db.dateTransaccionProduct(
          event.batchId,
          fechaFormateada,
          event.productId,
          event.idMove,
        );

        await db.setFieldTableBatchProducts(event.batchId, event.productId,
            'is_quantity_is_ok', 1, event.idMove);
        quantityIsOk = event.productIsOk;

        await db.setFieldTableBatchProducts(
            event.batchId, event.productId, 'is_selected', 1, event.idMove);
        await db.setFieldTableBatchProducts(
            event.batchId, event.productId, 'product_is_ok', 1, event.idMove);
      }
      productIsOk = event.productIsOk;
      emit(ChangeProductIsOkState(
        productIsOk,
      ));
    } catch (e, s) {
      print("❌ Error en el ChangeProductIsOkEvent $e ->$s");
    }
  }

  void _onClearSearchEvent(
      ClearSearchProudctsBatchEvent event, Emitter<BatchState> emit) async {
    try {
      searchController.clear();
      filteredProducts.clear();
      filteredProducts.addAll(batchWithProducts.products!);
      await sortProductsByLocationId();
      emit(LoadProductsBatchSuccesState(listOfProductsBatch: filteredProducts));
    } catch (e, s) {
      print("❌ Error en el ClearSearchProudctsBatchEvent $e ->$s");
    }
  }

  void _onSearchBacthEvent(
      SearchProductsBatchEvent event, Emitter<BatchState> emit) async {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      filteredProducts.clear();
      filteredProducts = batchWithProducts
          .products!; // Si la búsqueda está vacía, mostrar todos los productos
      await sortProductsByLocationId();
    } else {
      filteredProducts = batchWithProducts.products!.where((batch) {
        return batch.productId?.toLowerCase().contains(query) ?? false;
      }).toList();
    }
    emit(LoadProductsBatchSuccesState(
        listOfProductsBatch: filteredProducts)); // Emitir la lista filtrada
  }

  void _onFetchBatchWithProductsEvent(
      FetchBatchWithProductsEvent event, Emitter<BatchState> emit) async {
    try {
      batchWithProducts = BatchWithProducts();

      final response =
          await DataBaseSqlite().getBatchWithProducts(event.batchId);

      if (response != null) {
        batchWithProducts = response;

        if (batchWithProducts.products!.isEmpty) {
          print('No hay productos en el batch');
          emit(EmptyroductsBatch());
          return;
        }

        filteredProducts.clear();
        filteredProducts.addAll(batchWithProducts.products!);

        await sortProductsByLocationId();

        add(LoadDataInfoEvent());
        getSubmuelles();
        getPosicions();
        getMuelles();
        products();

        add(FetchBarcodesProductEvent());

        emit(LoadProductsBatchSuccesStateBD(
            listOfProductsBatch: filteredProducts));
      } else {
        batchWithProducts = BatchWithProducts();
        print('No se encontró el batch con ID: ${event.batchId}');
      }
    } catch (e, s) {
      print("❌ Error en el FetchBatchWithProductsEvent $e ->$s");
    }
  }

//*metodo para ordenar los productos por ubicacion
  Future<List<ProductsBatch>> sortProductsByLocationId() async {
    try {
      final products = filteredProducts;
      final batch = batchWithProducts.batch;

      //traemos el batch actualizado
      final batchUpdated =
          await db.batchPickingRepository.getBatchById(batch?.id ?? 0);

      //ORDENAMOS LOS PRODUCTOS SEGUN EL ORDENAMIENTO QUE DIGA EL BATCH
      switch (batchUpdated?.orderBy) {
        case "removal_priority":
          {
            if (batchUpdated?.orderPicking == "asc") {
              products.sort((a, b) {
                return a.rimovalPriority!.compareTo(b.rimovalPriority!);
              });
            } else {
              products.sort((a, b) {
                return b.rimovalPriority!.compareTo(a.rimovalPriority!);
              });
            }
          }
          break;
        case "location_name":
          {
            if (batchUpdated?.orderPicking == "asc") {
              products.sort((a, b) {
                return a.locationId!.compareTo(b.locationId!);
              });
            } else {
              products.sort((a, b) {
                return b.locationId!.compareTo(a.locationId!);
              });
            }
          }
          break;
        case "product_name":
          {
            if (batchUpdated?.orderPicking == "asc") {
              products.sort((a, b) {
                return a.productId!.compareTo(b.productId!);
              });
            } else {
              products.sort((a, b) {
                return b.productId!.compareTo(a.productId!);
              });
            }
          }
          break;
      }

      // Filtrar los productos con isPending == 1
      List<ProductsBatch> pendingProducts =
          products.where((product) => product.isPending == 1).toList();

      // Filtrar los productos que no están pendientes
      List<ProductsBatch> nonPendingProducts =
          products.where((product) => product.isPending != 1).toList();

      // Concatenar los productos no pendientes con los productos pendientes al final
      filteredProducts.clear();
      filteredProducts.addAll(nonPendingProducts);
      filteredProducts.addAll(pendingProducts);

      return filteredProducts;
    } catch (e, s) {
      print("❌ Error en el sortProductsByLocationId $e ->$s");
      return [];
    }
  }

  String calcularUnidadesSeparadas() {
    try {
      if (batchWithProducts.products == null ||
          batchWithProducts.products!.isEmpty) {
        return "0.0";
      }
      int totalSeparadas = 0;
      int totalCantidades = 0;
      for (var product in batchWithProducts.products!) {
        totalSeparadas += product.quantitySeparate ?? 0;
        totalCantidades +=
            (product.quantity as int?) ?? 0; // Aseguramos que sea int
      }
      // Evitar división por cero
      if (totalCantidades == 0) {
        return "0.0";
      }
      final progress = (totalSeparadas / totalCantidades) * 100;
      return progress.toStringAsFixed(1);
    } catch (e, s) {
      print("❌ Error en el calcularUnidadesSeparadas $e ->$s");
      return '';
    }
  }

  String formatSecondsToHHMMSS(double secondsDecimal) {
    try {
      // Redondear a los segundos más cercanos
      int totalSeconds = secondsDecimal.round();

      // Calcular horas, minutos y segundos
      int hours = totalSeconds ~/ 3600;
      int minutes = (totalSeconds % 3600) ~/ 60;
      int seconds = totalSeconds % 60;

      // Formatear en 00:00:00
      String formattedTime = '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';

      return formattedTime;
    } catch (e, s) {
      print("❌ Error en el formatSecondsToHHMMSS $e ->$s");
      return "";
    }
  }
}
