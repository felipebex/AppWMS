part of 'wms_packing_bloc.dart';

@immutable
sealed class WmsPackingEvent {}

class LoadAllPackingEvent extends WmsPackingEvent {
  final BuildContext context;
  final bool isLoadinDialog;
  LoadAllPackingEvent(this.isLoadinDialog, this.context);
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
class SearchPedidoPackingEvent extends WmsPackingEvent {
  final String query;
  final int idBatch;

  SearchPedidoPackingEvent(this.query, this.idBatch);
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
  final int idMove;
  ChangeQuantitySeparate(
      this.quantity, this.productId, this.pedidoId, this.idMove);
}

//
class AddProductPackingEvent extends WmsPackingEvent {}

//* CAMBIAR VALORES DE VARIABLES
class ChangeLocationIsOkEvent extends WmsPackingEvent {
  final int productId;
  final int pedidoId;
  final int idMove;
  ChangeLocationIsOkEvent(this.productId, this.pedidoId, this.idMove);
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
  final int idMove;
  ChangeProductIsOkEvent(this.productIsOk, this.productId, this.pedidoId,
      this.quantity, this.idMove);
}

class ChangeIsOkQuantity extends WmsPackingEvent {
  final bool isOk;
  final int productId;
  final int pedidoId;
  final int idMove;
  ChangeIsOkQuantity(this.isOk, this.productId, this.pedidoId, this.idMove);
}

class AddQuantitySeparate extends WmsPackingEvent {
  final int productId;
  final int idMove;
  final int quantity;
  final int pedidoId;
  AddQuantitySeparate(
      this.quantity, this.idMove, this.productId, this.pedidoId);
}


class SetPackingsEvent extends WmsPackingEvent {
  final List<PorductoPedido> productos;
  final bool isSticker;
  final bool isCertificate;
  final BuildContext context;

  SetPackingsEvent(
      this.productos, this.isSticker, this.isCertificate, this.context);
}

class ChangeStickerEvent extends WmsPackingEvent {
  final bool isSticker;
  ChangeStickerEvent(this.isSticker);
}

class FilterBatchPackingStatusEvent extends WmsPackingEvent {
  final String status;

  FilterBatchPackingStatusEvent(this.status);
}

class SearchProductPackingEvent extends WmsPackingEvent {
  final String query;

  SearchProductPackingEvent(
    this.query,
  );
}

class ShowKeyboardEvent extends WmsPackingEvent {
  final bool showKeyboard;

  ShowKeyboardEvent(this.showKeyboard);
}

class SelectProductPackingEvent extends WmsPackingEvent {
  final PorductoPedido producto;
  SelectProductPackingEvent(this.producto);
}

class UnSelectProductPackingEvent extends WmsPackingEvent {
  final PorductoPedido producto;
  UnSelectProductPackingEvent(this.producto);
}

class LoadAllNovedadesPackingEvent extends WmsPackingEvent {}


class LoadConfigurationsUserPack extends WmsPackingEvent {
  LoadConfigurationsUserPack();
}

class SetPickingSplitEvent extends WmsPackingEvent {
  final PorductoPedido producto;
  final int idMove;
  final int quantity;
  final int productId;
  final int pedidoId;
  SetPickingSplitEvent(this.producto,this.idMove, this.quantity, this.productId, this.pedidoId);
}


class SetPickingsEvent extends WmsPackingEvent {
  final int productId;
  final int pedidoId;
  final int idMove;

  SetPickingsEvent(this.productId, this.pedidoId, this.idMove);
}


class UnPackingEvent extends WmsPackingEvent {
  final UnPackingRequest request;
  final BuildContext context;
  final int pedidoId;
  UnPackingEvent(this.request, this.context, this.pedidoId);
}



class ClearScannedValuePackEvent extends WmsPackingEvent {
final String scan;
  ClearScannedValuePackEvent(this.scan);
}

class UpdateScannedValuePackEvent extends WmsPackingEvent {
    final String scannedValue;
  final String scan;
  UpdateScannedValuePackEvent(this.scannedValue, this.scan);
}


class ShowQuantityPackEvent extends WmsPackingEvent {
  final bool showQuantity;
  ShowQuantityPackEvent(this.showQuantity);
}



//*empezar el tiempo de separacion
class StartTimePack extends WmsPackingEvent {
  final BuildContext context;
  final int batchId;
  final DateTime time;
  StartTimePack(this.context, this.batchId, this.time);
}
class EndTimePack extends WmsPackingEvent {
  final BuildContext context;
  final int batchId;
  final DateTime time;
  EndTimePack(this.context, this.batchId, this.time);
}
