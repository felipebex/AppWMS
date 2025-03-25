// configurations_repository.dart

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_configurations/configuration_table.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';

class ConfigurationsRepository {
  // Método para insertar o actualizar una configuración
  Future<void> insertConfiguration(
      Configurations configuration, int userId) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Convertir valores booleanos a enteros (0 o 1)
      Map<String, dynamic> configurationData = {
        ConfigurationsTable.columnId: userId,
        ConfigurationsTable.columnName: configuration.result?.result?.name,
        ConfigurationsTable.columnLastName:
            configuration.result?.result?.lastName,
        ConfigurationsTable.columnEmail: configuration.result?.result?.email,
        ConfigurationsTable.columnRol: configuration.result?.result?.rol,
        ConfigurationsTable.columnMuelleOption:
            configuration.result?.result?.muelleOption,
        ConfigurationsTable.columnLocationPickingManual:
            _boolToInt(configuration.result?.result?.locationPickingManual),
        ConfigurationsTable.columnManualProductSelection:
            _boolToInt(configuration.result?.result?.manualProductSelection),
        ConfigurationsTable.columnManualQuantity:
            _boolToInt(configuration.result?.result?.manualQuantity),
        ConfigurationsTable.columnManualSpringSelection:
            _boolToInt(configuration.result?.result?.manualSpringSelection),
        ConfigurationsTable.columnShowDetallesPicking:
            _boolToInt(configuration.result?.result?.showDetallesPicking),
        ConfigurationsTable.columnShowNextLocationsInDetails: _boolToInt(
            configuration.result?.result?.showNextLocationsInDetails),
        ConfigurationsTable.columnLocationPackManual:
            _boolToInt(configuration.result?.result?.locationPackManual),
        ConfigurationsTable.columnShowDetallesPack:
            _boolToInt(configuration.result?.result?.showDetallesPack),
        ConfigurationsTable.columnShowNextLocationsInDetailsPack: _boolToInt(
            configuration.result?.result?.showNextLocationsInDetailsPack),
        ConfigurationsTable.columnManualProductSelectionPack: _boolToInt(
            configuration.result?.result?.manualProductSelectionPack),
        ConfigurationsTable.columnManualQuantityPack:
            _boolToInt(configuration.result?.result?.manualQuantityPack),
        ConfigurationsTable.columnManualSpringSelectionPack:
            _boolToInt(configuration.result?.result?.manualSpringSelectionPack),
        ConfigurationsTable.columnScanProduct:
            _boolToInt(configuration.result?.result?.scanProduct),
        ConfigurationsTable.columnAllowMoveExcess:
            _boolToInt(configuration.result?.result?.allowMoveExcess),
        ConfigurationsTable.columnHideExpectedQty:
            _boolToInt(configuration.result?.result?.hideExpectedQty),
        ConfigurationsTable.columnManualProductReading:
            _boolToInt(configuration.result?.result?.manualProductReading),
        ConfigurationsTable.columnManualSourceLocation:
            _boolToInt(configuration.result?.result?.manualSourceLocation),
        ConfigurationsTable.columnShowOwnerField:
            _boolToInt(configuration.result?.result?.showOwnerField),

        ConfigurationsTable.columnManualProductSelectionTransfer:
            _boolToInt(configuration.result?.result?.manualProductSelectionTransfer),
    ConfigurationsTable.columnManualSourceLocationTransfer:
            _boolToInt(configuration.result?.result?.manualSourceLocationTransfer),
    ConfigurationsTable.columnManualDestLocationTransfer:
            _boolToInt(configuration.result?.result?.manualDestLocationTransfer),
    ConfigurationsTable.columnManualQuantityTransfer:
            _boolToInt(configuration.result?.result?.manualQuantityTransfer),
        
        
      };

      // Realizar la inserción o actualización usando INSERT OR REPLACE
      await db.transaction((txn) async {
        await txn.insert(
          ConfigurationsTable.tableName,
          configurationData,
          conflictAlgorithm: ConflictAlgorithm
              .replace, // Actualiza si ya existe un registro con el mismo 'id'
        );
      });

