part of 'devoluciones_bloc.dart';

@immutable
sealed class DevolucionesState {}

final class DevolucionesInitial extends DevolucionesState {}

//*estado para actualizar el valor escaneado

class UpdateScannedValueState extends DevolucionesState {
  final String scannedValue;
  final String scan;

  UpdateScannedValueState(this.scannedValue, this.scan);
}

class ClearScannedValueState extends DevolucionesState {}

class GetProductLoading extends DevolucionesState {}

class GetProductsLoading extends DevolucionesState {}

class GetProductsSuccess extends DevolucionesState {
  final List<Product> products;
  GetProductsSuccess(this.products);
}

class GetProductsFailure extends DevolucionesState {
  final String error;
  GetProductsFailure(this.error);
}

class GetProductSuccess extends DevolucionesState {
  final Product product;
  GetProductSuccess(this.product);
}

class GetProductFailure extends DevolucionesState {
  final String error;
  GetProductFailure(this.error);
}

class AddProductSuccess extends DevolucionesState {
  final ProductDevolucion product;
  AddProductSuccess(this.product);
}

class AddProductFailure extends DevolucionesState {
  final String error;
  AddProductFailure(this.error);
}

class RemoveProductSuccess extends DevolucionesState {
}

class RemoveProductFailure extends DevolucionesState {
  final String error;
  RemoveProductFailure(this.error);
}

class SetQuantityState extends DevolucionesState {}

class ShowQuantityState extends DevolucionesState {
  final bool showQuantity;
  ShowQuantityState(this.showQuantity);
}


class LoadCurrentProductState extends DevolucionesState {
  final Product product;
  LoadCurrentProductState(this.product);
}

class UpdateProductInfoState extends DevolucionesState {
}