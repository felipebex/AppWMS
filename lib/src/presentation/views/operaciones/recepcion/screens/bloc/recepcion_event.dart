part of 'recepcion_bloc.dart';

@immutable
sealed class RecepcionEvent {}

class FetchOrdenesCompra extends RecepcionEvent {
  BuildContext context;
  FetchOrdenesCompra(this.context);
}

class FetchOrdenesCompraOfBd extends RecepcionEvent {
  BuildContext context;
  FetchOrdenesCompraOfBd(this.context);
}

class ShowKeyboardEvent extends RecepcionEvent {
  final bool showKeyboard;
  ShowKeyboardEvent(this.showKeyboard);
}

class SearchOrdenCompraEvent extends RecepcionEvent {
  final String query;
  SearchOrdenCompraEvent(this.query);
}

class AssignUserToOrder extends RecepcionEvent {
  final int idOrder;
  final BuildContext context;
  AssignUserToOrder(
    this.idOrder,
    this.context,
  );
}

class LoadConfigurationsUserOrder extends RecepcionEvent {}

class GetPorductsToEntrada extends RecepcionEvent {
  final int idEntrada;
  GetPorductsToEntrada(this.idEntrada);
}

class FetchPorductOrder extends RecepcionEvent {
  final LineasRecepcion product;
  final BuildContext  context;
  FetchPorductOrder(this.product, this.context);
}

class ValidateFieldsOrderEvent extends RecepcionEvent {
  final String field;
  final bool isOk;
  ValidateFieldsOrderEvent({required this.field, required this.isOk});
}

class ClearScannedValueOrderEvent extends RecepcionEvent {
  final String scan;
  ClearScannedValueOrderEvent(this.scan);
}

class UpdateScannedValueOrderEvent extends RecepcionEvent {
  final String scannedValue;
  final String scan;
  UpdateScannedValueOrderEvent(this.scannedValue, this.scan);
}

//* CAMBIAR VALORES DE VARIABLES




class ChangeProductIsOkEvent extends RecepcionEvent {
  final int idEntrada;
  final bool productIsOk;
  final int productId;
  final int quantity;
  final int idMove;
  ChangeProductIsOkEvent(this.idEntrada, this.productIsOk, this.productId,
      this.quantity, this.idMove);
}
class SelectecLoteEvent extends RecepcionEvent {
  final LotesProduct lote;
  SelectecLoteEvent(this.lote);
}

class ChangeIsOkQuantity extends RecepcionEvent {
  final int idEntrada;
  final bool isOk;
  final int productId;
  final int idMove;
  ChangeIsOkQuantity(this.idEntrada, this.isOk, this.productId, this.idMove);
}

class ChangeQuantitySeparate extends RecepcionEvent {
  final int quantity;
  final int productId;
  final int idRecepcion;
  final int idMove;
  ChangeQuantitySeparate(
      this.quantity, this.productId, this.idRecepcion, this.idMove);
}

class ShowQuantityOrderEvent extends RecepcionEvent {
  final bool showQuantity;
  ShowQuantityOrderEvent(this.showQuantity);
}

class AddQuantitySeparate extends RecepcionEvent {
  final int idRecepcion;
  final int productId;
  final int idMove;
  final int quantity;
  AddQuantitySeparate(
    this.idRecepcion,
    this.productId,
    this.idMove,
    this.quantity,
  );
}

class LoadAllNovedadesOrderEvent extends RecepcionEvent {}

class FinalizarRecepcionProducto extends RecepcionEvent {
}


class FinalizarRecepcionProductoSplit extends RecepcionEvent {

  final int quantity;

  FinalizarRecepcionProductoSplit(this.quantity);

}


class GetLotesProduct extends RecepcionEvent {
  final BuildContext  context;

  GetLotesProduct(this.context);
}

class SendProductToOrder extends RecepcionEvent {
  final BuildContext context;
  SendProductToOrder(this.context);
}


class CreateLoteProduct extends RecepcionEvent {
  final BuildContext context;
  final String nameLote;
  final String fechaCaducidad;
  CreateLoteProduct(this.context, this.nameLote, this.fechaCaducidad);
}