// productos_pedidos_repository.dart

// ignore_for_file: unnecessary_string_interpolations, unrelated_type_equality_checks

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_products_pedido/productos_pedido_pack_table.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/lista_product_packing.dart';

class ProductosPedidosRepository {
  // Insertar producto duplicado
  Future<void> insertDuplicateProductoPedido(
      ProductoPedido producto, dynamic cantidad, String type) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      Map<String, dynamic> productCopy = {
        ProductosPedidosTable.columnProductId: producto.productId,
        ProductosPedidosTable.columnBatchId: producto.batchId,
        ProductosPedidosTable.columnPedidoId: producto.pedidoId,
        ProductosPedidosTable.columnIdMove: producto.idMove,
        ProductosPedidosTable.columnIdProduct: producto.idProduct,
        ProductosPedidosTable.columnBarcodeLocation:
            producto.barcodeLocation ?? '',
        ProductosPedidosTable.columnLoteId: producto.loteId ?? '',
        ProductosPedidosTable.columnLotId: producto.lotId ?? '',
        ProductosPedidosTable.columnLocationId: producto.locationId ?? '',
        ProductosPedidosTable.columnIdLocation: producto.idLocation ?? 0,
        ProductosPedidosTable.columnLocationDestId:
            producto.locationDestId ?? '',
        ProductosPedidosTable.columnIdLocationDest:
            producto.idLocationDest ?? 0,
        ProductosPedidosTable.columnQuantity: cantidad,
        ProductosPedidosTable.columnExpireDate: producto.expireDate ?? '',
        ProductosPedidosTable.columnTracking: producto.tracking ?? '',
        ProductosPedidosTable.columnBarcode: producto.barcode ?? '',
        ProductosPedidosTable.columnWeight: producto.weight ?? 0.0,
        ProductosPedidosTable.columnUnidades: producto.unidades ?? '',
        ProductosPedidosTable.columnIsLocationIsOk: 0,
        ProductosPedidosTable.columnIsQuantityIsOk: 0,
        ProductosPedidosTable.columnLocationDestIsOk: 0,
        ProductosPedidosTable.columnProductIsOk: 0,
        ProductosPedidosTable.columnObservation: 'Sin novedad',
        ProductosPedidosTable.columnIsSelected: 0,
        ProductosPedidosTable.columnIsProductSplit: 1,
        ProductosPedidosTable.columnType: type,
        ProductosPedidosTable.columnManejoTemperature:
            producto.manejaTemperatura ?? 0,
        ProductosPedidosTable.columnTemperature: producto.temperatura ?? 0.0,
        ProductosPedidosTable.columnImage: producto.image ?? '',
        ProductosPedidosTable.columnImageNovedad: producto.imageNovedad ?? '',
        ProductosPedidosTable.columnTimeSeparate: 0,
        ProductosPedidosTable.columnTimeSeparateStart: null,
        ProductosPedidosTable.columnTimeSeparateEnd: null,
      };

