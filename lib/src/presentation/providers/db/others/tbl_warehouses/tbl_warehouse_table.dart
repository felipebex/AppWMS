class WarehouseTable {
  static const String tableName = 'tbl_warehouses';

  static const String columnId = 'id';
  static const String columnName = 'name';


  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnName VARCHAR(255)
      )
    ''';
  }
  
}