      print("Configuración insertada/actualizada con éxito.");
    } catch (e) {
      print("Error al insertar/actualizar configuración: $e");
    }
  }

  // Método para obtener la configuración de un usuario por su ID
  Future<Configurations?> getConfiguration(int userId) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realizamos la consulta para obtener la configuración del usuario
      final List<Map<String, dynamic>> maps = await db.query(
        ConfigurationsTable.tableName,
        where: '${ConfigurationsTable.columnId} = ?',
        whereArgs: [userId],
      );

      // Verificamos si hay resultados y devolvemos el primero
      if (maps.isNotEmpty) {
        final map = maps.first;

        // Convertimos el mapa en la estructura de la configuración
        final config = Configurations(
          jsonrpc: '2.0',
          id: 1,
          result: ConfigurationsResult(
            code: 200,
            result: DataConfig(
              name: map[ConfigurationsTable.columnName],
              lastName: map[ConfigurationsTable.columnLastName],
              email: map[ConfigurationsTable.columnEmail],
              rol: map[ConfigurationsTable.columnRol],
              id: map[ConfigurationsTable.columnId],
              locationPickingManual: _intToBool(
                  map[ConfigurationsTable.columnLocationPickingManual]),
              manualProductSelection: _intToBool(
                  map[ConfigurationsTable.columnManualProductSelection]),
              manualQuantity:
                  _intToBool(map[ConfigurationsTable.columnManualQuantity]),
              manualSpringSelection: _intToBool(
                  map[ConfigurationsTable.columnManualSpringSelection]),
              showDetallesPicking: _intToBool(
                  map[ConfigurationsTable.columnShowDetallesPicking]),
              showNextLocationsInDetails: _intToBool(
                  map[ConfigurationsTable.columnShowNextLocationsInDetails]),
              muelleOption: map[ConfigurationsTable.columnMuelleOption],
              manualProductSelectionPack: _intToBool(
                  map[ConfigurationsTable.columnManualProductSelectionPack]),
              manualQuantityPack:
                  _intToBool(map[ConfigurationsTable.columnManualQuantityPack]),
              manualSpringSelectionPack: _intToBool(
                  map[ConfigurationsTable.columnManualSpringSelectionPack]),
              showDetallesPack:
                  _intToBool(map[ConfigurationsTable.columnShowDetallesPack]),
              showNextLocationsInDetailsPack: _intToBool(map[
                  ConfigurationsTable.columnShowNextLocationsInDetailsPack]),
              locationPackManual:
                  _intToBool(map[ConfigurationsTable.columnLocationPackManual]),
              scanProduct:
                  _intToBool(map[ConfigurationsTable.columnScanProduct]),
              allowMoveExcess:
                  _intToBool(map[ConfigurationsTable.columnAllowMoveExcess]),
              hideExpectedQty:
                  _intToBool(map[ConfigurationsTable.columnHideExpectedQty]),
              manualProductReading: _intToBool(
                  map[ConfigurationsTable.columnManualProductReading]),
              manualSourceLocation: _intToBool(
                  map[ConfigurationsTable.columnManualSourceLocation]),
              showOwnerField:
                  _intToBool(map[ConfigurationsTable.columnShowOwnerField]),
              manualProductSelectionTransfer: _intToBool(
                  map[ConfigurationsTable.columnManualProductSelectionTransfer]),
              manualSourceLocationTransfer: _intToBool(
                  map[ConfigurationsTable.columnManualSourceLocationTransfer]),
              manualDestLocationTransfer: _intToBool(
                  map[ConfigurationsTable.columnManualDestLocationTransfer]),
              manualQuantityTransfer: _intToBool(
                  map[ConfigurationsTable.columnManualQuantityTransfer]),
              
            ),
          ),
        );

        return config;
      } else {
        return null;
      }
    } catch (e) {
      print("Error al obtener la configuración: $e");
      return null;
    }
  }

  // Función para convertir valores booleanos a enteros (0 o 1)
  int _boolToInt(bool? value) {
    return value == true ? 1 : 0;
  }

  // Función para convertir valores enteros (0, 1) en booleanos
  bool _intToBool(int value) {
    return value == 1;
  }
}
