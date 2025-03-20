class ProductEntradaTable {
  static const String tableName = 'product_entrada';

  static const String columnId = 'id';
  static const String columnIdMove = 'id_move';
  static const String columnProductId = 'product_id';
  static const String columnIdRecepcion = 'id_recepcion';
  static const String columnProductName = 'product_name';
  static const String columnProductCode = 'product_code';
  static const String columnProductBarcode = 'product_barcode';
  static const String columnProductTracking = 'product_tracking';
  static const String columnFechaVencimiento = 'fecha_vencimiento';
  static const String columnDiasVencimiento = 'dias_vencimiento';
  static const String columnQuantityOrdered = 'quantity_ordered';
  static const String columnQuantityToReceive = 'quantity_to_receive';
  static const String columnQuantityDone = 'quantity_done';
  static const String columnUom = 'uom';
  static const String columnLocationDestId = 'location_dest_id';
  static const String columnLocationDestName = 'location_dest_name';
  static const String columnLocationDestBarcode = 'location_dest_barcode';

  static const String columnLocationId = 'location_id';
  static const String columnLocationName = 'location_name';
  static const String columnLocationBarcode = 'location_barcode';
  static const String columnWeight = 'weight';

//info operaciones
  static const String columnIsSelected = 'is_selected';
  static const String columnIsSeparate = 'is_separate';
  static const String columnIsProductSplit = 'is_product_split';
  static const String columnObservation = 'observation';
  static const String columnQuantitySeparate = 'quantity_separate';

  static const String columnLoteId = 'lote_id';
  static const String columnLoteName = 'lote_name';
  static const String columnLoteDate = 'lote_date';
  
  static const String columnProductIsOk = 'product_is_ok';
  static const String columnIsQuantityIsOk = 'is_quantity_is_ok';
 

  static const String columnDateSeparate = 'date_separate';

//Meotdo para crar la tabla
  static String createTable() {
    return '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnIdMove INTEGER,
      $columnProductId TEXT,
      $columnIdRecepcion INTEGER,
      $columnProductName TEXT,
      $columnProductCode TEXT,
      $columnProductBarcode TEXT,
      $columnProductTracking TEXT,
      $columnFechaVencimiento TEXT,
      $columnDiasVencimiento INTEGER,
      $columnQuantityOrdered INTEGER,
      $columnQuantityToReceive INTEGER,
      $columnQuantityDone INTEGER,
      $columnUom TEXT,
      $columnLocationDestId INTEGER,
      $columnLocationDestName TEXT,
      $columnLocationDestBarcode TEXT,
      $columnLocationBarcode TEXT,
      $columnLocationId INTEGER,
      $columnLocationName TEXT,
      $columnWeight REAL,
      $columnIsSelected INTEGER,
      $columnIsSeparate INTEGER,
      $columnIsProductSplit INTEGER,
      $columnObservation TEXT,
      $columnQuantitySeparate INTEGER,

      $columnLoteId INTEGER,
      $columnLoteName TEXT,
      $columnProductIsOk INTEGER,
      $columnIsQuantityIsOk INTEGER,
      $columnDateSeparate TEXT,
      $columnLoteDate TEXT,
      FOREIGN KEY ($columnIdRecepcion) REFERENCES tbl_entradas_recepcion ($columnId)

    )
  ''';
  }
}
