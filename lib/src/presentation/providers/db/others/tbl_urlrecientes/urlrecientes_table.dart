// urls_recientes_table.dart

class UrlsRecientesTable {
  static const String tableName = 'tblurlsrecientes';

  // Columnas de la tabla
  static const String columnId = 'id';
  static const String columnUrl = 'url';
  static const String columnFecha = 'fecha';

  // Método para crear la tabla
  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnUrl VARCHAR(255),
        $columnFecha VARCHAR(255)
      )
    ''';
  }
}