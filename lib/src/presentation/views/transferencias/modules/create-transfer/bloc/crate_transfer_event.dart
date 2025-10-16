part of 'crate_transfer_bloc.dart';

@immutable
sealed class CreateTransferEvent {}

class UpdateScannedValueTransferEvent extends CreateTransferEvent {
  final String scannedValue;
  final String scan;
  UpdateScannedValueTransferEvent(this.scannedValue, this.scan);
}

class ClearScannedValueTransferEvent extends CreateTransferEvent {
  final String scan;
  ClearScannedValueTransferEvent(this.scan);
}

class LoadConfigurationsUserCreateTransferEvent extends CreateTransferEvent {
  LoadConfigurationsUserCreateTransferEvent();
}

class ValidateFieldsEvent extends CreateTransferEvent {
  final String field;
  final bool isOk;
  ValidateFieldsEvent({required this.field, required this.isOk});
}

class GetLocationsEvent extends CreateTransferEvent {}

class ShowKeyboardCreateTransferEvent extends CreateTransferEvent {
  final bool showKeyboard;

  ShowKeyboardCreateTransferEvent(this.showKeyboard);
}

class GetProductsFromDBEvent extends CreateTransferEvent {}

class SearchLocationEvent extends CreateTransferEvent {
  final String query;

  SearchLocationEvent(
    this.query,
  );
}

class SearchProductEvent extends CreateTransferEvent {
  final String query;

  SearchProductEvent(
    this.query,
  );
}

class ChangeLocationIsOkEvent extends CreateTransferEvent {
  final ResultUbicaciones locationSelect;
  ChangeLocationIsOkEvent(this.locationSelect);
}

class ChangeProductIsOkEvent extends CreateTransferEvent {
  final Product productSelect;
  final bool productIsOk;

  ChangeProductIsOkEvent(this.productSelect, this.productIsOk);
}

class CreateLoteProduct extends CreateTransferEvent {
  final String nameLote;
  final String fechaCaducidad;
  CreateLoteProduct(this.nameLote, this.fechaCaducidad);
}

class SearchLotevent extends CreateTransferEvent {
  final String query;

  SearchLotevent(
    this.query,
  );
}

class GetLotesProduct extends CreateTransferEvent {
  final bool isManual;
  final int idLote;
  GetLotesProduct({this.isManual = false, this.idLote = 0});
}

class SelectecLoteEvent extends CreateTransferEvent {
  final LotesProduct lote;
  SelectecLoteEvent(this.lote);
}

class ChangeIsOkQuantity extends CreateTransferEvent {
  final bool isOk;
  final int productId;
  ChangeIsOkQuantity(
    this.isOk,
    this.productId,
  );
}
