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
}
