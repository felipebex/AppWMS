// novedades_table.dart

class NovedadesTable {
  static const String tableName = 'tblnovedades';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnCode = 'code';

  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT,
        $columnCode TEXT
      )
    ''';
  }
}