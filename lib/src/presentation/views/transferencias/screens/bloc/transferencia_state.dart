part of 'transferencia_bloc.dart';

@immutable
sealed class TransferenciaState {}

final class TransferenciaInitial extends TransferenciaState {}

final class TransferenciaLoading extends TransferenciaState {}

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
