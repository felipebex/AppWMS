// ignore_for_file: unrelated_type_equality_checks

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/devoluciones/tbl_product/product_devolucion_table.dart';
import 'package:wms_app/src/presentation/views/devoluciones/models/product_devolucion_model.dart';
import 'dart:core'; // Asegúrate de importar esto para usar Stopwatch.

class ProductDevolucionRepository {
  final DataBaseSqlite _databaseProvider;

  ProductDevolucionRepository(this._databaseProvider);
  // Insertar productos en inventario
  Future<void> insertProductosDevoluciones(
      List<ProductDevolucion> productosList) async {
    // Crear el cronómetro para medir el tiempo de inserción
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    var count = 0;

    try {
      Database db = await _databaseProvider.getDatabaseInstance();

      // Iniciar una transacción
      await db.transaction((txn) async {
        // Usamos un batch para agrupar las operaciones y mejorar el rendimiento
        Batch batch = txn.batch();

        // Iterar sobre la lista de productos
        for (var producto in productosList) {
          // Aumentar el contador
          count++;

          Map<String, dynamic> productoMap = {
            // product_code
            ProductDevolucionTable.columnProductCode:
                producto.code == false ? "" : producto.code ?? '',
            ProductDevolucionTable.columnProductId: producto.productId,
            ProductDevolucionTable.columnProductName: producto.name ?? '',
            ProductDevolucionTable.columnBarcode:
                producto.barcode == false ? "" : producto.barcode ?? '',
            ProductDevolucionTable.columnProductracking:
                producto.tracking == false ? "none" : producto.tracking ?? '',
            ProductDevolucionTable.columnLotId:
                producto.lotId == false ? 0 : producto.lotId ?? 0,
            ProductDevolucionTable.columnLotName:
                producto.lotName == false ? "" : producto.lotName ?? '',
            ProductDevolucionTable.columnExpirationDate:
                producto.expirationDate == false
                    ? ""
                    : producto.expirationDate ?? '',
            ProductDevolucionTable.columnWeight:
                producto.weight == false ? 0 : producto.weight ?? 0,
            ProductDevolucionTable.columnWeightUomName:
                producto.weightUomName == false
                    ? ""
                    : producto.weightUomName ?? '',
            ProductDevolucionTable.columnVolume:
                producto.volume == false ? 0 : producto.volume ?? 0,
            ProductDevolucionTable.columnVolumeUomName:
                producto.volumeUomName == false
                    ? ""
                    : producto.volumeUomName ?? '',
            ProductDevolucionTable.columnUom:
                producto.uom == false ? "" : producto.uom ?? '',
            ProductDevolucionTable.columnLocationId:
                producto.locationId == false ? 0 : producto.locationId ?? 0,
            ProductDevolucionTable.columnLocationName:
                producto.locationName == false
                    ? ""
                    : producto.locationName ?? '',
            ProductDevolucionTable.columnQuantity:
                producto.quantity == false ? 0.0 : producto.quantity ?? 0.0,
          };

          batch.insert(
            ProductDevolucionTable.tableName,
            productoMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Ejecutar todas las operaciones del batch de una vez
        await batch.commit(noResult: true);
      });

      // Detener el cronómetro después de la inserción
      stopwatch.stop();

      // Mostrar el tiempo que ha tardado en completar la inserción
      print("Tiempo de inserción: ${stopwatch.elapsedMilliseconds} ms");
      // Mostrar la cantidad de productos insertados
      print("Cantidad de productos insertados: $count");
    } catch (e, s) {
      print(
          "Error al insertar productos en insertProductosDevoluciones: $e ==> $s");
    }
  }

  Future<void> insertProductoDevolucion(ProductDevolucion producto) async {
    try {
      Database db = await _databaseProvider.getDatabaseInstance();

      // Preparar los datos del producto

      Map<String, dynamic> productoMap = {
        // product_code
        ProductDevolucionTable.columnProductCode:
            producto.code == false ? "" : producto.code ?? '',
        ProductDevolucionTable.columnProductId: producto.productId,
        ProductDevolucionTable.columnProductName: producto.name ?? '',
        ProductDevolucionTable.columnBarcode:
            producto.barcode == false ? "" : producto.barcode ?? '',
        ProductDevolucionTable.columnProductracking:
            producto.tracking == false ? "none" : producto.tracking ?? '',
        ProductDevolucionTable.columnLotId:
            producto.lotId == false ? 0 : producto.lotId ?? 0,
        ProductDevolucionTable.columnLotName:
            producto.lotName == false ? "" : producto.lotName ?? '',
        ProductDevolucionTable.columnExpirationDate:
            producto.expirationDate == false
                ? ""
                : producto.expirationDate ?? '',
        ProductDevolucionTable.columnWeight:
            producto.weight == false ? 0 : producto.weight ?? 0,
        ProductDevolucionTable.columnWeightUomName:
            producto.weightUomName == false ? "" : producto.weightUomName ?? '',
        ProductDevolucionTable.columnVolume:
            producto.volume == false ? 0 : producto.volume ?? 0,
        ProductDevolucionTable.columnVolumeUomName:
            producto.volumeUomName == false ? "" : producto.volumeUomName ?? '',
        ProductDevolucionTable.columnUom:
            producto.uom == false ? "" : producto.uom ?? '',
        ProductDevolucionTable.columnLocationId:
            producto.locationId == false ? 0 : producto.locationId ?? 0,
        ProductDevolucionTable.columnLocationName:
            producto.locationName == false ? "" : producto.locationName ?? '',
        ProductDevolucionTable.columnQuantity:
            producto.quantity == false ? 0.0 : producto.quantity ?? 0.0,
      };

      // Insertar el producto directamente
      await db.insert(
        ProductDevolucionTable.tableName,
        productoMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print("✅ Producto insertado: ${producto.code}");
    } catch (e, s) {
      print("❌ Error en insertProductoDevolucion: $e ==> $s");
    }
  }

  //metodo para eliminar un producto
  Future<void> deleteProductoDevolucion(int productId) async {
    try {
      Database db = await _databaseProvider.getDatabaseInstance();
      await db.delete(
        ProductDevolucionTable.tableName,
        where: '${ProductDevolucionTable.columnProductId} = ?',
        whereArgs: [productId],
      );
    } catch (e, s) {
      print(
          "Error al eliminar producto en deleteProductoDevolucion: $e ==> $s");
    }
  }

  //metodo para eliminar todos los productos
  Future<void> deleteAllProductosDevoluciones() async {
    try {
      Database db = await _databaseProvider.getDatabaseInstance();
      await db.delete(ProductDevolucionTable.tableName);
    } catch (e, s) {
      print(
          "Error al eliminar todos los productos en deleteAllProductosDevoluciones: $e ==> $s");
    }
  }

  //metodo para obtener todos los productos
  Future<List<ProductDevolucion>> getAllProductosDevoluciones() async {
    try {
      Database db = await _databaseProvider.getDatabaseInstance();
      final List<Map<String, dynamic>> maps =
          await db.query(ProductDevolucionTable.tableName);

      return List.generate(maps.length, (i) {
        return ProductDevolucion.fromMap(maps[i]);
      });
    } catch (e, s) {
      print(
          "Error al obtener todos los productos en getAllProductosDevoluciones: $e ==> $s");
      return [];
    }
  }

  //metodo para obtener un producto por su id
  Future<ProductDevolucion?> getProductoDevolucionById(int productId) async {
    try {
      Database db = await _databaseProvider.getDatabaseInstance();
      final List<Map<String, dynamic>> maps = await db.query(
        ProductDevolucionTable.tableName,
        where: '${ProductDevolucionTable.columnProductId} = ?',
        whereArgs: [productId],
      );
      if (maps.isNotEmpty) {
        return ProductDevolucion.fromMap(maps.first);
      } else {
        return null; // No se encontró el producto
      }
    } catch (e, s) {
      print(
          "Error al obtener producto por ID en getProductoDevolucionById: $e ==> $s");
      return null;
    }
  }

  //metodo apra actualizar un producto
  Future<void> updateProductoDevolucion(ProductDevolucion producto) async {
    try {
      Database db = await _databaseProvider.getDatabaseInstance();

      Map<String, dynamic> productoMap = {
        // product_code
        ProductDevolucionTable.columnProductCode:
            producto.code == false ? "" : producto.code ?? '',
        ProductDevolucionTable.columnProductId: producto.productId,
        ProductDevolucionTable.columnProductName: producto.name ?? '',
        ProductDevolucionTable.columnBarcode:
            producto.barcode == false ? "" : producto.barcode ?? '',
        ProductDevolucionTable.columnProductracking:
            producto.tracking == false ? "none" : producto.tracking ?? '',
        ProductDevolucionTable.columnLotId:
            producto.lotId == false ? 0 : producto.lotId ?? 0,
        ProductDevolucionTable.columnLotName:
            producto.lotName == false ? "" : producto.lotName ?? '',
        ProductDevolucionTable.columnExpirationDate:
            producto.expirationDate == false
                ? ""
                : producto.expirationDate ?? '',
        ProductDevolucionTable.columnWeight:
            producto.weight == false ? 0 : producto.weight ?? 0,
        ProductDevolucionTable.columnWeightUomName:
            producto.weightUomName == false ? "" : producto.weightUomName ?? '',
        ProductDevolucionTable.columnVolume:
            producto.volume == false ? 0 : producto.volume ?? 0,
        ProductDevolucionTable.columnVolumeUomName:
            producto.volumeUomName == false ? "" : producto.volumeUomName ?? '',
        ProductDevolucionTable.columnUom:
            producto.uom == false ? "" : producto.uom ?? '',
        ProductDevolucionTable.columnLocationId:
            producto.locationId == false ? 0 : producto.locationId ?? 0,
        ProductDevolucionTable.columnLocationName:
            producto.locationName == false ? "" : producto.locationName ?? '',
        ProductDevolucionTable.columnQuantity:
            producto.quantity == false ? 0.0 : producto.quantity ?? 0.0,
      };

      await db.update(
        ProductDevolucionTable.tableName,
        productoMap,
        where: '${ProductDevolucionTable.columnProductId} = ?',
        whereArgs: [producto.productId],
      );

      print("✅ Producto actualizado: ${producto.code}");
    } catch (e, s) {
      print("❌ Error en updateProductoDevolucion: $e ==> $s");
    }
  }
}
