// tbl_barcodes_packages.dart

class BarcodesPackagesTable {
  static const String tableName = 'tblbarcodes_packages';

  static const String columnId = 'id';
  static const String columnBatchId = 'batch_id';
  static const String columnIdMove = 'id_move';
  static const String columnIdProduct = 'id_product';
  static const String columnBarcode = 'barcode';
  static const String columnCantidad = 'cantidad';
  static const String columnBarcodeType = 'barcode_type';

  static String createTable() {
    return '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnBatchId INTEGER,
      $columnIdMove INTEGER,
      $columnIdProduct INTEGER,
      $columnBarcode TEXT,
      $columnBarcodeType TEXT,
      $columnCantidad DECIMAL(10,2),
      FOREIGN KEY ($columnBatchId) REFERENCES tblbatchs (id)
    )
  ''';
  }
}
