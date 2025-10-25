part of 'packing_consolidade_bloc.dart';

@immutable
sealed class PackingConsolidateEvent {}

class LoadConfigurationsUserPackConsolidate extends PackingConsolidateEvent {
  LoadConfigurationsUserPackConsolidate();
}

class LoadAllPackingConsolidateEvent extends PackingConsolidateEvent {
  LoadAllPackingConsolidateEvent();
}

class SearchBatchPackingEvent extends PackingConsolidateEvent {
  final String query;
  final int indexMenu;

  SearchBatchPackingEvent(this.query, this.indexMenu);
}

class ShowKeyboardEvent extends PackingConsolidateEvent {
  final bool showKeyboard;

  ShowKeyboardEvent(this.showKeyboard);
}


class ClearScannedValuePackEvent extends PackingConsolidateEvent {
  final String scan;
  ClearScannedValuePackEvent(this.scan);
}


class UpdateScannedValuePackEvent extends PackingConsolidateEvent {
  final String scannedValue;
  final String scan;
  UpdateScannedValuePackEvent(this.scannedValue, this.scan);
}
