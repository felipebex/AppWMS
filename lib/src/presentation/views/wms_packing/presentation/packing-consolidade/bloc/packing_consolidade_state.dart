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
