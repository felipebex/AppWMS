// ignore_for_file: unnecessary_null_comparison, collection_methods_unrelated_type

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/transferencias/data/transferencias_repository.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/requets_transfer_model.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/utils/formats.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'transferencia_event.dart';
part 'transferencia_state.dart';

class TransferenciaBloc extends Bloc<TransferenciaEvent, TransferenciaState> {
  //*controller de busqueda
  TextEditingController searchControllerTransfer = TextEditingController();
  //*variables para validar
  bool isKeyboardVisible = false;

  //*repositorio
  final TransferenciasRepository _transferenciasRepository =
      TransferenciasRepository();

  //*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  //*configuracion del usuario //permisos
  Configurations configurations = Configurations();

  //*lista de todas las pocisiones de los productos del batchs
  List<String> positionsOrigen = [];

  //lista de transferencias
  List<ResultTransFerencias> transferencias = [];
  List<ResultTransFerencias> transferenciasDB = [];
  List<ResultTransFerencias> transferenciasDbFilters = [];

  List<LineasTransferenciaTrans> listProductsTransfer = [];
  //*lista de productos de un una entrada
  List<String> listOfProductsName = [];

  LineasTransferenciaTrans currentProduct = LineasTransferenciaTrans();

  // //*validaciones de campos del estado de la vista
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;

  String oldLocation = '';

  String selectedNovedad = '';
  String selectedLocation = '';
  //*valores de scanvalue

  int quantitySelected = 0;
  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';
  String scannedValue5 = '';

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  bool quantityEdit = false;

  bool viewQuantity = false;

  //*lista de novedades
  List<Novedad> novedades = [];
  //*lista de barcodes
  List<Barcodes> listOfBarcodes = [];

  //*lista de ubicaciones
  List<ResultUbicaciones> ubicaciones = [];

  //*metodo para empezar o terminar timepo

  //tranferencia actual
  ResultTransFerencias currentTransferencia = ResultTransFerencias();

  TransferenciaBloc() : super(TransferenciaInitial()) {
    on<TransferenciaEvent>((event, emit) {});
    //metodo para obtener todas las transferencias
    on<FetchAllTransferencias>(_onfetchTransferencias);
    //metodo para obtener todas las transferencias de la base de datos
    on<FetchAllTransferenciasDB>(_onfetchTransferenciasDB);
    //metodo para cargar la transferencia actual
    on<CurrentTransferencia>(_oncurrentTransferencia);

    // buscar una orden de compra
    on<SearchTransferEvent>(_onSearchOrderEvent);

    //activar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);

    //*obtener las configuraciones y permisos del usuario desde la bd
    on<LoadConfigurationsUserTransfer>(_onLoadConfigurationsUserEvent);

    //*obtener todos los productos de una transferencia
    on<GetPorductsToTransfer>(_onGetProductsToTransfer);

    //*evento para cargar la info del producto
    on<FetchPorductTransfer>(_onFetchPorductTransfer);

    //todo: estados para la sepracion

    on<ValidateFieldsEvent>(_onValidateFields);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeLocationDestIsOkEvent>(_onChangeLocationDestIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);

    //*evento para actualizar el valor del scan
    on<UpdateScannedValueEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValueEvent>(_onClearScannedValueEvent);

    //*evento para cambiar la cantidad seleccionada
    on<ChangeQuantitySeparate>(_onChangeQuantitySelectedEvent);
    on<AddQuantitySeparate>(_onAddQuantitySeparateEvent);

    //*evento para ver la cantidad
    on<ShowQuantityEvent>(_onShowQuantityEvent);
    //* evento para empezar o terminar el tiempo
    on<StartOrStopTimeTransfer>(_onStartOrStopTimeTransfer);

    //*asignar un usuario a una orden de compra
    on<AssignUserToTransfer>(_onAssignUserToTransfer);
    //*finalizarRececpcionProducto
    on<FinalizarTransferProducto>(_onFinalizaTransferProducto);

    //*finalizarRececpcionProductoSplit
    on<FinalizarTransferProductoSplit>(_onFinalizarTransferProductoSplit);

    //*metodo para enviar el producto a wms
    on<SendProductToTransfer>(_onSendProductToTransfer);

    //*metodo para cargar las ubicaciones
    on<LoadLocations>(_onLoadLocations);

    //*metodo para crear barckorder o no
    on<CreateBackOrderOrNot>(_onCreateBackOrder);

    //*evento para obtener las novedades
    on<LoadAllNovedadesTransferEvent>(_onLoadAllNovedadesEvent);
  }

