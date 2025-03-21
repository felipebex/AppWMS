part of 'transferencia_bloc.dart';

@immutable
sealed class TransferenciaEvent {}

class FetchAllTransferencias extends TransferenciaEvent {}