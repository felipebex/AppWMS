part of 'packing_pedido_bloc.dart';

@immutable
sealed class PackingPedidoState {}

final class PackingPedidoInitial extends PackingPedidoState {}



class ShowKeyboardState extends PackingPedidoState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}

final class WmsPackingPedidoWMSLoading extends PackingPedidoState {}

final class WmsPackingPedidoWMSLoaded extends PackingPedidoState {
  final List<PedidoPackingResult> listOfPedidos;
  WmsPackingPedidoWMSLoaded({required this.listOfPedidos});
}



final class PackingPedidoError extends PackingPedidoState {
  final String error;
  PackingPedidoError(this.error);
}

class PackingPedidoLoadingState extends PackingPedidoState {}

class PackingPedidoLoadedFromDBState extends PackingPedidoState {
  final List<PedidoPackingResult> listOfPedidos;
  PackingPedidoLoadedFromDBState({required this.listOfPedidos});
}

class AssignUserToPedidoLoading extends PackingPedidoState {}

class AssignUserToPedidoLoaded extends PackingPedidoState {
  final int id;
  AssignUserToPedidoLoaded({required this.id});
}
class AssignUserToPedidoError extends PackingPedidoState {
  final String error;
  AssignUserToPedidoError(this.error);
}



class StartOrStopTimeTransferSuccess extends PackingPedidoState {
  final String isStarted;
  StartOrStopTimeTransferSuccess(this.isStarted);
}

class StartOrStopTimeTransferFailure extends PackingPedidoState {
  final String error;
  StartOrStopTimeTransferFailure(this.error);
}


class ConfigurationLoading extends PackingPedidoState {}

class ConfigurationPickingLoaded extends PackingPedidoState {
  final Configurations configurations;

  ConfigurationPickingLoaded(this.configurations);
}

class ConfigurationError extends PackingPedidoState {
  final String error;

  ConfigurationError(this.error);
}


class LoadPedidoAndProductsLoading extends PackingPedidoState {}


class LoadPedidoAndProductsLoaded extends PackingPedidoState {
  final PedidoPackingResult pedidoPackingResult;

  LoadPedidoAndProductsLoaded(this.pedidoPackingResult);
}

class LoadPedidoAndProductsError extends PackingPedidoState {
  final String error;

  LoadPedidoAndProductsError(this.error);
}


class ShowDetailPackState extends PackingPedidoState {
  final bool showViewDetail;
  ShowDetailPackState(this.showViewDetail);
}