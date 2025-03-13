part of 'recepcion_bloc.dart';

@immutable
sealed class RecepcionEvent {}


class FetchOrdenesCompra extends RecepcionEvent {
  BuildContext context;
  FetchOrdenesCompra(this.context);
}