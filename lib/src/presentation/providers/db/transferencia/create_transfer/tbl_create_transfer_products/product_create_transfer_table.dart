class ProductCreateTransferTable {
  static const String tableName = 'tblproductos_create_transfer';

  // Columnas de la tabla
  static const String columnId = 'id';
  static const String columnProductId = 'product_id';
  static const String columnProductName = 'name';
  static const String columnBarcode = 'barcode';
  static const String columnProductracking = 'tracking';
  static const String columnLotId = 'lot_id';
  static const String columnLotName = 'lot_name';
  static const String columnLoteDate = 'lote_date';
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
  //uom
  static const String columnUom = 'uom';
  // int? locationId;
  static const String columnLocationId = 'location_id';
  // String? locationName;
  static const String columnLocationName = 'location_name';
  // dynamic quantity;
  static const String columnQuantity = 'quantity';

  //use_expiration_date
  static const String columnUseExpirationDate = 'use_expiration_date';


  static const String columnDateStart = 'date_start';
  static const String columnDateEnd = 'date_end';
  static const String columnTime = 'time';

  static const String columnDateTransaction = 'date_transaction';

  static const String columnQuantityDone = 'quantity_done';

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
        $columnUom TEXT,
        $columnLocationId INTEGER,
        $columnLocationName TEXT,
        $columnQuantity REAL,
        $columnUseExpirationDate INTEGER,
        $columnLoteDate TEXT,
        $columnDateStart TEXT,
        $columnDateEnd TEXT,
        $columnTime TEXT,
        $columnDateTransaction TEXT,
        $columnQuantityDone REAL,
        $columnVolumeUomName TEXT
        )

        ''';
  }
}
