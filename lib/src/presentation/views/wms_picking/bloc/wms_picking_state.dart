part of 'wms_picking_bloc.dart';

@immutable
sealed class PickingState {}

final class ProductspickingInitial extends PickingState {}

//* estados para las acciones de los productos
final class ProductspickingLoadingState extends PickingState {}
final class ProductsPickingErrorState extends PickingState {
  final String error;
  ProductsPickingErrorState(this.error);
}
final class LoadProductsSuccesState extends PickingState {
  final List<Products> listOfProducts;
  LoadProductsSuccesState({required this.listOfProducts});
}



//*estado para las acciones de los batchs
final class BatchsPickingLoadingState extends PickingState {}
final class BatchsPickingErrorState extends PickingState {
  final String error;
  BatchsPickingErrorState(this.error);
}



final class BatchHistoryLoadingState extends PickingState {}
final class BatchHistoryLoadedState extends PickingState {
  final HistoryBatchId batch;
  BatchHistoryLoadedState(this.batch);
}



final class LoadBatchsSuccesState extends PickingState {
  final List<BatchsModel> listOfBatchs;

  LoadBatchsSuccesState({required this.listOfBatchs});
}
final class LoadHistoryBatchState extends PickingState {
  final List<HistoryBatch> listOfBatchs;

  LoadHistoryBatchState({required this.listOfBatchs});
}


class ShowKeyboardState extends PickingState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}



class LoadSuccessNovedadesState extends PickingState {
  final List<Novedad> listOfNovedades;
  LoadSuccessNovedadesState({required this.listOfNovedades});
}