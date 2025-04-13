import 'package:sqflite/sqlite_api.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_ubicaciones/ubicaciones_table.dart';

class UbicacionesRepository {
  // Método para insertar o actualizar los barcodes de los productos
  Future<void> insertOrUpdateUbicaciones(
      List<ResultUbicaciones> ubicacionesList) async {

    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Inicia la transacción
      await db.transaction((txn) async {
        // Crear el batch
        Batch batch = txn.batch();

        // Obtener todas las ubicaciones existentes de una sola vez
        final List<Map<String, dynamic>> existingUbicaciones = await txn.query(
          UbicacionesTable.tableName,
          columns: [UbicacionesTable.columnId],
          where: '${UbicacionesTable.columnId} IN (?)',
          whereArgs: [
            ubicacionesList.map((ubicacion) => ubicacion.id).toList().join(',')
          ],
        );

        // Crear un conjunto para facilitar la comprobación de existencia
        Set<int> existingIds = Set.from(
            existingUbicaciones.map((e) => e[UbicacionesTable.columnId]));

        for (var ubicacion in ubicacionesList) {

          // Validación: Si el código de barras está vacío o es null, se salta este registro
          if (ubicacion.barcode == null || ubicacion.barcode == "") {
            continue; // Saltamos esta ubicación y no realizamos ningún insert o update
          }

          if (existingIds.contains(ubicacion.id)) {
            // Si la ubicacion ya existe, la actualizamos
            batch.update(
              UbicacionesTable.tableName,
              {
                UbicacionesTable.columnName: ubicacion.name,
                UbicacionesTable.columnBarcode: ubicacion.barcode,
                UbicacionesTable.columnLocationId: ubicacion.locationId,
                UbicacionesTable.columnLocationName: ubicacion.locationName,
              },
              where: '${UbicacionesTable.columnId} = ?',
              whereArgs: [ubicacion.id],
            );
          } else {
            // Si no existe, la insertamos
            batch.insert(
              UbicacionesTable.tableName,
              {
                UbicacionesTable.columnId: ubicacion.id,
                UbicacionesTable.columnName: ubicacion.name,
                UbicacionesTable.columnBarcode: ubicacion.barcode,
                UbicacionesTable.columnLocationId: ubicacion.locationId,
                UbicacionesTable.columnLocationName: ubicacion.locationName,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Ejecutar todas las operaciones del batch
        await batch.commit();
      });

      // Imprimimos el número de registros insertados y actualizados
    } catch (e, s) {
      print("Error al insertar/actualizar ubicaciones: $e => $s");
    }
  }

  //metodo para obtener todos las ubicaciones
  Future<List<ResultUbicaciones>> getAllUbicaciones() async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realizamos la consulta para obtener los barcodes
      final List<Map<String, dynamic>> maps =
          await db.query(UbicacionesTable.tableName);

      // Convertimos los resultados de la consulta en objetos Barcodes
      final List<ResultUbicaciones> ubicaciones = maps.map((map) {
        return ResultUbicaciones(
          id: map[UbicacionesTable.columnId],
          name: map[UbicacionesTable.columnName],
          barcode: map[UbicacionesTable.columnBarcode],
          locationId: map[UbicacionesTable.columnLocationId],
          locationName: map[UbicacionesTable.columnLocationName],
        );
      }).toList();

      return ubicaciones;
    } catch (e) {
      print("Error al obtener los barcodes: $e");
      return [];
    }
  }
}
