class CategoriasConteoTable {
  static const String tableName = 'tbl_categorias_conteo';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnOrdenConteoId = 'orden_conteo_id';

  static String createTable() {
    return '''
    CREATE TABLE $tableName (
      $columnId INTEGER NOT NULL,
      $columnName TEXT,
      $columnOrdenConteoId INTEGER,
       PRIMARY KEY ($columnId, $columnOrdenConteoId)
    )
    ''';
  }

}