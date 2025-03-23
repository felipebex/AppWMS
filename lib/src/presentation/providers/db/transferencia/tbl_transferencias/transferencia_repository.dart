import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/transferencia/tbl_transferencias/transferencia_table.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';

class TransferenciaRepository {
  //metodo para insertar una transferencia
  Future<void> insertEntrada(List<ResultTransFerencias> transferencias) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      // Comienza la transacción
      await db.transaction((txn) async {
        Batch batch = txn.batch();

        // Primero, obtener todas las IDs de las novedades existentes

        final List<Map<String, dynamic>> existingEntradas = await txn.query(
          TransferenciaTable.tableName,
          columns: [TransferenciaTable.columnId],
          where: '${TransferenciaTable.columnId} =? ',
          whereArgs: [
            transferencias.map((transfer) => transfer.id).toList().join(',')
          ],
        );

        // Crear un conjunto de los IDs existentes para facilitar la comprobación

        Set<int> existingIds = Set.from(existingEntradas.map((e) {
          return e[TransferenciaTable.columnId];
        }));

        // Recorrer todas las novedades y realizar insert o update según corresponda

        for (var transfer in transferencias) {
          if (existingIds.contains(transfer.id)) {
            // Si la novedad ya existe, la actualizamos
            batch.update(
              TransferenciaTable.tableName,
              {
                TransferenciaTable.columnId: transfer.id,
                TransferenciaTable.columnName: transfer.name,
                TransferenciaTable.columnFechaCreacion: transfer.fechaCreacion,
                TransferenciaTable.columnLocationDestId:
                    transfer.locationDestId,
                TransferenciaTable.columnLocationDestName:
                    transfer.locationDestName,
                TransferenciaTable.columnNumeroTrasnferencia:
                    transfer.numeroTransferencia,
                TransferenciaTable.columnPesoTotal: transfer.pesoTotal,
                TransferenciaTable.columnNumeroLineas: transfer.numeroLineas,
                TransferenciaTable.columnNumeroItems: transfer.numeroItems,
                TransferenciaTable.columnState: transfer.state,
                TransferenciaTable.columnOrigin: transfer.origin,
                TransferenciaTable.columnPriority: transfer.priority,
                TransferenciaTable.columnWarehouseId: transfer.warehouseId,
                TransferenciaTable.columnWarehouseName: transfer.warehouseName,
                TransferenciaTable.columnLocationId: transfer.locationId,
                TransferenciaTable.columnLocationName: transfer.locationName,
                TransferenciaTable.columnResponsableId: transfer.responsableId,
                TransferenciaTable.columnResponsable: transfer.responsable,
                TransferenciaTable.columnPickingType: transfer.pickingType,
                TransferenciaTable.columnDateStart: transfer.startTimeReception,
                TransferenciaTable.columnDateFinish: transfer.endTimeReception,
              },
              where: '${TransferenciaTable.columnId} = ?',
              whereArgs: [transfer.id],
            );
          } else {
            // Si la novedad no existe, la insertamos
            batch.insert(
              TransferenciaTable.tableName,
              {
                TransferenciaTable.columnId: transfer.id,
                TransferenciaTable.columnName: transfer.name,
                TransferenciaTable.columnFechaCreacion: transfer.fechaCreacion,
                TransferenciaTable.columnLocationDestId:
                    transfer.locationDestId,
                TransferenciaTable.columnLocationDestName:
                    transfer.locationDestName,
                TransferenciaTable.columnNumeroTrasnferencia:
                    transfer.numeroTransferencia,
                TransferenciaTable.columnPesoTotal: transfer.pesoTotal,
                TransferenciaTable.columnNumeroLineas: transfer.numeroLineas,
                TransferenciaTable.columnNumeroItems: transfer.numeroItems,
                TransferenciaTable.columnState: transfer.state,
                TransferenciaTable.columnOrigin: transfer.origin,
                TransferenciaTable.columnPriority: transfer.priority,
                TransferenciaTable.columnWarehouseId: transfer.warehouseId,
                TransferenciaTable.columnWarehouseName: transfer.warehouseName,
                TransferenciaTable.columnLocationId: transfer.locationId,
                TransferenciaTable.columnLocationName: transfer.locationName,
                TransferenciaTable.columnResponsableId: transfer.responsableId,
                TransferenciaTable.columnResponsable: transfer.responsable,
                TransferenciaTable.columnPickingType: transfer.pickingType,
                TransferenciaTable.columnDateStart: transfer.startTimeReception,
                TransferenciaTable.columnDateFinish: transfer.endTimeReception,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
        await batch.commit();
      });

      print('Entradas insertadas correctamente');
    } catch (e, s) {
      print('Error en insertEntrada: $e ->$s');
    }
  }

  //metodo para obtener una transferencia por id
  Future<ResultTransFerencias?> getTransferenciaById(int id) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> entradas = await db.query(
        TransferenciaTable.tableName,
        where: '${TransferenciaTable.columnId} = ?',
        whereArgs: [id],
      );
      if (entradas.isNotEmpty) {
        return ResultTransFerencias.fromMap(entradas.first);
      }
      return null;
    } catch (e, s) {
      print('Error en getTransferencias by id: $e ->$s');
      return null;
    }
  }

  //metodo para obtener todas las entradas
  Future<List<ResultTransFerencias>> getAllTransferencias() async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> entradas = await db.query(
        TransferenciaTable.tableName,
      );
      return entradas.map((e) => ResultTransFerencias.fromMap(e)).toList();
    } catch (e, s) {
      print('Error en getAllTransferencias: $e ->$s');
      return [];
    }
  }

  //*metodo para actualizar la tabla

  // Método: Actualizar un campo específico en la tabla productos_pedidos
  Future<int?> setFieldTableTransfer(int idTransfer, String field,
      dynamic setValue, ) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();

    final resUpdate = await db.rawUpdate(
        'UPDATE ${TransferenciaTable.tableName} SET $field = ? WHERE ${TransferenciaTable.columnId} = ?',
        [
          setValue,
          idTransfer,
        ]);
    print(
        "update TableTransfer (idTransfer ----($idTransfer)) -------($field): $resUpdate");

    return resUpdate;
  }
}
