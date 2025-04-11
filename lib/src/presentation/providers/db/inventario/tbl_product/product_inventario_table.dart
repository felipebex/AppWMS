class ProductInventarioTable {
  static const String tableName = 'tblproductos_inventario';

  // Columnas de la tabla
  static const String columnId = 'id';
  static const String columnProductId = 'product_id';
  static const String columnProductName = 'name';
  static const String columnBarcode = 'barcode';
  static const String columnProductracking = 'tracking';
  static const String columnLotId = 'lot_id';
  static const String columnLotName = 'lot_name';
  static const String columnExpirationDate = 'expiration_time';
  static const String columnProductCode = 'code';

  //weight
  static const String columnWeight = 'weight';
  // weight_uom_name
  static const String columnWeightUomName = 'weight_uom_name';
  //volume
  static const String columnVolume = 'volume';
  //volume_uom_name
  static const String columnVolumeUomName = 'volume_uom_name';

  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnProductCode TEXT,
        $columnProductId INTEGER,
        $columnProductName TEXT,
        $columnBarcode TEXT,
        $columnProductracking TEXT,
        $columnLotId INTEGER,
        $columnLotName TEXT,
        $columnExpirationDate TEXT,
        $columnWeight REAL,
        $columnWeightUomName TEXT,
        $columnVolume REAL,
        $columnVolumeUomName TEXT
        )

        ''';
  }
}
