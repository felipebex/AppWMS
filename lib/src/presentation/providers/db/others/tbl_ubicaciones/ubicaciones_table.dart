class UbicacionesTable {
  static const String tableName = 'tblUbicaciones';

  static const String columnId = 'id';
  static const String columnBarcode = 'barcode';
  static const String columnName = 'name';
  static const String columnLocationId = 'location_id';
  static const String columnLocationName = 'location_name';

  static String createTable() {
    return '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnBarcode TEXT,
      $columnName TEXT,
      $columnLocationId INTEGER,
      $columnLocationName TEXT
    )
  ''';
  }
}
