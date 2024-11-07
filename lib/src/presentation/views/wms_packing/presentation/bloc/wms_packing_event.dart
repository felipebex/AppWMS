part of 'wms_packing_bloc.dart';

@immutable
sealed class WmsPackingEvent {}

class LoadAllPackingEvent extends WmsPackingEvent {
  LoadAllPackingEvent();
}

class LoadBatchPackingFromDBEvent extends WmsPackingEvent {
  LoadBatchPackingFromDBEvent();
}

class LoadAllPedidosFromBatchEvent extends WmsPackingEvent {
  final int batchId;
  LoadAllPedidosFromBatchEvent(
    this.batchId,
  );
}

class FetchProductEvent extends WmsPackingEvent {
  final PorductoPedido pedido;
  FetchProductEvent(
    this.pedido,
  );
}

class LoadAllProductsFromPedidoEvent extends WmsPackingEvent {
  final int pedidoId;
  LoadAllProductsFromPedidoEvent(
    this.pedidoId,
  );
}

class SearchBatchPackingEvent extends WmsPackingEvent {
  final String query;
  final int indexMenu;

  SearchBatchPackingEvent(this.query, this.indexMenu);
}


class ValidateFieldsPackingEvent extends WmsPackingEvent {
  final String field;
  final bool isOk;
  ValidateFieldsPackingEvent({required this.field, required this.isOk});
}

class ChangeQuantitySeparate extends WmsPackingEvent {
  final int quantity;
  final int productId;
  final int pedidoId;
  ChangeQuantitySeparate(this.quantity, this.productId, this.pedidoId);
}

//
class AddProductPackingEvent extends WmsPackingEvent {}

//* CAMBIAR VALORES DE VARIABLES
class ChangeLocationIsOkEvent extends WmsPackingEvent {
  final bool locationIsOk;
  final int productId;
  final int pedidoId;
  ChangeLocationIsOkEvent(this.locationIsOk, this.productId, this.pedidoId);
}

class ChangeLocationDestIsOkEvent extends WmsPackingEvent {
  final bool locationDestIsOk;
  ChangeLocationDestIsOkEvent(this.locationDestIsOk);
}

class ChangeProductIsOkEvent extends WmsPackingEvent {
  final bool productIsOk;
  final int productId;
  final int pedidoId;
  final int quantity;
  ChangeProductIsOkEvent(
      this.productIsOk, this.productId, this.pedidoId, this.quantity);
}

class ChangeIsOkQuantity extends WmsPackingEvent {
  final bool isOk;
  final int productId;
  final int pedidoId;
  ChangeIsOkQuantity(this.isOk, this.productId, this.pedidoId);
}

class AddQuantitySeparate extends WmsPackingEvent {
  final int quantity;
  final int productId;
  final int pedidoId;
  AddQuantitySeparate(this.quantity, this.productId, this.pedidoId);
}

class SetPickingsEvent extends WmsPackingEvent {
  final int productId;
  final int pedidoId;

  SetPickingsEvent(this.productId, this.pedidoId);
}


class SetPackingsEvent extends WmsPackingEvent {
  final List<PorductoPedido> productos;
  final bool isSticker;
  final bool isCertificate;

  SetPackingsEvent( this.productos, this.isSticker, this.isCertificate);


}


class ChangeStickerEvent extends WmsPackingEvent {
  final bool isSticker;
  ChangeStickerEvent(this.isSticker);
}
