part of 'info_rapida_bloc.dart';

@immutable
sealed class InfoRapidaEvent {}

class GetInfoRapida extends InfoRapidaEvent {
  final String barcode;
  GetInfoRapida(this.barcode);
}

class UpdateScannedValueEvent extends InfoRapidaEvent {
  final String scannedValue;
  UpdateScannedValueEvent(this.scannedValue);
}


class ClearScannedValueEvent extends InfoRapidaEvent {
  ClearScannedValueEvent();
}

