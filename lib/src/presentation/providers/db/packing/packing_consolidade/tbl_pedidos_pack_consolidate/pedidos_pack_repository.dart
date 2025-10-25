// pedidos_packing_repository.dart

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/packing/packing_consolidade/tbl_pedidos_pack_consolidate/pedidos_pack_table.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/packing_response_model.dart';

class PedidosPackingConsolidateRepository {
  // Método para insertar o actualizar pedidos
  Future<void> insertPedidosBatchPacking(
      List<PedidoPacking> pedidosList, String type) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Inicia la transacción
      await db.transaction((txn) async {
        // Recorre la lista de pedidos
        for (var pedido in pedidosList) {
          // Verificar si el pedido ya existe
          final List<Map<String, dynamic>> existingPedido = await txn.query(
            PedidosPackingConsolidateTable.tableName,
            where: '${PedidosPackingConsolidateTable.columnId} = ?',
            whereArgs: [pedido.id],
          );

          if (existingPedido.isNotEmpty) {
            // Actualizar el pedido si ya existe
            await txn.update(
              PedidosPackingConsolidateTable.tableName,
              {
                PedidosPackingConsolidateTable.columnId: pedido.id,
                PedidosPackingConsolidateTable.columnBatchId: pedido.batchId,
                PedidosPackingConsolidateTable.columnName: pedido.name,
                PedidosPackingConsolidateTable.columnReferencia: pedido.referencia ?? '',
                PedidosPackingConsolidateTable.columnFecha: pedido.fecha.toString(),
                PedidosPackingConsolidateTable.columnContacto: pedido.contacto,
                PedidosPackingConsolidateTable.columnTipoOperacion:
                    pedido.tipoOperacion.toString(),
                PedidosPackingConsolidateTable.columnCantidadProductos:
                    pedido.cantidadProductos,
                PedidosPackingConsolidateTable.columnNumeroPaquetes: pedido.numeroPaquetes,
                PedidosPackingConsolidateTable.columnContactoName: pedido.contactoName,
                PedidosPackingConsolidateTable.columnIsZonaEntrega: pedido.zonaEntrega,
                PedidosPackingConsolidateTable.columnIsZonaEntregaTms:
                    pedido.zonaEntregaTms,
                PedidosPackingConsolidateTable.columnIsTerminate: 0,
                PedidosPackingConsolidateTable.columnType: type,
              },
              where: '${PedidosPackingConsolidateTable.columnId} = ?',
              whereArgs: [pedido.id],
            );
          } else {
            // Insertar el pedido si no existe
            await txn.insert(
              PedidosPackingConsolidateTable.tableName,
              {
                PedidosPackingConsolidateTable.columnId: pedido.id,
                PedidosPackingConsolidateTable.columnBatchId: pedido.batchId,
                PedidosPackingConsolidateTable.columnName: pedido.name,
                PedidosPackingConsolidateTable.columnReferencia: pedido.referencia ?? '',
                PedidosPackingConsolidateTable.columnFecha: pedido.fecha.toString(),
                PedidosPackingConsolidateTable.columnContacto: pedido.contacto,
                PedidosPackingConsolidateTable.columnTipoOperacion:
                    pedido.tipoOperacion.toString(),
                PedidosPackingConsolidateTable.columnCantidadProductos:
                    pedido.cantidadProductos,
                PedidosPackingConsolidateTable.columnNumeroPaquetes: pedido.numeroPaquetes,
                PedidosPackingConsolidateTable.columnContactoName: pedido.contactoName,
                PedidosPackingConsolidateTable.columnIsZonaEntrega: pedido.zonaEntrega,
                PedidosPackingConsolidateTable.columnIsZonaEntregaTms:
                    pedido.zonaEntregaTms,
                PedidosPackingConsolidateTable.columnIsTerminate: 0,
                PedidosPackingConsolidateTable.columnType: type,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });

      print("Pedidos de packing insertados/actualizados con éxito.");
    } catch (e, s) {
      print("Error al insertar/actualizar pedidos: $e ==> $s");
    }
  }

// Obtener los pedidos de packing por batch_id

  // Obtener todos los pedidos de un batch específico
  Future<List<PedidoPacking>> getAllPedidosBatch(int batchId) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> maps = await db.query(
        PedidosPackingConsolidateTable.tableName,
        where: '${PedidosPackingConsolidateTable.columnBatchId} = ?',
        whereArgs: [batchId],
      );

      final List<PedidoPacking> pedidos = maps.map((map) {
        return PedidoPacking.fromMap(map);
      }).toList();

      return pedidos;
    } catch (e) {
      print("Error al obtener todos los pedidos del batch: $e");
      return [];
    }
  }

  //metodo para obtener todos los pedidos de packing
  Future<List<PedidoPacking>> getAllPedidosPacking() async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> maps = await db.query(
        PedidosPackingConsolidateTable.tableName,
      );

      final List<PedidoPacking> pedidos = maps.map((map) {
        return PedidoPacking.fromMap(map);
      }).toList();

      return pedidos;
    } catch (e) {
      print("Error al obtener todos los pedidos de packing: $e");
      return [];
    }
  }

  // Método para actualizar un campo específico de un pedido en la tabla
  Future<int?> setFieldTablePedidosPacking(
      int batchId, int pedidoId, String field, dynamic setValue) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      // Realizar la actualización usando rawUpdate
      final resUpdate = await db.rawUpdate(
        'UPDATE ${PedidosPackingConsolidateTable.tableName} SET $field = ? WHERE id = ? AND batch_id = ?',
        [setValue, pedidoId, batchId],
      );

      // Devolver la cantidad de filas afectadas
      print(
          "update setFieldTablePedidosPacking  ($field)  pedido $pedidoId batch $batchId => $resUpdate");
      return resUpdate;
    } catch (e) {
      print("Error al actualizar el campo $field: $e");
      return null;
    }
  }
}
