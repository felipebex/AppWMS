// tblproductos_pedidos_table.dart

class ProductosPedidosTable {
  static const String tableName = 'tblproductos_pedidos';

  // Columnas de la tabla
  static const String columnId = 'id';
  static const String columnProductId = 'product_id';
  static const String columnBatchId = 'batch_id';
  static const String columnPedidoId = 'pedido_id';
  static const String columnIdProduct = 'id_product';
  static const String columnLoteId = 'lote_id';
  static const String columnLotId = 'lot_id';
  static const String columnLocationId = 'location_id';
  static const String columnIdLocation = 'id_location';
  static const String columnLocationDestId = 'location_dest_id';
  static const String columnIdLocationDest = 'id_location_dest';
  static const String columnQuantity = 'quantity';
  static const String columnTracking = 'tracking';
  static const String columnBarcode = 'barcode';
  static const String columnWeight = 'weight';
  static const String columnUnidades = 'unidades';
  static const String columnIdMove = 'id_move';
  static const String columnIsSelected = 'is_selected';
  static const String columnIsSeparate = 'is_separate';
  static const String columnQuantitySeparate = 'quantity_separate';
  static const String columnIsCertificate = 'is_certificate';
  static const String columnExpireDate = 'expire_date';
  static const String columnIsLocationIsOk = 'is_location_is_ok';
  static const String columnIsProductSplit = 'is_product_split';
  static const String columnBarcodeLocation = 'barcode_location';
  static const String columnProductIsOk = 'product_is_ok';
  static const String columnIsQuantityIsOk = 'is_quantity_is_ok';
  static const String columnLocationDestIsOk = 'location_dest_is_ok';
  static const String columnObservation = 'observation';
  static const String columnIsPackage = 'is_package';
  static const String columnIsPacking = 'is_packing';
  static const String columnIdPackage = 'id_package';
  static const String columnPackageName = 'package_name';

  // Método para crear la tabla
  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,

        $columnIdMove INTEGER,
        $columnProductId TEXT,
        $columnBatchId INTEGER,
        $columnPedidoId INTEGER,
        $columnIdProduct INTEGER,

        $columnLoteId INTEGER,
        $columnLotId TEXT,
        $columnExpireDate VARCHAR(255),
        $columnLocationId TEXT,
        $columnIdLocation INTEGER,
        $columnBarcodeLocation TEXT,
        $columnLocationDestId TEXT,
        $columnIdLocationDest INTEGER,
        $columnQuantity INTEGER,
        $columnTracking TEXT,


        $columnBarcode TEXT,
        $columnWeight INTEGER,
        
        $columnUnidades TEXT,
        $columnIsSelected INTEGER,
        $columnIsSeparate INTEGER,
        $columnQuantitySeparate INTEGER,
        $columnIsCertificate INTEGER,
        $columnIsLocationIsOk INTEGER,
        $columnIsProductSplit INTEGER,
        $columnProductIsOk INTEGER,
        $columnIsQuantityIsOk INTEGER,
        $columnLocationDestIsOk INTEGER,
        $columnObservation TEXT,
        $columnIsPackage INTEGER,
        $columnIsPacking INTEGER,
        $columnIdPackage INTEGER,
        $columnPackageName TEXT,
        FOREIGN KEY ($columnIdPackage) REFERENCES tblpackages ($columnId),
        FOREIGN KEY ($columnPedidoId) REFERENCES tblpedidos_packing (id)
      )
    ''';
  }
}
