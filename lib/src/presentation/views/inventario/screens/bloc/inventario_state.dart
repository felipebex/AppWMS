part of 'inventario_bloc.dart';

@immutable
sealed class InventarioState {}

final class InventarioInitial extends InventarioState {}

class LoadLocationsLoading extends InventarioState {}

class LoadLocationsSuccess extends InventarioState {
  final List<ResultUbicaciones> locations;
  LoadLocationsSuccess(this.locations);
}

class LoadLocationsFailure extends InventarioState {
  final String error;
  LoadLocationsFailure(this.error);
}

//estados para buscar una ubicacion

class SearchLoading extends InventarioState {}

class SearchLocationSuccess extends InventarioState {
  final List<ResultUbicaciones> locations;
  SearchLocationSuccess(this.locations);
}

class SearchProductSuccess extends InventarioState {
  final List<Product> products;
  SearchProductSuccess(this.products);
}

class SearchFailure extends InventarioState {
  final String error;
  SearchFailure(this.error);
}

class ShowKeyboardState extends InventarioState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}

class ClearScannedValueState extends InventarioState {}

class UpdateScannedValueState extends InventarioState {
  final String scannedValue;
  final String scan;
  UpdateScannedValueState(this.scannedValue, this.scan);
}

//*estado para validar campos
class ValidateFieldsStateSuccess extends InventarioState {
  final bool isOk;
  ValidateFieldsStateSuccess(this.isOk);
}

class ValidateFieldsStateError extends InventarioState {
  final String msg;
  ValidateFieldsStateError(this.msg);
}

class ChangeLocationIsOkState extends InventarioState {
  final bool isOk;
  ChangeLocationIsOkState(this.isOk);
}

class GetProductsLoading extends InventarioState {}

class GetProductsSuccess extends InventarioState {
  final List<Product> products;
  GetProductsSuccess(this.products);
}

class GetProductsFailure extends InventarioState {
  final String error;
  GetProductsFailure(this.error);
}


class ChangeProductIsOkState extends InventarioState {
  final bool isOk;
  ChangeProductIsOkState(this.isOk);
}


class CleanFieldsState  extends InventarioState {}