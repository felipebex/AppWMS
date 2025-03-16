part of 'recepcion_bloc.dart';

@immutable
sealed class RecepcionState {}

final class RecepcionInitial extends RecepcionState {}


//estados para obtener todas las orndes de compras
class FetchOrdenesCompraLoading extends RecepcionState {}

class FetchOrdenesCompraSuccess extends RecepcionState {
  final List<ResultEntrada> ordenesCompra;
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
  final List<ResultEntrada> ordenesCompra;
  SearchOrdenCompraSuccess(this.ordenesCompra);
}

class SearchOrdenCompraFailure extends RecepcionState {
  final String error;
  SearchOrdenCompraFailure(this.error);
}

///metodo para asignar un usuario a una orden de compra
class AssignUserToOrderLoading extends RecepcionState {}

class AssignUserToOrderSuccess extends RecepcionState {}

class AssignUserToOrderFailure extends RecepcionState {
  final String error;
  AssignUserToOrderFailure(this.error);
}



//metodo para obtener todas las entradas de recepcion dsde la bd
class FetchOrdenesCompraOfBdLoading extends RecepcionState {}

class FetchOrdenesCompraOfBdSuccess extends RecepcionState {
  final List<ResultEntrada> ordenesCompra;
  FetchOrdenesCompraOfBdSuccess(this.ordenesCompra);
}

class FetchOrdenesCompraOfBdFailure extends RecepcionState {
  final String error;
  FetchOrdenesCompraOfBdFailure(this.error);
}


//metodo para obtener los productos de una entrada
class GetProductsToEntradaLoading extends RecepcionState {}

class GetProductsToEntradaSuccess extends RecepcionState {
  final List<LineasRecepcion> productos;
  GetProductsToEntradaSuccess(this.productos);
}

class GetProductsToEntradaFailure extends RecepcionState {
  final String error;
  GetProductsToEntradaFailure(this.error);
}
