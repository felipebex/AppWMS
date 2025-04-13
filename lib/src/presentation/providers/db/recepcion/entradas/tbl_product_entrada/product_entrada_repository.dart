import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_product_entrada/product_entrada_table.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_model.dart';

class ProductsEntradaRepository {
  //metodo para insertar todas las entradas
  Future<void> insertarProductoEntrada(
      List<LineasTransferencia> products) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      // Comienza la transacción
      await db.transaction(
        (txn) async {
          Batch batch = txn.batch();
          // Primero, obtener todas las IDs de las novedades existentes

          final List<Map<String, dynamic>> existingProducts = await txn.query(
            ProductRecepcionTable.tableName,
            columns: [ProductRecepcionTable.columnId],
            where:
                '${ProductRecepcionTable.columnId} =? AND ${ProductRecepcionTable.columnIdMove} = ? AND ${ProductRecepcionTable.columnIdRecepcion} = ? ',
            whereArgs: [
              products.map((product) => product.productId).toList().join(','),
              products.map((product) => product.idMove).toList().join(','),
              products.map((product) => product.idRecepcion).toList().join(','),
            ],
          );

          // Crear un conjunto de los IDs existentes para facilitar la comprobación
          Set<int> existingIds = Set.from(existingProducts.map((e) {
            return e[ProductRecepcionTable.columnId];
          }));

          // Recorrer todas las novedades y realizar insert o update según corresponda
          // ignore: non_constant_identifier_names
          for (var LineasRecepcion in products) {
            if (existingIds.contains(LineasRecepcion.productId)) {
              // Si la novedad ya existe, la actualizamos
              batch.update(
                ProductRecepcionTable.tableName,
                {
                  ProductRecepcionTable.columnId: LineasRecepcion.id ?? 0,
                  ProductRecepcionTable.columnIdMove:
                      LineasRecepcion.idMove ?? 0,
                  ProductRecepcionTable.columnProductId:
                      LineasRecepcion.productId ?? 0,
                  ProductRecepcionTable.columnIdRecepcion:
                      LineasRecepcion.idRecepcion ?? 0,
                  ProductRecepcionTable.columnProductName:
                      LineasRecepcion.productName ?? '',
                  ProductRecepcionTable.columnProductCode:
                      LineasRecepcion.productCode ?? '',
                  ProductRecepcionTable.columnProductBarcode:
                      LineasRecepcion.productBarcode ?? '',
                  ProductRecepcionTable.columnProductTracking:
                      LineasRecepcion.productTracking ?? '',
                  ProductRecepcionTable.columnFechaVencimiento:
                      LineasRecepcion.fechaVencimiento ?? "",
                  ProductRecepcionTable.columnDiasVencimiento:
                      LineasRecepcion.diasVencimiento ?? '',
                  ProductRecepcionTable.columnQuantityOrdered:
                      LineasRecepcion.quantityOrdered ?? 0,
                  ProductRecepcionTable.columnQuantityToReceive:
                      LineasRecepcion.quantityToReceive ?? 0,
                  ProductRecepcionTable.columnQuantityDone:
                      LineasRecepcion.quantityDone ?? 0,
                  ProductRecepcionTable.columnUom: LineasRecepcion.uom ?? "",
                  ProductRecepcionTable.columnLocationDestId:
                      LineasRecepcion.locationDestId ?? 0,
                  ProductRecepcionTable.columnLocationDestName:
                      LineasRecepcion.locationDestName ?? '',
                  ProductRecepcionTable.columnLocationDestBarcode:
                      LineasRecepcion.locationDestBarcode ?? '',
                  ProductRecepcionTable.columnLocationId:
                      LineasRecepcion.locationId ?? 0,
                  ProductRecepcionTable.columnLocationBarcode:
                      LineasRecepcion.locationBarcode ?? '',
                  ProductRecepcionTable.columnLocationName:
                      LineasRecepcion.locationName ?? '',
                  ProductRecepcionTable.columnWeight:
                      LineasRecepcion.weight ?? 0,
                  ProductRecepcionTable.columnIsSeparate: 0,
                  ProductRecepcionTable.columnIsSelected: 0,
                  ProductRecepcionTable.columnLotName:
                      LineasRecepcion.lotName ?? "",
                  ProductRecepcionTable.columnLoteDate:
                      (LineasRecepcion.lotName != "" ||
                              LineasRecepcion.lotName != null)
                          ? LineasRecepcion.fechaVencimiento
                          : "",
                  ProductRecepcionTable.columnIsProductSplit: 0,
                  ProductRecepcionTable.columnObservation: "",
                  ProductRecepcionTable.columnDateStart: "",
                  ProductRecepcionTable.columnDateEnd: "",
                  ProductRecepcionTable.columnTime: LineasRecepcion.time,
                  ProductRecepcionTable.columnIsDoneItem:
                      LineasRecepcion.isDoneItem ?? 0,
                  ProductRecepcionTable.columnDateTransaction:
                      LineasRecepcion.dateTransaction ?? '',
                  ProductRecepcionTable.columnCantidadFaltante:
                      LineasRecepcion.cantidadFaltante ?? 0,
                },
                where:
                    '${ProductRecepcionTable.columnId} = ? AND ${ProductRecepcionTable.columnIdMove} = ? AND ${ProductRecepcionTable.columnIdRecepcion} = ? ',
                whereArgs: [
                  LineasRecepcion.productId,
                  LineasRecepcion.idMove,
                  LineasRecepcion.idRecepcion
                ],
              );
            } else {
              batch.insert(
                ProductRecepcionTable.tableName,
                {
                  ProductRecepcionTable.columnId: LineasRecepcion.id ?? 0,
                  ProductRecepcionTable.columnIdMove:
                      LineasRecepcion.idMove ?? 0,
                  ProductRecepcionTable.columnProductId:
                      LineasRecepcion.productId ?? 0,
                  ProductRecepcionTable.columnIdRecepcion:
                      LineasRecepcion.idRecepcion ?? 0,
                  ProductRecepcionTable.columnProductName:
                      LineasRecepcion.productName ?? '',
                  ProductRecepcionTable.columnProductCode:
                      LineasRecepcion.productCode ?? "",
                  ProductRecepcionTable.columnProductBarcode:
                      LineasRecepcion.productBarcode ?? '',
                  ProductRecepcionTable.columnProductTracking:
                      LineasRecepcion.productTracking ?? '',
                  ProductRecepcionTable.columnFechaVencimiento:
                      LineasRecepcion.fechaVencimiento ?? "",
                  ProductRecepcionTable.columnDiasVencimiento:
                      LineasRecepcion.diasVencimiento ?? '',
                  ProductRecepcionTable.columnQuantityOrdered:
                      LineasRecepcion.quantityOrdered ?? 0,
                  ProductRecepcionTable.columnQuantityToReceive:
                      LineasRecepcion.quantityToReceive ?? 0,
                  ProductRecepcionTable.columnQuantityDone:
                      LineasRecepcion.quantityDone ?? 0,
                  ProductRecepcionTable.columnUom: LineasRecepcion.uom ?? "",
                  ProductRecepcionTable.columnLocationDestId:
                      LineasRecepcion.locationDestId ?? 0,
                  ProductRecepcionTable.columnLocationDestName:
                      LineasRecepcion.locationDestName ?? '',
                  ProductRecepcionTable.columnLocationDestBarcode:
                      LineasRecepcion.locationDestBarcode ?? '',
                  ProductRecepcionTable.columnLocationId:
                      LineasRecepcion.locationId ?? 0,
                  ProductRecepcionTable.columnLocationBarcode:
                      LineasRecepcion.locationBarcode ?? '',
                  ProductRecepcionTable.columnLocationName:
                      LineasRecepcion.locationName ?? '',
                  ProductRecepcionTable.columnWeight:
                      LineasRecepcion.weight ?? 0,
                  ProductRecepcionTable.columnIsSeparate: 0,
                  ProductRecepcionTable.columnIsSelected: 0,
                  ProductRecepcionTable.columnLotName:
                      LineasRecepcion.lotName ?? "",
                  ProductRecepcionTable.columnLoteDate:
                      (LineasRecepcion.lotName != "" ||
                              LineasRecepcion.lotName != null)
                          ? LineasRecepcion.fechaVencimiento
                          : "",
                  ProductRecepcionTable.columnIsProductSplit: 0,
                  ProductRecepcionTable.columnObservation: "",
                  ProductRecepcionTable.columnDateStart: "",
                  ProductRecepcionTable.columnDateEnd: "",
                  ProductRecepcionTable.columnTime: LineasRecepcion.time,
                  ProductRecepcionTable.columnIsDoneItem:
                      LineasRecepcion.isDoneItem ?? 0,
                  ProductRecepcionTable.columnDateTransaction:
                      LineasRecepcion.dateTransaction ?? '',
                  ProductRecepcionTable.columnCantidadFaltante:
                      LineasRecepcion.cantidadFaltante ?? 0,
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

  Future<void> insertDuplicateProducto(
      LineasTransferencia producto, int cantidad) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      Map<String, dynamic> productCopy = {
        ProductRecepcionTable.columnIdMove: producto.idMove ?? 0,
        ProductRecepcionTable.columnProductId: producto.productId ?? 0,
        ProductRecepcionTable.columnIdRecepcion: producto.idRecepcion ?? 0,
        ProductRecepcionTable.columnProductName: producto.productName ?? '',
        ProductRecepcionTable.columnProductCode: producto.productCode ?? "",
        ProductRecepcionTable.columnProductBarcode:
            producto.productBarcode ?? '',
        ProductRecepcionTable.columnProductTracking:
            producto.productTracking ?? '',
        ProductRecepcionTable.columnFechaVencimiento:
            producto.fechaVencimiento ?? '',
        ProductRecepcionTable.columnDiasVencimiento:
            producto.diasVencimiento ?? 0,
        ProductRecepcionTable.columnQuantityOrdered: cantidad,
        ProductRecepcionTable.columnQuantityToReceive:
            producto.quantityToReceive ?? 0,
        ProductRecepcionTable.columnQuantityDone: producto.quantityDone ?? 0,
        ProductRecepcionTable.columnUom: producto.uom ?? '',
        ProductRecepcionTable.columnLocationDestId:
            producto.locationDestId ?? 0,
        ProductRecepcionTable.columnLocationDestName:
            producto.locationDestName ?? '',
        ProductRecepcionTable.columnLocationDestBarcode:
            producto.locationDestBarcode ?? "",
        ProductRecepcionTable.columnLocationId: producto.locationId ?? 0,
        ProductRecepcionTable.columnLocationBarcode:
            producto.locationBarcode ?? '',
        ProductRecepcionTable.columnLocationName: producto.locationName ?? '',
        ProductRecepcionTable.columnWeight: producto.weight ?? 0,
        ProductRecepcionTable.columnIsSeparate: 0,
        ProductRecepcionTable.columnIsProductSplit: 1,
        ProductRecepcionTable.columnIsSelected: 0,
        ProductRecepcionTable.columnObservation: producto.observation ?? '',
        ProductRecepcionTable.columnQuantitySeparate: 0,
        ProductRecepcionTable.columnLoteId: 0,
        ProductRecepcionTable.columnLotName: "",
        ProductRecepcionTable.columnLoteDate: "",
        ProductRecepcionTable.columnIsQuantityIsOk: 0,
        ProductRecepcionTable.columnProductIsOk: 0,
        ProductRecepcionTable.columnLocationDestIsOk: 0,
        ProductRecepcionTable.columnDateStart: "",
        ProductRecepcionTable.columnDateEnd: "",
        ProductRecepcionTable.columnTime: "",
        ProductRecepcionTable.columnIsDoneItem: 0,
        ProductRecepcionTable.columnDateTransaction: "",
        ProductRecepcionTable.columnCantidadFaltante: cantidad,
      };

      await db.insert(
        ProductRecepcionTable.tableName,
        productCopy,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Producto duplicado insertado con éxito.");
    } catch (e, s) {
      print("Error al insertar producto duplicado: $e ==> $s");
    }
  }

  //metodo para obtener todos los productos de la entrada
  Future<List<LineasTransferencia>> getAllProductsEntrada() async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> products = await db.query(
        ProductRecepcionTable.tableName,
      );
      return products
          .map((product) => LineasTransferencia.fromMap(product))
          .toList();
    } catch (e, s) {
      print('Error en getAllProductsEntrada: $e, $s');
      return [];
    }
  }

//*Método para obtener todos los productos de una entrada por idRecepcion
  Future<List<LineasTransferencia>> getProductsByRecepcionId(
      int idRecepcion) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      // Consulta para obtener los productos con el idRecepcion correspondiente
      final List<Map<String, dynamic>> products = await db.query(
        ProductRecepcionTable.tableName,
        where: '${ProductRecepcionTable.columnIdRecepcion} = ?',
        whereArgs: [idRecepcion],
      );
      // Convertir los resultados de la consulta en objetos de tipo LineasRecepcion
      return products
          .map((product) => LineasTransferencia.fromMap(product))
          .toList();
    } catch (e, s) {
      print('Error en getProductsByRecepcionId: $e, $s');
      return [];
    }
  }

  //*metodo para actualizar la tabla

  // Método: Actualizar un campo específico en la tabla productos_pedidos
  Future<int?> setFieldTableProductEntrada(int idEntrada, int productId,
      String field, dynamic setValue, int idMove) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();

    final resUpdate = await db.rawUpdate(
        'UPDATE ${ProductRecepcionTable.tableName} SET $field = ? WHERE ${ProductRecepcionTable.columnProductId} = ? AND ${ProductRecepcionTable.columnIdMove} = ? AND ${ProductRecepcionTable.columnIdRecepcion} = ? AND ${ProductRecepcionTable.columnIsDoneItem} = 0',
        [setValue, productId, idMove, idEntrada]);

    print(
        "update TableProductEntrada (idProduct ----($productId)) -------($field): $resUpdate");

    return resUpdate;
  }

