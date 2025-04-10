// productos_pedidos_repository.dart

// ignore_for_file: unnecessary_string_interpolations, unrelated_type_equality_checks

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_products_pedido/productos_pedido_pack_table.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/lista_product_packing.dart';

class ProductosPedidosRepository {
  // Insertar producto duplicado
  Future<void> insertDuplicateProductoPedido(
      PorductoPedido producto, int cantidad) async {
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
        ProductosPedidosTable.columnObservation: 'sin novedad',
        ProductosPedidosTable.columnIsSelected: 0,
        ProductosPedidosTable.columnIsProductSplit: 1,
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

  // Insertar productos en productos_pedidos
  Future<void> insertProductosPedidos(
      List<PorductoPedido> productosList) async {
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
                ProductosPedidosTable.columnBarcodeLocation:
                    producto.barcodeLocation == false
                        ? ""
                        : producto.barcodeLocation,
                ProductosPedidosTable.columnLoteId: producto.loteId,
                ProductosPedidosTable.columnLotId:
                    (producto.lotId != null && producto.lotId!.isNotEmpty)
                        ? producto.lotId![1]
                        : "",
                ProductosPedidosTable.columnLocationId: producto.locationId?[1],
                ProductosPedidosTable.columnIdLocation: producto.locationId?[0],
                ProductosPedidosTable.columnLocationDestId:
                    producto.locationDestId?[1],
                ProductosPedidosTable.columnIdLocationDest:
                    producto.idLocationDest?[0],
                ProductosPedidosTable.columnQuantity: producto.quantity,
                ProductosPedidosTable.columnExpireDate: producto.expireDate,
                ProductosPedidosTable.columnTracking: producto.tracking == false
                    ? ""
                    : producto.tracking.toString(),
                ProductosPedidosTable.columnBarcode: producto.barcode == false
                    ? ""
                    : (producto.barcode == "" ? "" : producto.barcode),
                ProductosPedidosTable.columnWeight:
                    producto.weight == false ? 0 : producto.weight.toDouble(),
                ProductosPedidosTable.columnUnidades: producto.unidades == false
                    ? ""
                    : producto.unidades.toString(),
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
                ProductosPedidosTable.columnBarcodeLocation:
                    producto.barcodeLocation == false
                        ? ""
                        : producto.barcodeLocation,
                ProductosPedidosTable.columnLoteId: producto.loteId,
                ProductosPedidosTable.columnLotId:
                    (producto.lotId != null && producto.lotId!.isNotEmpty)
                        ? producto.lotId![1]
                        : "",
                ProductosPedidosTable.columnLocationId: producto.locationId?[1],
                ProductosPedidosTable.columnIdLocation: producto.locationId?[0],
                ProductosPedidosTable.columnLocationDestId:
                    producto.locationDestId?[1],
                ProductosPedidosTable.columnIdLocationDest:
                    producto.idLocationDest?[0],
                ProductosPedidosTable.columnQuantity: producto.quantity,
                ProductosPedidosTable.columnExpireDate: producto.expireDate,
                ProductosPedidosTable.columnTracking: producto.tracking == false
                    ? ""
                    : producto.tracking.toString(),
                ProductosPedidosTable.columnBarcode: producto.barcode == false
                    ? ""
                    : (producto.barcode == "" ? "" : producto.barcode),
                ProductosPedidosTable.columnWeight:
                    producto.weight == false ? 0 : producto.weight.toDouble(),
                ProductosPedidosTable.columnUnidades: producto.unidades == false
                    ? ""
                    : producto.unidades.toString(),
              },
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
      List<PorductoPedido> productosList) async {
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
  Future<List<PorductoPedido>> getProductosPedido(int pedidoId) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final List<Map<String, dynamic>> maps = await db.query(
      ProductosPedidosTable.tableName,
      where: '${ProductosPedidosTable.columnPedidoId} = ?',
      whereArgs: [pedidoId],
    );

    return maps.map((map) => PorductoPedido.fromMap(map)).toList();
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
    print("update separated tblproductos_pedidos: $resUpdate");
    return resUpdate;
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
        "update tblproductos_pedidos (certificate and no package): $resUpdate");
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
        "update tblproductos_pedidos (certificate and no package) String: $resUpdate");
    return resUpdate;
  }

  // Actualizar la tabla de productos de un pedido (separados, con certificado)
  Future<int?> setFieldTableProductosPedidos3String(int pedidoId, int productId,
      String field, dynamic setValue, int idMove) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final resUpdate = await db.rawUpdate(
      "UPDATE ${ProductosPedidosTable.tableName} SET $field = '$setValue' WHERE ${ProductosPedidosTable.columnIdProduct} = ? AND ${ProductosPedidosTable.columnPedidoId} = ? AND ${ProductosPedidosTable.columnIdMove} = ? AND ${ProductosPedidosTable.columnIsCertificate} = 0 AND ${ProductosPedidosTable.columnIsPackage} = 1",
      [productId, pedidoId, idMove],
    );
    print("update separated tblproductos_pedidos ($field): $resUpdate");
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
        "update tblproductos_pedidos (idProduct ----($productId)) -------($field): $resUpdate");

    return resUpdate;
  }

  // Incrementar cantidad de producto separado para empaque
  Future<int?> incremenQtytProductSeparatePacking(
      int pedidoId, int productId, int idMove, int quantity) async {
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
        int currentQty =
            (result.first[ProductosPedidosTable.columnQuantitySeparate] as int);

        int newQty = currentQty + quantity;
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
}
