// tblpackages_table.dart

class PackagesTable {
  static const String tableName = 'tblpackages';

  // Columnas de la tabla
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnBatchId = 'batch_id';
  static const String columnPedidoId = 'pedido_id';
  static const String columnCantidadProductos = 'cantidad_productos';
  static const String columnIsSticker = 'is_sticker';

  // Método para crear la tabla
  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnName VARCHAR(255),
        $columnBatchId INTEGER,
        $columnPedidoId INTEGER,
        $columnCantidadProductos INTEGER,
        $columnIsSticker INTEGER,
        FOREIGN KEY ($columnPedidoId) REFERENCES tblpedidos_packing (id)
      )
    ''';
  }
}
