// pedidos_packing_table.dart

class PedidosPackingTable {
  static const String tableName = 'tblpedidos_packing';

  // Columnas de la tabla
  static const String columnId = 'id';
  static const String columnBatchId = 'batch_id';
  static const String columnName = 'name';
  static const String columnReferencia = 'referencia';
  static const String columnFecha = 'fecha';
  static const String columnContacto = 'contacto';
  static const String columnContactoName = 'contacto_name';
  static const String columnTipoOperacion = 'tipo_operacion';
  static const String columnCantidadProductos = 'cantidad_productos';
  static const String columnNumeroPaquetes = 'numero_paquetes';
  static const String columnIsSelected = 'is_selected';
  static const String columnIsTerminate = 'is_terminate';
  static const String columnIsZonaEntrega = 'zona_entrega';
  static const String columnIsZonaEntregaTms = 'zona_entrega_tms';



  // Método para crear la tabla
  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnBatchId INTEGER,
        $columnName TEXT,
        $columnReferencia TEXT,
        $columnFecha TEXT,
        $columnContacto TEXT,
        $columnContactoName TEXT,
        $columnTipoOperacion TEXT,
        $columnCantidadProductos REAL,
        $columnNumeroPaquetes INTEGER,
        $columnIsSelected INTEGER,
        $columnIsTerminate INTEGER,
        $columnIsZonaEntrega TEXT,
        $columnIsZonaEntregaTms TEXT,
        FOREIGN KEY ($columnBatchId) REFERENCES tblbatchs_packing (id)
      )
    ''';
  }
}
