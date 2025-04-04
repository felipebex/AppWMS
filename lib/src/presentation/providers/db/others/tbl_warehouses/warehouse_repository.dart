import 'package:sqflite/sqlite_api.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_warehouses/tbl_warehouse_table.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';

class WarehouseRepository {
  Future<List<AllowedWarehouse>> getAllowedWarehouse() async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      final List<Map<String, dynamic>> maps =
          await db.query(WarehouseTable.tableName);

      final List<AllowedWarehouse> warehouses = maps.map((map) {
        return AllowedWarehouse(
          id: map[WarehouseTable.columnId],
          name: map[WarehouseTable.columnName],
        );
      }).toList();

      return warehouses;
    } catch (e) {
      print("Error al obtener los almacenes: $e");
      return []; // Devuelve una lista vacía en caso de error
    }
  }

  Future<void> insertAllowedWarehouse(List<AllowedWarehouse> warehouses) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Comienza la transacción
      await db.transaction((txn) async {
        Batch batch = txn.batch();

        // 1. Eliminar todos los almacenes existentes
        batch.delete(WarehouseTable.tableName);

        // 2. Insertar los nuevos almacenes
        for (var warehouse in warehouses) {
          batch.insert(
            WarehouseTable.tableName,
            {
              WarehouseTable.columnId: warehouse.id,
              WarehouseTable.columnName: warehouse.name,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Ejecutar la transacción en batch
        await batch.commit();
      });

      print("Almacenes actualizados con éxito.");
    } catch (e) {
      print("Error al actualizar almacenes: $e");
    }
  }
}
