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
  static const String columnType = 'type'; // si es de type batch o pedido

  //temperature
  static const String columnManejoTemperature = 'maneja_temperatura';
  static const String columnTemperature = 'temperatura';
  static const String columnImage = 'image';
  static const String columnImageNovedad = 'image_novedad';

  static const String columnTimeSeparate = 'time_separate';
  static const String columnTimeSeparateStart = 'time_separate_start';
  static const String columnTimeSeparateEnd = 'time_separate_end';

  //product_code
  static const String columnProductCode = 'product_code';

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
        $columnQuantity REAL,
        $columnTracking TEXT,


        $columnBarcode TEXT,
        $columnWeight INTEGER,
        
        $columnUnidades TEXT,
        $columnIsSelected INTEGER,
        $columnIsSeparate INTEGER,
        $columnQuantitySeparate REAL,
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
        $columnType TEXT,
        

        $columnManejoTemperature INTEGER,
        $columnTemperature INTEGER,
        $columnImage TEXT,
        $columnImageNovedad TEXT,
        $columnProductCode TEXT,
        $columnTimeSeparate REAL,
        $columnTimeSeparateStart VARCHAR(255),
        $columnTimeSeparateEnd VARCHAR(255),

        FOREIGN KEY ($columnIdPackage) REFERENCES tblpackages ($columnId),
        FOREIGN KEY ($columnPedidoId) REFERENCES tblpedidos_packing (id)
      )
    ''';
  }
}
