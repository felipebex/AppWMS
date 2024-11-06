part of 'wms_packing_bloc.dart';

@immutable
sealed class WmsPackingState {}

final class WmsPackingInitial extends WmsPackingState {}

//*estados para cargar todos los batchs para packing
final class WmsPackingLoading extends WmsPackingState {}

final class WmsPackingLoaded extends WmsPackingState {
}

final class WmsPackingError extends WmsPackingState {
  final String error;
  WmsPackingError(this.error);
}



class ChangeIsOkState extends WmsPackingState {
  final bool isOk;
  ChangeIsOkState(this.isOk);
}


class BatchsPackingLoadingState extends WmsPackingState {}





