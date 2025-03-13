part of 'recepcion_bloc.dart';

@immutable
sealed class RecepcionState {}

final class RecepcionInitial extends RecepcionState {}


//estados para obtener todas las orndes de compras
class FetchOrdenesCompraLoading extends RecepcionState {}

class FetchOrdenesCompraSuccess extends RecepcionState {
  final List<OrdenCompra> ordenesCompra;
  FetchOrdenesCompraSuccess(this.ordenesCompra);
}

class FetchOrdenesCompraFailure extends RecepcionState {
  final String error;
  FetchOrdenesCompraFailure(this.error);
}


class ShowKeyboardState extends RecepcionState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}

//estados para buscar una  orden de compra


class SearchOrdenCompraSuccess extends RecepcionState {
  final List<OrdenCompra> ordenesCompra;
  SearchOrdenCompraSuccess(this.ordenesCompra);
}

class SearchOrdenCompraFailure extends RecepcionState {
  final String error;
  SearchOrdenCompraFailure(this.error);
}