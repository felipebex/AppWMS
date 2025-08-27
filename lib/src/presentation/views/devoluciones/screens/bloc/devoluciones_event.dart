part of 'devoluciones_bloc.dart';

@immutable
sealed class DevolucionesEvent {}

class UpdateScannedValueEvent extends DevolucionesEvent {
  final String scannedValue;
  final String scan;
  UpdateScannedValueEvent(this.scannedValue, this.scan);
}

class ClearScannedValueEvent extends DevolucionesEvent {
  final String scan;
  ClearScannedValueEvent(this.scan);
}

class GetProductEvent extends DevolucionesEvent {
  final String barcode;
  final bool isManual;
  final int idProduct;
  GetProductEvent(this.barcode, this.isManual, [this.idProduct = 0]);
}

class GetProductsList extends DevolucionesEvent {
  GetProductsList();
}

class Addproduct extends DevolucionesEvent {
  final ProductDevolucion product;
  Addproduct(this.product);
}

class RemoveProduct extends DevolucionesEvent {
  final ProductDevolucion product;
  RemoveProduct(this.product);
}

class SetQuantityEvent extends DevolucionesEvent {
  final dynamic quantity;
  SetQuantityEvent(this.quantity);
}

class SetLoteEvent extends DevolucionesEvent {
  final Product product;
  final String loteName;
  SetLoteEvent(this.product, this.loteName);
}

class ShowQuantityEvent extends DevolucionesEvent {
  final bool showQuantity;
  ShowQuantityEvent(this.showQuantity);
}

class LoadCurrentProductEvent extends DevolucionesEvent {
  final Product product;
  LoadCurrentProductEvent(this.product);
}

class UpdateProductInfoEvent extends DevolucionesEvent {}

class LoadTercerosEvent extends DevolucionesEvent {}

class ShowKeyboardEvent extends DevolucionesEvent {
  final bool showKeyboard;
  ShowKeyboardEvent(this.showKeyboard);
}

class SelectTerceroEvent extends DevolucionesEvent {
  final Terceros tercero;
  SelectTerceroEvent(this.tercero);
}

class SelectLocationEvent extends DevolucionesEvent {
  final ResultUbicaciones location;
  SelectLocationEvent(this.location);
}

class SearchTerceroEvent extends DevolucionesEvent {
  final String query;
  SearchTerceroEvent(this.query);
}

// class FilterTercerosEvent extends DevolucionesEvent {
//   final String almacen;
//   FilterTercerosEvent(this.almacen);
// }

class FilterUbicacionesEvent extends DevolucionesEvent {
  final String almacen;
  FilterUbicacionesEvent(this.almacen);
}

class LoadLocationsEvent extends DevolucionesEvent {}

class SearchLocationEvent extends DevolucionesEvent {
  final String query;

  SearchLocationEvent(
    this.query,
  );
}

class SelectecLoteEvent extends DevolucionesEvent {
  final LotesProduct lote;
  SelectecLoteEvent(this.lote);
}

class SearchLotevent extends DevolucionesEvent {
  final String query;

  SearchLotevent(
    this.query,
  );
}

class CreateLoteProduct extends DevolucionesEvent {
  final String nameLote;
  final String fechaCaducidad;
  CreateLoteProduct(this.nameLote, this.fechaCaducidad);
}

class GetLotesProduct extends DevolucionesEvent {}

class ClearValueEvent extends DevolucionesEvent {}

class SearchProductEvent extends DevolucionesEvent {
  final String query;

  SearchProductEvent(
    this.query,
  );
}

class SendDevolucionEvent extends DevolucionesEvent {}

class ValidateFieldsEvent extends DevolucionesEvent {
  final String field;
  final bool isOk;
  ValidateFieldsEvent(this.field, this.isOk);
}

class ChangeStateIsDialogVisibleEvent extends DevolucionesEvent {
  final bool isVisible;
  ChangeStateIsDialogVisibleEvent(this.isVisible);
}

class LoadConfigurationsUser extends DevolucionesEvent {
  LoadConfigurationsUser();
}

class FetchAllBarcodesInventarioEvent extends DevolucionesEvent {
  FetchAllBarcodesInventarioEvent();
}
