part of 'wms_packing_bloc.dart';

@immutable
sealed class WmsPackingEvent {}

class LoadAllPackingEvent extends WmsPackingEvent {
  final int batchId;
  final BuildContext context;
  LoadAllPackingEvent(
    this.batchId,
    this.context,
  );
}

class LoadProdcutsPackingEvent extends WmsPackingEvent {
  final int packingId;
  final BuildContext context;
  LoadProdcutsPackingEvent(
    this.packingId,
    this.context,
  );
}

class AddProductPackingEvent extends WmsPackingEvent {}

class GetProductById extends WmsPackingEvent {
  final int productId;
  GetProductById(
    this.productId,
  );
}

//* CAMBIAR VALORES DE VARIABLES
class ChangeLocationIsOkEvent extends WmsPackingEvent {
  final bool locationIsOk;
  ChangeLocationIsOkEvent(this.locationIsOk);
}

class ChangeLocationDestIsOkEvent extends WmsPackingEvent {
  final bool locationDestIsOk;
  ChangeLocationDestIsOkEvent(this.locationDestIsOk);
}

class ChangeProductIsOkEvent extends WmsPackingEvent {
  final bool productIsOk;
  ChangeProductIsOkEvent(this.productIsOk);
}

class ChangeIsOkQuantity extends WmsPackingEvent {
  final bool isOk;
  ChangeIsOkQuantity(this.isOk);
}



class FetchBatchWithProductsEvent extends WmsPackingEvent {
  final int batchId;
  FetchBatchWithProductsEvent(this.batchId);
}

