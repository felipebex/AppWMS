part of 'wms_packing_bloc.dart';

@immutable
sealed class WmsPackingState {}

final class WmsPackingInitial extends WmsPackingState {}

//*estados para cargar todos los batchs para packing
final class WmsPackingLoading extends WmsPackingState {}

final class WmsPackingLoaded extends WmsPackingState {
  final List<Packing> listPacking;
  WmsPackingLoaded(this.listPacking);
}

final class WmsPackingError extends WmsPackingState {
  final String error;
  WmsPackingError(this.error);
}

//* estados pra cargar todos los productos de un packing
final class WmsPackingLoadingProducts extends WmsPackingState {}

final class WmsPackingLoadedProducts extends WmsPackingState {
  final List<ProductPacking> listProductPacking;
  WmsPackingLoadedProducts(this.listProductPacking);
}

class ChangeIsOkState extends WmsPackingState {
  final bool isOk;
  ChangeIsOkState(this.isOk);
}

final class LoadProductsBatchSuccesStateBD extends WmsPackingState {
  final List<ProductsBatch> listOfProductsBatch;
  LoadProductsBatchSuccesStateBD({required this.listOfProductsBatch});
}

final class EmptyroductsBatch extends WmsPackingState {}



final class BatchErrorState extends WmsPackingState {
  final String error;
  BatchErrorState(this.error);
}