part of 'info_rapida_bloc.dart';

@immutable
sealed class InfoRapidaState {}

final class InfoRapidaInitial extends InfoRapidaState {}

class InfoRapidaLoading extends InfoRapidaState {}

class InfoRapidaLoaded extends InfoRapidaState {
  final InfoRapidaResult infoRapidaResult;
  final String message;

  InfoRapidaLoaded(this.infoRapidaResult, this.message);
}

class InfoRapidaError extends InfoRapidaState {}

//*estado para actualizar el valor escaneado

class UpdateScannedValueState extends InfoRapidaState {
  final String scannedValue;
  UpdateScannedValueState(this.scannedValue);
}

class ClearScannedValueState extends InfoRapidaState {}

class SearchLoading extends InfoRapidaState {}

class SearchFailure extends InfoRapidaState {
  final String error;
  SearchFailure(this.error);
}

class SearchLocationSuccess extends InfoRapidaState {
  final List<ResultUbicaciones> locations;
  SearchLocationSuccess(this.locations);
}


class ShowKeyboardState extends InfoRapidaState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}




class LoadLocationsLoading extends InfoRapidaState {}

class LoadLocationsSuccess extends InfoRapidaState {
  final List<ResultUbicaciones> locations;
  LoadLocationsSuccess(this.locations);
}

class LoadLocationsFailure extends InfoRapidaState {
  final String error;
  LoadLocationsFailure(this.error);
}


class SearchProductSuccess extends InfoRapidaState {
  final List<Product> products;
  SearchProductSuccess(this.products);
}



class GetProductsLoading extends InfoRapidaState {}

class GetProductsSuccess extends InfoRapidaState {
  final List<Product> products;
  GetProductsSuccess(this.products);
}


class GetProductsFailure extends InfoRapidaState {
  final String error;
  GetProductsFailure(this.error);
}



class FilterUbicacionesLoading extends InfoRapidaState {}

class FilterUbicacionesFailure extends InfoRapidaState {
  final String error;
  FilterUbicacionesFailure(this.error);
}

class FilterUbicacionesSuccess extends InfoRapidaState {
  final List<ResultUbicaciones> locations;
  FilterUbicacionesSuccess(this.locations);
}