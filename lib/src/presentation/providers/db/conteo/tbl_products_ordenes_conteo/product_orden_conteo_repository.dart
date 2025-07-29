import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/conteo/tbl_products_ordenes_conteo/product_orden_conteo_table.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';

class ProductoOrdenConteoRepository {
  // Insertar/actualizar productos de orden de conteo
  Future<void> upsertProductosOrdenConteo(List<CountedLine> productos) async {
    Stopwatch stopwatch = Stopwatch()..start();
    // ignore: unused_local_variable
    var count = 0;
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      await db.transaction((txn) async {
        final Batch batch = txn.batch();

        for (final producto in productos) {
          count++;

          final productoMap = {
            ProductosOrdenConteoTable.columnId: producto.id,
            ProductosOrdenConteoTable.columnOrderId: producto.orderId,
            ProductosOrdenConteoTable.columnProductId: producto.productId,
            ProductosOrdenConteoTable.columnProductName:
                producto.productName ?? '',
            ProductosOrdenConteoTable.columnProductCode:
                producto.productCode ?? '',
            ProductosOrdenConteoTable.columnProductBarcode:
                producto.productBarcode ?? '',
            ProductosOrdenConteoTable.columnProductTracking:
                producto.productTracking ?? 'none',
            ProductosOrdenConteoTable.columnLocationId:
                producto.locationId ?? 0,
            ProductosOrdenConteoTable.columnLocationName:
                producto.locationName ?? '',
            ProductosOrdenConteoTable.columnLocationBarcode:
                producto.locationBarcode ?? '',
            ProductosOrdenConteoTable.columnQuantityInventory:
                producto.quantityInventory ?? 0.0,
            ProductosOrdenConteoTable.columnQuantityCounted:
                producto.quantityCounted ?? 0.0,
            ProductosOrdenConteoTable.columnDifferenceQty:
                producto.differenceQty ?? 0.0,
            ProductosOrdenConteoTable.columnUom: producto.uom ?? '',
            ProductosOrdenConteoTable.columnWeight: producto.weight ?? 0.0,
            ProductosOrdenConteoTable.columnIsDoneItem:
                producto.isDoneItem == true ? 1 : 0,
            ProductosOrdenConteoTable.columnDateTransaction:
                producto.dateTransaction ?? '',
            ProductosOrdenConteoTable.columnObservation:
                producto.observation ?? '',
            ProductosOrdenConteoTable.columnTime: producto.time ?? '',
            ProductosOrdenConteoTable.columnUserOperatorId:
                producto.userOperatorId ?? 0,
            ProductosOrdenConteoTable.columnUserOperatorName:
                producto.userOperatorName ?? '',
            ProductosOrdenConteoTable.columnCategoryId:
                producto.categoryId ?? 0,
            ProductosOrdenConteoTable.columnCategoryName:
                producto.categoryName ?? '',
            ProductosOrdenConteoTable.columnLotId: producto.lotId ?? 0,
            ProductosOrdenConteoTable.columnLotName: producto.lotName ?? '',
            ProductosOrdenConteoTable.columnFechaVencimiento:
                producto.fechaVencimiento ?? '',
          };

          batch.insert(
            ProductosOrdenConteoTable.tableName,
            productoMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit(noResult: true);
      });

      stopwatch.stop();
      print(
          '✅ ${productos.length} productos insertados/actualizados en ${stopwatch.elapsedMilliseconds}ms');
    } catch (e, s) {
      print('❌ Error en upsertProductosOrdenConteo: $e');
      print(s);
      rethrow;
    }
  }

  // Obtener todos los productos de una orden específica
  Future<List<CountedLine>> getProductosByOrderId(int orderId) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> maps = await db.query(
        ProductosOrdenConteoTable.tableName,
        where: '${ProductosOrdenConteoTable.columnOrderId} = ?',
        whereArgs: [orderId],
      );

      return List.generate(maps.length, (i) => CountedLine.fromMap(maps[i]));
    } catch (e, s) {
      print('Error en getProductosByOrderId: $e');
      print(s);
      return [];
    }
  }

  // Actualizar cantidad contada de un producto
  Future<int> updateCantidadContada({
    required int productId,
    required int orderId,
    required double cantidad,
    required int userId,
    required String userName,
    String? observation,
  }) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      return await db.update(
        ProductosOrdenConteoTable.tableName,
        {
          ProductosOrdenConteoTable.columnQuantityCounted: cantidad,
          ProductosOrdenConteoTable.columnDifferenceQty:
              cantidad - (await _getCantidadInventario(db, productId, orderId)),
          ProductosOrdenConteoTable.columnUserOperatorId: userId,
          ProductosOrdenConteoTable.columnUserOperatorName: userName,
          ProductosOrdenConteoTable.columnDateTransaction:
              DateTime.now().toIso8601String(),
          ProductosOrdenConteoTable.columnObservation: observation,
          ProductosOrdenConteoTable.columnIsDoneItem: 1,
        },
        where:
            '${ProductosOrdenConteoTable.columnProductId} = ? AND ${ProductosOrdenConteoTable.columnOrderId} = ?',
        whereArgs: [productId, orderId],
      );
    } catch (e, s) {
      print('Error en updateCantidadContada: $e');
      print(s);
      return 0;
    }
  }

  // Método privado para obtener cantidad en inventario
  Future<double> _getCantidadInventario(
      Database db, int productId, int orderId) async {
    final maps = await db.query(
      ProductosOrdenConteoTable.tableName,
      columns: [ProductosOrdenConteoTable.columnQuantityInventory],
      where:
          '${ProductosOrdenConteoTable.columnProductId} = ? AND ${ProductosOrdenConteoTable.columnOrderId} = ?',
      whereArgs: [productId, orderId],
      limit: 1,
    );

    return maps.isNotEmpty
        ? maps.first[ProductosOrdenConteoTable.columnQuantityInventory]
            as double
        : 0.0;
  }

  // Eliminar productos de una orden
}
