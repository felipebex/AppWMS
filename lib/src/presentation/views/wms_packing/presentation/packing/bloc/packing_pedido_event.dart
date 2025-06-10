part of 'packing_pedido_bloc.dart';

@immutable
sealed class PackingPedidoEvent {}

class ShowKeyboardEvent extends PackingPedidoEvent {
  final bool showKeyboard;
  ShowKeyboardEvent(this.showKeyboard);
}

class LoadAllPackingPedidoEvent extends PackingPedidoEvent {
  final bool isLoadinDialog;
  LoadAllPackingPedidoEvent(
    this.isLoadinDialog,
  );
}

class LoadPackingPedidoFromDBEvent extends PackingPedidoEvent {
}

class   SearchPedidoEvent extends PackingPedidoEvent {
  final String query;
  SearchPedidoEvent(this.query, );
}

class AssignUserToPedido extends PackingPedidoEvent {
  final int id;
  AssignUserToPedido( this.id);
}

class StartOrStopTimePedido extends PackingPedidoEvent {
  final int id;
  final String value;
  StartOrStopTimePedido(this.id , this.value);
}



class LoadConfigurationsUser extends PackingPedidoEvent {}


class LoadPedidoAndProductsEvent extends PackingPedidoEvent {
  final int idPedido;
  LoadPedidoAndProductsEvent(this.idPedido);
}

class ShowDetailvent extends PackingPedidoEvent {
  final bool show;
  ShowDetailvent(this.show);
}