  //*meotod para cargar todas las novedades
  void _onLoadAllNovedadesEvent(LoadAllNovedadesTransferEvent event,
      Emitter<TransferenciaState> emit) async {
    try {
      emit(NovedadesTransferLoadingState());
      final response = await db.novedadesRepository.getAllNovedades();
      if (response != null) {
        novedades.clear();
        novedades = response;
        print("novedades: ${novedades.length}");
        emit(NovedadesTransferLoadedState(listOfNovedades: novedades));
      }
    } catch (e, s) {
      print("Error en __onLoadAllNovedadesEvent: $e, $s");
      emit(NovedadesTransferErrorState(e.toString()));
    }
  }

  void _onCreateBackOrder(
      CreateBackOrderOrNot event, Emitter<TransferenciaState> emit) async {
    try {
      emit(CreateBackOrderOrNotLoading());
      final response = await _transferenciasRepository.validateTransfer(
          event.idRecepcion, event.isBackOrder, false);

      if (response.result?.code == 200) {
        add(StartOrStopTimeTransfer(
          event.idRecepcion,
          'end_time_reception',
        ));

        emit(CreateBackOrderOrNotSuccess(event.isBackOrder));
      } else {
        emit(CreateBackOrderOrNotFailure(response.result?.msg ?? ''));
      }
    } catch (e, s) {
      emit(CreateBackOrderOrNotFailure('Error al crear la backorder'));
      print('Error en el _onCreateBackOrder: $e, $s');
    }
  }

  void _onLoadLocations(
      LoadLocations event, Emitter<TransferenciaState> emit) async {
    try {
      emit(LoadLocationsLoading());
      final response = await db.ubicacionesRepository.getAllUbicaciones();
      if (response.isNotEmpty) {
        ubicaciones.clear();
        ubicaciones = response;
        print('ubicaciones length: ${ubicaciones.length}');
        emit(LoadLocationsSuccess(ubicaciones));
      } else {
        emit(LoadLocationsFailure('No se encontraron ubicaciones'));
      }
    } catch (e, s) {
      emit(LoadLocationsFailure('Error al cargar las ubicaciones'));
      print('Error en el fetch de ubicaciones: $e=>$s');
    }
  }

  void getProductFromBd() async {
    final productBD = await db.productTransferenciaRepository.getProductById(
      int.parse(currentProduct.productId),
      currentProduct.idMove ?? 0,
      currentProduct.idTransferencia ?? 0,
    );

    print("productBD: ${productBD?.toMap()}");
  }

  void _onSendProductToTransfer(
      SendProductToTransfer event, Emitter<TransferenciaState> emit) async {
    try {
      emit(SendProductToTransferLoading());

      final userid = await PrefUtils.getUserId();

      //calculamos la fecha de transaccion
      DateTime fechaTransaccion = DateTime.now();
      String fechaFormateada = formatoFecha(fechaTransaccion);
      //agregamos la fecha de transaccion
      await db.productTransferenciaRepository.setFieldTableProductTransfer(
        currentProduct.idTransferencia ?? 0,
        int.parse(currentProduct.productId),
        'date_transaction',
        fechaFormateada,
        currentProduct.idMove ?? 0,
      );

      final productBD = await db.productTransferenciaRepository.getProductById(
        int.parse(currentProduct.productId),
        currentProduct.idMove ?? 0,
        currentProduct.idTransferencia ?? 0,
      );

      final responseSend = await _transferenciasRepository.sendProductTransfer(
        TransferRequest(
          idTransferencia: currentProduct.idTransferencia ?? 0,
          listItems: [
            ListItem(
              idMove: productBD?.idMove ?? 0,
              idProducto: int.parse(productBD?.productId),
              idLote: int.parse(productBD!.lotId.toString()),
              idUbicacionOrigen: int.parse(productBD.locationId.toString()),
              idUbicacionDestino:
                  int.parse(productBD.locationDestId.toString()),
              cantidadEnviada: productBD.quantitySeparate,
              idOperario: userid,
              timeLine: 10,
              fechaTransaccion: fechaFormateada,
              observacion: productBD.observation == ""
                  ? "Sin novedad"
                  : productBD.observation,
            ),
          ],
        ),
        false,
      );

      if (responseSend.result?.code == 200) {
        emit(SendProductToTransferSuccess());
      } else {
        emit(SendProductToTransferFailure('Error al enviar el producto'));
      }
    } catch (e, s) {
      emit(SendProductToTransferFailure('Error al enviar el producto'));
      print('Error en el _onSendProductToTransfer: $e, $s');
    }
  }

