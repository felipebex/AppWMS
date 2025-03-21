part of 'transferencia_bloc.dart';

@immutable
sealed class TransferenciaState {}

final class TransferenciaInitial extends TransferenciaState {}


final class TransferenciaLoading extends TransferenciaState {}

final class TransferenciaLoaded extends TransferenciaState {
  final List<ResultTransFerencias> transferencias;
  TransferenciaLoaded(this.transferencias);
}

final class TransferenciaError extends TransferenciaState {
  final String message;
  TransferenciaError(this.message);
}