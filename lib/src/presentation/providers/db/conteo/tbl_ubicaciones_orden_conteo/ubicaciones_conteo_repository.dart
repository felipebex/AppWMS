
import 'package:wms_app/src/presentation/providers/db/conteo/tbl_ubicaciones_orden_conteo/ubicaciones_conteo_table.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';

import 'package:sqflite/sqflite.dart';

class UbicacionesConteoRepository {
  // Insertar/actualizar ubicaciones de conteo
  Future<void> upsertUbicacionesConteo(List<Allowed> ubicaciones, ) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      await db.transaction((txn) async {
        final Batch batch = txn.batch();

     

        // Luego insertamos las nuevas
        for (final ubicacion in ubicaciones) {
          final ubicacionMap = {
            UbicacionesConteoTable.columnId: ubicacion.id,
            UbicacionesConteoTable.columnName: ubicacion.name ?? '',
            UbicacionesConteoTable.columnOrdenConteoId: ubicacion.ordenConteoId ?? 0,
            UbicacionesConteoTable.columnBarcode: ubicacion.barcode ?? '',
          };

          batch.insert(
            UbicacionesConteoTable.tableName,
            ubicacionMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit(noResult: true);
      });

      print('✅ ${ubicaciones.length} ubicaciones insertadas');
    } catch (e, s) {
      print('❌ Error en upsertUbicacionesConteo: $e');
      print(s);
      rethrow;
    }
  }

  // Obtener todas las ubicaciones de conteo para una orden específica
  Future<List<Allowed>> getUbicacionesByOrdenId(int ordenConteoId) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> maps = await db.query(
        UbicacionesConteoTable.tableName,
        where: '${UbicacionesConteoTable.columnOrdenConteoId} = ?',
        whereArgs: [ordenConteoId],
      );

      print( 'Ubicaciones obtenidas para orden $ordenConteoId: ${maps.length}'); 

      return List.generate(maps.length, (i) {
        return Allowed(
          id: maps[i][UbicacionesConteoTable.columnId],
          name: maps[i][UbicacionesConteoTable.columnName],
        );
      });
    } catch (e, s) {
      print('Error en getUbicacionesByOrdenId: $e');
      print(s);
      return [];
    }
  }

  // Obtener todas las ubicaciones de conteo (sin filtrar)
  Future<List<Allowed>> getAllUbicacionesConteo() async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> maps = 
          await db.query(UbicacionesConteoTable.tableName);

      return List.generate(maps.length, (i) {
        return Allowed(
          id: maps[i][UbicacionesConteoTable.columnId],
          name: maps[i][UbicacionesConteoTable.columnName],
        );
      });
    } catch (e, s) {
      print('Error en getAllUbicacionesConteo: $e');
      print(s);
      return [];
    }
  }

  // Eliminar ubicaciones de una orden específica
  Future<int> deleteUbicacionesByOrdenId(int ordenConteoId) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();
      return await db.delete(
        UbicacionesConteoTable.tableName,
        where: '${UbicacionesConteoTable.columnOrdenConteoId} = ?',
        whereArgs: [ordenConteoId],
      );
    } catch (e, s) {
      print('Error en deleteUbicacionesByOrdenId: $e');
      print(s);
      return 0;
    }
  }


}