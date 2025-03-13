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