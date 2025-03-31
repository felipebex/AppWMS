import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/data/info_rapida_repository.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/info_rapida_model.dart';

part 'info_rapida_event.dart';
part 'info_rapida_state.dart';

class InfoRapidaBloc extends Bloc<InfoRapidaEvent, InfoRapidaState> {
  final InfoRapidaRepository _infoRapidaRepository = InfoRapidaRepository();

  InfoRapidaResult infoRapidaResult = InfoRapidaResult();

  String scannedValue1 = '';

  InfoRapidaBloc() : super(InfoRapidaInitial()) {
    on<InfoRapidaEvent>((event, emit) {});

    //*evento para actualizar el valor del scan
    on<UpdateScannedValueEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValueEvent>(_onClearScannedValueEvent);

    on<GetInfoRapida>(_onGetInfoRapida);
  }


  void _onGetInfoRapida(
      GetInfoRapida event, Emitter<InfoRapidaState> emit) async {
    emit(InfoRapidaLoading());
    try {
      infoRapidaResult = InfoRapidaResult();
      InfoRapida infoRapida =
          await _infoRapidaRepository.getInfoQuick(false, event.barcode);
      if (infoRapida.result?.code == 200) {
        infoRapidaResult = infoRapida.result!;
        emit(InfoRapidaLoaded(infoRapidaResult, infoRapida.result!.type!));
      } else {
        emit(InfoRapidaError());
      }
      add(ClearScannedValueEvent());
    } catch (e) {
      emit(InfoRapidaError());
    }
  }

  void _onUpdateScannedValueEvent(
      UpdateScannedValueEvent event, Emitter<InfoRapidaState> emit) {
    scannedValue1 += event.scannedValue;
    emit(UpdateScannedValueState(scannedValue1));
  }

  void _onClearScannedValueEvent(
      ClearScannedValueEvent event, Emitter<InfoRapidaState> emit) {
    scannedValue1 = '';
    emit(ClearScannedValueState());
  }
}