  //*Metodo para finalizar un producto Split
  void _onFinalizarTransferProductoSplit(FinalizarTransferProductoSplit event,
      Emitter<TransferenciaState> emit) async {
    try {
      emit(FinalizarTransferProductoSplitLoading());

      //actualizamso el estado del producto como separado
      await db.productTransferenciaRepository.setFieldTableProductTransfer(
          currentProduct.idTransferencia ?? 0,
          int.parse(currentProduct.productId),
          "is_separate",
          1,
          currentProduct.idMove ?? 0);

      //marcamos el producto como split
      await db.productTransferenciaRepository.setFieldTableProductTransfer(
          currentProduct.idTransferencia ?? 0,
          int.parse(currentProduct.productId),
          "is_product_split",
          1,
          currentProduct.idMove ?? 0);
      //marcamos tiempo final de separacion
      await db.productTransferenciaRepository.setFieldTableProductTransfer(
          currentProduct.idTransferencia ?? 0,
          int.parse(currentProduct.productId),
          "date_end",
          DateTime.now().toString(),
          currentProduct.idMove ?? 0);
      //marcamso el producto como is_done_item
      await db.productTransferenciaRepository.setFieldTableProductTransfer(
          currentProduct.idTransferencia ?? 0,
          int.parse(currentProduct.productId),
          "is_done_item",
          1,
          currentProduct.idMove ?? 0);

      //calculamos la cantidad pendiente del producto
      var pendingQuantity = (currentProduct.quantityOrdered - event.quantity);

      //creamos un nuevo producto (duplicado) con la cantidad separada
      await db.productTransferenciaRepository
          .insertDuplicateProducto(currentProduct, pendingQuantity);

      add(GetPorductsToTransfer(currentProduct.idTransferencia ?? 0));
      emit(FinalizarTransferProductoSplitSuccess());
    } catch (e, s) {
      print('Error al finalizar la recepcion del producto split: $e, $s');
    }
  }

  //*Metodo pra finalizar un producto en transferencia
  void _onFinalizaTransferProducto(
      FinalizarTransferProducto event, Emitter<TransferenciaState> emit) async {
    try {
      emit(FinalizarTransferProductoLoading());
      //marcamos el producto como terminado
      await db.productTransferenciaRepository.setFieldTableProductTransfer(
          currentProduct.idTransferencia ?? 0,
          int.parse(currentProduct.productId),
          "is_separate",
          1,
          currentProduct.idMove ?? 0);

      //marcamos tiempo final de separacion
      await db.productTransferenciaRepository.setFieldTableProductTransfer(
          currentProduct.idTransferencia ?? 0,
          int.parse(currentProduct.productId),
          "date_end",
          DateTime.now().toString(),
          currentProduct.idMove ?? 0);
      //marcamos el producto como termiado

      //marcamos tiempo final de separacion
      await db.productTransferenciaRepository.setFieldTableProductTransfer(
          currentProduct.idTransferencia ?? 0,
          int.parse(currentProduct.productId),
          "is_done_item",
          1,
          currentProduct.idMove ?? 0);
      add(GetPorductsToTransfer(currentProduct.idTransferencia ?? 0));
    } catch (e, s) {
      emit(FinalizarTransferProductoFailure(
          'Error al finalizar la recepcion del producto'));
      print('Error en el _onFinalizarRecepcionProducto: $e, $s');
    }
  }

//metodo para empezar o terminar el tiempo
  void _onStartOrStopTimeTransfer(
      StartOrStopTimeTransfer event, Emitter<TransferenciaState> emit) async {
    try {
      final time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      print("time : $time");

      if (event.value == "start_time_transfer") {
        await db.transferenciaRepository.setFieldTableTransfer(
          event.idTransfer,
          "start_time_transfer",
          time,
        );
      } else if (event.value == "end_time_transfer") {
        await db.transferenciaRepository.setFieldTableTransfer(
          event.idTransfer,
          "end_time_transfer",
          time,
        );
        await db.transferenciaRepository.setFieldTableTransfer(
          event.idTransfer,
          "is_finish",
          1,
        );
      }

      await db.transferenciaRepository.setFieldTableTransfer(
        event.idTransfer,
        "is_selected",
        1,
      );

      await db.transferenciaRepository.setFieldTableTransfer(
        event.idTransfer,
        "is_started",
        1,
      );

      //hacemos la peticion de mandar el tiempo
      final response = await _transferenciasRepository.sendTime(
        event.idTransfer,
        event.value,
        time,
        false,
      );

      if (response) {
        emit(StartOrStopTimeTransferSuccess(event.value));
      } else {
        emit(StartOrStopTimeTransferFailure('Error al enviar el tiempo'));
      }
    } catch (e, s) {
      print('Error en el _onStartOrStopTimeOrder: $e, $s');
    }
  }