      await db.insert(
        ProductosPedidosTable.tableName,
        productCopy,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Producto duplicado insertado con éxito.");
    } catch (e, s) {
      print("Error al insertar producto duplicado: $e ==> $s");
    }
  }

  Future<void> insertProductosPedidos(
      List<ProductoPedido> productosList, String type) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      await db.transaction((txn) async {
        for (var producto in productosList) {
          final List<Map<String, dynamic>> existingProducto = await txn.query(
            ProductosPedidosTable.tableName,
            where:
                '${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnBatchId} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ?',
            whereArgs: [
              producto.idProduct,
              producto.batchId,
              producto.pedidoId,
              producto.idMove
            ],
          );

          // Función para limpiar valores booleanos
          dynamic cleanValue(dynamic value,
              {String defaultString = '', num defaultNum = 0}) {
            if (value is bool) return value ? defaultString : defaultString;
            return value ?? defaultString;
          }

          double cleanDouble(dynamic value) {
            if (value is bool || value == null) return 0.0;
            return double.tryParse(value.toString()) ?? 0.0;
          }

          Map<String, dynamic> dataMap = {
            ProductosPedidosTable.columnProductId:
                producto.productId is List && producto.productId.length > 1
                    ? producto.productId[1]
                    : '',
            ProductosPedidosTable.columnBatchId: producto.batchId,
            ProductosPedidosTable.columnPedidoId: producto.pedidoId,
            ProductosPedidosTable.columnIdMove: producto.idMove,
            ProductosPedidosTable.columnIdProduct: producto.idProduct,
            ProductosPedidosTable.columnBarcodeLocation:
                cleanValue(producto.barcodeLocation),
            ProductosPedidosTable.columnLoteId: producto.loteId,
            ProductosPedidosTable.columnLotId:
                producto.lotId is List && producto.lotId.isNotEmpty
                    ? producto.lotId[1]
                    : '',
            ProductosPedidosTable.columnLocationId:
                producto.locationId is List && producto.locationId.length > 1
                    ? producto.locationId[1]
                    : null,
            ProductosPedidosTable.columnIdLocation:
                producto.locationId is List && producto.locationId.length > 1
                    ? producto.locationId[0]
                    : null,
            ProductosPedidosTable.columnLocationDestId:
                producto.locationDestId is List &&
                        producto.locationDestId.length > 1
                    ? producto.locationDestId[1]
                    : null,
            ProductosPedidosTable.columnIdLocationDest:
                producto.locationDestId is List &&
                        producto.locationDestId.length > 1
                    ? producto.locationDestId[0]
                    : null,
            ProductosPedidosTable.columnQuantity: producto.quantity,
            ProductosPedidosTable.columnExpireDate: producto.expireDate,
            ProductosPedidosTable.columnTracking:
                cleanValue(producto.tracking).toString(),
            ProductosPedidosTable.columnBarcode:
                cleanValue(producto.barcode).toString(),
            ProductosPedidosTable.columnWeight: cleanDouble(producto.weight),
            ProductosPedidosTable.columnUnidades:
                cleanValue(producto.unidades).toString(),
            ProductosPedidosTable.columnType: type,
            ProductosPedidosTable.columnManejoTemperature:
                producto.manejaTemperatura ?? 0,
            ProductosPedidosTable.columnTemperature:
                cleanDouble(producto.temperatura),
            ProductosPedidosTable.columnImage: producto.image ?? '',
            ProductosPedidosTable.columnImageNovedad:
                producto.imageNovedad ?? '',
            ProductosPedidosTable.columnTimeSeparate:
                producto.timeSeparate ?? 0,
          };

          if (existingProducto.isNotEmpty) {
            await txn.update(
              ProductosPedidosTable.tableName,
              dataMap,
              where:
                  '${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnBatchId} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ?',
              whereArgs: [
                producto.idProduct,
                producto.batchId,
                producto.pedidoId,
                producto.idMove
              ],
            );
          } else {
            await txn.insert(
              ProductosPedidosTable.tableName,
              dataMap,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
    } catch (e, s) {
      print("Error al insertar productos en productos_pedidos: $e ==> $s");
    }
  }

  Future<void> insertProductosOnPackage(
      List<ProductoPedido> productosList, String type) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      await db.transaction((txn) async {
        for (var producto in productosList) {
          final List<Map<String, dynamic>> existingProducto = await txn.query(
            ProductosPedidosTable.tableName,
            where:
                '${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnBatchId} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ?',
            whereArgs: [
              producto.idProduct,
              producto.batchId,
              producto.pedidoId,
              producto.idMove
            ],
          );

          if (existingProducto.isNotEmpty) {
            await txn.update(
              ProductosPedidosTable.tableName,
              {
                ProductosPedidosTable.columnProductId:
                    producto.productId[1] ?? '',
                ProductosPedidosTable.columnBatchId: producto.batchId,
                ProductosPedidosTable.columnPedidoId: producto.pedidoId,
                ProductosPedidosTable.columnIdMove: producto.idMove,
                ProductosPedidosTable.columnIdProduct: producto.idProduct,
                ProductosPedidosTable.columnLotId:
                    (producto.loteId != null && producto.loteId!.isNotEmpty)
                        ? producto.loteId![1]
                        : "",
                ProductosPedidosTable.columnQuantity: producto.quantity,
                ProductosPedidosTable.columnWeight:
                    producto.weight == false ? 0 : producto.weight.toDouble(),
                ProductosPedidosTable.columnUnidades: producto.unidades == false
                    ? ""
                    : producto.unidades.toString(),
                ProductosPedidosTable.columnIsCertificate:
                    producto.isCertificate,
                ProductosPedidosTable.columnIsPackage: 1,
                ProductosPedidosTable.columnIdPackage: producto.idPackage,
                ProductosPedidosTable.columnPackageName: producto.packageName,
                ProductosPedidosTable.columnObservation: producto.observation,
                ProductosPedidosTable.columnQuantitySeparate:
                    producto.quantitySeparate,
                ProductosPedidosTable.columnIsSeparate: 1,
                ProductosPedidosTable.columnTracking: producto.tracking == false
                    ? ""
                    : producto.tracking.toString(),
                ProductosPedidosTable.columnType: type,
                ProductosPedidosTable.columnImage: producto.image ?? '',
                ProductosPedidosTable.columnImageNovedad:
                    producto.imageNovedad ?? '',
                ProductosPedidosTable.columnManejoTemperature:
                    producto.manejaTemperatura ?? 0,
                ProductosPedidosTable.columnTemperature:
                    producto.temperatura ?? 0.0,
                ProductosPedidosTable.columnLocationId:
                    producto.locationId is List &&
                            producto.locationId.length > 1
                        ? producto.locationId[1]
                        : null,
                ProductosPedidosTable.columnIdLocation:
                    producto.locationId is List &&
                            producto.locationId.length > 1
                        ? producto.locationId[0]
                        : null,
                ProductosPedidosTable.columnLocationDestId:
                    producto.locationDestId is List &&
                            producto.locationDestId.length > 1
                        ? producto.locationDestId[1]
                        : null,
                ProductosPedidosTable.columnIdLocationDest:
                    producto.locationDestId is List &&
                            producto.locationDestId.length > 1
                        ? producto.locationDestId[0]
                        : null,
                ProductosPedidosTable.columnTimeSeparate:
                    producto.timeSeparate ?? 0,
              },
              where:
                  '${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnBatchId} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ?',
              whereArgs: [
                producto.idProduct,
                producto.batchId,
                producto.pedidoId,
                producto.idMove
              ],
            );
          } else {
            await txn.insert(
              ProductosPedidosTable.tableName,
              {
                ProductosPedidosTable.columnProductId:
                    producto.productId[1] ?? '',
                ProductosPedidosTable.columnBatchId: producto.batchId,
                ProductosPedidosTable.columnPedidoId: producto.pedidoId,
                ProductosPedidosTable.columnIdMove: producto.idMove,
                ProductosPedidosTable.columnIdProduct: producto.idProduct,
                ProductosPedidosTable.columnLotId:
                    (producto.loteId != null && producto.loteId!.isNotEmpty)
                        ? producto.loteId![1]
                        : "",
                ProductosPedidosTable.columnQuantity: producto.quantity,
                ProductosPedidosTable.columnWeight:
                    producto.weight == false ? 0 : producto.weight.toDouble(),
                ProductosPedidosTable.columnUnidades: producto.unidades == false
                    ? ""
                    : producto.unidades.toString(),
                ProductosPedidosTable.columnIsCertificate:
                    producto.isCertificate,
                ProductosPedidosTable.columnIsPackage: 1,
                ProductosPedidosTable.columnIdPackage: producto.idPackage,
                ProductosPedidosTable.columnPackageName: producto.packageName,
                ProductosPedidosTable.columnObservation: producto.observation,
                ProductosPedidosTable.columnQuantitySeparate:
                    producto.quantitySeparate,
                ProductosPedidosTable.columnIsSeparate: 1,
                ProductosPedidosTable.columnTracking: producto.tracking == false
                    ? ""
                    : producto.tracking.toString(),
                ProductosPedidosTable.columnType: type,
                ProductosPedidosTable.columnImage: producto.image ?? '',
                ProductosPedidosTable.columnImageNovedad:
                    producto.imageNovedad ?? '',
                ProductosPedidosTable.columnManejoTemperature:
                    producto.manejaTemperatura ?? 0,
                ProductosPedidosTable.columnTemperature:
                    producto.temperatura ?? 0.0,
                ProductosPedidosTable.columnLocationId:
                    producto.locationId is List &&
                            producto.locationId.length > 1
                        ? producto.locationId[1]
                        : null,
                ProductosPedidosTable.columnIdLocation:
                    producto.locationId is List &&
                            producto.locationId.length > 1
                        ? producto.locationId[0]
                        : null,
                ProductosPedidosTable.columnLocationDestId:
                    producto.locationDestId is List &&
                            producto.locationDestId.length > 1
                        ? producto.locationDestId[1]
                        : null,
                ProductosPedidosTable.columnIdLocationDest:
                    producto.locationDestId is List &&
                            producto.locationDestId.length > 1
                        ? producto.locationDestId[0]
                        : null,
                ProductosPedidosTable.columnTimeSeparate:
                    producto.timeSeparate ?? 0,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
    } catch (e, s) {
      print("Error al insertar productos de paquetes ya creado : $e ==> $s");
    }
  }

  // Obtener productos de un pedido
  Future<List<ProductoPedido>> getProductosPedido(int pedidoId) async {
    print('idPedido: $pedidoId');
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final List<Map<String, dynamic>> maps = await db.query(
      ProductosPedidosTable.tableName,
      where: '${ProductosPedidosTable.columnPedidoId} = ?',
      whereArgs: [pedidoId],
    );
    return maps.map((map) => ProductoPedido.fromMap(map)).toList();
  }

  Future<ProductoPedido> getProductoPedidoById(int pedidoId, int idMove) async {
    print('idPedido: $pedidoId   idMove: $idMove');
    final db = await DataBaseSqlite().getDatabaseInstance();

    final List<Map<String, dynamic>> maps = await db.query(
      ProductosPedidosTable.tableName,
      where:
          '${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ?',
      whereArgs: [pedidoId, idMove],
    );

    if (maps.isNotEmpty) {
      return ProductoPedido.fromMap(maps.first);
    } else {
      throw Exception(
          'ProductoPedido no encontrado con pedidoId: $pedidoId y idMove: $idMove');
    }
  }

  Future<List<ProductoPedido>> getAllProductosPedidos() async {
    try {
      final Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realiza una consulta a la tabla sin ninguna cláusula WHERE
      final List<Map<String, dynamic>> maps = await db.query(
        ProductosPedidosTable.tableName,
        // Opcional: puedes añadir un 'orderBy' si quieres una ordenación por defecto
        // Por ejemplo, por ID o nombre de producto
        // orderBy: '${ProductosPedidosTable.columnProductId} ASC',
      );

      // Mapea cada Map de la base de datos a un objeto ProductoPedido.
      // La robustez del mapeo recae en la implementación de ProductoPedido.fromMap.
      return maps.map((map) => ProductoPedido.fromMap(map)).toList();
    } catch (e, s) {
      print(
          "Error al obtener todos los productos de tbl_products_pedido: $e\n$s");
      // Retorna una lista vacía en caso de error para que la aplicación pueda continuar.
      return [];
    }
  }

  // Actualizar el campo de la tabla productos_pedidos (unpacking)
  Future<int?> setFieldTableProductosPedidosUnPacking(
      int pedidoId,
      int productId,
      String field,
      dynamic setValue,
      int idMove,
      int idPackage) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final resUpdate = await db.rawUpdate(
      'UPDATE ${ProductosPedidosTable.tableName} SET $field = ? WHERE ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ? AND ${ProductosPedidosTable.columnIdPackage} = ?',
      [setValue, productId, pedidoId, idMove, idPackage],
    );
    print("update unpacking tblproductos_pedidos: $resUpdate");
    return resUpdate;
  }

  // Actualizar la tabla de productos de un pedido (separados)
  Future<int?> setFieldTableProductosPedidos3(int pedidoId, int productId,
      String field, dynamic setValue, int idMove) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final resUpdate = await db.rawUpdate(
      'UPDATE ${ProductosPedidosTable.tableName} SET $field = ? WHERE ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ? AND ${ProductosPedidosTable.columnIsCertificate} IS NULL',
      [setValue, productId, pedidoId, idMove],
    );
    print("☢️3 update separated tblproductos_pedidos: ($field): $resUpdate");
    return resUpdate;
  }

  Future<String> getFieldTableProductsPedidos(
      int pedidoId, int productId, String field, int idMove) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final res = await db.rawQuery('''
      SELECT $field FROM  ${ProductosPedidosTable.tableName}  WHERE ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ? AND ${ProductosPedidosTable.columnIsCertificate} IS NULL
    ''');
      if (res.isNotEmpty) {
        String responsefield = res[0]['$field'].toString();
        return responsefield;
      }
      return "";
    } catch (e, s) {
      print("error getFieldTableProductsPick: $e => $s");
    }
    return "";
  }

  // Actualizar la tabla de productos de un pedido (con certificado y sin paquete)
  Future<int?> setFieldTableProductosPedidos2(int pedidoId, int productId,
      String field, dynamic setValue, int idMove) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final resUpdate = await db.rawUpdate(
      'UPDATE ${ProductosPedidosTable.tableName} SET $field = ? WHERE ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ? AND ${ProductosPedidosTable.columnIsCertificate} = 1 AND ${ProductosPedidosTable.columnIsPackage} = 0',
      [setValue, productId, pedidoId, idMove],
    );
    print(
        "☢️2 update tblproductos_pedidos (certificate and no package): ($field): $resUpdate");
    return resUpdate;
  }

  // Actualizar la tabla de productos de un pedido (con certificado y paquete)
  Future<int?> setFieldTableProductosPedidos2String(int pedidoId, int productId,
      String field, dynamic setValue, int idMove) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final resUpdate = await db.rawUpdate(
      "UPDATE ${ProductosPedidosTable.tableName} SET $field = '$setValue' WHERE ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ? AND ${ProductosPedidosTable.columnIsCertificate} = 1 AND ${ProductosPedidosTable.columnIsPackage} = 0",
      [productId, pedidoId, idMove],
    );
    print(
        "☢️2String update tblproductos_pedidos (certificate and no package) String: ($field): $resUpdate");
    return resUpdate;
  }

  // Actualizar la tabla de productos de un pedido (separados, sin certificado)
  Future<int?> setFieldTableProductosPedidos3String(int pedidoId, int productId,
      String field, dynamic setValue, int idMove) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final resUpdate = await db.rawUpdate(
      "UPDATE ${ProductosPedidosTable.tableName} SET $field = '$setValue' WHERE ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ? AND ${ProductosPedidosTable.columnIsCertificate} = 0 AND ${ProductosPedidosTable.columnIsPackage} = 1",
      [productId, pedidoId, idMove],
    );
    print(
        "☢️3String update separated tblproductos_pedidos ($field): $resUpdate");
    return resUpdate;
  }

  //*metodo para actualizar la tabla de productos de un pedido

  // Método: Actualizar un campo específico en la tabla productos_pedidos
  Future<int?> setFieldTableProductosPedidos(int pedidoId, int productId,
      String field, dynamic setValue, int idMove) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final resUpdate = await db.rawUpdate(
        'UPDATE ${ProductosPedidosTable.tableName} SET $field = ? WHERE ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ?',
        [setValue, productId, pedidoId, idMove]);

    print(
        "☢️ update tblproductos_pedidos (idProduct ----($productId)) -------($field): $resUpdate");

    return resUpdate;
  }

  // Incrementar cantidad de producto separado para empaque
  Future<int?> incremenQtytProductSeparatePacking(
      int pedidoId, int productId, int idMove, dynamic quantity) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    return await db.transaction((txn) async {
      final result = await txn.query(
        ProductosPedidosTable.tableName,
        columns: ['${ProductosPedidosTable.columnQuantitySeparate}'],
        where:
            '${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnIdMove} = ?',
        whereArgs: [pedidoId, productId, idMove],
      );

      if (result.isNotEmpty) {
        dynamic currentQty =
            (result.first[ProductosPedidosTable.columnQuantitySeparate]);

        dynamic newQty = currentQty + quantity;
        return await txn.update(
          ProductosPedidosTable.tableName,
          {ProductosPedidosTable.columnQuantitySeparate: newQty},
          where:
              '${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnIdMove} = ?',
          whereArgs: [pedidoId, productId, idMove],
        );
      }
      return null; // No encontrado
    });
  }

