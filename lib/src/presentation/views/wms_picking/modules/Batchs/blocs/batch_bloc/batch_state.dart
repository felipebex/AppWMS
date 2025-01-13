part of 'batch_bloc.dart';

@immutable
sealed class BatchState {}

final class BatchInitial extends BatchState {}


final class ProductsBatchLoadingState extends BatchState {}


final class LoadProductsBatchSuccesState extends BatchState {
  final List<ProductsBatch> listOfProductsBatch;
  LoadProductsBatchSuccesState({required this.listOfProductsBatch});
}



final class LoadProductsBatchSuccesStateBD extends BatchState {
  final List<ProductsBatch> listOfProductsBatch;
  LoadProductsBatchSuccesStateBD({required this.listOfProductsBatch});
}



class ShowKeyboardState extends BatchState {
  final bool showKeyboard;
  ShowKeyboardState({required this.showKeyboard});
}

class ShouldRunDependenciesState extends BatchState {
  final bool shouldRunDependencies;
  ShouldRunDependenciesState({required this.shouldRunDependencies});
}




final class BatchErrorState extends BatchState {
  final String error;
  BatchErrorState(this.error);
}


final class EmptyroductsBatch extends BatchState {}


final class GetProductByIdLoaded extends BatchState {
  final Products product;
  GetProductByIdLoaded(this.product);
}


class ChangeIsOkState extends BatchState {
  final bool isOk;
  ChangeIsOkState(this.isOk);
}
class ChangeProductIsOkState extends BatchState {
  final bool isOk;
  ChangeProductIsOkState(this.isOk);
}
class ChangeLocationIsOkState extends BatchState {
  final bool isOk;
  ChangeLocationIsOkState(this.isOk);
}


final class CurrentProductChangedState extends BatchState {
  final ProductsBatch currentProduct;
  final int index;
  CurrentProductChangedState({required this.currentProduct, required this.index});
}



final class QuantityChangedState extends BatchState {
  final int quantity;
  QuantityChangedState(this.quantity);
}


class SelectNovedadState extends BatchState {
  final String novedad;
  SelectNovedadState(this.novedad);
}


class ValidateFieldsState extends BatchState {
  final bool isOk;
  ValidateFieldsState(this.isOk);
}


class LoadDataInfoState extends BatchState {
}


class ChangeQuantitySeparateState extends BatchState {
  final int quantity;
  ChangeQuantitySeparateState(this.quantity);
}

class PickingOkState extends BatchState {
}



class ConfigurationLoading extends BatchState {}

class ConfigurationLoaded extends BatchState {
  final Configurations configurations;

  ConfigurationLoaded(this.configurations);
}

class ConfigurationError extends BatchState {
  final String error;

  ConfigurationError(this.error);
}

class ProductPendingState extends BatchState {
  final List<ProductsBatch> listOfProductsBatch;
  ProductPendingState({required this.listOfProductsBatch});

}

class LoadingSendProductEdit extends BatchState {}

class ProductEditOk extends BatchState {}


class ScanBarcodeState extends BatchState {
  final String barcode;
  ScanBarcodeState(this.barcode);
}


class NovedadesLoadedState  extends BatchState {
  final List<Novedad> listOfNovedades;
  NovedadesLoadedState({required this.listOfNovedades});
}

class SelectSubMuelle extends BatchState {
  final Muelles subMuelle;
  SelectSubMuelle(this.subMuelle);
}

class SubMuelleEditSusses extends BatchState {
  final String message;
  SubMuelleEditSusses(this.message);
}
class SubMuelleEditFail extends BatchState {
  final String message;
  SubMuelleEditFail(this.message);
}