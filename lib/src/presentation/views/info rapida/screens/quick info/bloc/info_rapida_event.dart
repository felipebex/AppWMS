part of 'info_rapida_bloc.dart';

@immutable
sealed class InfoRapidaEvent {}

class GetInfoRapida extends InfoRapidaEvent {
  final String barcode;
  final bool isManual;
  final bool isProduct;
  GetInfoRapida(this.barcode, this.isManual, this.isProduct );
}

class UpdateScannedValueEvent extends InfoRapidaEvent {
  final String scannedValue;
  UpdateScannedValueEvent(this.scannedValue);
}

class ClearScannedValueEvent extends InfoRapidaEvent {
  ClearScannedValueEvent();
}

class SearchLocationEvent extends InfoRapidaEvent {
  final String query;

  SearchLocationEvent(
    this.query,
  );
}

class ShowKeyboardEvent extends InfoRapidaEvent {
  final bool showKeyboard;
  ShowKeyboardEvent(this.showKeyboard);
}


class GetListLocationsEvent extends InfoRapidaEvent {
  GetListLocationsEvent();
}

class SearchProductEvent extends InfoRapidaEvent {
  final String query;

  SearchProductEvent(
    this.query,
  );
}

class GetProductsList extends InfoRapidaEvent {
  GetProductsList();
}