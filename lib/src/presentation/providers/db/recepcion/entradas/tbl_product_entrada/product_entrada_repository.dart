import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_product_entrada/product_entrada_table.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_deleted_product_model.dart';

class ProductsEntradaRepository {
  //metodo para insertar todas las entradas
  Future<void> insertarProductoEntrada(
      List<LineasTransferencia> products, String type) async {
    try {
      // Obtener la instancia de la base de datos.
      Database dbInstance = await DataBaseSqlite().getDatabaseInstance();

      await dbInstance.transaction((txn) async {
        Batch batch = txn.batch();

        // Generar el conjunto de productIds a consultar y crear las claves compuestas de los productos a insertar/actualizar.
        final productIds =
            products.map((p) => p.productId ?? 0).toSet().toList();
        final Set<String> keysToInsert = products
            .map((p) => '${p.productId}-${p.idMove}-${p.idRecepcion}')
            .toSet();

        // Consulta única para obtener los registros existentes en la tabla
        final List<Map<String, dynamic>> existingRows = await txn.query(
          ProductRecepcionTable.tableName,
          columns: [
            ProductRecepcionTable.columnProductId,
            ProductRecepcionTable.columnIdMove,
            ProductRecepcionTable.columnIdRecepcion,
          ],
          where:
              '${ProductRecepcionTable.columnProductId} IN (${List.filled(productIds.length, '?').join(',')})',
          whereArgs: productIds,
        );

        // Construir un Set de claves compuestas de los registros existentes.
        Set<String> existingKeys = existingRows.map((e) {
          return '${e[ProductRecepcionTable.columnProductId]}-${e[ProductRecepcionTable.columnIdMove]}-${e[ProductRecepcionTable.columnIdRecepcion]}';
        }).toSet();

        // Recorrer cada producto y definir si se debe hacer UPDATE o INSERT.
        for (var product in products) {
          final key =
              '${product.productId}-${product.idMove}-${product.idRecepcion}';

          // Definir los valores a insertar/actualizar.
          final Map<String, dynamic> values = {
            ProductRecepcionTable.columnId: product.id ?? 0,
            ProductRecepcionTable.columnIdMove: product.idMove ?? 0,
            ProductRecepcionTable.columnProductId: product.productId ?? 0,
            ProductRecepcionTable.columnIdRecepcion: product.idRecepcion ?? 0,
            ProductRecepcionTable.columnProductName: product.productName ?? '',
            ProductRecepcionTable.columnProductCode: product.productCode ?? '',
            ProductRecepcionTable.columnProductBarcode:
                product.productBarcode ?? '',
            ProductRecepcionTable.columnProductTracking:
                product.productTracking ?? '',
            ProductRecepcionTable.columnFechaVencimiento:
                product.fechaVencimiento ?? "",
            ProductRecepcionTable.columnDiasVencimiento:
                product.diasVencimiento ?? '',
            ProductRecepcionTable.columnQuantityOrdered:
                product.quantityOrdered ?? 0,
            ProductRecepcionTable.columnQuantityToReceive:
                product.quantityToReceive ?? 0,
            ProductRecepcionTable.columnQuantityDone: product.quantityDone ?? 0,
            ProductRecepcionTable.columnUom: product.uom ?? "",
            ProductRecepcionTable.columnLocationDestId:
                product.locationDestId ?? 0,
            ProductRecepcionTable.columnLocationDestName:
                product.locationDestName ?? '',
            ProductRecepcionTable.columnLocationDestBarcode:
                product.locationDestBarcode ?? '',
            ProductRecepcionTable.columnLocationId: product.locationId ?? 0,
            ProductRecepcionTable.columnLocationBarcode:
                product.locationBarcode ?? '',
            ProductRecepcionTable.columnLocationName:
                product.locationName ?? '',
            ProductRecepcionTable.columnWeight: product.weight ?? 0,
            ProductRecepcionTable.columnIsSeparate: 0,
            ProductRecepcionTable.columnIsSelected: 0,
            ProductRecepcionTable.columnLotName: product.lotName ?? "",
            // Se valida que exista el lote para asignar la fecha de vencimiento.
            ProductRecepcionTable.columnLoteDate:
                (product.lotName != "" ? product.fechaVencimiento : ""),
            ProductRecepcionTable.columnIsProductSplit: 0,
            ProductRecepcionTable.columnObservation: "",
            ProductRecepcionTable.columnDateStart: "",
            ProductRecepcionTable.columnDateEnd: "",
            ProductRecepcionTable.columnTime: product.time,
            ProductRecepcionTable.columnIsDoneItem: product.isDoneItem ?? 0,
            ProductRecepcionTable.columnDateTransaction:
                product.dateTransaction ?? '',
            ProductRecepcionTable.columnCantidadFaltante:
                product.cantidadFaltante ?? 0,
            ProductRecepcionTable.columnType: type,
            ProductRecepcionTable.columnManejoTemperature:
                product.manejaTemperatura ?? 0,
            ProductRecepcionTable.columnTemperature: product.temperatura ?? 0,
            ProductRecepcionTable.columnImage: product.image ?? '',
            ProductRecepcionTable.columnImageNovedad: product.imageNovedad ?? '',

          };

          // Si la clave ya existe, se hace UPDATE; si no, se hace INSERT.
          if (existingKeys.contains(key)) {
            batch.update(
              ProductRecepcionTable.tableName,
              values,
              where:
                  '${ProductRecepcionTable.columnProductId} = ? AND ${ProductRecepcionTable.columnIdMove} = ? AND ${ProductRecepcionTable.columnIdRecepcion} = ?',
              whereArgs: [
                product.productId,
                product.idMove,
                product.idRecepcion
              ],
            );
          } else {
            batch.insert(
              ProductRecepcionTable.tableName,
              values,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
        // Ejecutar el batch sin esperar los resultados individuales para mayor eficiencia.
        await batch.commit(noResult: true);
      });
      print('Productos de entradas insertados con éxito.');
    } catch (e, s) {
      print('Error en el insertarProductoEntrada: $e, $s');
    }
  }

  Future<void> insertDuplicateProducto(
      LineasTransferencia producto, dynamic cantidad, String type) async {
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
        ProductRecepcionTable.columnQuantityOrdered:
            producto.quantityOrdered ?? 0,
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
        ProductRecepcionTable.columnType: type,
        ProductRecepcionTable.columnManejoTemperature:
            producto.manejaTemperatura ?? 0,
        ProductRecepcionTable.columnTemperature: 0.0,
        ProductRecepcionTable.columnImage: '',
        ProductRecepcionTable.columnImageNovedad: '',

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

  //metodo para eliminar un producto de la entrada
  Future<int?> deleteProductEntrada(int idRecepcion, int idMove) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final resDelete = await db.delete(
        ProductRecepcionTable.tableName,
        where:
            '${ProductRecepcionTable.columnIdRecepcion} = ? AND ${ProductRecepcionTable.columnIdMove} = ?',
        whereArgs: [idRecepcion, idMove],
      );
      print('Producto eliminado de la entrada: $resDelete');
      return resDelete;
    } catch (e, s) {
      print('Error en deleteProductEntrada: $e, $s');
      return null;
    }
  }

  // Método para eliminar una lista de productos de la entrada
  Future<int?> deleteProductsEntrada(
      int idRecepcion, List<int> listIdMove) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final resDelete = await db.delete(
        ProductRecepcionTable.tableName,
        where:
            '${ProductRecepcionTable.columnIdRecepcion} = ? AND ${ProductRecepcionTable.columnIdMove} IN (${List.filled(listIdMove.length, '?').join(',')})',
        whereArgs: [idRecepcion, ...listIdMove],
      );
      print('Productos eliminados de la entrada: $resDelete');
      return resDelete;
    } catch (e, s) {
      print('Error en deleteProductsEntrada: $e, $s');
      return null;
    }
  }

