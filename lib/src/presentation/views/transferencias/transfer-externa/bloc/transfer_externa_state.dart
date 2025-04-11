part of 'transfer_externa_bloc.dart';

@immutable
sealed class TransferExternaState {}

final class TransferExternaInitial extends TransferExternaState {}

class ClearScannedValueState extends TransferExternaState {}

class UpdateScannedValueState extends TransferExternaState {
  final String scannedValue;
  final String scan;
  UpdateScannedValueState(this.scannedValue, this.scan);
}

class ShowKeyboardState extends TransferExternaState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}

class LoadLocationsLoading extends TransferExternaState {}

class LoadLocationsSuccess extends TransferExternaState {
  final List<ResultUbicaciones> locations;
  LoadLocationsSuccess(this.locations);
}

class LoadLocationsFailure extends TransferExternaState {
  final String error;
  LoadLocationsFailure(this.error);
}

//*estado para validar campos
class ValidateFieldsStateSuccess extends TransferExternaState {
  final bool isOk;
  ValidateFieldsStateSuccess(this.isOk);
}

class ValidateFieldsStateError extends TransferExternaState {
  final String msg;
  ValidateFieldsStateError(this.msg);
}

class ChangeLocationIsOkState extends TransferExternaState {
  final bool isOk;
  ChangeLocationIsOkState(this.isOk);
}

class GetProductsLoading extends TransferExternaState {}

class GetProductsSuccessByLocation extends TransferExternaState {
  // final List<Product> products;
  // GetProductsSuccessByLocation(this.products);
}

class GetProductsFailure extends TransferExternaState {
  final String error;
  GetProductsFailure(this.error);
}



class GetProductsFailureByLocation extends TransferExternaState {
  final String error;
  GetProductsFailureByLocation(this.error);
}

class ChangeProductIsOkState extends TransferExternaState {
  final bool isOk;
  ChangeProductIsOkState(this.isOk);
}


class ChangeQuantityIsOkState extends TransferExternaState {
  final bool isOk;
  ChangeQuantityIsOkState(this.isOk);
}



class SearchLoading extends TransferExternaState {}

class SearchLocationSuccess extends TransferExternaState {
  final List<ResultUbicaciones> locations;
  SearchLocationSuccess(this.locations);
}

class SearchProductSuccess extends TransferExternaState {
  // final List<Product> products;
  // SearchProductSuccess(this.products);
}



class SearchFailure extends TransferExternaState {
  final String error;
  SearchFailure(this.error);
}
