import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_pick/picking_pick_table.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/models/response_pick_model.dart';

class PickingPickRepository {
  Future<void> insertAllPickingPicks(
    List<ResultPick> listOfPickingPicks,
    String typePick,
  ) async {
    final db = await DataBaseSqlite().getDatabaseInstance();

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var pickItem in listOfPickingPicks) {
        if (pickItem.id != null && pickItem.name != null) {
          final data = {
            PickingPickTable.columnId: pickItem.id,
            PickingPickTable.columnName: pickItem.name ?? '',
            PickingPickTable.columnFechaCreacion: pickItem.fechaCreacion ?? '',
            PickingPickTable.columnLocationId: pickItem.locationId,
            PickingPickTable.columnLocationName: pickItem.locationName ?? '',
            PickingPickTable.columnLocationBarcode:
                pickItem.locationBarcode ?? '',
            PickingPickTable.columnLocationDestId: pickItem.locationDestId,
            PickingPickTable.columnLocationDestName:
                pickItem.locationDestName ?? '',
            PickingPickTable.columnLocationDestBarcode:
                pickItem.locationDestBarcode ?? '',
            PickingPickTable.columnProveedor: pickItem.proveedor ?? '',
            PickingPickTable.columnNumeroTransferencia:
                pickItem.numeroTransferencia ?? '',
            PickingPickTable.columnPesoTotal: pickItem.pesoTotal,
            PickingPickTable.columnNumeroLineas:
                pickItem.numeroLineas?.toString(),
            PickingPickTable.columnNumeroItems:
                pickItem.numeroItems?.toString(),
            PickingPickTable.columnState: pickItem.state ?? '',
            PickingPickTable.columnOrigin: pickItem.origin ?? '',
            PickingPickTable.columnPriority: pickItem.priority ?? '',
            PickingPickTable.columnWarehouseId: pickItem.warehouseId,
            PickingPickTable.columnWarehouseName: pickItem.warehouseName ?? '',
            PickingPickTable.columnResponsableId: pickItem.responsableId,
            PickingPickTable.columnResponsable: pickItem.responsable ?? '',
            PickingPickTable.columnPickingType: pickItem.pickingType ?? '',
            PickingPickTable.columnStartTimeTransfer:
                pickItem.startTimeTransfer ?? '',
            PickingPickTable.columnEndTimeTransfer:
                pickItem.endTimeTransfer ?? '',
            PickingPickTable.columnBackorderId: pickItem.backorderId,
            PickingPickTable.columnBackorderName: pickItem.backorderName ?? '',
            PickingPickTable.columnShowCheckAvailability:
                pickItem.showCheckAvailability == true ? 1 : 0,
            PickingPickTable.columnIsSeparate:
                pickItem.isSeparate == true ? 1 : 0,
            PickingPickTable.columnIsSelected:
                pickItem.isSelected == true ? 1 : 0,
            PickingPickTable.columnZonaEntrega: pickItem.zonaEntrega ?? '',
            PickingPickTable.columnMuelle: pickItem.muelle ?? '',
            PickingPickTable.columnBarcodeMuelle: pickItem.barcodeMuelle ?? '',
            PickingPickTable.columnMuelleId: pickItem.muelleId,
            PickingPickTable.columnIndexList: pickItem.indexList,
            PickingPickTable.columnIsSendOddo:
                pickItem.isSendOdoo == true ? 1 : 0,
            PickingPickTable.columnIsSendOddoDate:
                pickItem.isSendOdooDate ?? '',
            PickingPickTable.columnOrderBy: pickItem.orderBy,
            PickingPickTable.columnOrderPicking: pickItem.orderPicking,
            PickingPickTable.columnTypePick: typePick,
          };

          // Elimina si existe (por ID), y luego inserta
          batch.delete(
            PickingPickTable.tableName,
            where: '${PickingPickTable.columnId} = ?',
            whereArgs: [pickItem.id],
          );

          batch.insert(
            PickingPickTable.tableName,
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Ejecutar todas las operaciones en lote
      await batch.commit(noResult: true);
    });
  }

// Método para obtener todos los picking picks de un usuario
  Future<List<ResultPick>> getAllPickingPicks(String typePick) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      // Consulta optimizada: solo columnas necesarias
      final List<Map<String, dynamic>> maps = await db.query(
        PickingPickTable.tableName,
        columns: [
          PickingPickTable.columnId,
          PickingPickTable.columnName,
          PickingPickTable.columnFechaCreacion,
          PickingPickTable.columnLocationId,
          PickingPickTable.columnLocationName,
          PickingPickTable.columnLocationBarcode,
          PickingPickTable.columnLocationDestId,
          PickingPickTable.columnLocationDestName,
          PickingPickTable.columnLocationDestBarcode,
          PickingPickTable.columnProveedor,
          PickingPickTable.columnNumeroTransferencia,
          PickingPickTable.columnPesoTotal,
          PickingPickTable.columnNumeroLineas,
          PickingPickTable.columnNumeroItems,
          PickingPickTable.columnState,
          PickingPickTable.columnOrigin,
          PickingPickTable.columnPriority,
          PickingPickTable.columnWarehouseId,
          PickingPickTable.columnWarehouseName,
          PickingPickTable.columnResponsableId,
          PickingPickTable.columnResponsable,
          PickingPickTable.columnPickingType,
          PickingPickTable.columnStartTimeTransfer,
          PickingPickTable.columnEndTimeTransfer,
          PickingPickTable.columnBackorderId,
          PickingPickTable.columnBackorderName,
          PickingPickTable.columnShowCheckAvailability,
          PickingPickTable.columnIsSeparate,
          PickingPickTable.columnIsSelected,
          PickingPickTable.columnZonaEntrega,
          PickingPickTable.columnMuelle,
          PickingPickTable.columnBarcodeMuelle,
          PickingPickTable.columnMuelleId,
          PickingPickTable.columnIndexList,
          PickingPickTable.columnIsSendOddo,
          PickingPickTable.columnIsSendOddoDate,
          PickingPickTable.columnOrderBy,
          PickingPickTable.columnOrderPicking,
          // type_pick
          PickingPickTable.columnTypePick
        ],
        where: '${PickingPickTable.columnTypePick} = ?',
        whereArgs: [typePick],
      );