  //*metodo para obtener los permisos del usuario
  void _onAssignUserToTransfer(
      AssignUserToTransfer event, Emitter<TransferenciaState> emit) async {
    try {
      int userId = await PrefUtils.getUserId();
      String nameUser = await PrefUtils.getUserName();

      emit(AssignUserToTransferLoading());
      final response = await _transferenciasRepository.assignUserToTransfer(
        true,
        userId,
        event.transfer.id ?? 0,
      );

      if (response) {
        //actualizamos la tabla entrada:
        await db.transferenciaRepository.setFieldTableTransfer(
          event.transfer.id ?? 0,
          "responsable_id",
          userId,
        );

        await db.transferenciaRepository.setFieldTableTransfer(
          event.transfer.id ?? 0,
          "responsable",
          nameUser,
        );
        await db.transferenciaRepository.setFieldTableTransfer(
          event.transfer.id ?? 0,
          "is_selected",
          1,
        );

        add(StartOrStopTimeTransfer(
          event.transfer.id ?? 0,
          "start_time_transfer",
        ));

        emit(AssignUserToTransferSuccess(
          event.transfer,
        ));
      } else {
        emit(AssignUserToTransferFailure(
            "La recepción ya tiene un responsable asignado"));
      }
    } catch (e, s) {
      emit(AssignUserToTransferFailure('Error al asignar el usuario'));
      print('Error en el _onAssignUserToOrder: $e, $s');
    }
  }

  //*evento para ver la cantidad
  void _onShowQuantityEvent(
      ShowQuantityEvent event, Emitter<TransferenciaState> emit) {
    try {
      viewQuantity = !viewQuantity;
      emit(ShowQuantityState(viewQuantity));
    } catch (e, s) {
      print("❌ Error en _onShowQuantityEvent: $e, $s");
    }
  }

  //*metodo para cambiar la cantidad seleccionada
  void _onChangeQuantitySelectedEvent(
      ChangeQuantitySeparate event, Emitter<TransferenciaState> emit) async {
    try {
      if (event.quantity > 0) {
        quantitySelected = event.quantity;
        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'quantity_separate',
          event.quantity,
          event.idMove,
        );
      }
      emit(ChangeQuantitySeparateStateSuccess(quantitySelected));
    } catch (e, s) {
      emit(ChangeQuantitySeparateStateError('Error al separar cantidad'));
      print('❌ Error en ChangeQuantitySeparate: $e -> $s ');
    }
  }

  //*evento para aumentar la cantidad
  void _onAddQuantitySeparateEvent(
      AddQuantitySeparate event, Emitter<TransferenciaState> emit) async {
    try {
      if (quantitySelected > (currentProduct.quantityOrdered ?? 0)) {
        return;
      } else {
        quantitySelected = quantitySelected + event.quantity;

        await db.productTransferenciaRepository.incremenQtytProductSeparate(
            event.idTransfer, event.productId, event.idMove, event.quantity);

        emit(ChangeQuantitySeparateStateSuccess(quantitySelected));
      }
    } catch (e, s) {
      emit(ChangeQuantitySeparateStateError('Error al aumentar cantidad'));
      print("❌ Error en el AddQuantitySeparate $e ->$s");
    }
  }

