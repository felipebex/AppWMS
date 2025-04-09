part of 'transfer_externa_bloc.dart';

@immutable
sealed class TransferExternaEvent {}

class ClearScannedValueEvent extends TransferExternaEvent {
  final String scan;
  ClearScannedValueEvent(this.scan);
}

class UpdateScannedValueEvent extends TransferExternaEvent {
  final String scannedValue;
  final String scan;
  UpdateScannedValueEvent(this.scannedValue, this.scan);
}

class ShowKeyboardTransExtEvent extends TransferExternaEvent {
  final bool showKeyboard;

  ShowKeyboardTransExtEvent(this.showKeyboard);
}


class GetLocationsEvent extends TransferExternaEvent {}




class ValidateFieldsEvent extends TransferExternaEvent {
  final String field;
  final bool isOk;
  ValidateFieldsEvent({required this.field, required this.isOk});
}

class ChangeLocationIsOkEvent extends TransferExternaEvent {
  final ResultUbicaciones locationSelect;
  ChangeLocationIsOkEvent(
    this.locationSelect,
  );
}



class GetProductsByLocationEvent extends TransferExternaEvent {
  final int locationId;
  GetProductsByLocationEvent(this.locationId);
}


class ChangeProductIsOkEvent extends TransferExternaEvent {
  final Product productSelect;
  ChangeProductIsOkEvent(
    this.productSelect,
  );
}


class ChangeIsOkQuantity extends TransferExternaEvent {
  final bool isQuantity;
  ChangeIsOkQuantity(
    this.isQuantity,
  );
}


class SearchLocationEvent extends TransferExternaEvent {
  final String query;

  SearchLocationEvent(
    this.query,
  );
}

class SearchProductEvent extends TransferExternaEvent {
  final String query;

  SearchProductEvent(
    this.query,
  );
}