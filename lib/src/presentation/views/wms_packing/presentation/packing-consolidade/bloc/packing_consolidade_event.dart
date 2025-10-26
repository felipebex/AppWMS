part of 'packing_consolidade_bloc.dart';

@immutable
sealed class PackingConsolidateEvent {}

class LoadConfigurationsUserPackConsolidate extends PackingConsolidateEvent {
  LoadConfigurationsUserPackConsolidate();
}

class LoadAllPackingConsolidateEvent extends PackingConsolidateEvent {
  LoadAllPackingConsolidateEvent();
}

class SearchBatchPackingEvent extends PackingConsolidateEvent {
  final String query;
  final int indexMenu;

  SearchBatchPackingEvent(this.query, this.indexMenu);
}

class ShowKeyboardEvent extends PackingConsolidateEvent {
  final bool showKeyboard;

  ShowKeyboardEvent(this.showKeyboard);
}

class ClearScannedValuePackEvent extends PackingConsolidateEvent {
  final String scan;
  ClearScannedValuePackEvent(this.scan);
}

class UpdateScannedValuePackEvent extends PackingConsolidateEvent {
  final String scannedValue;
  final String scan;
  UpdateScannedValuePackEvent(this.scannedValue, this.scan);
}

class LoadBatchPackingFromDBEvent extends PackingConsolidateEvent {
  LoadBatchPackingFromDBEvent();
}

//*empezar el tiempo de separacion
class StartTimePack extends PackingConsolidateEvent {
  final int batchId;
  final DateTime time;
  StartTimePack(this.batchId, this.time);
}

class EndTimePack extends PackingConsolidateEvent {
  final int batchId;
  final DateTime time;
  EndTimePack(this.batchId, this.time);
}

class LoadAllPedidosFromBatchEvent extends PackingConsolidateEvent {
  final int batchId;
  LoadAllPedidosFromBatchEvent(
    this.batchId,
  );
}

class LoadDocOriginsEvent extends PackingConsolidateEvent {
  final int idBatch;
  LoadDocOriginsEvent(this.idBatch);
}

class ShowDetailvent extends PackingConsolidateEvent {
  final bool show;
  ShowDetailvent(this.show);
}

class LoadAllProductsFromPedidoEvent extends PackingConsolidateEvent {
  final int pedidoId;
  LoadAllProductsFromPedidoEvent(
    this.pedidoId,
  );
}



class SearchPedidoPackingEvent extends PackingConsolidateEvent {
  final String query;
  final int idBatch;

  SearchPedidoPackingEvent(this.query, this.idBatch);
}


class FetchProductEvent extends PackingConsolidateEvent {
  final ProductoPedido pedido;
  FetchProductEvent(
    this.pedido,
  );
}



//* CAMBIAR VALORES DE VARIABLES
class ChangeLocationIsOkEvent extends PackingConsolidateEvent {
  final int productId;
  final int pedidoId;
  final int idMove;
  ChangeLocationIsOkEvent(this.productId, this.pedidoId, this.idMove);
}

class ChangeLocationDestIsOkEvent extends PackingConsolidateEvent {
  final bool locationDestIsOk;
  ChangeLocationDestIsOkEvent(this.locationDestIsOk);
}

class ChangeProductIsOkEvent extends PackingConsolidateEvent {
  final bool productIsOk;
  final int productId;
  final int pedidoId;
  final dynamic quantity;
  final int idMove;
  ChangeProductIsOkEvent(this.productIsOk, this.productId, this.pedidoId,
      this.quantity, this.idMove);
}

class ChangeIsOkQuantity extends PackingConsolidateEvent {
  final bool isOk;
  final int productId;
  final int pedidoId;
  final int idMove;
  ChangeIsOkQuantity(this.isOk, this.productId, this.pedidoId, this.idMove);
}

class AddQuantitySeparate extends PackingConsolidateEvent {
  final int productId;
  final int idMove;
  final dynamic quantity;
  final int pedidoId;
  AddQuantitySeparate(
      this.quantity, this.idMove, this.productId, this.pedidoId);
}

class SetPackingsEvent extends PackingConsolidateEvent {
  final List<ProductoPedido> productos;
  final bool isSticker;
  final bool isCertificate;

  SetPackingsEvent(
    this.productos,
    this.isSticker,
    this.isCertificate,
  );
}


class SetPickingsEvent extends PackingConsolidateEvent {
  final int productId;
  final int pedidoId;
  final int idMove;

  SetPickingsEvent(this.productId, this.pedidoId, this.idMove);
}

class ChangeStickerEvent extends PackingConsolidateEvent {
  final bool isSticker;
  ChangeStickerEvent(this.isSticker);
}



class SelectProductPackingEvent extends PackingConsolidateEvent {
  final ProductoPedido producto;
  SelectProductPackingEvent(this.producto);
}

class UnSelectProductPackingEvent extends PackingConsolidateEvent {
  final ProductoPedido producto;
  UnSelectProductPackingEvent(this.producto);
}


class DeleteProductFromTemporaryPackageEvent extends PackingConsolidateEvent {
  final ProductoPedido product;

  DeleteProductFromTemporaryPackageEvent({
    required this.product,
  });
}
