part of 'transferencia_bloc.dart';

@immutable
sealed class TransferenciaState {}

final class TransferenciaInitial extends TransferenciaState {}

final class TransferenciaLoading extends TransferenciaState {}
final class TransferenciaLoadingBD extends TransferenciaState {}

final class TransferenciaLoaded extends TransferenciaState {
  final List<ResultTransFerencias> transferencias;
  TransferenciaLoaded(this.transferencias);
}

final class TransferenciaBDLoaded extends TransferenciaState {
  final List<ResultTransFerencias> transferencias;
  TransferenciaBDLoaded(this.transferencias);
}

final class TransferenciaError extends TransferenciaState {
  final String message;
  TransferenciaError(this.message);
}

final class TransferenciaErrorBD extends TransferenciaState {
  final String message;
  TransferenciaErrorBD(this.message);
}

final class CurrentTransferenciaLoaded extends TransferenciaState {}

final class CurrentTransferenciaError extends TransferenciaState {
  final String message;
  CurrentTransferenciaError(this.message);
}

final class CurrentTransferenciaLoading extends TransferenciaState {}

class SearchTransferenciasSuccess extends TransferenciaState {
  final List<ResultTransFerencias> transferencias;
  SearchTransferenciasSuccess(this.transferencias);
}

class ShowKeyboardState extends TransferenciaState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}

class ConfigurationLoadedOrder extends TransferenciaState {
  final Configurations configurations;

  ConfigurationLoadedOrder(this.configurations);
}

class ConfigurationErrorOrder extends TransferenciaState {
  final String error;

  ConfigurationErrorOrder(this.error);
}

//metodo para obtener los productos de una entrada
class GetProductsToTransferLoading extends TransferenciaState {}

class GetProductsToTransferSuccess extends TransferenciaState {
  final List<LineasTransferenciaTrans> productos;
  GetProductsToTransferSuccess(this.productos);
}

class GetProductsToTransferFailure extends TransferenciaState {
  final String error;
  GetProductsToTransferFailure(this.error);
}

class FetchPorductTransferLoading extends TransferenciaState {}

class FetchPorductTransferSuccess extends TransferenciaState {
  final LineasTransferenciaTrans producto;
  FetchPorductTransferSuccess(this.producto);
}

class FetchPorductTransferFailure extends TransferenciaState {
  final String error;
  FetchPorductTransferFailure(this.error);
}

//*estado para validar campos
class ValidateFieldsStateSuccess extends TransferenciaState {
  final bool isOk;
  ValidateFieldsStateSuccess(this.isOk);
}

class ValidateFieldsStateError extends TransferenciaState {
  final String msg;
  ValidateFieldsStateError(this.msg);
}

class ChangeQuantityIsOkState extends TransferenciaState {
  final bool isOk;
  ChangeQuantityIsOkState(this.isOk);
}

class ChangeLocationDestIsOkState extends TransferenciaState {
  final bool isOk;
  ChangeLocationDestIsOkState(this.isOk);
}

class ChangeProductIsOkState extends TransferenciaState {
  final bool isOk;
  ChangeProductIsOkState(this.isOk);
}

class ChangeLocationIsOkState extends TransferenciaState {
  final bool isOk;
  ChangeLocationIsOkState(this.isOk);
}

//*estado para actualizar el valor escaneado

class UpdateScannedValueState extends TransferenciaState {
  final String scannedValue;
  final String scan;
  UpdateScannedValueState(this.scannedValue, this.scan);
}

class ClearScannedValueState extends TransferenciaState {}

//*estado para separar la cantidad
class ChangeQuantitySeparateStateSuccess extends TransferenciaState {
  final int quantity;
  ChangeQuantitySeparateStateSuccess(this.quantity);
}

class ChangeQuantitySeparateStateError extends TransferenciaState {
  final String msg;
  ChangeQuantitySeparateStateError(this.msg);
}

class ShowQuantityState extends TransferenciaState {
  final bool showQuantity;
  ShowQuantityState(this.showQuantity);
}

class StartOrStopTimeTransferSuccess extends TransferenciaState {
  final String isStarted;
  StartOrStopTimeTransferSuccess(this.isStarted);
}

class StartOrStopTimeTransferFailure extends TransferenciaState {
  final String error;
  StartOrStopTimeTransferFailure(this.error);
}

///metodo para asignar un usuario a una orden de compra
class AssignUserToTransferLoading extends TransferenciaState {}

class AssignUserToTransferSuccess extends TransferenciaState {
  final ResultTransFerencias transfer;
  AssignUserToTransferSuccess(this.transfer);
}

class AssignUserToTransferFailure extends TransferenciaState {
  final String error;
  AssignUserToTransferFailure(this.error);
}



class FinalizarTransferProductoLoading extends TransferenciaState {}

class FinalizarTransferProductoSuccess extends TransferenciaState {}

class FinalizarTransferProductoFailure extends TransferenciaState {
  final String error;
  FinalizarTransferProductoFailure(this.error);
}



class FinalizarTransferProductoSplitLoading extends TransferenciaState {}

class FinalizarTransferProductoSplitSuccess extends TransferenciaState {}

class FinalizarTransferProductoSplitFailure extends TransferenciaState {
  final String error;
  FinalizarTransferProductoSplitFailure(this.error);
}



class SendProductToTransferLoading extends TransferenciaState {}

class SendProductToTransferSuccess extends TransferenciaState {}

class SendProductToTransferFailure extends TransferenciaState {
  final String error;
  SendProductToTransferFailure(this.error);
}

class LoadLocationsLoading extends TransferenciaState {}

class LoadLocationsSuccess extends TransferenciaState {
  final List<ResultUbicaciones> locations;
  LoadLocationsSuccess(this.locations);
}

class LoadLocationsFailure extends TransferenciaState {
  final String error;
  LoadLocationsFailure(this.error);
}



class CreateBackOrderOrNotLoading extends TransferenciaState {}


class CreateBackOrderOrNotSuccess extends TransferenciaState {
  final bool isBackorder;
  final String msg;
  CreateBackOrderOrNotSuccess(this.isBackorder, this.msg);
}

class CreateBackOrderOrNotFailure extends TransferenciaState {
  final String error;
  CreateBackOrderOrNotFailure(this.error);
}



//*estados para cargar las novedades
class NovedadesTransferLoadedState extends TransferenciaState {
  final List<Novedad> listOfNovedades;
  NovedadesTransferLoadedState({required this.listOfNovedades});
}

class NovedadesTransferLoadingState extends TransferenciaState {}

class NovedadesTransferErrorState extends TransferenciaState {
  final String message;
  NovedadesTransferErrorState(this.message);
}



class FilterTransferByWarehouseLoading extends TransferenciaState {}

class FilterTransferByWarehouseSuccess extends TransferenciaState {
  final List<ResultTransFerencias> transferencias;
  FilterTransferByWarehouseSuccess(this.transferencias);
}

class FilterTransferByWarehouseFailure extends TransferenciaState {
  final String error;
  FilterTransferByWarehouseFailure(this.error);
}


class CheckAvailabilityLoading extends TransferenciaState {}


class CheckAvailabilitySuccess extends TransferenciaState {
  final ResultTransFerencias transferencia;
  final String msg;
  CheckAvailabilitySuccess(this.transferencia, this.msg);
}

class CheckAvailabilityFailure extends TransferenciaState {
  final String error;
  CheckAvailabilityFailure(this.error);
}