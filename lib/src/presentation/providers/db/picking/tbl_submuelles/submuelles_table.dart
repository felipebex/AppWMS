// submuelles_table.dart

class SubmuellesTable {
  static const String tableName = 'tblsubmuelles';

  // Columnas de la tabla
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnCompleteName = 'complete_name';
  static const String columnBarcode = 'barcode';
  static const String columnLocationId = 'location_id';

  // Método para crear la tabla
  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT,
        $columnCompleteName TEXT,
        $columnBarcode TEXT,
        $columnLocationId INTEGER
      )
    ''';
  }
}