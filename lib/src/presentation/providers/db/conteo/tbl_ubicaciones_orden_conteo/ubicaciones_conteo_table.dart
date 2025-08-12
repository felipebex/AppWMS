class UbicacionesConteoTable {
  static const String tableName = 'tbl_ubicaciones_conteo';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnOrdenConteoId = 'orden_conteo_id';
  //barcode
  static const String columnBarcode = 'barcode';



  static String createTable() {
    return '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnName TEXT,
      $columnOrdenConteoId INTEGER,
      $columnBarcode TEXT,
      FOREIGN KEY ($columnOrdenConteoId) REFERENCES tbl_orden_conteo(id)
    )
    ''';
  }
}
