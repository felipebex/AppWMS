// ignore_for_file: unrelated_type_equality_checks

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/inventario/tbl_product/product_inventario_table.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/update_product_request.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'dart:core'; // Asegúrate de importar esto para usar Stopwatch.

class ProductInventarioRepository {
  // Insertar productos en inventario
  Future<void> insertProductosInventario(List<Product> productosList) async {
    // Crear el cronómetro para medir el tiempo de inserción
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    var count = 0;

    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Iniciar una transacción
      await db.transaction((txn) async {
        // Usamos un batch para agrupar las operaciones y mejorar el rendimiento
        Batch batch = txn.batch();

        // Iterar sobre la lista de productos
        for (var producto in productosList) {
          // Aumentar el contador
          count++;

          // Preparar los datos del producto para insertarlos o actualizarlos
          Map<String, dynamic> productoMap = {
            // product_code
            ProductInventarioTable.columnProductCode:
                producto.code == false ? "" : producto.code ?? '',
            ProductInventarioTable.columnProductId: producto.productId,
            ProductInventarioTable.columnProductName: producto.name ?? '',
            ProductInventarioTable.columnBarcode:
                producto.barcode == false ? "" : producto.barcode ?? '',
            ProductInventarioTable.columnProductracking:
                producto.tracking == false ? "none" : producto.tracking ?? '',
            ProductInventarioTable.columnLotId:
                producto.lotId == false ? 0 : producto.lotId ?? 0,
            ProductInventarioTable.columnLotName:
                producto.lotName == false ? "" : producto.lotName ?? '',
            ProductInventarioTable.columnExpirationDate:
                producto.expirationDate == false
                    ? ""
                    : producto.expirationDate ?? '',
            ProductInventarioTable.columnWeight:
                producto.weight == false ? 0 : producto.weight ?? 0,
            ProductInventarioTable.columnWeightUomName:
                producto.weightUomName == false
                    ? ""
                    : producto.weightUomName ?? '',
            ProductInventarioTable.columnVolume:
                producto.volume == false ? 0 : producto.volume ?? 0,
            ProductInventarioTable.columnVolumeUomName:
                producto.volumeUomName == false
                    ? ""
                    : producto.volumeUomName ?? '',
            ProductInventarioTable.columnUom:
                producto.uom == false ? "" : producto.uom ?? '',
            ProductInventarioTable.columnLocationId:
                producto.locationId == false ? 0 : producto.locationId ?? 0,
            ProductInventarioTable.columnLocationName:
                producto.locationName == false
                    ? ""
                    : producto.locationName ?? '',
            ProductInventarioTable.columnQuantity:
                producto.quantity == false ? 0.0 : producto.quantity ?? 0.0,
            ProductInventarioTable.columnUseExpirationDate:
                producto.useExpirationDate == true ? 1 : 0,
          };

          batch.insert(
            ProductInventarioTable.tableName,
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
      print("Error al insertar productos en productos_inventario: $e ==> $s");
    }
  }

  //metodo para traer todos los productos
  Future<List<Product>> getAllProducts() async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      List<Map<String, dynamic>> maps =
          await db.query(ProductInventarioTable.tableName);
      if (maps.isNotEmpty) {
        return List.generate(
          maps.length,
          (i) => Product.fromMap(maps[i]),
        );
      } else {
        return [];
      }
    } catch (e, s) {
      print("Error al obtener productos: $e ==> $s");
      return [];
    }
  }

  Future<List<Product>> getAllUniqueProducts() async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      // Consulta para agrupar por productId
      final maps = await db.rawQuery('''
      SELECT * FROM ${ProductInventarioTable.tableName}
      GROUP BY ${ProductInventarioTable.columnProductId}
    ''');

      return maps.map((map) => Product.fromMap(map)).toList();
    } catch (e, s) {
      print("Error al obtener productos únicos por ID: $e ==> $s");
      return [];
    }
  }

  //metodo para traer un producto por su id
  Future<Product?> getProductById(int productId) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      List<Map<String, dynamic>> maps = await db.query(
        ProductInventarioTable.tableName,
        where: '${ProductInventarioTable.columnProductId} = ?',
        whereArgs: [productId],
      );
      if (maps.isNotEmpty) {
        return Product.fromMap(maps.first);
      } else {
        return null;
      }
    } catch (e, s) {
      print("Error al obtener producto por id: $e ==> $s");
      return null;
    }
  }

  //metodo para actualizar un producto por su id
  Future<void> updateProduct(UpdateProductRequest product) async {
    try {
      print('product to update: ${product.toMap()}');
      Database db = await DataBaseSqlite().getDatabaseInstance();
      await db.update(
        ProductInventarioTable.tableName,
        {
          ProductInventarioTable.columnProductName: product.name,
          ProductInventarioTable.columnBarcode: product.barcode,
          ProductInventarioTable.columnProductCode: product.defaultCode,
          ProductInventarioTable.columnWeight: product.weight,
          ProductInventarioTable.columnVolume: product.volume,
        },            
        where: '${ProductInventarioTable.columnProductId} = ?',
        whereArgs: [product.productId],
      );
      print("Producto actualizado correctamente: ${product.productId}");
    } catch (e, s) {
      print("Error al actualizar producto: $e ==> $s");   
    }
  }


}
