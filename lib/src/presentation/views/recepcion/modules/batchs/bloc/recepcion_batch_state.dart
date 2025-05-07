part of 'recepcion_batch_bloc.dart';

@immutable
sealed class RecepcionBatchState {}

final class RecepcionBatchInitial extends RecepcionBatchState {}

class FetchRecepcionBatchLoading extends RecepcionBatchState {}

class FetchRecepcionBatchFailure extends RecepcionBatchState {
  final String error;
  FetchRecepcionBatchFailure(this.error);
}

class FetchRecepcionBatchSuccess extends RecepcionBatchState {
  final List<ReceptionBatch> listReceptionBatch;

  FetchRecepcionBatchSuccess({required this.listReceptionBatch});
}
class FetchRecepcionBatchLoadingFromBD extends RecepcionBatchState {}

class FetchRecepcionBatchFailureFromBD extends RecepcionBatchState {
  final String error;
  FetchRecepcionBatchFailureFromBD(this.error);
}

class FetchRecepcionBatchSuccessFromBD extends RecepcionBatchState {
  final List<ReceptionBatch> listReceptionBatch;

  FetchRecepcionBatchSuccessFromBD({required this.listReceptionBatch});
}


class ShowKeyboardState extends RecepcionBatchState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}


class SearchOrdenCompraSuccess extends RecepcionBatchState {
  final List<ReceptionBatch> ordenesCompra;
  SearchOrdenCompraSuccess(this.ordenesCompra);
}

class SearchOrdenCompraFailure extends RecepcionBatchState {
  final String error;
  SearchOrdenCompraFailure(this.error);
}




///metodo para asignar un usuario a una orden de compra
class AssignUserToOrderLoading extends RecepcionBatchState {}

class AssignUserToOrderSuccess extends RecepcionBatchState {
  final  ReceptionBatch ordenCompra ;
  AssignUserToOrderSuccess(this.ordenCompra);
}

class AssignUserToOrderFailure extends RecepcionBatchState {
  final String error;
  AssignUserToOrderFailure(this.error);
}




class StartOrStopTimeOrderSuccess extends RecepcionBatchState {
  final String isStarted;
  StartOrStopTimeOrderSuccess(this.isStarted);
}

class StartOrStopTimeOrderFailure extends RecepcionBatchState {
  final String error;
  StartOrStopTimeOrderFailure(this.error);
}
