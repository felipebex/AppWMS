// novedades_repository.dart

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'novedades_table.dart';

class NovedadesRepository {
  // Método para insertar/actualizar novedades en lote
  Future<void> insertBatchNovedades(List<Novedad> novedades) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Comienza la transacción
      await db.transaction((txn) async {
        Batch batch = txn.batch();

        // Primero, obtener todas las IDs de las novedades existentes
        final List<Map<String, dynamic>> existingNovedades = await txn.query(
          NovedadesTable.tableName,
          columns: [NovedadesTable.columnId],
          where: '${NovedadesTable.columnId} IN (?)',
          whereArgs: [
            novedades.map((novedad) => novedad.id).toList().join(','),
          ],
        );

        // Crear un conjunto de los IDs existentes para facilitar la comprobación
        Set<int> existingIds =
            Set.from(existingNovedades.map((e) => e[NovedadesTable.columnId]));

        // Recorrer todas las novedades y realizar insert o update según corresponda
        for (var novedad in novedades) {
          if (existingIds.contains(novedad.id)) {
            // Si la novedad ya existe, la actualizamos
            batch.update(
              NovedadesTable.tableName,
              {
                NovedadesTable.columnName: novedad.name,
                NovedadesTable.columnCode: novedad.code,
              },
              where: '${NovedadesTable.columnId} = ?',
              whereArgs: [novedad.id],
            );
          } else {
            // Si no existe, la insertamos
            batch.insert(
              NovedadesTable.tableName,
              {
                NovedadesTable.columnId: novedad.id,
                NovedadesTable.columnName: novedad.name,
                NovedadesTable.columnCode: novedad.code,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Ejecutar la transacción en batch
        await batch.commit();
      });

      print("Novedades insertadas/actualizadas con éxito.");
    } catch (e) {
      print("Error al insertar novedades: $e");
    }
  }

  // Método para obtener todas las novedades
  Future<List<Novedad>> getAllNovedades() async {
    try {
            Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realiza la consulta a la tabla de novedades
      final List<Map<String, dynamic>> maps =
          await db.query(NovedadesTable.tableName);

      // Mapea los resultados a una lista de objetos Novedad
      final List<Novedad> novedades = maps.map((map) {
        return Novedad(
          id: map[NovedadesTable.columnId],
          name: map[NovedadesTable.columnName],
          code: map[NovedadesTable.columnCode],
        );
      }).toList();

      return novedades;
    } catch (e) {
      print("Error al obtener novedades: $e");
      return []; // Devuelve una lista vacía en caso de error
    }
  }
}
