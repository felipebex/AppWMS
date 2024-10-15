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