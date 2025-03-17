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
  ValidateFieldsOrderState({ required this.isOk});
}


class ClearScannedValueOrderState extends RecepcionState {}



class UpdateScannedValueOrderState extends RecepcionState {
  final String scannedValue;
  final String scan;
  UpdateScannedValueOrderState(this.scannedValue, this.scan);
}



class ChangeLocationOrderIsOkState extends RecepcionState {
  final bool isOk;
  ChangeLocationOrderIsOkState(this.isOk);
}


class ChangeIsOkState extends RecepcionState {
  final bool isOk;
  ChangeIsOkState(this.isOk);
}

class ChangeProductOrderIsOkState extends RecepcionState {
  final bool isOk;
  ChangeProductOrderIsOkState(this.isOk);
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