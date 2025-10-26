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

class LoadBatchPackingFromDBEvent extends PackingConsolidateEvent {
  LoadBatchPackingFromDBEvent();
}

//*empezar el tiempo de separacion
class StartTimePack extends PackingConsolidateEvent {
  final int batchId;
  final DateTime time;
  StartTimePack(this.batchId, this.time);
}

class EndTimePack extends PackingConsolidateEvent {
  final int batchId;
  final DateTime time;
  EndTimePack(this.batchId, this.time);
}

class LoadAllPedidosFromBatchEvent extends PackingConsolidateEvent {
  final int batchId;
  LoadAllPedidosFromBatchEvent(
    this.batchId,
  );
}

class LoadDocOriginsEvent extends PackingConsolidateEvent {
  final int idBatch;
  LoadDocOriginsEvent(this.idBatch);
}

class ShowDetailvent extends PackingConsolidateEvent {
  final bool show;
  ShowDetailvent(this.show);
}

class LoadAllProductsFromPedidoEvent extends PackingConsolidateEvent {
  final int pedidoId;
  LoadAllProductsFromPedidoEvent(
    this.pedidoId,
  );
}



class SearchPedidoPackingEvent extends PackingConsolidateEvent {
  final String query;
  final int idBatch;

  SearchPedidoPackingEvent(this.query, this.idBatch);
}
