part of 'wms_picking_bloc.dart';

@immutable
sealed class PickingEvent {}

//*evento para cargar todos los productos de odoo
class LoadAllProductsEvent extends PickingEvent {
  LoadAllProductsEvent();
}

//*evento para cargar todos los batchs de odoo

class LoadAllBatchsEvent extends PickingEvent {
  LoadAllBatchsEvent();
}

//*evento para buscar un producto

class SearchProductsEvent extends PickingEvent {
  final String query;

  SearchProductsEvent(this.query);
}

class ClearSearchEvent extends PickingEvent {
  ClearSearchEvent();
}

//*evento para cargar productos de la base de datos
class LoadProductsFromDBEvent extends PickingEvent {
  LoadProductsFromDBEvent();
}

class SearchBatchEvent extends PickingEvent {
  final String query;

  SearchBatchEvent(this.query);
}


//*evento para cargar los batchs de la base de datos

class LoadBatchsFromDBEvent extends PickingEvent {
  LoadBatchsFromDBEvent();
}


//*evento para cargar los productos de un batch
class LoadAllProductsFromBatchEvent extends PickingEvent {
  final int batchId;

  LoadAllProductsFromBatchEvent(this.batchId);
}

//* evento para eliminar la busqueda de los batchs
class ClearSearchBacthEvent extends PickingEvent {
  ClearSearchBacthEvent();
}


class FilterBatchesBStatusEvent extends PickingEvent {
  final String status;

  FilterBatchesBStatusEvent(this.status);
}
