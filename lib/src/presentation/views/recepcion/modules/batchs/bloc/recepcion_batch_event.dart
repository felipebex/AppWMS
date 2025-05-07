part of 'recepcion_batch_bloc.dart';

@immutable
sealed class RecepcionBatchEvent {}

class FetchRecepcionBatchEvent extends RecepcionBatchEvent {
  final bool isLoadinDialog;

  FetchRecepcionBatchEvent({required this.isLoadinDialog});
}

class FetchRecepcionBatchEventFromBD extends RecepcionBatchEvent {}

class ShowKeyboardEvent extends RecepcionBatchEvent {
  final bool showKeyboard;
  ShowKeyboardEvent(this.showKeyboard);
}

class SearchReceptionEvent extends RecepcionBatchEvent {
  final String query;
  SearchReceptionEvent(this.query);
}

class AssignUserToReception extends RecepcionBatchEvent {
  final ReceptionBatch order;
  AssignUserToReception(
    this.order,
  );
}



class StartOrStopTimeOrder extends RecepcionBatchEvent {
  final int idRecepcion;
  final String value;

  StartOrStopTimeOrder(
    this.idRecepcion,
    this.value,
  );
}