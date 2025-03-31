class BarcodesInventarioTable {
  static const String tableName = 'tblbarcodes_inventario';

  static const String columnId = 'id';
  static const String columnIdQuant = 'id_quant';
  static const String columnIdProduct = 'id_product';
  static const String columnBarcode = 'barcode';
  static const String columnCantidad = 'cantidad';

  static String createTable() {
    return '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnIdQuant INTEGER,
      $columnIdProduct INTEGER,
      $columnBarcode TEXT,
      $columnCantidad DECIMAL(10,2)
    )
  ''';
  }
}
