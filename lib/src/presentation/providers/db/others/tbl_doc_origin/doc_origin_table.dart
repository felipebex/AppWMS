// batch_picking_table.dart

import 'package:wms_app/src/presentation/providers/db/picking/tbl_batch/batch_picking_table.dart';

class DocOriginTable {
  static const String tableName = 'tbldoc_origin';

  // Columnas de la tabla
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnIdBatch = 'id_batch';
  static const String columnOriginType = 'origin_type';

  // Método para crear la tabla
  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnName VARCHAR(255),
        $columnIdBatch INTEGER,
        $columnOriginType VARCHAR(100),
        FOREIGN KEY ($columnIdBatch) REFERENCES ${BatchPickingTable.tableName} (id)
    ''';
  }
}
