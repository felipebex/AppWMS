// ignore_for_file: must_be_immutable

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
  final int idMove;
  ChangeLocationIsOkEvent(this.locationIsOk, this.productId, this.batchId, this.idMove);
}

class ChangeLocationDestIsOkEvent extends BatchEvent {
  final bool locationDestIsOk;
  final int productId;
  final int batchId;
  final int idMove;
  ChangeLocationDestIsOkEvent(
      this.locationDestIsOk, this.productId, this.batchId, this.idMove);
}

class ChangeProductIsOkEvent extends BatchEvent {
  final bool productIsOk;
  final int productId;
  final int batchId;
  final int quantity;
  final int idMove;
  ChangeProductIsOkEvent(this.productIsOk, this.productId, this.batchId, this.quantity, this.idMove);
}

class ChangeIsOkQuantity extends BatchEvent {
  final bool isOk;
  final int productId;
  final int batchId;
  final int idMove;
  ChangeIsOkQuantity(this.isOk, this.productId, this.batchId, this.idMove);
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
  final int idMove;
  ChangeQuantitySeparate(this.quantity, this.productId, this.idMove);
}
class AddQuantitySeparate extends BatchEvent {
  final int productId;
  final int idMove;
  final int quantity;
  AddQuantitySeparate(this.productId, this.idMove, this.quantity);
}


class PickingOkEvent extends BatchEvent {
  final int batchId;
  final int productId;

  PickingOkEvent(this.batchId, this.productId);
}


class ProductPendingEvent extends BatchEvent {
  final int batchId;
  final ProductsBatch product;

  ProductPendingEvent(this.batchId, this.product);
}


class LoadConfigurationsUser extends BatchEvent {
  LoadConfigurationsUser();
}

class UpdateProductOdooEvent extends BatchEvent {
  final int batchId;
  final BuildContext context;
  UpdateProductOdooEvent( this.batchId,  this.context);
}

class LoadProductEditEvent extends BatchEvent {

}

class SendProductEditOdooEvent extends BatchEvent {
  final ProductsBatch product;
  final int cantidad;
  SendProductEditOdooEvent(  this.product, this.cantidad);
}

class AssignSubmuelleEvent extends BatchEvent {
  final List<ProductsBatch> productsSeparate;
  final Muelles muelle;
  AssignSubmuelleEvent(this.productsSeparate, this.muelle);
}