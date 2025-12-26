class BarcodesInventarioTable {
  static const String tableName = 'tblbarcodes_inventario';

  static const String columnId = 'id';
  static const String columnIdProduct = 'id_product';
  static const String columnBarcode = 'barcode';
  static const String columnCantidad = 'cantidad';
  
  // ✅ NUEVO: Columna para Mark & Sweep
  static const String columnIsSynced = 'is_synced';

  static String createTable() {
    return '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnIdProduct INTEGER,
      $columnBarcode TEXT,
      $columnCantidad DECIMAL(10,2),
      $columnIsSynced INTEGER DEFAULT 0
    );

    -- ✅ ÍNDICES DE RENDIMIENTO (Creados al inicio)
    
    -- Para que el Upsert funcione automático (Reemplaza lógica manual)
    CREATE UNIQUE INDEX idx_unique_barcode_inv ON $tableName ($columnIdProduct, $columnBarcode);

    -- Para que getBarcodesProduct sea instantáneo
    CREATE INDEX idx_search_inv_product ON $tableName ($columnIdProduct);
  ''';
  }
}