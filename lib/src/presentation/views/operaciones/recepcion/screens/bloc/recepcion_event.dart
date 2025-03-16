part of 'recepcion_bloc.dart';

@immutable
sealed class RecepcionEvent {}


class FetchOrdenesCompra extends RecepcionEvent {
  BuildContext context;
  FetchOrdenesCompra(this.context);
}
class FetchOrdenesCompraOfBd extends RecepcionEvent {
  BuildContext context;
  FetchOrdenesCompraOfBd(this.context);
}

class ShowKeyboardEvent extends RecepcionEvent {
  final bool showKeyboard;
  ShowKeyboardEvent(this.showKeyboard);
}

class SearchOrdenCompraEvent extends RecepcionEvent {
  final String query;
  SearchOrdenCompraEvent(this.query);
}

class AssignUserToOrder extends RecepcionEvent {
  final String idOrder;
  final String idUser;
  AssignUserToOrder(this.idOrder, this.idUser);
}


class LoadConfigurationsUserOrder  extends RecepcionEvent {
}


class GetPorductsToEntrada extends RecepcionEvent {
  final int idEntrada;
  GetPorductsToEntrada(this.idEntrada);
}