part of 'wms_packing_bloc.dart';

@immutable
sealed class WmsPackingState {}

final class WmsPackingInitial extends WmsPackingState {}

//*estados para cargar todos los batchs para packing
final class WmsPackingLoading extends WmsPackingState {}

final class WmsProductInfoLoading extends WmsPackingState {}

final class WmsProductInfoLoaded extends WmsPackingState {}

final class WmsPackingLoaded extends WmsPackingState {}

final class WmsPackingError extends WmsPackingState {
  final String error;
  WmsPackingError(this.error);
}

class ChangeProductPackingIsOkState extends WmsPackingState {
  final bool isOk;
  ChangeProductPackingIsOkState(this.isOk);
}

class ChangeIsOkState extends WmsPackingState {
  final bool isOk;
  ChangeIsOkState(this.isOk);
}

class ChangeLocationPackingIsOkState extends WmsPackingState {
  final bool isOk;
  ChangeLocationPackingIsOkState(this.isOk);
}

class BatchsPackingLoadingState extends WmsPackingState {}

class ValidateFieldsPackingState extends WmsPackingState {
  final bool isOk;
  ValidateFieldsPackingState(this.isOk);
}

class ChangeQuantitySeparateState extends WmsPackingState {
  final int quantity;
  ChangeQuantitySeparateState(this.quantity);
}

class ChangeStickerState extends WmsPackingState {
  final bool isSticker;
  ChangeStickerState(this.isSticker);
}

class ShowKeyboardState extends WmsPackingState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}


class ListOfProductsForPackingState extends WmsPackingState {
  final List<PorductoPedido> productos;
  ListOfProductsForPackingState(this.productos);
}

//estado de carga mientras se hace el packing
class WmsPackingLoadingState extends WmsPackingState {}


 class WmsPackingSuccessState extends WmsPackingState {
  final String message;
  WmsPackingSuccessState(this.message);
}

class WmsPackingErrorState extends WmsPackingState {
  final String message;
  WmsPackingErrorState(this.message);
}


class NovedadesPackingLoadedState  extends WmsPackingState {
  final List<Novedad> listOfNovedades;
  NovedadesPackingLoadedState({required this.listOfNovedades});
}