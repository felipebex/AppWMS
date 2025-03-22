part of 'transferencia_bloc.dart';

@immutable
sealed class TransferenciaEvent {}

class FetchAllTransferencias extends TransferenciaEvent {}

class FetchAllTransferenciasDB extends TransferenciaEvent {}

class CurrentTransferencia extends TransferenciaEvent {
  final ResultTransFerencias trasnferencia;
  CurrentTransferencia(this.trasnferencia);
}

class SearchTransferEvent extends TransferenciaEvent {
  final String query;
  SearchTransferEvent(this.query);
}

class ShowKeyboardEvent extends TransferenciaEvent {
  final bool showKeyboard;
  ShowKeyboardEvent({required this.showKeyboard});
}

class LoadConfigurationsUserTransfer extends TransferenciaEvent {}

class GetPorductsToTransfer extends TransferenciaEvent {
  final int idTransfer;
  GetPorductsToTransfer(this.idTransfer);
}