  /// Método optimizado para actualizar cantidades y eliminar productos en lote
  Future<void> updateCantidadAndDeleteProductsEntrada({
    required int idRecepcion,
    required List<ProductDeleted>? products,
  }) async {
    if (products == null || products.isEmpty) return;

    final db = await DataBaseSqlite().getDatabaseInstance();

    await db.transaction((txn) async {
      for (final product in products) {
        final int? idMoveDestino = product.idMove;
        final int? idMoveEliminar = product.idMoveDeleted;
        final int? idProducto = product.idProducto;
        final String? nombre = product.producto;

        if (idMoveDestino == null ||
            idMoveEliminar == null ||
            idProducto == null) continue;

        final double cantidadNueva =
            double.tryParse(product.cantidad.toString()) ?? 0;

        // Paso 1: Buscar el producto equivalente
        final destino = await txn.query(
          ProductRecepcionTable.tableName,
          columns: [ProductRecepcionTable.columnCantidadFaltante],
          where: '${ProductRecepcionTable.columnIdRecepcion} = ? AND '
              '${ProductRecepcionTable.columnProductId} = ? AND '
              '${ProductRecepcionTable.columnIdMove} = ?',
          whereArgs: [idRecepcion, idProducto, idMoveDestino],
          limit: 1,
        );

        if (destino.isNotEmpty) {
          // ✔️ CASO 1: Sí existe el equivalente
          final actualRaw =
              destino.first[ProductRecepcionTable.columnCantidadFaltante];
          final double cantidadAnterior = actualRaw is double
              ? actualRaw
              : double.tryParse(actualRaw.toString()) ?? 0;

          final double cantidadActualizada = cantidadAnterior + cantidadNueva;

          await txn.update(
            ProductRecepcionTable.tableName,
            {ProductRecepcionTable.columnCantidadFaltante: cantidadActualizada},
            where: '${ProductRecepcionTable.columnIdRecepcion} = ? AND '
                '${ProductRecepcionTable.columnProductId} = ? AND '
                '${ProductRecepcionTable.columnIdMove} = ?',
            whereArgs: [idRecepcion, idProducto, idMoveDestino],
          );

          await txn.delete(
            ProductRecepcionTable.tableName,
            where: '${ProductRecepcionTable.columnIdRecepcion} = ? AND '
                '${ProductRecepcionTable.columnProductId} = ? AND '
                '${ProductRecepcionTable.columnIdMove} = ?',
            whereArgs: [idRecepcion, idProducto, idMoveEliminar],
          );

          print("🔁 Producto ACTUALIZADO:");
          print("📦 $nombre");
          print("🆔 Producto: $idProducto");
          print("🔢 idMove destino: $idMoveDestino");
          print("📉 Cantidad anterior: $cantidadAnterior");
          print("📈 Cantidad nueva: $cantidadActualizada");
          print("🗑️ Eliminado producto con idMove: $idMoveEliminar");
        } else {
          // ❌ CASO 2: No se encuentra el equivalente
          await txn.update(
            ProductRecepcionTable.tableName,
            {
              ProductRecepcionTable.columnCantidadFaltante: cantidadNueva,
              ProductRecepcionTable.columnIdMove: idMoveDestino,
              ProductRecepcionTable.columnIsSeparate: 0,
              ProductRecepcionTable.columnIsSelected: 0,
              ProductRecepcionTable.columnIsDoneItem: 0,
              ProductRecepcionTable.columnDateStart: "",
              ProductRecepcionTable.columnDateEnd: "",
              ProductRecepcionTable.columnTime: "",
              ProductRecepcionTable.columnQuantityDone: 0.0,
              ProductRecepcionTable.columnProductIsOk: null,
              ProductRecepcionTable.columnIsQuantityIsOk: null,
              ProductRecepcionTable.columnQuantitySeparate: null,
            },
            where: '${ProductRecepcionTable.columnIdRecepcion} = ? AND '
                '${ProductRecepcionTable.columnProductId} = ? AND '
                '${ProductRecepcionTable.columnIdMove} = ?',
            whereArgs: [idRecepcion, idProducto, idMoveEliminar],
          );

          print("🔁 Producto REASIGNADO y RESET:");
          print("📦 $nombre");
          print("🆔 Producto: $idProducto");
          print("🔁 idMove actualizado de $idMoveEliminar → $idMoveDestino");
          print("🆕 Cantidad faltante actualizada a: $cantidadNueva");
          print("🔧 Otros campos reiniciados correctamente");
        }
      }
    });
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
        'UPDATE ${ProductRecepcionTable.tableName} SET $field = ?'
        'WHERE ${ProductRecepcionTable.columnProductId} = ?'
        'AND ${ProductRecepcionTable.columnIdMove} = ?'
        'AND ${ProductRecepcionTable.columnIdRecepcion} = ?'
        'AND ${ProductRecepcionTable.columnIsDoneItem} = 0',
        [setValue, productId, idMove, idEntrada]);

