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
class SearchLotevent extends InventarioEvent {
  final String query;

  SearchLotevent(
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

class ChangeIsOkQuantity extends InventarioEvent {
  final bool isQuantity;
  ChangeIsOkQuantity(
    this.isQuantity,
  );
}

class GetProductsEvent extends InventarioEvent {
}

class GetProductsForDB extends InventarioEvent {}

// class GetProductsByLocationEvent extends InventarioEvent {
//   final int locationId;
//   GetProductsByLocationEvent(this.locationId);
// }

class CleanFieldsEent extends InventarioEvent {}

class GetLotesProduct extends InventarioEvent {}

class SelectecLoteEvent extends InventarioEvent {
  final LotesProduct lote;
  SelectecLoteEvent(this.lote);
}

class ShowQuantityEvent extends InventarioEvent {
  final bool showQuantity;
  ShowQuantityEvent(this.showQuantity);
}

class FetchBarcodesProductEvent extends InventarioEvent {}

class AddQuantitySeparate extends InventarioEvent {
  final int quantity;
  final bool isOk;
  AddQuantitySeparate(this.quantity, this.isOk);
}

class ChangeQuantitySeparate extends InventarioEvent {
  final int quantity;
  ChangeQuantitySeparate(this.quantity,);
}



class SendProductInventarioEnvet extends InventarioEvent{

  final int cantidad;

SendProductInventarioEnvet(this.cantidad);
  
}


class CreateLoteProduct extends InventarioEvent {
 
  final String nameLote;
  final String fechaCaducidad;
  CreateLoteProduct( this.nameLote, this.fechaCaducidad);
}



class LoadConfigurationsUserInventory extends InventarioEvent {}