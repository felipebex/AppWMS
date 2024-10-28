part of 'batch_bloc.dart';

@immutable
sealed class BatchEvent {}

class LoadAllProductsBatchsEvent extends BatchEvent {
  int batchId;
  final BuildContext context;
  LoadAllProductsBatchsEvent({required this.batchId, required this.context});
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
  final int productId;
  final int batchId;
  ChangeLocationIsOkEvent(this.locationIsOk, this.productId, this.batchId);
}

class ChangeLocationDestIsOkEvent extends BatchEvent {
  final bool locationDestIsOk;
  final int productId;
  final int batchId;
  ChangeLocationDestIsOkEvent(
      this.locationDestIsOk, this.productId, this.batchId);
}

class ChangeProductIsOkEvent extends BatchEvent {
  final bool productIsOk;
  final int productId;
  final int batchId;
  final int quantity;
  ChangeProductIsOkEvent(this.productIsOk, this.productId, this.batchId, this.quantity);
}

class ChangeIsOkQuantity extends BatchEvent {
  final bool isOk;
  final int productId;
  final int batchId;
  ChangeIsOkQuantity(this.isOk, this.productId, this.batchId);
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

class ValidateFieldsEvent extends BatchEvent {
  final String field;
  final bool isOk;
  ValidateFieldsEvent({required this.field, required this.isOk});
}


class LoadDataInfoEvent extends BatchEvent {
}


class ChangeQuantitySeparate extends BatchEvent {
  final int quantity;
  final int productId;
  ChangeQuantitySeparate(this.quantity, this.productId);
}
class AddQuantitySeparate extends BatchEvent {
  final int quantity;
  final int productId;
  AddQuantitySeparate(this.quantity, this.productId);
}