    print(
        "update TableProductEntrada (idProduct ----($productId)) -------($field): $resUpdate");

    return resUpdate;
  }

  Future<int?> setFieldTableProductEntradaImg(int idEntrada, int productId,
      String field, dynamic setValue, int idMove) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();

    final resUpdate = await db.rawUpdate(
        'UPDATE ${ProductRecepcionTable.tableName} SET $field = ?'
        'WHERE ${ProductRecepcionTable.columnProductId} = ?'
        'AND ${ProductRecepcionTable.columnIdMove} = ?'
        'AND ${ProductRecepcionTable.columnIdRecepcion} = ?',
        [setValue, productId, idMove, idEntrada]);

    print(
        "update TableProductEntrada (idProduct ----($productId)) -------($field): $resUpdate");

    return resUpdate;
  }

  Future<int?> setFieldTableProductSendEntrada(int idEntrada, int productId,
      String field, dynamic setValue, int idMove) async {
    Database db = await DataBaseSqlite().getDatabaseInstance();

    final resUpdate = await db.rawUpdate(
        'UPDATE ${ProductRecepcionTable.tableName} SET $field = ?'
        'WHERE ${ProductRecepcionTable.columnProductId} = ?'
        'AND ${ProductRecepcionTable.columnIdMove} = ?'
        'AND ${ProductRecepcionTable.columnIdRecepcion} = ?'
        'AND ${ProductRecepcionTable.columnIsDoneItem} = 1',
        [setValue, productId, idMove, idEntrada]);

    print(
        "update TableProductEntrada product Send (idProduct ----($productId)) -------($field): $resUpdate");

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

  Future<int?> incremenQtytProductSeparatePacking(
      int idRecepcion, int productId, int idMove, dynamic quantity) async {
    final db = await DataBaseSqlite().getDatabaseInstance();

    return await db.transaction((txn) async {
      final result = await txn.query(
        ProductRecepcionTable.tableName,
        columns: [ProductRecepcionTable.columnQuantitySeparate],
        where:
            '${ProductRecepcionTable.columnIdRecepcion} = ? AND ${ProductRecepcionTable.columnProductId} = ? AND ${ProductRecepcionTable.columnIdMove} = ?',
        whereArgs: [idRecepcion, productId, idMove],
      );

      if (result.isNotEmpty) {
        final rawValue =
            result.first[ProductRecepcionTable.columnQuantitySeparate];
        final int currentQty = rawValue is int
            ? rawValue
            : (int.tryParse(rawValue.toString()) ?? 0);
        final int addQty = quantity is int
            ? quantity
            : (int.tryParse(quantity.toString()) ?? 0);

        final int newQty = currentQty + addQty;

        return await txn.update(
          ProductRecepcionTable.tableName,
          {ProductRecepcionTable.columnQuantitySeparate: newQty},
          where:
              '${ProductRecepcionTable.columnIdRecepcion} = ? AND ${ProductRecepcionTable.columnProductId} = ? AND ${ProductRecepcionTable.columnIdMove} = ?',
          whereArgs: [idRecepcion, productId, idMove],
        );
      }

      return null; // No se encontró el producto
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
