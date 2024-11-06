part of 'wms_packing_bloc.dart';

@immutable
sealed class WmsPackingEvent {}

class LoadAllPackingEvent extends WmsPackingEvent {
  LoadAllPackingEvent(
  );
}

class LoadBatchPackingFromDBEvent extends WmsPackingEvent {
  LoadBatchPackingFromDBEvent(
  );
}


class LoadAllPedidosFromBatchEvent extends WmsPackingEvent {
  final int batchId;
  LoadAllPedidosFromBatchEvent(
    this.batchId,
  );
}

// 
class AddProductPackingEvent extends WmsPackingEvent {}


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



