part of 'batch_bloc.dart';

@immutable
sealed class BatchState {}

final class BatchInitial extends BatchState {}


final class ProductsBatchLoadingState extends BatchState {}


final class LoadProductsBatchSuccesState extends BatchState {
  final List<ProductsBatch> listOfProductsBatch;
  LoadProductsBatchSuccesState({required this.listOfProductsBatch});
}



final class LoadProductsBatchSuccesStateBD extends BatchState {
  final List<ProductsBatch> listOfProductsBatch;
  LoadProductsBatchSuccesStateBD({required this.listOfProductsBatch});
}



final class BatchErrorState extends BatchState {
  final String error;
  BatchErrorState(this.error);
}


final class EmptyroductsBatch extends BatchState {}


final class GetProductByIdLoaded extends BatchState {
  final Products product;
  GetProductByIdLoaded(this.product);
}


class ChangeIsOkState extends BatchState {
  final bool isOk;
  ChangeIsOkState(this.isOk);
}


final class CurrentProductChangedState extends BatchState {
  final ProductsBatch currentProduct;
  final int index;
  CurrentProductChangedState({required this.currentProduct, required this.index});
}



final class QuantityChangedState extends BatchState {
  final int quantity;
  QuantityChangedState(this.quantity);
}


class SelectNovedadState extends BatchState {
  final String novedad;
  SelectNovedadState(this.novedad);
}


class ValidateFieldsState extends BatchState {
  final bool isOk;
  ValidateFieldsState(this.isOk);
}


class LoadDataInfoState extends BatchState {
}


class ChangeQuantitySeparateState extends BatchState {
  final int quantity;
  ChangeQuantitySeparateState(this.quantity);
}

class PickingOkState extends BatchState {
  // final bool isOk;
  // PickingOkState(this.isOk);
}