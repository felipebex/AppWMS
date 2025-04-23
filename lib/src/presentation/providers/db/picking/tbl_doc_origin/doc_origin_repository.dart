

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_doc_origin/doc_origin_table.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

class DocOriginRepository {




  Future<void> insertAllDocsOrigins(
      List<Origin> listOfOrigins, int userId) async {
    final db = await DataBaseSqlite().getDatabaseInstance();

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var batchItem in listOfOrigins) {
        if (batchItem.id != null && batchItem.name != null) {
          final data = {
            DocOriginTable.columnId: batchItem.id,
            DocOriginTable.columnName: batchItem.name ?? '',
            DocOriginTable.columnIdBatch: batchItem.idBatch,
          
          };

          // Elimina si existe (por ID), y luego inserta
          batch.delete(
            DocOriginTable.tableName,
            where: '${DocOriginTable.columnId} = ? AND ${DocOriginTable.columnIdBatch} = ?',
            whereArgs: [batchItem.id, batchItem.idBatch],
          );

          batch.insert(
            DocOriginTable.tableName,
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Ejecutar todas las operaciones en lote
      await batch.commit(noResult: true);
    });
  }



    Future<List<Origin>> getAllOriginsByIdBatch(int idBatch) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      // Consulta optimizada: solo columnas necesarias
      final List<Map<String, dynamic>> maps = await db.query(
        DocOriginTable.tableName,
        columns: [
          DocOriginTable.columnId,
          DocOriginTable.columnName,
         
        ],
        where: '${DocOriginTable.columnIdBatch} = ?',
        whereArgs: [idBatch],
      );

      // Mapeo directo
      return maps.map((map) => Origin.fromMap(map)).toList();
    } catch (e, s) {
      print("Error getAllOriginsByIdBatch: $e => $s");
      return [];
    }
  }







}