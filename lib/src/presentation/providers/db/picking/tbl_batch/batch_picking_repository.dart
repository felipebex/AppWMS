// batch_picking_repository.dart

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'batch_picking_table.dart'; // Importa el archivo de la tabla

class BatchPickingRepository {
  // Método para insertar o actualizar un batch
  Future<void> insertBatch(BatchsModel batch) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      await db.transaction((txn) async {
        // Verificar si el batch ya existe
        final List<Map<String, dynamic>> existingBatch = await txn.query(
          BatchPickingTable.tableName,
          where: '${BatchPickingTable.columnId} = ?',
          whereArgs: [batch.id],
        );

        if (existingBatch.isNotEmpty) {
          // Actualizar el batch
          await txn.update(
            BatchPickingTable.tableName,
            {
              BatchPickingTable.columnId: batch.id,
              BatchPickingTable.columnName: batch.name,
              BatchPickingTable.columnScheduledDate: batch.scheduleddate,
              BatchPickingTable.columnPickingTypeId: batch.pickingTypeId,
              BatchPickingTable.columnState: batch.state,
              BatchPickingTable.columnUserId: batch.userId,
              BatchPickingTable.columnUserName: batch.userName,
              BatchPickingTable.columnIsWave: batch.isWave,
              BatchPickingTable.columnMuelle: batch.muelle,
              BatchPickingTable.columnBarcodeMuelle: batch.barcodeMuelle,
              BatchPickingTable.columnIdMuelle: batch.idMuelle,
              BatchPickingTable.columnOrderBy: batch.orderBy,
              BatchPickingTable.columnOrderPicking: batch.orderPicking,
              BatchPickingTable.columnCountItems: batch.countItems,
              BatchPickingTable.columnTotalQuantityItems:
                  batch.totalQuantityItems,
              BatchPickingTable.columnStartTimePick: batch.startTimePick,
              BatchPickingTable.columnEndTimePick: batch.endTimePick,
              BatchPickingTable.columnZonaEntrega: batch.zonaEntrega,
            },
            where: '${BatchPickingTable.columnId} = ?',
            whereArgs: [batch.id],
          );
        } else {
          // Insertar nuevo batch
          await txn.insert(
            BatchPickingTable.tableName,
            {
              BatchPickingTable.columnId: batch.id,
              BatchPickingTable.columnName: batch.name,
              BatchPickingTable.columnScheduledDate: batch.scheduleddate,
              BatchPickingTable.columnPickingTypeId: batch.pickingTypeId,
              BatchPickingTable.columnState: batch.state,
              BatchPickingTable.columnUserId: batch.userId,
              BatchPickingTable.columnUserName: batch.userName,
              BatchPickingTable.columnIsWave: batch.isWave,
              BatchPickingTable.columnMuelle: batch.muelle,
              BatchPickingTable.columnBarcodeMuelle: batch.barcodeMuelle,
              BatchPickingTable.columnIdMuelle: batch.idMuelle,
              BatchPickingTable.columnOrderBy: batch.orderBy,
              BatchPickingTable.columnOrderPicking: batch.orderPicking,
              BatchPickingTable.columnCountItems: batch.countItems,
              BatchPickingTable.columnTotalQuantityItems:
                  batch.totalQuantityItems,
              BatchPickingTable.columnIndexList: batch.indexList,
              BatchPickingTable.columnStartTimePick: batch.startTimePick,
              BatchPickingTable.columnEndTimePick: batch.endTimePick,
              BatchPickingTable.columnZonaEntrega: batch.zonaEntrega,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      print("Error al insertar batch: $e");
    }
  }

  // Método para obtener un batch por su ID
  Future<BatchsModel?> getBatchById(int batchId) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realiza la consulta a la tabla tblbatchs
      final List<Map<String, dynamic>> maps = await db.query(
        BatchPickingTable.tableName,
        where: '${BatchPickingTable.columnId} = ?',
        whereArgs: [batchId],
      );

      // Si se encontró un registro, lo mapea a un objeto BatchsModel
      if (maps.isNotEmpty) {
        return BatchsModel.fromMap(maps.first);
      }

      // Si no se encontró ningún registro, devuelve null
      return null;
    } catch (e) {
      print("Error al obtener el batch por ID: $e");
      return null; // Devuelve null en caso de error
    }
  }

//metodo para obtener todos los batchs de un usuario
  Future<List<BatchsModel>> getAllBatchs(int userId) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Agregar una condición de búsqueda por user_id
      final List<Map<String, dynamic>> maps = await db.query(
        BatchPickingTable.tableName,
        where: '${BatchPickingTable.columnUserId} = ?', // Condición de búsqueda
        whereArgs: [userId], // Argumento para el ? (el user_id que buscas)
      );

      final List<BatchsModel> batchs = maps.map((map) {
        return BatchsModel.fromMap(map);
      }).toList();

      return batchs;
    } catch (e, s) {
      print("Error getBatchsByUserId: $e => $s");
    }
    return [];
  }

  // Método para actualizar un campo específico de un batch de picking
  Future<int?> setFieldTableBatch(
      int batchId, String field, dynamic setValue) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      // Usamos rawUpdate para actualizar el campo específico
      final resUpdate = await db.rawUpdate(
          'UPDATE ${BatchPickingTable.tableName} SET $field = ? WHERE ${BatchPickingTable.columnId} = ?',
          [setValue, batchId]);

      return resUpdate;
    } catch (e) {
      print("Error al actualizar el campo $field en tblbatchs: $e");
      return null;
    }
  }

// Método para obtener el valor de un campo específico de un batch de picking
  Future<String> getFieldTableBatch(int batchId, String field) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      // Ejecutar consulta raw para obtener el valor del campo
      final res = await db.rawQuery('''
      // SELECT $field FROM ${BatchPickingTable.tableName} WHERE ${BatchPickingTable.columnId} = ? LIMIT 1
    ''', [batchId]);

      if (res.isNotEmpty) {
        // Devuelve el valor del campo como String
        return res[0][field].toString();
      }
      return "";
    } catch (e) {
      print("Error al obtener el campo $field de tblbatchs: $e");
      return "";
    }
  }

  // Método para iniciar el cronómetro de un batch de picking
  Future<int?> startStopwatchBatch(int batchId, String date) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      // Actualiza el campo 'start_time_pick' con la fecha proporcionada
      final resUpdate = await db.rawUpdate(
          "UPDATE ${BatchPickingTable.tableName} SET ${BatchPickingTable.columnStartTimePick} = ? WHERE ${BatchPickingTable.columnId} = ?",
          [date, batchId]);

      print("startStopwatchBatch: $resUpdate");
      return resUpdate;
    } catch (e) {
      print("Error al iniciar el cronómetro para el batch $batchId: $e");
      return null;
    }
  }

  // Método para finalizar el cronómetro de un batch de picking
  Future<int?> endStopwatchBatch(int batchId, String date) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      // Actualiza el campo 'end_time_pick' con la fecha proporcionada
      final resUpdate = await db.rawUpdate(
          "UPDATE ${BatchPickingTable.tableName} SET ${BatchPickingTable.columnEndTimePick} = ? WHERE ${BatchPickingTable.columnId} = ?",
          [date, batchId]);

      print("endStopwatchBatch: $resUpdate");
      return resUpdate;
    } catch (e) {
      print("Error al finalizar el cronómetro para el batch $batchId: $e");
      return null;
    }
  }


  

}
