// configurations_table.dart

class ConfigurationsTable {
  static const String tableName = 'tblconfigurations';

  // Columnas de la tabla
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnLastName = 'last_name';
  static const String columnEmail = 'email';
  static const String columnRol = 'rol';
  static const String columnMuelleOption = 'muelle_option';
  static const String columnLocationPickingManual = 'location_picking_manual';
  static const String columnManualProductSelection = 'manual_product_selection';
  static const String columnManualQuantity = 'manual_quantity';
  static const String columnManualSpringSelection = 'manual_spring_selection';
  static const String columnShowDetallesPicking = 'show_detalles_picking';
  static const String columnShowNextLocationsInDetails =
      'show_next_locations_in_details';
  static const String columnLocationPackManual = 'location_pack_manual';
  static const String columnShowDetallesPack = 'show_detalles_pack';
  static const String columnShowNextLocationsInDetailsPack =
      'show_next_locations_in_details_pack';
  static const String columnManualProductSelectionPack =
      'manual_product_selection_pack';
  static const String columnManualQuantityPack = 'manual_quantity_pack';
  static const String columnManualSpringSelectionPack =
      'manual_spring_selection_pack';
  static const String columnScanProduct = 'scan_product';

  static const String columnAllowMoveExcess = 'allow_move_excess';
  static const String columnHideExpectedQty = 'hide_expected_qty';
  static const String columnManualProductReading = 'manual_product_reading';
  static const String columnManualSourceLocation = 'manual_source_location';
  static const String columnShowOwnerField = 'show_owner_field';

  static const String columnManualSourceLocationTransfer =
      'manual_source_location_transfer';
  static const String columnManualDestLocationTransfer =
      'manual_dest_location_transfer';
  static const String columnManualQuantityTransfer = 'manual_quantity_transfer';
  static const String columnManualProductSelectionTransfer =
      'manual_product_selection_transfer';

  static const String columnCountQuantityInventory = 'count_quantity_inventory';

  static const String columnScanDestinationLocationReception =
      'scan_destination_location_reception';

//hide_validate_transfer
  static const String columnHideValidateTransfer = 'hide_validate_transfer';
  

  // Método para crear la tabla
  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT,
        $columnLastName TEXT,
        $columnEmail TEXT,
        $columnRol TEXT,
        $columnMuelleOption TEXT,
        $columnLocationPickingManual INTEGER,
        $columnManualProductSelection INTEGER,
        $columnManualQuantity INTEGER,
        $columnManualSpringSelection INTEGER,
        $columnShowDetallesPicking INTEGER,
        $columnShowNextLocationsInDetails INTEGER,
        $columnLocationPackManual INTEGER,
        $columnShowDetallesPack INTEGER,
        $columnShowNextLocationsInDetailsPack INTEGER,
        $columnManualProductSelectionPack INTEGER,
        $columnManualQuantityPack INTEGER,
        $columnManualSpringSelectionPack INTEGER,
        $columnScanProduct INTEGER,
        $columnAllowMoveExcess INTEGER,
        $columnHideExpectedQty INTEGER,
        $columnManualProductReading INTEGER,
        $columnManualSourceLocation INTEGER,
        $columnShowOwnerField INTEGER,
        $columnManualProductSelectionTransfer INTEGER,
        $columnManualSourceLocationTransfer INTEGER,
        $columnManualDestLocationTransfer INTEGER,
        $columnManualQuantityTransfer INTEGER,
        $columnScanDestinationLocationReception INTEGER,
        $columnHideValidateTransfer INTEGER,
        $columnCountQuantityInventory INTEGER
      )
    ''';
  }
}
