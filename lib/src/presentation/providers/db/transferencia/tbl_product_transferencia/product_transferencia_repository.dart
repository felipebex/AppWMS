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
                  ProductTransferenciaTable.columnQuantitySeparate: 0,
                  ProductTransferenciaTable.columnLotName:
                      LineasTransferenciaTrans.lotName ?? "",
                  ProductTransferenciaTable.columnLoteId:
                      LineasTransferenciaTrans.lotId ?? "",
                  ProductTransferenciaTable.columnLoteDate:
                      (LineasTransferenciaTrans.lotName != "" ||
                              LineasTransferenciaTrans.lotName != null)
                          ? LineasTransferenciaTrans.fechaVencimiento
                          : "",
                  ProductTransferenciaTable.columnIsProductSplit: 0,
                  ProductTransferenciaTable.columnObservation:
                      LineasTransferenciaTrans.observation,
                  ProductTransferenciaTable.columnDateStart: "",
                  ProductTransferenciaTable.columnDateEnd: "",
                  ProductTransferenciaTable.columnTime:
                      LineasTransferenciaTrans.time,
                  ProductTransferenciaTable.columnIsDoneItem:
                      LineasTransferenciaTrans.isDoneItem ?? 0,
                  ProductTransferenciaTable.columnCantidadFaltante:
                      LineasTransferenciaTrans.cantidadFaltante ?? 0
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
                  ProductTransferenciaTable.columnQuantitySeparate: 0,
                  ProductTransferenciaTable.columnLotName:
                      LineasTransferenciaTrans.lotName ?? "",
                  ProductTransferenciaTable.columnLoteId:
                      LineasTransferenciaTrans.lotId ?? "",
                  ProductTransferenciaTable.columnLoteDate:
                      (LineasTransferenciaTrans.lotName != "" ||
                              LineasTransferenciaTrans.lotName != null)
                          ? LineasTransferenciaTrans.fechaVencimiento
                          : "",
                  ProductTransferenciaTable.columnIsProductSplit: 0,
                  ProductTransferenciaTable.columnObservation:
                      LineasTransferenciaTrans.observation,
                  ProductTransferenciaTable.columnDateStart: "",
                  ProductTransferenciaTable.columnDateEnd: "",
                  ProductTransferenciaTable.columnTime:
                      LineasTransferenciaTrans.time,
                  ProductTransferenciaTable.columnIsDoneItem:
                      LineasTransferenciaTrans.isDoneItem ?? 0,
                  ProductTransferenciaTable.columnCantidadFaltante:
                      LineasTransferenciaTrans.cantidadFaltante ?? 0
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

  //METODO PARA OBTENER UN PRODUCTO POR SU ID
  Future<LineasTransferenciaTrans?> getProductById(
      int idProduct, int idMove, int idTransferencia) async {
    try {
      print(
          'idProduct: $idProduct, idMove: $idMove, idTransferencia: $idTransferencia');
      // Obtener la instancia de la base de datos
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Convertir idProduct a String (porque en la tabla está como TEXT)
      final List<Map<String, dynamic>> product = await db.query(
        ProductTransferenciaTable.tableName,
        where:
            '${ProductTransferenciaTable.columnProductId} = ? AND ${ProductTransferenciaTable.columnIdMove} = ? AND ${ProductTransferenciaTable.columnIdTransferencia} = ?',
        whereArgs: [
          idProduct.toString(), // Convertir idProduct a String
          idMove,
          idTransferencia
        ],
      );

      // Si hay datos, crear un objeto de LineasRecepcion, si no, retornar null
      return product.isNotEmpty
          ? LineasTransferenciaTrans.fromMap(product.first)
          : null;
    } catch (e, s) {
      // Imprimir detalles del error para facilitar la depuración
      print('Error en getProductById: $e, StackTrace: $s');
      return null;
    }
  }

  Future<void> insertDuplicateProducto(
      LineasTransferenciaTrans producto, int cantidad) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      Map<String, dynamic> productCopy = {
        ProductTransferenciaTable.columnIdMove: producto.idMove,
        ProductTransferenciaTable.columnProductId: producto.productId,
        ProductTransferenciaTable.columnIdTransferencia:
            producto.idTransferencia,
        ProductTransferenciaTable.columnProductName: producto.productName,
        ProductTransferenciaTable.columnProductCode: producto.productCode,
        ProductTransferenciaTable.columnProductBarcode: producto.productBarcode,
        ProductTransferenciaTable.columnProductTracking:
            producto.productTracking,
        ProductTransferenciaTable.columnFechaVencimiento:
            producto.fechaVencimiento,
        ProductTransferenciaTable.columnDiasVencimiento:
            producto.diasVencimiento,
        ProductTransferenciaTable.columnQuantityOrdered: producto.quantityOrdered,

        ProductTransferenciaTable.columnQuantityDone: producto.quantityDone,
        ProductTransferenciaTable.columnUom: producto.uom,

        ProductTransferenciaTable.columnLocationDestId: producto.locationDestId,
        ProductTransferenciaTable.columnLocationDestName:
            producto.locationDestName,
        ProductTransferenciaTable.columnLocationDestBarcode:
            producto.locationDestBarcode,
        ProductTransferenciaTable.columnLocationId: producto.locationId,
        ProductTransferenciaTable.columnLocationBarcode:
            producto.locationBarcode,
        ProductTransferenciaTable.columnLocationName: producto.locationName,
        ProductTransferenciaTable.columnWeight: producto.weight,
        //parametros para ver que es diferente
        ProductTransferenciaTable.columnIsSeparate: 0,
        ProductTransferenciaTable.columnIsProductSplit: 1,

        ProductTransferenciaTable.columnIsSelected: 0,
        ProductTransferenciaTable.columnObservation: producto.observation,

        ProductTransferenciaTable.columnQuantitySeparate: 0,
        ProductTransferenciaTable.columnLoteId: 0,
        ProductTransferenciaTable.columnLotName: "",
        ProductTransferenciaTable.columnLoteDate: "",

        ProductTransferenciaTable.columnIsQuantityIsOk: 0,
        ProductTransferenciaTable.columnProductIsOk: 0,
        ProductTransferenciaTable.columnDateStart: "",
        ProductTransferenciaTable.columnDateEnd: "",
        ProductTransferenciaTable.columnTime: "",
        ProductTransferenciaTable.columnIsDoneItem: 0,
        ProductTransferenciaTable.columnDateTransaction: "",
        ProductTransferenciaTable.columnCantidadFaltante: cantidad
      };

      await db.insert(
        ProductTransferenciaTable.tableName,
        productCopy,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Producto duplicado insertado con éxito.");
    } catch (e, s) {
      print("Error al insertar producto duplicado: $e ==> $s");
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
    print(
        "datos de transfer: idTransfer: $idEntrada, productId: $productId, field: $field, setValue: $setValue, idMove: $idMove");

    Database db = await DataBaseSqlite().getDatabaseInstance();

    // Realizar la actualización solo si is_done_item = 0
    final resUpdate = await db.rawUpdate(
      'UPDATE ${ProductTransferenciaTable.tableName} SET $field = ? '
      'WHERE ${ProductTransferenciaTable.columnProductId} = ? '
      'AND ${ProductTransferenciaTable.columnIdMove} = ? '
      'AND ${ProductTransferenciaTable.columnIdTransferencia} = ? '
      'AND ${ProductTransferenciaTable.columnIsDoneItem} = 0',
      [setValue, productId, idMove, idEntrada],
    );

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
        int currentQty = (result
            .first[ProductTransferenciaTable.columnQuantitySeparate] as int);

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

  // Método: Actualizar la novedad (observación) en la tabla
  Future<int?> updateNovedadTransfer(
    int idRecepcion,
    int productId,
    int idMove,
    String novedad,
  ) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final resUpdate = await db.rawUpdate(
        "UPDATE ${ProductTransferenciaTable.tableName} SET ${ProductTransferenciaTable.columnObservation} = ? WHERE ${ProductTransferenciaTable.columnProductId} = ? AND ${ProductTransferenciaTable.columnIdTransferencia} = ? AND ${ProductTransferenciaTable.columnIdMove} = ?",
        [novedad, productId, idRecepcion, idMove]);

    print("updateNovedad: $resUpdate");
    return resUpdate;
  }
}
