// ignore_for_file: must_be_immutable

part of 'batch_bloc.dart';

@immutable
sealed class BatchEvent {}

class InitialStateEvent extends BatchEvent {}

class LoadAllProductsBatchsEvent extends BatchEvent {
  int batchId;
 
  LoadAllProductsBatchsEvent({required this.batchId, });
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

//*empezar el tiempo de separacion
class StartTimePick extends BatchEvent {
 
  final int batchId;
  final DateTime time;
  StartTimePick( this.batchId, this.time);
}
class EndTimePick extends BatchEvent {
  
  final int batchId;
  final DateTime time;
  EndTimePick( this.batchId, this.time);
}

//* CAMBIAR VALORES DE VARIABLES
class ChangeLocationIsOkEvent extends BatchEvent {
  final int productId;
  final int batchId;
  final int idMove;
  ChangeLocationIsOkEvent(this.productId, this.batchId, this.idMove);
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
  final dynamic quantity;
  final int idMove;
  ChangeProductIsOkEvent(this.productIsOk, this.productId, this.batchId,
      this.quantity, this.idMove);
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
  
  ChangeCurrentProduct({required this.currentProduct, });
}

class QuantityChanged extends BatchEvent {
  final dynamic quantity;
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

class LoadDataInfoEvent extends BatchEvent {}

class ChangeQuantitySeparate extends BatchEvent {
  final dynamic quantity;
  final int productId;
  final int idMove;
  ChangeQuantitySeparate(this.quantity, this.productId, this.idMove);
}

class AddQuantitySeparate extends BatchEvent {
  final int productId;
  final int idMove;
  final dynamic quantity;
  final bool isOk;
  AddQuantitySeparate(this.productId, this.idMove, this.quantity, this.isOk);
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

class LoadProductEditEvent extends BatchEvent {}

class SendProductEditOdooEvent extends BatchEvent {
  final ProductsBatch product;
  final dynamic cantidad;

  SendProductEditOdooEvent(this.product, this.cantidad, );
}

class AssignSubmuelleEvent extends BatchEvent {
  final List<ProductsBatch> productsSeparate;
  final Muelles muelle;
  final bool isOccupied;
  
  AssignSubmuelleEvent(this.productsSeparate, this.muelle, this.isOccupied );
}

class ScanBarcodeEvent extends BatchEvent {}

class LoadInfoDeviceEvent extends BatchEvent {}

class ShowKeyboard extends BatchEvent {
  final bool showKeyboard;

  ShowKeyboard(this.showKeyboard);
}

class LoadAllNovedadesEvent extends BatchEvent {}

class SelectedSubMuelleEvent extends BatchEvent {
  final Muelles subMuelleSlected;

  SelectedSubMuelleEvent(this.subMuelleSlected);
}

class FetchBarcodesProductEvent extends BatchEvent {}

class ResetValuesEvent extends BatchEvent {}

class SortProductsByLocation extends BatchEvent {}

//evento para enviar un producto a odoo
class SendProductOdooEvent extends BatchEvent {
  final ProductsBatch product;

  SendProductOdooEvent(this.product, );
}

class UpdateScannedValueEvent extends BatchEvent {
  final String scannedValue;
  final String scan;
  UpdateScannedValueEvent(this.scannedValue, this.scan);
}

class ClearScannedValueEvent extends BatchEvent {
  final String scan;
  ClearScannedValueEvent(this.scan);
}

class ShowQuantityEvent extends BatchEvent {
  final bool showQuantity;
  ShowQuantityEvent(this.showQuantity);
}

class SetIsProcessingEvent extends BatchEvent {
  final bool isProcessing;
  SetIsProcessingEvent(this.isProcessing);
}

class CloseStateEvent extends BatchEvent {}


class FetchMuellesEvent extends BatchEvent {

}

class LoadSelectedProductEvent extends BatchEvent {
  final ProductsBatch selectedProduct;
  LoadSelectedProductEvent(this.selectedProduct);
}