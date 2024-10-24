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


class GetProductById extends BatchEvent {
  final int productId;

  GetProductById(this.productId);
}




//* CAMBIAR VALORES DE VARIABLES
class ChangeLocationIsOkEvent extends BatchEvent {
  final bool locationIsOk;
  ChangeLocationIsOkEvent(this.locationIsOk);
}

class ChangeLocationDestIsOkEvent extends BatchEvent {
  final bool locationDestIsOk;
  ChangeLocationDestIsOkEvent(this.locationDestIsOk);
}

class ChangeProductIsOkEvent extends BatchEvent {
  final bool productIsOk;
  ChangeProductIsOkEvent(this.productIsOk);
}


class ChangeIsOkQuantity extends BatchEvent {
  final bool isOk;
  ChangeIsOkQuantity(this.isOk);
}


class ChangeCurrentProduct extends BatchEvent {
  final ProductsBatch currentProduct;
  ChangeCurrentProduct({required this.currentProduct});
}


class QuantityChanged extends BatchEvent {
  final int quantity;
  QuantityChanged(this.quantity);
}


class SelectNovedadEvent extends BatchEvent {
  final String novedad;
  SelectNovedadEvent(this.novedad);
}