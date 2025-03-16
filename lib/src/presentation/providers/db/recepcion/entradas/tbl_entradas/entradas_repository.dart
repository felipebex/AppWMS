import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_entradas/entradas_table.dart';

import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';

class EntradasRepository {
  Future<void> insertEntrada(List<ResultEntrada> entradas) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      // Comienza la transacción
      await db.transaction((txn) async {
        Batch batch = txn.batch();

        // Primero, obtener todas las IDs de las novedades existentes

        final List<Map<String, dynamic>> existingEntradas = await txn.query(
          EntradasRepeccionTable.tableName,
          columns: [EntradasRepeccionTable.columnId],
          where: '${EntradasRepeccionTable.columnId} =? ',
          whereArgs: [entradas.map((entrada) => entrada.id).toList().join(',')],
        );

        // Crear un conjunto de los IDs existentes para facilitar la comprobación

        Set<int> existingIds = Set.from(existingEntradas.map((e) {
          return e[EntradasRepeccionTable.columnId];
        }));

        // Recorrer todas las novedades y realizar insert o update según corresponda

        for (var entrada in entradas) {
          if (existingIds.contains(entrada.id)) {
            // Si la novedad ya existe, la actualizamos
            batch.update(
              EntradasRepeccionTable.tableName,
              {
                EntradasRepeccionTable.columnName: entrada.name,
                EntradasRepeccionTable.columnFechaCreacion:
                    entrada.fechaCreacion,
                EntradasRepeccionTable.columnProveedorId: entrada.proveedorId,
                EntradasRepeccionTable.columnProveedor: entrada.proveedor,
                EntradasRepeccionTable.columnLocationDestId:
                    entrada.locationDestId,
                EntradasRepeccionTable.columnLocationDestName:
                    entrada.locationDestName,
                EntradasRepeccionTable.columnPurchaseOrderId:
                    entrada.purchaseOrderId,
                EntradasRepeccionTable.columnPurchaseOrderName:
                    entrada.purchaseOrderName,
                EntradasRepeccionTable.columnNumeroEntrada:
                    entrada.numeroEntrada,
                EntradasRepeccionTable.columnPesoTotal: entrada.pesoTotal,
                EntradasRepeccionTable.columnNumeroLineas: entrada.numeroLineas,
                EntradasRepeccionTable.columnNumeroItems: entrada.numeroItems,
                EntradasRepeccionTable.columnState: entrada.state,
                EntradasRepeccionTable.columnOrigin: entrada.origin,
                EntradasRepeccionTable.columnPriority: entrada.priority,
                EntradasRepeccionTable.columnWarehouseId: entrada.warehouseId,
                EntradasRepeccionTable.columnWarehouseName:
                    entrada.warehouseName,
                EntradasRepeccionTable.columnLocationId: entrada.locationId,
                EntradasRepeccionTable.columnLocationName: entrada.locationName,
                EntradasRepeccionTable.columnResponsableId:
                    entrada.responsableId,
                EntradasRepeccionTable.columnResponsable: entrada.responsable,
                EntradasRepeccionTable.columnPickingType: entrada.pickingType,
              },
              where: '${EntradasRepeccionTable.columnId} = ?',
              whereArgs: [entrada.id],
            );
          } else {
            // Si la novedad no existe, la insertamos
            batch.insert(
              EntradasRepeccionTable.tableName,
              {
                EntradasRepeccionTable.columnName: entrada.name,
                EntradasRepeccionTable.columnFechaCreacion:
                    entrada.fechaCreacion,
                EntradasRepeccionTable.columnProveedorId: entrada.proveedorId,
                EntradasRepeccionTable.columnProveedor: entrada.proveedor,
                EntradasRepeccionTable.columnLocationDestId:
                    entrada.locationDestId,
                EntradasRepeccionTable.columnLocationDestName:
                    entrada.locationDestName,
                EntradasRepeccionTable.columnPurchaseOrderId:
                    entrada.purchaseOrderId,
                EntradasRepeccionTable.columnPurchaseOrderName:
                    entrada.purchaseOrderName,
                EntradasRepeccionTable.columnNumeroEntrada:
                    entrada.numeroEntrada,
                EntradasRepeccionTable.columnPesoTotal: entrada.pesoTotal,
                EntradasRepeccionTable.columnNumeroLineas: entrada.numeroLineas,
                EntradasRepeccionTable.columnNumeroItems: entrada.numeroItems,
                EntradasRepeccionTable.columnState: entrada.state,
                EntradasRepeccionTable.columnOrigin: entrada.origin,
                EntradasRepeccionTable.columnPriority: entrada.priority,
                EntradasRepeccionTable.columnWarehouseId: entrada.warehouseId,
                EntradasRepeccionTable.columnWarehouseName:
                    entrada.warehouseName,
                EntradasRepeccionTable.columnLocationId: entrada.locationId,
                EntradasRepeccionTable.columnLocationName: entrada.locationName,
                EntradasRepeccionTable.columnResponsableId:
                    entrada.responsableId,
                EntradasRepeccionTable.columnResponsable: entrada.responsable,
                EntradasRepeccionTable.columnPickingType: entrada.pickingType,
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
}
