part of 'transferencia_bloc.dart';

@immutable
sealed class TransferenciaEvent {}

class FetchAllTransferencias extends TransferenciaEvent {
  final bool isLoadingDialog;
  FetchAllTransferencias(this.isLoadingDialog);
}

class FetchAllTransferenciasDB extends TransferenciaEvent {
  final bool isLoadingDialog;
  FetchAllTransferenciasDB(this.isLoadingDialog);
}

class CurrentTransferencia extends TransferenciaEvent {
  final ResultTransFerencias trasnferencia;
  CurrentTransferencia(this.trasnferencia);
}

class SearchTransferEvent extends TransferenciaEvent {
  final String query;
  SearchTransferEvent(this.query);
}

class ShowKeyboardEvent extends TransferenciaEvent {
  final bool showKeyboard;
  ShowKeyboardEvent({required this.showKeyboard});
}

class LoadConfigurationsUserTransfer extends TransferenciaEvent {}

class GetPorductsToTransfer extends TransferenciaEvent {
  final int idTransfer;
  GetPorductsToTransfer(this.idTransfer);
}

class FetchPorductTransfer extends TransferenciaEvent {
  final LineasTransferenciaTrans product;
  FetchPorductTransfer(
    this.product,
  );
}

class QuantityChanged extends TransferenciaEvent {
  final int quantity;
  QuantityChanged(this.quantity);
}

class SelectNovedadEvent extends TransferenciaEvent {
  final String novedad;
  SelectNovedadEvent(this.novedad);
}

class ValidateFieldsEvent extends TransferenciaEvent {
  final String field;
  final bool isOk;
  ValidateFieldsEvent({required this.field, required this.isOk});
}

//* CAMBIAR VALORES DE VARIABLES
class ChangeLocationIsOkEvent extends TransferenciaEvent {
  final int productId;
  final int idTransfer;
  final int idMove;
  ChangeLocationIsOkEvent(this.productId, this.idTransfer, this.idMove);
}

class ChangeLocationDestIsOkEvent extends TransferenciaEvent {
  final bool locationDestIsOk;
  final int productId;
  final int idTransfer;
  final int idMove;
  final ResultUbicaciones location;
  ChangeLocationDestIsOkEvent(this.locationDestIsOk, this.productId,
      this.idTransfer, this.idMove, this.location);
}

class ChangeProductIsOkEvent extends TransferenciaEvent {
  final bool productIsOk;
  final int productId;
  final int idTransfer;
  final int quantity;
  final int idMove;
  ChangeProductIsOkEvent(this.productIsOk, this.productId, this.idTransfer,
      this.quantity, this.idMove);
}

class ChangeIsOkQuantity extends TransferenciaEvent {
  final bool isOk;
  final int productId;
  final int idTransfer;
  final int idMove;
  ChangeIsOkQuantity(this.isOk, this.productId, this.idTransfer, this.idMove);
}

class UpdateScannedValueEvent extends TransferenciaEvent {
  final String scannedValue;
  final String scan;
  UpdateScannedValueEvent(this.scannedValue, this.scan);
}

class ClearScannedValueEvent extends TransferenciaEvent {
  final String scan;
  ClearScannedValueEvent(this.scan);
}

class ChangeQuantitySeparate extends TransferenciaEvent {
  final int quantity;
  final int productId;
  final int idMove;
  final int idTransfer;
  ChangeQuantitySeparate(
      this.quantity, this.productId, this.idMove, this.idTransfer);
}

class AddQuantitySeparate extends TransferenciaEvent {
  final int productId;
  final int idMove;
  final int quantity;
  final bool isOk;
  final int idTransfer;
  AddQuantitySeparate(
      this.productId, this.idMove, this.quantity, this.isOk, this.idTransfer);
}

class ShowQuantityEvent extends TransferenciaEvent {
  final bool showQuantity;
  ShowQuantityEvent(this.showQuantity);
}

class StartOrStopTimeTransfer extends TransferenciaEvent {
  final int idTransfer;
  final String value;

  StartOrStopTimeTransfer(
    this.idTransfer,
    this.value,
  );
}

class AssignUserToTransfer extends TransferenciaEvent {
  final ResultTransFerencias transfer;
  AssignUserToTransfer(
    this.transfer,
  );
}

class FinalizarTransferProducto extends TransferenciaEvent {}

class FinalizarTransferProductoSplit extends TransferenciaEvent {
  final int quantity;

  FinalizarTransferProductoSplit(this.quantity);
}

class SendProductToTransfer extends TransferenciaEvent {
  final bool isDividio;
  final int quantity;
  SendProductToTransfer(this.isDividio, this.quantity);
}

class LoadLocations extends TransferenciaEvent {}

class CreateBackOrderOrNot extends TransferenciaEvent {
  final int idRecepcion;
  final bool isBackOrder;
  CreateBackOrderOrNot(this.idRecepcion, this.isBackOrder);
}

class LoadAllNovedadesTransferEvent extends TransferenciaEvent {}

class FilterTransferByWarehouse extends TransferenciaEvent {
  final String warehouseName;
  FilterTransferByWarehouse(this.warehouseName);
}


class CheckAvailabilityEvent extends TransferenciaEvent {
  final int idTransfer;
  CheckAvailabilityEvent(this.idTransfer, );
}


class CleanFieldsEvent extends TransferenciaEvent {
}
