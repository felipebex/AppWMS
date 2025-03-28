part of 'info_rapida_bloc.dart';

@immutable
sealed class InfoRapidaState {}

final class InfoRapidaInitial extends InfoRapidaState {}


class InfoRapidaLoading extends InfoRapidaState {}


class InfoRapidaLoaded extends InfoRapidaState {
  final InfoRapidaResult infoRapidaResult;
  final String message;

  InfoRapidaLoaded(this.infoRapidaResult, this.message);
}

class InfoRapidaError extends InfoRapidaState {}





//*estado para actualizar el valor escaneado

class UpdateScannedValueState extends InfoRapidaState {
  final String scannedValue;
  UpdateScannedValueState(this.scannedValue);
}

class ClearScannedValueState extends InfoRapidaState {}