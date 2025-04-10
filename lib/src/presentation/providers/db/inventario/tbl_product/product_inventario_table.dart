class ProductInventarioTable {
  static const String tableName = 'tblproductos_inventario';

  // Columnas de la tabla
  static const String columnId = 'id';
  static const String columnQuantId = 'quant_id';
  static const String columnLocationId = 'location_id';
  static const String columnLocationName = 'location_name';
  static const String columnProductId = 'product_id';
  static const String columnProductName = 'product_name';
  static const String columnBarcode = 'barcode';
  static const String columnProductracking = 'product_tracking';
  static const String columnLotId = 'lot_id';
  static const String columnLotName = 'lot_name';
  static const String columnInDate = 'in_date';
  static const String columnExpirationDate = 'expiration_date';
  static const String columnAvailableQuantity = 'available_quantity';
  static const String columnQuantity = 'quantity';
  // product_code
  static const String columnProductCode = 'product_code';


  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnQuantId INTEGER,
        $columnLocationId INTEGER,
        $columnLocationName TEXT,
        $columnProductCode TEXT,
        $columnProductId INTEGER,
        $columnProductName TEXT,
        $columnBarcode TEXT,
        $columnProductracking TEXT,
        $columnLotId INTEGER,
        $columnLotName TEXT,
        $columnInDate TEXT,
        $columnExpirationDate TEXT,
        $columnAvailableQuantity INTEGER,
        $columnQuantity INTEGER
        )

        ''';
  }
}
