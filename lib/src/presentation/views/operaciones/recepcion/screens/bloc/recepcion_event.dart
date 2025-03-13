part of 'recepcion_bloc.dart';

@immutable
sealed class RecepcionEvent {}


class FetchOrdenesCompra extends RecepcionEvent {
  BuildContext context;
  FetchOrdenesCompra(this.context);
}

class ShowKeyboardEvent extends RecepcionEvent {
  final bool showKeyboard;
  ShowKeyboardEvent(this.showKeyboard);
}

class SearchOrdenCompraEvent extends RecepcionEvent {
  final String query;
  SearchOrdenCompraEvent(this.query);
}