//*evento para limpiar el valor del scan
  void _onClearScannedValueEvent(
      ClearScannedValueEvent event, Emitter<TransferenciaState> emit) {
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
        case 'toDo':
          scannedValue5 = '';
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
      UpdateScannedValueEvent event, Emitter<TransferenciaState> emit) {
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

        case 'toDo':
          print('scannedValue5: $scannedValue5');
          scannedValue5 += event.scannedValue;
          emit(UpdateScannedValueState(scannedValue5, event.scan));
          break;
        default:
          print('Scan type not recognized: ${event.scan}');
      }
    } catch (e, s) {
      print("❌ Error en _onUpdateScannedValueEvent: $e, $s");
    }
  }

  void _onChangeLocationDestIsOkEvent(ChangeLocationDestIsOkEvent event,
      Emitter<TransferenciaState> emit) async {
    try {
      if (event.locationDestIsOk) {
        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'location_dest_is_ok',
          1,
          event.idMove,
        );
        //asiganmos la ubicacion al producto
        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'location_dest_id',
          event.location.id,
          event.idMove,
        );
        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'location_dest_name',
          event.location.name,
          event.idMove,
        );
        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'location_dest_barcode',
          event.location.barcode,
          event.idMove,
        );
      }
      locationDestIsOk = event.locationDestIsOk;
      selectedLocation = event.location.name ?? "";

      emit(ChangeLocationDestIsOkState(
        locationDestIsOk,
      ));
    } catch (e, s) {
      print("❌ Error en el ChangeLocationDestIsOkEvent $e ->$s");
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<TransferenciaState> emit) async {
    try {
      if (event.isOk) {
        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'is_quantity_is_ok',
          1,
          event.idMove,
        );
      }
      quantityIsOk = event.isOk;
      emit(ChangeQuantityIsOkState(
        quantityIsOk,
      ));
    } catch (e, s) {
      print("❌ Error en el ChangeIsOkQuantity $e ->$s");
    }
  }

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<TransferenciaState> emit) async {
    try {
      if (event.productIsOk) {
        //empezamos el tiempo de separacion del producto
        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'date_start',
          DateTime.now().toString(),
          event.idMove,
        );

        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'is_quantity_is_ok',
          1,
          event.idMove,
        );

        quantityIsOk = event.productIsOk;
        quantityEdit = event.productIsOk;

        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'product_is_ok',
          1,
          event.idMove,
        );

        // actualizamos la table de transferencias como seleccionada

        await db.transferenciaRepository.setFieldTableTransfer(
          event.idTransfer,
          'is_selected',
          1,
        );
      }
      productIsOk = event.productIsOk;
      emit(ChangeProductIsOkState(
        productIsOk,
      ));
    } catch (e, s) {
      print("❌ Error en el ChangeProductIsOkEvent $e ->$s");
    }
  }

  void _onValidateFields(
      ValidateFieldsEvent event, Emitter<TransferenciaState> emit) {
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

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<TransferenciaState> emit) async {
    try {
      if (isLocationOk) {
        //ubicacion en true
        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'is_location_is_ok',
          1,
          event.idMove,
        );

        //seleccion del proyecto
        await db.productTransferenciaRepository.setFieldTableProductTransfer(
          event.idTransfer,
          event.productId,
          'is_selected',
          1,
          event.idMove,
        );

        // actualizamos la table de transferencias como seleccionada

        await db.transferenciaRepository.setFieldTableTransfer(
          event.idTransfer,
          'is_selected',
          1,
        );

        locationIsOk = true;
        emit(ChangeLocationIsOkState(
          locationIsOk,
        ));
      }
    } catch (e, s) {
      print("❌ Error en el ChangeLocationIsOkEvent $e ->$s");
    }
  }

  //*metodo para cargar la informacion del producto actual
  void _onFetchPorductTransfer(
      FetchPorductTransfer event, Emitter<TransferenciaState> emit) async {
    try {
      isLocationOk = true;
      isProductOk = true;
      viewQuantity = false;
      isQuantityOk = true;
      isLocationDestOk = true;
      selectedLocation = "";

      emit(FetchPorductTransferLoading());

      // traemos toda la lista de barcodes
      listOfBarcodes.clear();
      print('listOfBarcodes: ${listOfBarcodes.length}');
      currentProduct = LineasTransferenciaTrans();
      currentProduct = event.product;

      listOfBarcodes = await db.barcodesPackagesRepository.getBarcodesProduct(
        currentProduct.idTransferencia ?? 0,
        int.parse(currentProduct.productId),
        currentProduct.idMove ?? 0,
      );

      //cargamos la informacion de las variables de validacion
      locationIsOk = currentProduct.isLocationIsOk == 1 ? true : false;
      locationDestIsOk = currentProduct.locationDestIsOk == 1 ? true : false;
      productIsOk = currentProduct.productIsOk == 1 ? true : false;
      quantityIsOk = currentProduct.isQuantityIsOk == 1 ? true : false;
      quantityEdit = currentProduct.isQuantityIsOk == 1 ? true : false;
      quantitySelected = currentProduct.isProductSplit == 1
          ? 0
          : currentProduct.quantitySeparate ?? 0;

      selectedLocation = currentProduct.locationDestName ?? '';

      //llamamos los productos de esa entrada
      products();
      getPosicions();
      //cargamos la configuracion del usuario

      emit(FetchPorductTransferSuccess(currentProduct));
    } catch (e, s) {
      emit(FetchPorductTransferFailure('Error al obtener el producto'));
      print('Error en el _onFetchPorductOrder: $e, $s');
    }
  }

  void getPosicions() {
    try {
      // Usar un Set para evitar duplicados automáticamente
      Set<String> positionsSet = {};
      // Usamos un filtro para no tener que comprobar locationId en cada iteración
      for (var product in listProductsTransfer) {
        // Solo añadimos locationId si no es nulo ni vacío
        String location = product.locationName ?? '';
        if (location.isNotEmpty) {
          positionsSet.add(location);
        }
      }

      // Convertimos el Set a lista si es necesario
      positionsOrigen = positionsSet.toList();
    } catch (e, s) {
      print("❌ Error en getPosicions: $e -> $s");
    }
  }

  void products() {
    try {
      // Usamos un Set para evitar duplicados y mejorar el rendimiento de búsqueda
      Set<String> productIdsSet = {};
      // Recorremos los productos del batch
      for (var product in listProductsTransfer) {
        // Validamos que el productId no sea nulo y lo convertimos a String
        if (product.productId != null) {
          productIdsSet.add(product.productName.toString());
        }
      }
      // Asignamos el Set a la lista, si es necesario
      listOfProductsName = productIdsSet.toList();
    } catch (e, s) {
      print("❌ Error en el products $e ->$s");
    }
  }

  //*metodo para obtener los productos de una entrada por id
  void _onGetProductsToTransfer(
      GetPorductsToTransfer event, Emitter<TransferenciaState> emit) async {
    try {
      emit(GetProductsToTransferLoading());
      final response = await db.productTransferenciaRepository
          .getProductsByTrasnferId(event.idTransfer);

      listProductsTransfer = [];
      listProductsTransfer = response;
      print('listProductsTransfer: ${listProductsTransfer.length}');
      emit(GetProductsToTransferSuccess(listProductsTransfer));
    } catch (e, s) {
      print('Error en el _onGetProductsToTrasnfer: $e, $s');
    }
  }

  void _onLoadConfigurationsUserEvent(LoadConfigurationsUserTransfer event,
      Emitter<TransferenciaState> emit) async {
    try {
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

  //metodo para buscar una transferencia
  void _onSearchOrderEvent(
      SearchTransferEvent event, Emitter<TransferenciaState> emit) async {
    try {
      transferenciasDbFilters = [];
      transferenciasDbFilters = transferencias;

      final query = event.query.toLowerCase();

      if (query.isNotEmpty) {
        transferenciasDbFilters = transferenciasDbFilters
            .where((element) => element.name!.contains(query))
            .toList();
      } else {
        transferenciasDbFilters = transferencias;
      }
      emit(SearchTransferenciasSuccess(transferenciasDbFilters));
    } catch (e, s) {
      print('Error en el fetch de transferencias: $e=>$s');
    }
  }

  //*metodo para ocultar y mostrar el teclado
  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<TransferenciaState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  //metodo para obtener todas las transferencias de la base de datos

  void _onfetchTransferenciasDB(
      FetchAllTransferenciasDB event, Emitter<TransferenciaState> emit) async {
    try {
      emit(TransferenciaLoading());

      transferenciasDB.clear();
      transferenciasDbFilters.clear();
      final response = await db.transferenciaRepository.getAllTransferencias();
      if (response.isNotEmpty) {
        transferenciasDB = response;
        transferenciasDbFilters = response;
        emit(TransferenciaBDLoaded(transferenciasDB));
        add(LoadLocations());
      } else {
        emit(TransferenciaError('No se encontraron transferencias'));
      }
    } catch (e, s) {
      print('Error en el fetch de transferencias: $e=>$s');
    }
  }

  //metodo para cargar la transferencia actual
  _oncurrentTransferencia(
      CurrentTransferencia event, Emitter<TransferenciaState> emit) async {
    try {
      emit(CurrentTransferenciaLoading());
      currentTransferencia = ResultTransFerencias();

      final responseTransfer = await db.transferenciaRepository
          .getTransferenciaById(event.trasnferencia.id ?? 0);
      currentTransferencia = responseTransfer ?? ResultTransFerencias();

      print("-----------------");
      print(currentTransferencia.toMap());
      print("-----------------");
      emit(CurrentTransferenciaLoaded());
    } catch (e, s) {
      print('Error en el fetch de transferencias: $e=>$s');
    }
  }

  //metodo para traer todas las transferencias
  _onfetchTransferencias(
      FetchAllTransferencias event, Emitter<TransferenciaState> emit) async {
    try {
      emit(TransferenciaLoading());
      transferencias.clear();
      final response =
          await _transferenciasRepository.fetAllTransferencias(true);
      if (response.isNotEmpty) {
        await db.transferenciaRepository.insertEntrada(response);

        // Convertir el mapa en una lista de productos únicos con cantidades sumadas
        List<LineasTransferenciaTrans> productsToInsert =
            response.expand((batch) => batch.lineasTransferencia!).toList();
        //Convertir el mapa en una lista los productos ya enviados
        List<LineasTransferenciaTrans> productsSedToInsert = response
            .expand((batch) => batch.lineasTransferenciaEnviadas!)
            .toList();
        //Convertir el mapa en una lista los barcodes unicos de cada producto
        List<Barcodes> barcodesToInsert = productsToInsert
            .expand((product) => product.otherBarcodes!)
            .toList();
        //convertir el mapap en una lsita de los otros barcodes de cada producto
        List<Barcodes> otherBarcodesToInsert = productsToInsert
            .expand((product) => product.productPacking!)
            .toList();

        print('trasnfer productsToInsert: ${productsToInsert.length}');
        print('trasnfer productsSedToInsert: ${productsSedToInsert.length}');
        print('trasnfer barcodesToInsert: ${barcodesToInsert.length}');
        print(
            'trasnfer otherBarcodesToInsert: ${otherBarcodesToInsert.length}');

        // Enviar la lista agrupada a insertBatchProducts
        await db.productTransferenciaRepository
            .insertarProductoEntrada(productsToInsert);
        //productos de la transferencia enviados
        await db.productTransferenciaRepository
            .insertarProductoEntrada(productsSedToInsert);

        // Enviar la lista agrupada de barcodes de un producto para packing
        await db.barcodesPackagesRepository
            .insertOrUpdateBarcodes(barcodesToInsert);
        // Enviar la lista agrupada de otros barcodes de un producto para packing
        await db.barcodesPackagesRepository
            .insertOrUpdateBarcodes(otherBarcodesToInsert);

        transferencias = response;
        emit(TransferenciaLoaded(transferencias));
      } else {
        emit(TransferenciaError('No se encontraron transferencias'));
      }
    } catch (e, s) {
      print('Error en el fetch de transferencias: $e=>$s');
    }
  }
}
