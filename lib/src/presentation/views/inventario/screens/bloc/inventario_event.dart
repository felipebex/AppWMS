part of 'inventario_bloc.dart';

@immutable
sealed class InventarioEvent {}

class GetLocationsEvent extends InventarioEvent {}

class SearchLocationEvent extends InventarioEvent {
  final String query;

  SearchLocationEvent(
    this.query,
  );
}
class SearchProductEvent extends InventarioEvent {
  final String query;

  SearchProductEvent(
    this.query,
  );
}

class ShowKeyboardEvent extends InventarioEvent {
  final bool showKeyboard;

  ShowKeyboardEvent(this.showKeyboard);
}

class ClearScannedValueEvent extends InventarioEvent {
  final String scan;
  ClearScannedValueEvent(this.scan);
}

class UpdateScannedValueEvent extends InventarioEvent {
  final String scannedValue;
  final String scan;
  UpdateScannedValueEvent(this.scannedValue, this.scan);
}

class ValidateFieldsEvent extends InventarioEvent {
  final String field;
  final bool isOk;
  ValidateFieldsEvent({required this.field, required this.isOk});
}

class ChangeLocationIsOkEvent extends InventarioEvent {
  final ResultUbicaciones locationSelect;
  ChangeLocationIsOkEvent(
    this.locationSelect,
  );
}
class ChangeProductIsOkEvent extends InventarioEvent {
  final Product productSelect;
  ChangeProductIsOkEvent(
    this.productSelect,
  );
}



class GetProductsEvent extends InventarioEvent{
  final int warehouseId;
  GetProductsEvent(this.warehouseId);
}


class GetProductsForDB extends InventarioEvent{
}


class GetProductsByLocationEvent extends InventarioEvent{
  final int locationId;
  GetProductsByLocationEvent(this.locationId);
}

class CleanFieldsEent extends InventarioEvent{}