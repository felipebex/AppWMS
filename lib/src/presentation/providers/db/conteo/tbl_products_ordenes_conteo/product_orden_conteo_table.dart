import 'package:wms_app/src/presentation/providers/db/conteo/tbl_ordenes/orden_table.dart';

class ProductosOrdenConteoTable {
  static const String tableName = 'tblproductos_orden_conteo';

  // Columnas
  static const String columnId = 'id';
  static const String columnOrderId = 'order_id';
  static const String columnProductId = 'product_id';
  static const String columnProductName = 'product_name';
  static const String columnProductCode = 'product_code';
  static const String columnProductBarcode = 'product_barcode';
  static const String columnProductTracking = 'product_tracking';
  static const String columnLocationId = 'location_id';
  static const String columnLocationName = 'location_name';
  static const String columnLocationBarcode = 'location_barcode';
  static const String columnQuantityInventory = 'quantity_inventory';
  static const String columnQuantityCounted = 'quantity_counted';  // Cantidad contada
  static const String columnDifferenceQty = 'difference_qty';
  static const String columnUom = 'uom';
  static const String columnWeight = 'weight';
  static const String columnIsDoneItem = 'is_done_item';
  static const String columnDateTransaction = 'date_transaction';
  static const String columnObservation = 'observation';
  static const String columnTime = 'time';
  static const String columnUserOperatorId = 'user_operator_id';
  static const String columnUserOperatorName = 'user_operator_name';
  static const String columnCategoryId = 'category_id';
  static const String columnCategoryName = 'category_name';
  static const String columnLotId = 'lot_id';
  static const String columnLotName = 'lot_name';
  static const String columnFechaVencimiento = 'fecha_vencimiento';



  static String createTable() {
    return '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnOrderId INTEGER,
      $columnProductId INTEGER,
      $columnProductName TEXT,
      $columnProductCode TEXT,
      $columnProductBarcode TEXT,
      $columnProductTracking TEXT,
      $columnLocationId INTEGER,
      $columnLocationName TEXT,
      $columnLocationBarcode TEXT,
      $columnQuantityInventory REAL,
      $columnQuantityCounted REAL,
      $columnDifferenceQty REAL,
      $columnUom TEXT,
      $columnWeight REAL,
      $columnIsDoneItem INTEGER,
      $columnDateTransaction TEXT,
      $columnObservation TEXT,
      $columnTime TEXT,
      $columnUserOperatorId INTEGER,
      $columnUserOperatorName TEXT,
      $columnCategoryId INTEGER,
      $columnCategoryName TEXT,
      $columnLotId INTEGER,
      $columnLotName TEXT,
      $columnFechaVencimiento TEXT
      )
    ''';
  }
}
