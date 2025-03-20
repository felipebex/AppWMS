part of 'recepcion_bloc.dart';

@immutable
sealed class RecepcionState {}

final class RecepcionInitial extends RecepcionState {}

//estados para obtener todas las orndes de compras
class FetchOrdenesCompraLoading extends RecepcionState {}

class FetchOrdenesCompraSuccess extends RecepcionState {
  final List<ResultEntrada> ordenesCompra;
  FetchOrdenesCompraSuccess(this.ordenesCompra);
}

class FetchOrdenesCompraFailure extends RecepcionState {
  final String error;
  FetchOrdenesCompraFailure(this.error);
}

class ShowKeyboardState extends RecepcionState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}

//estados para buscar una  orden de compra

class SearchOrdenCompraSuccess extends RecepcionState {
  final List<ResultEntrada> ordenesCompra;
  SearchOrdenCompraSuccess(this.ordenesCompra);
}

class SearchOrdenCompraFailure extends RecepcionState {
  final String error;
  SearchOrdenCompraFailure(this.error);
}

///metodo para asignar un usuario a una orden de compra
class AssignUserToOrderLoading extends RecepcionState {}

class AssignUserToOrderSuccess extends RecepcionState {}

class AssignUserToOrderFailure extends RecepcionState {
  final String error;
  AssignUserToOrderFailure(this.error);
}

//metodo para obtener todas las entradas de recepcion dsde la bd
class FetchOrdenesCompraOfBdLoading extends RecepcionState {}

class FetchOrdenesCompraOfBdSuccess extends RecepcionState {
  final List<ResultEntrada> ordenesCompra;
  FetchOrdenesCompraOfBdSuccess(this.ordenesCompra);
}

class FetchOrdenesCompraOfBdFailure extends RecepcionState {
  final String error;
  FetchOrdenesCompraOfBdFailure(this.error);
}

//metodo para obtener los productos de una entrada
class GetProductsToEntradaLoading extends RecepcionState {}

class GetProductsToEntradaSuccess extends RecepcionState {
  final List<LineasRecepcion> productos;
  GetProductsToEntradaSuccess(this.productos);
}

class GetProductsToEntradaFailure extends RecepcionState {
  final String error;
  GetProductsToEntradaFailure(this.error);
}

//metodo para cargar la informacion del producto actual
class FetchPorductOrderLoading extends RecepcionState {}

class FetchPorductOrderSuccess extends RecepcionState {
  final LineasRecepcion producto;
  FetchPorductOrderSuccess(this.producto);
}

class FetchPorductOrderFailure extends RecepcionState {
  final String error;
  FetchPorductOrderFailure(this.error);
}

class ValidateFieldsOrderState extends RecepcionState {
  final bool isOk;
  ValidateFieldsOrderState({required this.isOk});
}

class ClearScannedValueOrderState extends RecepcionState {}

class UpdateScannedValueOrderState extends RecepcionState {
  final String scannedValue;
  final String scan;
  UpdateScannedValueOrderState(this.scannedValue, this.scan);
}


class ChangeIsOkState extends RecepcionState {
  final bool isOk;
  ChangeIsOkState(this.isOk);
}

class ChangeProductOrderIsOkState extends RecepcionState {
  final bool isOk;
  ChangeProductOrderIsOkState(this.isOk);
}
class ChangeLoteOrderIsOkState extends RecepcionState {
  final bool isOk;
  ChangeLoteOrderIsOkState(this.isOk);
}

class ConfigurationLoadedOrder extends RecepcionState {
  final Configurations configurations;

  ConfigurationLoadedOrder(this.configurations);
}

class ConfigurationErrorOrder extends RecepcionState {
  final String error;

  ConfigurationErrorOrder(this.error);
}

class ChangeQuantitySeparateState extends RecepcionState {
  final int quantity;
  ChangeQuantitySeparateState(this.quantity);
}

class ShowQuantityOrderState extends RecepcionState {
  final bool showQuantity;
  ShowQuantityOrderState(this.showQuantity);
}

class ChangeQuantitySeparateOrder extends RecepcionState {
  final int quantity;
  ChangeQuantitySeparateOrder(this.quantity);
}

class ChangeQuantitySeparateErrorOrder extends RecepcionState {
  final String error;
  ChangeQuantitySeparateErrorOrder(this.error);
}

//*estados para cargar las novedades
class NovedadesOrderLoadedState extends RecepcionState {
  final List<Novedad> listOfNovedades;
  NovedadesOrderLoadedState({required this.listOfNovedades});
}

class NovedadesOrderLoadingState extends RecepcionState {}

class NovedadesOrderErrorState extends RecepcionState {
  final String message;
  NovedadesOrderErrorState(this.message);
}



class FinalizarRecepcionProductoLoading extends RecepcionState {}

class FinalizarRecepcionProductoSuccess extends RecepcionState {}

class FinalizarRecepcionProductoFailure extends RecepcionState {
  final String error;
  FinalizarRecepcionProductoFailure(this.error);
}



class FinalizarRecepcionProductoSplitLoading extends RecepcionState {}

class FinalizarRecepcionProductoSplitSuccess extends RecepcionState {}

class FinalizarRecepcionProductoSplitFailure extends RecepcionState {
  final String error;
  FinalizarRecepcionProductoSplitFailure(this.error);
}



class GetLotesProductLoading extends RecepcionState {}

class GetLotesProductSuccess extends RecepcionState {
  final List<LotesProduct> lotesProduct;
  GetLotesProductSuccess(this.lotesProduct);
}

class GetLotesProductFailure extends RecepcionState {
  final String error;
  GetLotesProductFailure(this.error);
}


class SendProductToOrderLoading extends RecepcionState {}

class SendProductToOrderSuccess extends RecepcionState {}

class SendProductToOrderFailure extends RecepcionState {
  final String error;
  SendProductToOrderFailure(this.error);
}



class CreateLoteProductLoading extends RecepcionState {}

class CreateLoteProductSuccess extends RecepcionState {}

class CreateLoteProductFailure extends RecepcionState {
  final String error;
  CreateLoteProductFailure(this.error);
}


class CurrentOrdenesCompraState extends RecepcionState {
  final ResultEntrada ordenCompra;
  CurrentOrdenesCompraState(this.ordenCompra);
}



class StartOrStopTimeOrderSuccess extends RecepcionState {
  final String isStarted;
  StartOrStopTimeOrderSuccess(this.isStarted);
}


class CreateBackOrderOrNotLoading extends RecepcionState {}


class CreateBackOrderOrNotSuccess extends RecepcionState {
  final bool isBackorder;
  CreateBackOrderOrNotSuccess(this.isBackorder);
}

class CreateBackOrderOrNotFailure extends RecepcionState {
  final String error;
  CreateBackOrderOrNotFailure(this.error);
}