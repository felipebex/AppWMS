class OrdenTable {
  static const String tableName = 'tbl_orden_conteo';

  // Columnas
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnState = 'state';
  static const String columnWarehouseId = 'warehouse_id';
  static const String columnWarehouseName = 'warehouse_name';
  static const String columnResponsableId = 'responsable_id';
  static const String columnResponsableName = 'responsable_name';
  static const String columnCreateDate = 'create_date';
  static const String columnDateCount = 'date_count';
  static const String columnMostrarCantidad = 'mostrar_cantidad';
  static const String columnCountType = 'count_type';
  static const String columnNumberCount = 'number_count';
  static const String columnNumeroLineas = 'numero_lineas';
  static const String columnNumeroItemsContados = 'numero_items_contados';
  static const String columnFilterType = 'filter_type';
  static const String columnEnableAllLocations = 'enable_all_locations';
  static const String columnEnableAllProducts = 'enable_all_products';
  static const String columnIsSelected = 'is_selected';
  static const String columnIsStarted = 'is_started';
  static const String columnIsFinished = 'is_finished';
  static const String columnDateFinish = 'end_time_orden';
  static const String columnDateStart = 'start_time_orden';

  static const String columnIsDoneItem = 'is_done_item';

  // observation_general
  static const String columnObservationGeneral = 'observation_general';

  static String createTable() {
    return '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnName TEXT,
      $columnState TEXT,
      $columnWarehouseId INTEGER,
      $columnWarehouseName TEXT,
      $columnResponsableId INTEGER,
      $columnResponsableName TEXT,
      $columnCreateDate TEXT,
      $columnDateCount TEXT,
      $columnMostrarCantidad INTEGER,
      $columnCountType TEXT,
      $columnNumberCount TEXT,
      $columnNumeroLineas INTEGER,
      $columnNumeroItemsContados INTEGER,
      $columnFilterType TEXT,
      $columnEnableAllLocations INTEGER,
      $columnEnableAllProducts INTEGER,
      $columnIsSelected INTEGER,
      $columnIsStarted INTEGER,
      $columnIsFinished INTEGER,
      $columnDateFinish TEXT,
      $columnIsDoneItem INTEGER,
      $columnObservationGeneral TEXT,
      $columnDateStart TEXT
    )
    ''';
  }


}