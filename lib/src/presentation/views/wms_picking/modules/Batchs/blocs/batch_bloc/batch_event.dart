part of 'batch_bloc.dart';

@immutable
sealed class BatchEvent {}



class LoadAllProductsBatchsEvent extends BatchEvent {
  int batchId;
  LoadAllProductsBatchsEvent({required this.batchId});
}


class ClearSearchProudctsBatchEvent extends BatchEvent {}


class SearchProductsBatchEvent extends BatchEvent {
  final String query;

  SearchProductsBatchEvent(this.query);
}


class LoadProductsBatchFromDBEvent extends BatchEvent {
  int batchId;

  LoadProductsBatchFromDBEvent({required this.batchId});
}


class NextProductEvent extends BatchEvent {}



class FetchBatchWithProductsEvent extends BatchEvent {
  final int batchId;

  FetchBatchWithProductsEvent(this.batchId);
}