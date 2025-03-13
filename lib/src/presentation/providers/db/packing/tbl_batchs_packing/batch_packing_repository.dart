import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_batchs_packing/batch_table.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:sqflite/sqflite.dart';

class BatchPackingRepository {
  //* Método para insertar o actualizar un batch de packing
  Future<void> insertBatchPacking(BatchPackingModel batch) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      await db.transaction((txn) async {
        // Verificar si el batch ya existe
        final List<Map<String, dynamic>> existingBatch = await txn.query(
          BatchPackingTable.tableName,
          where: '${BatchPackingTable.columnId} = ?',
          whereArgs: [batch.id],
        );

        if (existingBatch.isNotEmpty) {
          // Actualizar el batch
          await txn.update(
            BatchPackingTable.tableName,
            {
              BatchPackingTable.columnId: batch.id,
              BatchPackingTable.columnName: batch.name,
              BatchPackingTable.columnScheduledDate:
                  batch.scheduleddate.toString(),
              BatchPackingTable.columnPickingTypeId: batch.pickingTypeId,
              BatchPackingTable.columnState: batch.state,
              BatchPackingTable.columnUserId: batch.userId,
              BatchPackingTable.columnUserName: batch.userName,
              BatchPackingTable.columnCantidadPedidos: batch.cantidadPedidos,
              BatchPackingTable.columnZonaEntrega: batch.zonaEntrega,
              BatchPackingTable.columnZonaEntregaTms: batch.zonaEntregaTms,
              BatchPackingTable.columnStartTimePack: batch.startTimePack,
              BatchPackingTable.columnEndTimePack: batch.endTimePack,
            },
            where: '${BatchPackingTable.columnId} = ?',
            whereArgs: [batch.id],
          );
        } else {
          // Insertar nuevo batch
          await txn.insert(
            BatchPackingTable.tableName,
            {
              BatchPackingTable.columnId: batch.id,
              BatchPackingTable.columnName: batch.name,
              BatchPackingTable.columnScheduledDate:
                  batch.scheduleddate.toString(),
              BatchPackingTable.columnPickingTypeId: batch.pickingTypeId,
              BatchPackingTable.columnState: batch.state,
              BatchPackingTable.columnUserId: batch.userId,
              BatchPackingTable.columnUserName: batch.userName,
              BatchPackingTable.columnCantidadPedidos: batch.cantidadPedidos,
              BatchPackingTable.columnZonaEntrega: batch.zonaEntrega,
              BatchPackingTable.columnZonaEntregaTms: batch.zonaEntregaTms,
              BatchPackingTable.columnStartTimePack: batch.startTimePack,
              BatchPackingTable.columnEndTimePack: batch.endTimePack,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      print("Error al insertar tblbatchs_packing: $e");
    }
  }

  //* Obtener todos los batchs de packing
  Future<List<BatchPackingModel>> getAllBatchsPacking() async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> maps =
          await db.query(BatchPackingTable.tableName);

      final List<BatchPackingModel> batchs = maps.map((map) {
        return BatchPackingModel.fromMap(map);
      }).toList();

      return batchs;
    } catch (e, s) {
      print("Error tblbatchs_packing: $e => $s");
    }
    return [];
  }

  //* Método para actualizar un campo específico de un batch de packing
  Future<int?> setFieldTableBatchPacking(
      int batchId, String field, dynamic setValue) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      // Usamos rawUpdate para actualizar el campo específico
      final resUpdate = await db.rawUpdate(
          'UPDATE ${BatchPackingTable.tableName} SET $field = ? WHERE ${BatchPackingTable.columnId} = ?',
          [setValue, batchId]);

      return resUpdate;
    } catch (e) {
      print("Error al actualizar el campo $field en tblbatchs_packing: $e");
      return null;
    }
  }




  // Método para iniciar el cronómetro de un batch de picking
  Future<int?> startStopwatchBatch(int batchId, String date) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      // Actualiza el campo 'start_time_pick' con la fecha proporcionada
      final resUpdate = await db.rawUpdate(
          "UPDATE ${BatchPackingTable.tableName} SET ${BatchPackingTable.columnStartTimePack} = ? WHERE ${BatchPackingTable.columnId} = ?",
          [date, batchId]);

      print("startStopwatchBatchPack: $resUpdate");
      return resUpdate;
    } catch (e) {
      print("Error al iniciar el cronómetro para el batch en pack: $batchId: $e");
      return null;
    }
  }



}
