import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/transferencia/tbl_product_transferencia/product_transferencia_table.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';

class ProductTransferenciaRepository {
  //metodo para insertar todos los productos de una transferencia
  Future<void> insertarProductoEntrada(
      List<LineasTransferenciaTrans> products) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      // Comienza la transacción
      await db.transaction(
        (txn) async {
          Batch batch = txn.batch();
          // Primero, obtener todas las IDs de las novedades existentes

          final List<Map<String, dynamic>> existingProducts = await txn.query(
            ProductTransferenciaTable.tableName,
            columns: [ProductTransferenciaTable.columnId],
            where:
                '${ProductTransferenciaTable.columnId} =? AND ${ProductTransferenciaTable.columnIdMove} = ? AND ${ProductTransferenciaTable.columnIdTransferencia} = ? ',
            whereArgs: [
              products.map((product) => product.productId).toList().join(','),
              products.map((product) => product.idMove).toList().join(','),
              products
                  .map((product) => product.idTransferencia)
                  .toList()
                  .join(','),
            ],
          );

          // Crear un conjunto de los IDs existentes para facilitar la comprobación
          Set<int> existingIds = Set.from(existingProducts.map((e) {
            return e[ProductTransferenciaTable.columnId];
          }));

          // Recorrer todas las novedades y realizar insert o update según corresponda
          // ignore: non_constant_identifier_names
          for (var LineasTransferenciaTrans in products) {
            if (existingIds.contains(LineasTransferenciaTrans.productId)) {
              // Si la novedad ya existe, la actualizamos
              batch.update(
                ProductTransferenciaTable.tableName,
                {
                  ProductTransferenciaTable.columnId:
                      LineasTransferenciaTrans.id,
                  ProductTransferenciaTable.columnIdMove:
                      LineasTransferenciaTrans.idMove,
                  ProductTransferenciaTable.columnProductId:
                      LineasTransferenciaTrans.productId,
                  ProductTransferenciaTable.columnIdTransferencia:
                      LineasTransferenciaTrans.idTransferencia,
                  ProductTransferenciaTable.columnProductName:
                      LineasTransferenciaTrans.productName,
                  ProductTransferenciaTable.columnProductCode:
                      LineasTransferenciaTrans.productCode,
                  ProductTransferenciaTable.columnProductBarcode:
                      LineasTransferenciaTrans.productBarcode,
                  ProductTransferenciaTable.columnProductTracking:
                      LineasTransferenciaTrans.productTracking,
                  ProductTransferenciaTable.columnFechaVencimiento:
                      LineasTransferenciaTrans.fechaVencimiento,
                  ProductTransferenciaTable.columnDiasVencimiento:
                      LineasTransferenciaTrans.diasVencimiento,
                  ProductTransferenciaTable.columnQuantityOrdered:
                      LineasTransferenciaTrans.quantityOrdered,
                  ProductTransferenciaTable.columnQuantityDone:
                      LineasTransferenciaTrans.quantityDone,
                  ProductTransferenciaTable.columnUom:
                      LineasTransferenciaTrans.uom,
                  ProductTransferenciaTable.columnLocationDestId:
                      LineasTransferenciaTrans.locationDestId,
                  ProductTransferenciaTable.columnLocationDestName:
                      LineasTransferenciaTrans.locationDestName,
                  ProductTransferenciaTable.columnLocationDestBarcode:
                      LineasTransferenciaTrans.locationDestBarcode,
                  ProductTransferenciaTable.columnLocationId:
                      LineasTransferenciaTrans.locationId,
                  ProductTransferenciaTable.columnLocationBarcode:
                      LineasTransferenciaTrans.locationBarcode,
                  ProductTransferenciaTable.columnLocationName:
                      LineasTransferenciaTrans.locationName,
                  ProductTransferenciaTable.columnWeight:
                      LineasTransferenciaTrans.weight,
                  ProductTransferenciaTable.columnIsSeparate: 0,
                  ProductTransferenciaTable.columnIsSelected: 0,
                  ProductTransferenciaTable.columnLotName:
                      LineasTransferenciaTrans.lotName ?? "",
                  ProductTransferenciaTable.columnLoteDate:
                      (LineasTransferenciaTrans.lotName != "" ||
                              LineasTransferenciaTrans.lotName != null)
                          ? LineasTransferenciaTrans.fechaVencimiento
                          : "",
                  ProductTransferenciaTable.columnIsProductSplit: 0,
                  ProductTransferenciaTable.columnObservation: "",
                  ProductTransferenciaTable.columnDateStart: "",
                  ProductTransferenciaTable.columnDateEnd: "",
                  ProductTransferenciaTable.columnTimeTotalSeparate: "",
                },
                where:
                    '${ProductTransferenciaTable.columnId} = ? AND ${ProductTransferenciaTable.columnIdMove} = ? AND ${ProductTransferenciaTable.columnIdTransferencia} = ? ',
                whereArgs: [
                  LineasTransferenciaTrans.productId,
                  LineasTransferenciaTrans.idMove,
                  LineasTransferenciaTrans.idTransferencia
                ],
              );
            } else {
              batch.insert(
                ProductTransferenciaTable.tableName,
                {
                  ProductTransferenciaTable.columnId:
                      LineasTransferenciaTrans.id,
                  ProductTransferenciaTable.columnIdMove:
                      LineasTransferenciaTrans.idMove,
                  ProductTransferenciaTable.columnProductId:
                      LineasTransferenciaTrans.productId,
                  ProductTransferenciaTable.columnIdTransferencia:
                      LineasTransferenciaTrans.idTransferencia,
                  ProductTransferenciaTable.columnProductName:
                      LineasTransferenciaTrans.productName,
                  ProductTransferenciaTable.columnProductCode:
                      LineasTransferenciaTrans.productCode,
                  ProductTransferenciaTable.columnProductBarcode:
                      LineasTransferenciaTrans.productBarcode,
                  ProductTransferenciaTable.columnProductTracking:
                      LineasTransferenciaTrans.productTracking,
                  ProductTransferenciaTable.columnFechaVencimiento:
                      LineasTransferenciaTrans.fechaVencimiento,
                  ProductTransferenciaTable.columnDiasVencimiento:
                      LineasTransferenciaTrans.diasVencimiento,
                  ProductTransferenciaTable.columnQuantityOrdered:
                      LineasTransferenciaTrans.quantityOrdered,
                  ProductTransferenciaTable.columnQuantityDone:
                      LineasTransferenciaTrans.quantityDone,
                  ProductTransferenciaTable.columnUom:
                      LineasTransferenciaTrans.uom,
                  ProductTransferenciaTable.columnLocationDestId:
                      LineasTransferenciaTrans.locationDestId,
                  ProductTransferenciaTable.columnLocationDestName:
                      LineasTransferenciaTrans.locationDestName,
                  ProductTransferenciaTable.columnLocationDestBarcode:
                      LineasTransferenciaTrans.locationDestBarcode,
                  ProductTransferenciaTable.columnLocationId:
                      LineasTransferenciaTrans.locationId,
                  ProductTransferenciaTable.columnLocationBarcode:
                      LineasTransferenciaTrans.locationBarcode,
                  ProductTransferenciaTable.columnLocationName:
                      LineasTransferenciaTrans.locationName,
                  ProductTransferenciaTable.columnWeight:
                      LineasTransferenciaTrans.weight,
                  ProductTransferenciaTable.columnIsSeparate: 0,
                  ProductTransferenciaTable.columnIsSelected: 0,
                  ProductTransferenciaTable.columnLotName:
                      LineasTransferenciaTrans.lotName ?? "",
                  ProductTransferenciaTable.columnLoteDate:
                      (LineasTransferenciaTrans.lotName != "" ||
                              LineasTransferenciaTrans.lotName != null)
                          ? LineasTransferenciaTrans.fechaVencimiento
                          : "",
                  ProductTransferenciaTable.columnIsProductSplit: 0,
                  ProductTransferenciaTable.columnObservation: "",
                  ProductTransferenciaTable.columnDateStart: "",
                  ProductTransferenciaTable.columnDateEnd: "",
                  ProductTransferenciaTable.columnTimeTotalSeparate: "",
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

//*Método para obtener todos los productos de una entrada por idRecepcion
  Future<List<LineasTransferenciaTrans>> getProductsByTrasnferId(
      int idTransfer) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      // Consulta para obtener los productos con el idRecepcion correspondiente
      final List<Map<String, dynamic>> products = await db.query(
        ProductTransferenciaTable.tableName,
        where: '${ProductTransferenciaTable.columnIdTransferencia} = ?',
        whereArgs: [idTransfer],
      );
      // Convertir los resultados de la consulta en objetos de tipo LineasRecepcion
      return products
          .map((product) => LineasTransferenciaTrans.fromMap(product))
          .toList();
    } catch (e, s) {
      print('Error en getProductsByTrasnferId: $e, $s');
      return [];
    }
  }

  //*metodo para actualizar la tabla

  // Método: Actualizar un campo específico en la tabla productos_pedidos
  Future<int?> setFieldTableProductTransfer(int idEntrada, int productId,
      String field, dynamic setValue, int idMove) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();

    final resUpdate = await db.rawUpdate(
        'UPDATE ${ProductTransferenciaTable.tableName} SET $field = ? WHERE ${ProductTransferenciaTable.columnProductId} = ? AND ${ProductTransferenciaTable.columnIdMove} = ? AND ${ProductTransferenciaTable.columnIdTransferencia} = ?',
        [setValue, productId, idMove, idEntrada]);

    print(
        "update TableProductTransfer (idProduct ----($productId)) -------($field): $resUpdate");

    return resUpdate;
  }

  // Incrementar cantidad de producto separado para empaque
  Future<int?> incremenQtytProductSeparate(
      int idTransfer, int productId, int idMove, int quantity) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    return await db.transaction((txn) async {
      final result = await txn.query(
        ProductTransferenciaTable.tableName,
        columns: [(ProductTransferenciaTable.columnQuantitySeparate)],
        where:
            '${ProductTransferenciaTable.columnIdTransferencia} = ? AND ${ProductTransferenciaTable.columnProductId} = ? AND ${ProductTransferenciaTable.columnIdMove} = ?',
        whereArgs: [idTransfer, productId, idMove],
      );

      if (result.isNotEmpty) {
        int currentQty =
            (result.first[ProductTransferenciaTable.columnQuantitySeparate] as int);

        int newQty = currentQty + quantity;
        return await txn.update(
          ProductTransferenciaTable.tableName,
          {ProductTransferenciaTable.columnQuantitySeparate: newQty},
          where:
              '${ProductTransferenciaTable.columnIdTransferencia} = ? AND ${ProductTransferenciaTable.columnProductId} = ? AND ${ProductTransferenciaTable.columnIdMove} = ?',
          whereArgs: [idTransfer, productId, idMove],
        );
      }
      return null; // No encontrado
    });
  }
}
