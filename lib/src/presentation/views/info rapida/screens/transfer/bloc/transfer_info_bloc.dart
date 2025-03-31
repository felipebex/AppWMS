import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/data/info_rapida_repository.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/transfer_info_request.dart';
import 'package:wms_app/src/utils/formats.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'transfer_info_event.dart';
part 'transfer_info_state.dart';

class TransferInfoBloc extends Bloc<TransferInfoEvent, TransferInfoState> {
  bool isLocationDestOk = true;
  bool locationDestIsOk = false;

  bool quantityIsOk = true;
  int quantitySelected = 0;
  String scannedValue1 = '';

  String selectedLocation = '';
  int selectLocationDestId = 0;
  //*valores de scanvalue
  final InfoRapidaRepository repository = InfoRapidaRepository();

  DataBaseSqlite db = DataBaseSqlite();

  //*lista de ubicaciones
  List<ResultUbicaciones> ubicaciones = [];

  TransferInfoBloc() : super(TransferInfoInitial()) {
    on<TransferInfoEvent>((event, emit) {
      // TODO: implement event handler
    });

    //*evento para actualizar el valor del scan
    on<UpdateScannedValueEventTransfer>(_onUpdateScannedValueEvent);
    on<ClearScannedValueEventTransfer>(_onClearScannedValueEvent);
    //*metodo para cargar las ubicaciones
    on<LoadLocationsTransfer>(_onLoadLocations);
    on<ValidateFieldsEventTransfer>(_onValidateFields);

    on<ChangeLocationDestIsOkEventTransfer>(_onChangeLocationDestIsOkEvent);
    on<SendTransferInfo>(_onSetQuantity);
    add(LoadLocationsTransfer());
  }

  void _onSetQuantity(
      SendTransferInfo event, Emitter<TransferInfoState> emit) async {
    try {
      emit(SendTransferInfoLoadingTransfer());
      quantitySelected = event.quantity;

      final userid = await PrefUtils.getUserId();

      //calculamos la fecha de transaccion
      DateTime fechaTransaccion = DateTime.now();
      String fechaFormateada = formatoFecha(fechaTransaccion);

      final responseSend = await repository.sendProductTransferInfo(
          TransferInfoRequest(
            idAlmacen: event.request.idAlmacen,
            idMove: event.request.idMove,
            idProducto: event.request.idProducto,
            idLote: event.request.idLote,
            idUbicacionOrigen: event.request.idUbicacionOrigen,
            idUbicacionDestino: selectLocationDestId,
            cantidadEnviada: quantitySelected,
            idOperario: userid,
            timeLine: event.request.timeLine,
            fechaTransaccion: fechaFormateada,
            observacion: event.request.observacion,
          ),
          true);

      if (responseSend.result?.code == 200) {
        //limpiamos los valores
        clearFields();

        emit(SendTransferInfoSuccess(responseSend.result?.msg ?? ""));
      } else {
        emit(SendTransferInfoFailureTransfer(
            'Error al enviar la transferencia'));
      }
    } catch (e, s) {
      print("❌ Error en el SetQuantity $e ->$s");
    }
  }

  void clearFields() {
    scannedValue1 = '';
    quantitySelected = 0;
    selectedLocation = '';
    selectLocationDestId = 0;
    locationDestIsOk = false;
  }

  void _onChangeLocationDestIsOkEvent(ChangeLocationDestIsOkEventTransfer event,
      Emitter<TransferInfoState> emit) async {
    try {
      locationDestIsOk = event.locationDestIsOk;
      selectedLocation = event.location.name ?? "";
      selectLocationDestId = event.location.id ?? 0;

      emit(ChangeLocationDestIsOkStateTransfer(
        locationDestIsOk,
      ));
    } catch (e, s) {
      print("❌ Error en el ChangeLocationDestIsOkEvent $e ->$s");
    }
  }

  //*evento para actualizar el valor del scan
  void _onUpdateScannedValueEvent(
      UpdateScannedValueEventTransfer event, Emitter<TransferInfoState> emit) {
    try {
      switch (event.scan) {
        case 'muelle':
          scannedValue1 += event.scannedValue;
          emit(UpdateScannedValueStateTransfer(scannedValue1, event.scan));
          break;
        default:
          print('Scan type not recognized: ${event.scan}');
      }
    } catch (e, s) {
      print("❌ Error en _onUpdateScannedValueEvent: $e, $s");
    }
  }

//*evento para limpiar el valor del scan
  void _onClearScannedValueEvent(
      ClearScannedValueEventTransfer event, Emitter<TransferInfoState> emit) {
    try {
      switch (event.scan) {
        case 'muelle':
          scannedValue1 = '';
          emit(ClearScannedValueStateTransfer());
          break;
        default:
          print('Scan type not recognized: ${event.scan}');
      }
      emit(ClearScannedValueStateTransfer());
    } catch (e, s) {
      print("❌ Error en _onClearScannedValueEvent: $e, $s");
    }
  }

  void _onLoadLocations(
      LoadLocationsTransfer event, Emitter<TransferInfoState> emit) async {
    try {
      emit(LoadLocationsLoadingTransfer());
      final response = await db.ubicacionesRepository.getAllUbicaciones();
      if (response.isNotEmpty) {
        ubicaciones.clear();
        ubicaciones = response;
        print('ubicaciones length: ${ubicaciones.length}');
        emit(LoadLocationsSuccessTransfer(ubicaciones));
      } else {
        emit(LoadLocationsFailureTransfer('No se encontraron ubicaciones'));
      }
    } catch (e, s) {
      emit(LoadLocationsFailureTransfer('Error al cargar las ubicaciones'));
      print('Error en el fetch de ubicaciones: $e=>$s');
    }
  }

  void _onValidateFields(
      ValidateFieldsEventTransfer event, Emitter<TransferInfoState> emit) {
    try {
      switch (event.field) {
        case 'muelle':
          isLocationDestOk = event.isOk;
          break;
      }
      emit(ValidateFieldsStateSuccessTransfer(event.isOk));
    } catch (e, s) {
      emit(ValidateFieldsStateErrorTransfer('Error al validar campos'));
      print("❌ Error en el ValidateFieldsEvent $e ->$s");
    }
  }
}
