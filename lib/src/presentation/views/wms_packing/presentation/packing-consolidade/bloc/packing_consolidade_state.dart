part of 'packing_consolidade_bloc.dart';

@immutable
sealed class PackingConsolidateState {}

final class PackingConsolidateInitial extends PackingConsolidateState {}

//*estasos para cargar la configuracion del usuario

class ConfigurationLoadingPack extends PackingConsolidateState {}

class ConfigurationLoadedPack extends PackingConsolidateState {
  final Configurations configurations;

  ConfigurationLoadedPack(this.configurations);
}

class ConfigurationErrorPack extends PackingConsolidateState {
  final String error;

  ConfigurationErrorPack(this.error);
}

class PackingConsolidateLoading extends PackingConsolidateState {}

class PackingConsolidateLoaded extends PackingConsolidateState {
  final List<BatchPackingModel> listOfBatchs;

  PackingConsolidateLoaded({required this.listOfBatchs});
}

//error al cargar los batchs
class PackingConsolidateError extends PackingConsolidateState {
  final String error;

  PackingConsolidateError(this.error);
}

class NeedUpdateVersionState extends PackingConsolidateState {}

class ShowKeyboardState extends PackingConsolidateState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}

class ClearScannedValuePackState extends PackingConsolidateState {}

class UpdateScannedValuePackState extends PackingConsolidateState {
  final String scannedValue;
  final String scan;
  UpdateScannedValuePackState(this.scannedValue, this.scan);
}

class BatchsPackingLoadingState extends PackingConsolidateState {}

final class WmsPackingLoadedBD extends PackingConsolidateState {}

//*tiempo de separacion
class TimeSeparatePackSuccess extends PackingConsolidateState {
  final String time;
  TimeSeparatePackSuccess(this.time);
}

class TimeSeparatePackError extends PackingConsolidateState {
  final String msg;
  TimeSeparatePackError(this.msg);
}

class LoadAllPedidosFromBatchLoaded extends PackingConsolidateState {
  final List<PedidoPacking> listOfPedidos;

  LoadAllPedidosFromBatchLoaded({required this.listOfPedidos});
}

class LoadDocOriginsState extends PackingConsolidateState {
  final List<Origin> listOfOrigins;
  LoadDocOriginsState({required this.listOfOrigins});
}

class ShowDetailState extends PackingConsolidateState {
  final bool show;
  ShowDetailState(this.show);
}


class LoadingLoadAllProductsFromPedido extends PackingConsolidateState {}

class LoadAllProductsFromPedidoLoaded extends PackingConsolidateState {
  final List<ProductoPedido> listOfProducts;

  LoadAllProductsFromPedidoLoaded({required this.listOfProducts});
}

class ErrorLoadAllProductsFromPedido extends PackingConsolidateState {
  final String error;

  ErrorLoadAllProductsFromPedido(this.error);
}

class SearPedidoPackingErrorState extends PackingConsolidateState {
  final String error;

  SearPedidoPackingErrorState(this.error);
}

class SearchPedidoPackingLoadedState extends PackingConsolidateState {
  final List<PedidoPacking> listOfPedidos;

  SearchPedidoPackingLoadedState({required this.listOfPedidos});
}


class ProductInfoLoading extends PackingConsolidateState {}

class ProductInfoLoaded extends PackingConsolidateState {}

class ProductInfoError extends PackingConsolidateState {
  final String error;

  ProductInfoError(this.error);
}

class ChangeLocationPackingIsOkState extends PackingConsolidateState {
  final bool isOk;
  ChangeLocationPackingIsOkState(this.isOk);
}
class ChangeStickerState extends PackingConsolidateState {
  final bool isSticker;
  ChangeStickerState(this.isSticker);
}

class UnSelectProductPackingErrorState extends PackingConsolidateState {
  final String error;

  UnSelectProductPackingErrorState(this.error);
}

class SelectProductPackingErrorState extends PackingConsolidateState {
  final String error;

  SelectProductPackingErrorState(this.error);
}


class SelectProductPackingLoadedState extends PackingConsolidateState {
  final List<ProductoPedido> listOfProductsForPacking;

  SelectProductPackingLoadedState({required this.listOfProductsForPacking});
}

class UnSelectProductPackingLoadedState extends PackingConsolidateState {
  final List<ProductoPedido> listOfProductsForPacking;

  UnSelectProductPackingLoadedState({required this.listOfProductsForPacking});
}




class DeleteProductFromTemporaryPackageLoading extends PackingConsolidateState {}


class DeleteProductFromTemporaryPackageError extends PackingConsolidateState {
  final String message;
  DeleteProductFromTemporaryPackageError(this.message);
}

class DeleteProductFromTemporaryPackageOkState extends PackingConsolidateState {}


class SetPickingPackingOkState extends PackingConsolidateState {}

class SetPickingPackingErrorState extends PackingConsolidateState {
  final String message;
  SetPickingPackingErrorState(this.message);
}

class SetPickingPackingLoadingState extends PackingConsolidateState {}


class SetPackingsErrorState extends PackingConsolidateState {
  final String message;
  SetPackingsErrorState(this.message);
}

class SetPackingsOkState extends PackingConsolidateState {
  final String message;
  SetPackingsOkState(this.message);
}

class SetPackingsLoadingState extends PackingConsolidateState {}