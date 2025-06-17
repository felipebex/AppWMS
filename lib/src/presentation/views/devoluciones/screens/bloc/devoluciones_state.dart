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

class GetProductExists extends DevolucionesState {
  final Product product;
  GetProductExists(this.product);
}

class AddProductSuccess extends DevolucionesState {
  final ProductDevolucion product;
  AddProductSuccess(this.product);
}

class AddProductFailure extends DevolucionesState {
  final String error;
  AddProductFailure(this.error);
}

class RemoveProductSuccess extends DevolucionesState {}

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

class UpdateProductInfoState extends DevolucionesState {}

class LoadTercerosFailure extends DevolucionesState {
  final String error;
  LoadTercerosFailure(this.error);
}

class LoadTercerosSuccess extends DevolucionesState {
  final List<Terceros> terceros;
  LoadTercerosSuccess(this.terceros);
}

class ShowKeyboardState extends DevolucionesState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}

class SelectTerceroState extends DevolucionesState {
  final Terceros tercero;
  SelectTerceroState(this.tercero);
}

class SearchLoading extends DevolucionesState {}

class SearchFailure extends DevolucionesState {
  final String error;
  SearchFailure(this.error);
}

class SearchTerceroSuccess extends DevolucionesState {
  final List<Terceros> terceros;
  SearchTerceroSuccess(this.terceros);
}

class FilterTercerosLoading extends DevolucionesState {}

class FilterTercerosSuccess extends DevolucionesState {
  final List<Terceros> tercerosFilters;
  FilterTercerosSuccess(this.tercerosFilters);
}

class FilterTercerosFailure extends DevolucionesState {
  final String error;
  FilterTercerosFailure(this.error);
}

class LoadingLocationsState extends DevolucionesState {}

class LoadLocationsSuccessState extends DevolucionesState {
  final List<ResultUbicaciones> locations;
  LoadLocationsSuccessState(this.locations);
}

class LoadLocationsFailureState extends DevolucionesState {
  final String error;
  LoadLocationsFailureState(this.error);
}

class SearchLocationSuccess extends DevolucionesState {
  final List<ResultUbicaciones> locations;
  SearchLocationSuccess(this.locations);
}

class FilterLocationsLoading extends DevolucionesState {}

class FilterLocationsSuccess extends DevolucionesState {
  final List<ResultUbicaciones> locationsFilters;
  FilterLocationsSuccess(this.locationsFilters);
}

class FilterLocationsFailure extends DevolucionesState {
  final String error;
  FilterLocationsFailure(this.error);
}

class SelectLocationState extends DevolucionesState {
  final ResultUbicaciones location;
  SelectLocationState(this.location);
}
