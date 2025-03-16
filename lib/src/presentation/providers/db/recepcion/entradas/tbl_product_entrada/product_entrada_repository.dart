import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_product_entrada/product_entrada_table.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';

class ProductsEntradaRepository {
  Future<void> insertarProductoEntrada(List<LineasRecepcion> products) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      // Comienza la transacción
      await db.transaction(
        (txn) async {
          Batch batch = txn.batch();
          // Primero, obtener todas las IDs de las novedades existentes

          final List<Map<String, dynamic>> existingProducts = await txn.query(
            ProductEntradaTable.tableName,
            columns: [ProductEntradaTable.columnId],
            where:
                '${ProductEntradaTable.columnId} =? AND ${ProductEntradaTable.columnIdMove} = ? AND ${ProductEntradaTable.columnIdRecepcion} = ? ',
            whereArgs: [
              products.map((product) => product.productId).toList().join(','),
              products.map((product) => product.idMove).toList().join(','),
              products.map((product) => product.idRecepcion).toList().join(','),
            ],
          );

          // Crear un conjunto de los IDs existentes para facilitar la comprobación
          Set<int> existingIds = Set.from(existingProducts.map((e) {
            return e[ProductEntradaTable.columnId];
          }));

          // Recorrer todas las novedades y realizar insert o update según corresponda
          for (var LineasRecepcion in products) {
            if (existingIds.contains(LineasRecepcion.productId)) {
              // Si la novedad ya existe, la actualizamos
              batch.update(
                ProductEntradaTable.tableName,
                {
                  ProductEntradaTable.columnIdMove: LineasRecepcion.idMove,
                  ProductEntradaTable.columnProductId:
                      LineasRecepcion.productId,
                  ProductEntradaTable.columnIdRecepcion:
                      LineasRecepcion.idRecepcion,
                  ProductEntradaTable.columnProductName:
                      LineasRecepcion.productName,
                  ProductEntradaTable.columnProductCode:
                      LineasRecepcion.productCode,
                  ProductEntradaTable.columnProductBarcode:
                      LineasRecepcion.productBarcode,
                  ProductEntradaTable.columnProductTracking:
                      LineasRecepcion.productTracking,
                  ProductEntradaTable.columnFechaVencimiento:
                      LineasRecepcion.fechaVencimiento,
                  ProductEntradaTable.columnDiasVencimiento:
                      LineasRecepcion.diasVencimiento,
                  ProductEntradaTable.columnQuantityOrdered:
                      LineasRecepcion.quantityOrdered,
                  ProductEntradaTable.columnQuantityToReceive:
                      LineasRecepcion.quantityToReceive,
                  ProductEntradaTable.columnQuantityDone:
                      LineasRecepcion.quantityDone,
                  ProductEntradaTable.columnUom: LineasRecepcion.uom,
                  ProductEntradaTable.columnLocationDestId:
                      LineasRecepcion.locationDestId,
                  ProductEntradaTable.columnLocationDestName:
                      LineasRecepcion.locationDestName,
                  ProductEntradaTable.columnLocationBarcode:
                      LineasRecepcion.locationBarcode,
                  ProductEntradaTable.columnLocationId:
                      LineasRecepcion.locationId,
                  ProductEntradaTable.columnLocationName:
                      LineasRecepcion.locationName,
                  ProductEntradaTable.columnWeight: LineasRecepcion.weight,
                },
                where:
                    '${ProductEntradaTable.columnId} = ? AND ${ProductEntradaTable.columnIdMove} = ? AND ${ProductEntradaTable.columnIdRecepcion} = ? ',
                whereArgs: [
                  LineasRecepcion.productId,
                  LineasRecepcion.idMove,
                  LineasRecepcion.idRecepcion
                ],
              );
            } else {
              batch.insert(
                ProductEntradaTable.tableName,
                {
                  ProductEntradaTable.columnId: LineasRecepcion.id,
                  ProductEntradaTable.columnIdMove: LineasRecepcion.idMove,
                  ProductEntradaTable.columnProductId:
                      LineasRecepcion.productId,
                  ProductEntradaTable.columnIdRecepcion:
                      LineasRecepcion.idRecepcion,
                  ProductEntradaTable.columnProductName:
                      LineasRecepcion.productName,
                  ProductEntradaTable.columnProductCode:
                      LineasRecepcion.productCode,
                  ProductEntradaTable.columnProductBarcode:
                      LineasRecepcion.productBarcode,
                  ProductEntradaTable.columnProductTracking:
                      LineasRecepcion.productTracking,
                  ProductEntradaTable.columnFechaVencimiento:
                      LineasRecepcion.fechaVencimiento,
                  ProductEntradaTable.columnDiasVencimiento:
                      LineasRecepcion.diasVencimiento,
                  ProductEntradaTable.columnQuantityOrdered:
                      LineasRecepcion.quantityOrdered,
                  ProductEntradaTable.columnQuantityToReceive:
                      LineasRecepcion.quantityToReceive,
                  ProductEntradaTable.columnQuantityDone:
                      LineasRecepcion.quantityDone,
                  ProductEntradaTable.columnUom: LineasRecepcion.uom,
                  ProductEntradaTable.columnLocationDestId:
                      LineasRecepcion.locationDestId,
                  ProductEntradaTable.columnLocationDestName:
                      LineasRecepcion.locationDestName,
                  ProductEntradaTable.columnLocationBarcode:
                      LineasRecepcion.locationBarcode,
                  ProductEntradaTable.columnLocationId:
                      LineasRecepcion.locationId,
                  ProductEntradaTable.columnLocationName:
                      LineasRecepcion.locationName,
                  ProductEntradaTable.columnWeight: LineasRecepcion.weight,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          await batch.commit();
        },
      );
      print('Productos de entragas insertados con éxito.');
    } catch (e, s) {
      print('Error en el insertarProductoEntrada: $e, $s');
    }
  }
}