      // Mapeo directo
      return maps.map((map) => ResultPick.fromMap(map)).toList();
    } catch (e, s) {
      print("Error getAllPickingPicks: $e => $s");
      return [];
    }
  }

  Future<int?> setFieldTablePick(
      int batchId, String field, dynamic setValue) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      // Usamos rawUpdate para actualizar el campo específico
      final resUpdate = await db.rawUpdate(
          'UPDATE ${PickingPickTable.tableName} SET $field = ? WHERE ${PickingPickTable.columnId} = ?',
          [setValue, batchId]);
      print(
          'Se actualizó el campo $field en ${PickingPickTable.tableName} con valor $setValue para el ID $batchId');
      return resUpdate;
    } catch (e) {
      print(
          "Error al actualizar el campo $field en ${PickingPickTable.tableName}: $e");
      return null;
    }
  }

  // Método para obtener un batch por su ID
  Future<ResultPick?> getPickById(int pickId) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realiza la consulta a la tabla tblbatchs
      final List<Map<String, dynamic>> maps = await db.query(
        PickingPickTable.tableName,
        where: '${PickingPickTable.columnId} = ?',
        whereArgs: [pickId],
      );

      // Si se encontró un registro, lo mapea a un objeto BatchsModel
      if (maps.isNotEmpty) {
        return ResultPick.fromMap(maps.first);
      }

      // Si no se encontró ningún registro, devuelve null
      return null;
    } catch (e) {
      print("Error al obtener el pick por ID: $e");
      return null; // Devuelve null en caso de error
    }
  }
}