// Método: Actualizar la novedad (observación) en la tabla productos_pedidos
  Future<int?> updateNovedadPacking(
    int pedidoId,
    int productId,
    String novedad,
  ) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final resUpdate = await db.rawUpdate(
        "UPDATE ${ProductosPedidosTable.tableName} SET ${ProductosPedidosTable.columnObservation} = ? WHERE ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnPedidoId} = ?",
        [novedad, productId, pedidoId]);

    print("updateNovedad: $resUpdate");
    return resUpdate;
  }

  Future<int> updateProductosBatch({
    required List<ProductoPedido> productos,
    required Map<String, dynamic> fieldsToUpdate,
    required bool isCertificate,
  }) async {
    if (productos.isEmpty) return 0;

    final db = await DataBaseSqlite().getDatabaseInstance();
    int totalUpdated = 0;

    // Usamos una transacción para asegurar atomicidad
    await db.transaction((txn) async {
      // Preparamos la consulta base
      final setClauses =
          fieldsToUpdate.keys.map((key) => "$key = ?").join(', ');
      final setValues = fieldsToUpdate.values.toList();
      final condition = isCertificate
          ? "AND is_certificate = 1 AND is_package = 0"
          : "AND is_certificate IS NULL";

      // Actualizamos cada producto individualmente pero en una sola transacción
      for (final producto in productos) {
        if (producto.idProduct == null ||
            producto.pedidoId == null ||
            producto.idMove == null) {
          continue;
        }

        final sql = '''
        UPDATE ${ProductosPedidosTable.tableName}
        SET $setClauses
        WHERE ${ProductosPedidosTable.columnIdProduct} = ?
        AND ${ProductosPedidosTable.columnPedidoId} = ?
        AND ${ProductosPedidosTable.columnIdMove} = ?
        $condition
      ''';

        final result = await txn.rawUpdate(sql, [
          ...setValues,
          producto.idProduct,
          producto.pedidoId,
          producto.idMove
        ]);

        totalUpdated += result;
      }
    });

    return totalUpdated;
  }
}
