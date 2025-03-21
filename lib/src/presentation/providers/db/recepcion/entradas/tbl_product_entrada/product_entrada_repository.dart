import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_product_entrada/product_entrada_table.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_model.dart';

class ProductsEntradaRepository {
  //metodo para insertar todas las entradas
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
          // ignore: non_constant_identifier_names
          for (var LineasRecepcion in products) {
            if (existingIds.contains(LineasRecepcion.productId)) {
              // Si la novedad ya existe, la actualizamos
              batch.update(
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
                  ProductEntradaTable.columnLocationDestBarcode:
                      LineasRecepcion.locationDestBarcode,
                  ProductEntradaTable.columnLocationId:
                      LineasRecepcion.locationId,
                  ProductEntradaTable.columnLocationBarcode:
                      LineasRecepcion.locationBarcode,
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
                  ProductEntradaTable.columnLocationDestBarcode:
                      LineasRecepcion.locationDestBarcode,
                  ProductEntradaTable.columnLocationId:
                      LineasRecepcion.locationId,
                  ProductEntradaTable.columnLocationBarcode:
                      LineasRecepcion.locationBarcode,
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

  Future<void> insertDuplicateProducto(
      LineasRecepcion producto, int cantidad) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      Map<String, dynamic> productCopy = {
        ProductEntradaTable.columnIdMove: producto.idMove,
        ProductEntradaTable.columnProductId: producto.productId,
        ProductEntradaTable.columnIdRecepcion: producto.idRecepcion,
        ProductEntradaTable.columnProductName: producto.productName,
        ProductEntradaTable.columnProductCode: producto.productCode,
        ProductEntradaTable.columnProductBarcode: producto.productBarcode,
        ProductEntradaTable.columnProductTracking: producto.productTracking,
        ProductEntradaTable.columnFechaVencimiento: producto.fechaVencimiento,
        ProductEntradaTable.columnDiasVencimiento: producto.diasVencimiento,
        ProductEntradaTable.columnQuantityOrdered: cantidad,
        ProductEntradaTable.columnQuantityToReceive: producto.quantityToReceive,
        ProductEntradaTable.columnQuantityDone: producto.quantityDone,
        ProductEntradaTable.columnUom: producto.uom,

        ProductEntradaTable.columnLocationDestId: producto.locationDestId,
        ProductEntradaTable.columnLocationDestName: producto.locationDestName,
        ProductEntradaTable.columnLocationDestBarcode:
            producto.locationDestBarcode,
        ProductEntradaTable.columnLocationId: producto.locationId,
        ProductEntradaTable.columnLocationBarcode: producto.locationBarcode,
        ProductEntradaTable.columnLocationName: producto.locationName,
        ProductEntradaTable.columnWeight: producto.weight,
        //parametros para ver que es diferente
        ProductEntradaTable.columnIsSeparate: 0,
        ProductEntradaTable.columnIsProductSplit: 1,
        ProductEntradaTable.columnDateSeparate: "",

        ProductEntradaTable.columnIsSelected: 0,
        ProductEntradaTable.columnObservation: producto.observation,

        ProductEntradaTable.columnQuantitySeparate: 0,
        ProductEntradaTable.columnLoteId: 0,
        ProductEntradaTable.columnLoteName: "",
        ProductEntradaTable.columnLoteDate: "",

        ProductEntradaTable.columnIsQuantityIsOk: 0,
        ProductEntradaTable.columnProductIsOk: 0,
      };

      await db.insert(
        ProductEntradaTable.tableName,
        productCopy,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Producto duplicado insertado con éxito.");
    } catch (e, s) {
      print("Error al insertar producto duplicado: $e ==> $s");
    }
  }

  //metodo para obtener todos los productos de la entrada
  Future<List<LineasRecepcion>> getAllProductsEntrada() async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> products = await db.query(
        ProductEntradaTable.tableName,
      );
      return products
          .map((product) => LineasRecepcion.fromMap(product))
          .toList();
    } catch (e, s) {
      print('Error en getAllProductsEntrada: $e, $s');
      return [];
    }
  }

//*Método para obtener todos los productos de una entrada por idRecepcion
  Future<List<LineasRecepcion>> getProductsByRecepcionId(
      int idRecepcion) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      // Consulta para obtener los productos con el idRecepcion correspondiente
      final List<Map<String, dynamic>> products = await db.query(
        ProductEntradaTable.tableName,
        where: '${ProductEntradaTable.columnIdRecepcion} = ?',
        whereArgs: [idRecepcion],
      );
      // Convertir los resultados de la consulta en objetos de tipo LineasRecepcion
      return products
          .map((product) => LineasRecepcion.fromMap(product))
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
        'UPDATE ${ProductEntradaTable.tableName} SET $field = ? WHERE ${ProductEntradaTable.columnProductId} = ? AND ${ProductEntradaTable.columnIdMove} = ? AND ${ProductEntradaTable.columnIdRecepcion} = ?',
        [setValue, productId, idMove, idEntrada]);

    print(
        "update TableProductEntrada (idProduct ----($productId)) -------($field): $resUpdate");

    return resUpdate;
  }

  //METODO PARA OBTENER UN PRODUCTO POR SU ID
Future<LineasRecepcion?> getProductById(
    int idProduct, int idMove, int idRecepcion) async {
  try {

    print('idProduct: $idProduct, idMove: $idMove, idRecepcion: $idRecepcion');
    // Obtener la instancia de la base de datos
    Database db = await DataBaseSqlite().getDatabaseInstance();
    
    // Convertir idProduct a String (porque en la tabla está como TEXT)
    final List<Map<String, dynamic>> product = await db.query(
      ProductEntradaTable.tableName,
      where:
          '${ProductEntradaTable.columnProductId} = ? AND ${ProductEntradaTable.columnIdMove} = ? AND ${ProductEntradaTable.columnIdRecepcion} = ?',
      whereArgs: [
        idProduct.toString(),  // Convertir idProduct a String
        idMove, 
        idRecepcion
      ],
    );

    // Si hay datos, crear un objeto de LineasRecepcion, si no, retornar null
    return product.isNotEmpty ? LineasRecepcion.fromMap(product.first) : null;
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
        ProductEntradaTable.tableName,
        columns: [(ProductEntradaTable.columnQuantitySeparate)],
        where:
            '${ProductEntradaTable.columnIdRecepcion} = ? AND ${ProductEntradaTable.columnProductId} = ? AND ${ProductEntradaTable.columnIdMove} = ?',
        whereArgs: [idRecepcion, productId, idMove],
      );

      if (result.isNotEmpty) {
        int currentQty =
            (result.first[ProductEntradaTable.columnQuantitySeparate] as int);

        int newQty = currentQty + quantity;
        return await txn.update(
          ProductEntradaTable.tableName,
          {ProductEntradaTable.columnQuantitySeparate: newQty},
          where:
              '${ProductEntradaTable.columnIdRecepcion} = ? AND ${ProductEntradaTable.columnProductId} = ? AND ${ProductEntradaTable.columnIdMove} = ?',
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
        "UPDATE ${ProductEntradaTable.tableName} SET ${ProductEntradaTable.columnObservation} = ? WHERE ${ProductEntradaTable.columnProductId} = ? AND ${ProductEntradaTable.columnIdRecepcion} = ? AND ${ProductEntradaTable.columnIdMove} = ?",
        [novedad, productId, idRecepcion, idMove]);

    print("updateNovedad: $resUpdate");
    return resUpdate;
  }
}