  //METODO PARA OBTENER UN PRODUCTO POR SU ID
  Future<LineasTransferencia?> getProductById(
      int idProduct, int idMove, int idRecepcion) async {
    try {
      print(
          'idProduct: $idProduct, idMove: $idMove, idRecepcion: $idRecepcion');
      // Obtener la instancia de la base de datos
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Convertir idProduct a String (porque en la tabla está como TEXT)
      final List<Map<String, dynamic>> product = await db.query(
        ProductRecepcionTable.tableName,
        where:
            '${ProductRecepcionTable.columnProductId} = ? AND ${ProductRecepcionTable.columnIdMove} = ? AND ${ProductRecepcionTable.columnIdRecepcion} = ?',
        whereArgs: [
          idProduct.toString(), // Convertir idProduct a String
          idMove,
          idRecepcion
        ],
      );

      // Si hay datos, crear un objeto de LineasRecepcion, si no, retornar null
      return product.isNotEmpty
          ? LineasTransferencia.fromMap(product.first)
          : null;
    } catch (e, s) {
      // Imprimir detalles del error para facilitar la depuración
      print('Error en getProductById: $e, StackTrace: $s');
      return null;
    }
  }

  // Incrementar cantidad de producto separado para empaque
  Future<int?> incremenQtytProductSeparatePacking(
      int idRecepcion, int productId, int idMove, int quantity) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    return await db.transaction((txn) async {
      final result = await txn.query(
        ProductRecepcionTable.tableName,
        columns: [(ProductRecepcionTable.columnQuantitySeparate)],
        where:
            '${ProductRecepcionTable.columnIdRecepcion} = ? AND ${ProductRecepcionTable.columnProductId} = ? AND ${ProductRecepcionTable.columnIdMove} = ?',
        whereArgs: [idRecepcion, productId, idMove],
      );

      if (result.isNotEmpty) {
        int currentQty =
            (result.first[ProductRecepcionTable.columnQuantitySeparate] as int);

        int newQty = currentQty + quantity;
        return await txn.update(
          ProductRecepcionTable.tableName,
          {ProductRecepcionTable.columnQuantitySeparate: newQty},
          where:
              '${ProductRecepcionTable.columnIdRecepcion} = ? AND ${ProductRecepcionTable.columnProductId} = ? AND ${ProductRecepcionTable.columnIdMove} = ?',
          whereArgs: [idRecepcion, productId, idMove],
        );
      }
      return null; // No encontrado
    });
  }

  // Método: Actualizar la novedad (observación) en la tabla
  Future<int?> updateNovedadOrder(
    int idRecepcion,
    int productId,
    int idMove,
    String novedad,
  ) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();
    final resUpdate = await db.rawUpdate(
        "UPDATE ${ProductRecepcionTable.tableName} SET ${ProductRecepcionTable.columnObservation} = ? WHERE ${ProductRecepcionTable.columnProductId} = ? AND ${ProductRecepcionTable.columnIdRecepcion} = ? AND ${ProductRecepcionTable.columnIdMove} = ?",
        [novedad, productId, idRecepcion, idMove]);

    print("updateNovedad: $resUpdate");
    return resUpdate;
  }
}
