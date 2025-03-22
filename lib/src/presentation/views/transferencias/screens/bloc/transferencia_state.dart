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
