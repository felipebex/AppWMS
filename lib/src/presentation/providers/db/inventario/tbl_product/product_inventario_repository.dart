// ignore_for_file: unrelated_type_equality_checks

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/inventario/tbl_product/product_inventario_table.dart';
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
            ProductInventarioTable.columnQuantId: producto.quantId,
            ProductInventarioTable.columnLocationId: producto.locationId,
            ProductInventarioTable.columnLocationName:
                producto.locationName ?? '',
            ProductInventarioTable.columnProductId: producto.productId,
            ProductInventarioTable.columnProductName:
                producto.productName ?? '',
            ProductInventarioTable.columnBarcode:
                producto.barcode == false ? "" : producto.barcode ?? '',
            ProductInventarioTable.columnProductracking:
                producto.productTracking == false
                    ? "none"
                    : producto.productTracking ?? '',
            ProductInventarioTable.columnLotId:
                producto.lotId == false ? 0 : producto.lotId ?? 0,
            ProductInventarioTable.columnLotName:
                producto.lotName == false ? "" : producto.lotName ?? '',
            ProductInventarioTable.columnInDate:
                producto.inDate == false ? "" : producto.inDate ?? '',
            ProductInventarioTable.columnExpirationDate:
                producto.expirationDate == false
                    ? ""
                    : producto.expirationDate ?? '',
            ProductInventarioTable.columnAvailableQuantity:
                producto.availableQuantity ?? 0,
            ProductInventarioTable.columnQuantity: producto.quantity,
          };

          // Usar el método batch para insertar o actualizar sin bloqueos
          // El conflicto se resuelve con el algoritmo 'replace', lo que reemplazará
          // cualquier registro con la misma clave primaria (o índice único).
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

  //metodo para traer todos los productos de una ubicacion
  Future<List<Product>> getAllProductsByLocation(int locationId) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      print("locationId: $locationId");
      List<Map<String, dynamic>> maps = await db.query(
        ProductInventarioTable.tableName,
        where: '${ProductInventarioTable.columnLocationId} = ?',
        whereArgs: [locationId],
      );
      if (maps.isNotEmpty) {
        return List.generate(
          maps.length,
          (i) => Product.fromMap(maps[i]),
        );
      } else {
        return [];
      }
    } catch (e, s) {
      print("Error al obtener productos por ubicacion: $e ==> $s");
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

}
