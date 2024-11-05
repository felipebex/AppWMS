// ignore_for_file: avoid_print, depend_on_referenced_packages, unnecessary_string_interpolations, unnecessary_brace_in_string_interps

import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseSqlite {
  static final DataBaseSqlite _instance = DataBaseSqlite._internal();
  factory DataBaseSqlite() => _instance;
  DataBaseSqlite._internal();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wmsapp.db');

    return await openDatabase(path,
        version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Crear tablas
    await db.execute('''
      CREATE TABLE tblproducts (
        id INTEGER PRIMARY KEY,
        name VARCHAR(255),
        barcode VARCHAR(255),
        tracking TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblbatchs (
        id INTEGER PRIMARY KEY,
        name VARCHAR(255),
        scheduled_date VARCHAR(255),
        picking_type_id VARCHAR(255),
        muelle VARCHAR(255),
        state VARCHAR(255),
        user_id VARCHAR(255),
        is_wave TEXT,
        is_separate INTEGER, 
        is_selected INTEGER, 
        product_separate_qty INTEGER,
        product_qty INTEGER,
        index_list INTEGER,
        time_separate_total DECIMAL(10,2),

        time_separate_start VARCHAR(255),
        time_separate_end VARCHAR(255),
        is_send_oddo TEXT,
        is_send_oddo_date VARCHAR(255),
        observation TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblbatch_products (
        id INTEGER PRIMARY KEY,
        id_product INTEGER,
        batch_id INTEGER,
        product_id INTEGER,
        picking_id TEXT,
        lot_id TEXT,
        lote_id INTEGER,
        id_move INTEGER,
        location_id TEXT,
        location_dest_id TEXT,
        quantity INTEGER,
        quantity_separate INTEGER,
        is_selected INTEGER,
        is_separate INTEGER,

        time_separate DECIMAL(10,2),
        time_separate_start VARCHAR(255),
        time_separate_end VARCHAR(255),




        observation TEXT,
        unidades TEXT,
        is_location_is_ok INTEGER,
        product_is_ok INTEGER,
        is_quantity_is_ok INTEGER,
        location_dest_is_ok INTEGER,
        FOREIGN KEY (batch_id) REFERENCES tblbatchs (id),
        FOREIGN KEY (product_id) REFERENCES tblproducts (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE tblurlsrecientes (
        id INTEGER PRIMARY KEY,
        url VARCHAR(255),
        fecha VARCHAR(255),
        method VARCHAR(255)
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE tblbatchs ADD COLUMN is_wave VARCHAR(255)");
    }
  }

  //Todo: Métodos para productos
  //* Insertar un producto
  Future<void> insertProduct(Products product) async {
    final db = await database;
    await db?.insert('tblproducts', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //* Insertar varios productos
  Future<void> insertProducts(List<Products> products) async {
    final db = await database;
    final batch = db?.batch();
    for (var product in products) {
      batch?.insert('tblproducts', product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch?.commit();
  }

  //* Obtener todos los productos
  Future<List<Products>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('tblproducts');
    return maps.map((map) => Products.fromMap(map)).toList();
  }

  //* obtener un producto por id
  Future<Products?> getProductById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db!.query('tblproducts', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      print("maps.first: ${maps.first}");
      return Products.fromMap(maps.first);
    }
    return null;
  }

  //Todo: Métodos para batches
  //* Insertar un batch
  Future<void> insertBatch(BatchsModel batch) async {
    try {
      final db = await database;

      await db!.transaction((txn) async {
        // Verificar si el batch ya existe
        final List<Map<String, dynamic>> existingBatch = await txn.query(
          'tblbatchs',
          where: 'id = ?',
          whereArgs: [batch.id],
        );

        if (existingBatch.isNotEmpty) {
          // Actualizar el batch
          await txn.update(
            'tblbatchs',
            {
              "id": batch.id,
              "name": batch.name,
              "scheduled_date": batch.scheduleddate.toString(),
              "picking_type_id": batch.pickingTypeId,
              "state": batch.state,
              "user_id": batch.userId,
              "is_wave": batch.isWave,
              'muelle': batch.muelle,
            },
            where: 'id = ?',
            whereArgs: [batch.id],
          );
        } else {
          // Insertar nuevo batch
          await txn.insert(
            'tblbatchs',
            {
              "id": batch.id,
              "name": batch.name,
              "scheduled_date": batch.scheduleddate.toString(),
              "picking_type_id": batch.pickingTypeId,
              "state": batch.state,
              "user_id": batch.userId,
              "is_wave": batch.isWave,
              'muelle': batch.muelle,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      print("Error al insertar batch: $e");
    }
  }

  //* Obtener todos los batchs
  Future<List<BatchsModel>> getAllBatchs() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db!.query('tblbatchs');

      final List<BatchsModel> batchs = maps.map((map) {
        return BatchsModel.fromMap(map);
      }).toList();
      return batchs;
    } catch (e, s) {
      print("Error getAllBatchs: $e => $s");
    }
    return [];
  }

  //Todo: Métodos para batchs_products

  Future<void> insertBatchProducts(
      List<ProductsBatch> productsBatchList) async {
    try {
      final db = await database;
      // Inicia la transacción
      await db!.transaction((txn) async {
        for (var productBatch in productsBatchList) {
          // Verificar si el producto ya existe con el batchId
          // final List<Map<String, dynamic>> existingProduct = await txn.query(
          //   'tblbatch_products',
          //   where: 'id_product = ? AND batch_id = ? AND lot_id',
          //   whereArgs: [productBatch.idProduct, productBatch.batchId, productBatch.lotId],
          // );

          final List<Map<String, dynamic>> existingProduct = await txn.query(
            'tblbatch_products',
            where: 'id_product = ? AND batch_id = ? AND lot_id = ?',
            whereArgs: [
              productBatch.idProduct,
              productBatch.batchId,
              productBatch.loteId
            ],
          );

          if (existingProduct.isNotEmpty) {
            // se comenta para que no actualice todo el modelo
            await txn.update(
              'tblbatch_products',
              {
                "id_product": productBatch.idProduct,
                "batch_id": productBatch.batchId,
                // "picking_id": productBatch.pickingId?[1],
                "location_id": productBatch.locationId?[1],
                "lot_id": productBatch.lotId?[1],
                "lote_id": productBatch.loteId,
                "id_move": productBatch.idMove,
                "location_dest_id": productBatch.locationDestId?[1],
                "quantity": productBatch.quantity,
                "unidades": productBatch.unidades,
                "barcode": productBatch.barcode,
                "weight": productBatch.weigth,
                

              },
              where: 'id_product = ? AND batch_id = ?',
              whereArgs: [productBatch.idProduct, productBatch.batchId],
            );
          } else {
            // Insertar nuevo producto
            await txn.insert(
              'tblbatch_products',
              {
                "id_product": productBatch.idProduct,
                "batch_id": productBatch.batchId,
                "product_id": productBatch.productId?[1],
                // "picking_id": productBatch.pickingId?[1],
                "location_id": productBatch.locationId?[1],
                "lot_id": productBatch.lotId?[1],
                "lote_id": productBatch.loteId,
                "id_move": productBatch.idMove,

                "location_dest_id": productBatch.locationDestId?[1],
                "quantity": productBatch.quantity,
                "unidades": productBatch.unidades,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
    } catch (e, s) {
      print('Error insertBatchProducts: $e => $s');
    }
  }

  //* Obtener todos los productos de tblbatch_products
  Future<List<ProductsBatch>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db!.query('tblbatch_products');
    return maps.map((map) => ProductsBatch.fromMap(map)).toList();
  }

  //* Obtener un batch con sus productos
  Future<BatchWithProducts?> getBatchWithProducts(int batchId) async {
    try {
      print("batchId: $batchId");
      final db = await database;
      final List<Map<String, dynamic>> batchMaps = await db!.query(
        'tblbatchs',
        where: 'id = ?',
        whereArgs: [batchId],
      );
      if (batchMaps.isEmpty) {
        return null; // No se encontró el batch
      }

      final BatchsModel batch = BatchsModel.fromMap(batchMaps.first);
      final List<Map<String, dynamic>> productMaps = await db.query(
        'tblbatch_products',
        where: 'batch_id = ?',
        whereArgs: [batchId],
      );
      final List<ProductsBatch> products =
          productMaps.map((map) => ProductsBatch.fromMap(map)).toList();

      return BatchWithProducts(batch: batch, products: products);
    } catch (e, s) {
      print('Error getBatchWithProducts: $e => $s');
    }
    return null;
  }

  //Todo: Eliminar todos los registros
  Future<void> deleteAll() async {
    final db = await database;
    await db?.delete('tblproducts');
    await db?.delete('tblbatchs');
    await db?.delete('tblbatch_products');
  }

  //todo: Metodos para realizar el picking de un producto

  Future<int?> updateIsLocationIsOk(
    int batchId,
    int productId,
    int idMove,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET is_location_is_ok = true WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("updateIsLocationIsOk: $resUpdate");

    return resUpdate;
  }

  Future<int?> updateIsProductIsOk(
    int batchId,
    int productId,
    int idMove,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET product_is_ok = true WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("updateIsProductIsOk: $resUpdate");

    return resUpdate;
  }

  Future<int?> updateLocationDestIsOk(
    int batchId,
    int productId,
    int idMove,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET location_dest_is_ok = true WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("updateLocationDestIsOk: $resUpdate");

    return resUpdate;
  }

  Future<int?> updateIsQuantityIsOk(
    int batchId,
    int productId,
    int idMove,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET is_quantity_is_ok = true WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("updateIsQuantityIsOk: $resUpdate");

    return resUpdate;
  }

  Future<int?> isPickingBatch(
    int batchId,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatchs SET is_separate = true WHERE id = $batchId ');
    print("isPickingBatch: $resUpdate");

    return resUpdate;
  }

  Future<int?> updateIsQuantityIsFalse(
    int batchId,
    int productId,
    int idMove,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET is_quantity_is_ok = false WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("updateIsQuantityIsOk: $resUpdate");

    return resUpdate;
  }

  Future<int?> updateProductQuantitySeparate(
    int batchId,
    int productId,
    int quantitySeparate,
    int idMove,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET quantity_separate = $quantitySeparate WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("updateIsQuantityIsOk: $resUpdate");

    return resUpdate;
  }

  Future<int?> startStopwatch(
      int batchId, int productId, int moveId, String date) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatch_products SET time_separate_start = '$date' WHERE batch_id = $batchId AND id_product = $productId AND id_move = $moveId ");
    print("startStopwatch: $resUpdate");
    return resUpdate;
  }

  Future<int?> startStopwatchBatch(int batchId, String date) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatchs SET time_separate_start = '$date' WHERE id = $batchId ");
    print("startStopwatchBatch: $resUpdate");
    return resUpdate;
  }

  //obtener el tiempo de inicio de la separacion
  Future<String> getFieldTableBtach(int batchId, String field) async {
    final db = await database;
    final res = await db!.rawQuery('''
      SELECT $field FROM tblbatchs WHERE id = $batchId LIMIT 1
    ''');
    if (res.isNotEmpty) {
      String responsefield = res[0]['${field}'].toString();
      print("getFieldTableBtach {$field}   : $responsefield");
      return responsefield;
    }
    return "";
  }

  //obtener el tiempo de inicio de la separacion de la tabla product
  Future<String> getFieldTableProducts(
      int batchId, int productId, int moveId, String field) async {
    try {
      final db = await database;
      final res = await db!.rawQuery('''
      SELECT $field FROM tblbatch_products WHERE id = $batchId AND  id_product = $productId AND id_move = $moveId LIMIT 1
    ''');
      if (res.isNotEmpty) {
        String responsefield = res[0]['${field}'].toString();
        print("getFieldTableBtach {$field}   : $responsefield");
        return responsefield;
      }
      return "";
    } catch (e, s) {
      print("error getFieldTableProducts: $e => $s");
    }
    return "";
  }

  Future<int?> endStopwatchBatch(int batchId, String date) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatchs SET time_separate_end = '$date' WHERE id = $batchId ");
    print("startStopwatchBatch: $resUpdate");
    return resUpdate;
  }

  Future<int?> endStopwatchProduct(
      int batchId, String date, int productId, int moveId) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatch_products SET time_separate_end = '$date' WHERE id = $batchId AND id_product = $productId AND id_move = $moveId");

    print("endStopwatchProduct: $resUpdate");
    return resUpdate;
  }

  Future<int?> totalStopwatchBatch(int batchId, double date) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatchs SET time_separate_total = $date WHERE id = $batchId ");
    print("endStopwatchBatch: $resUpdate");
    return resUpdate;
  }

  Future<int?> selectProduct(
    int batchId,
    int productId,
    int idMove,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET is_selected = true WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("selectProduct: $resUpdate");
    return resUpdate;
  }

  Future<int?> deselectProduct(
    int batchId,
    int productId,
    int idMove,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET is_selected = false WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("deselectProduct: $resUpdate");
    return resUpdate;
  }

  Future<int?> separateProduct(
    int batchId,
    int productId,
    int idMove,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET is_separate = true WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("separateProduct: $resUpdate");
    return resUpdate;
  }

  Future<int?> selectBatch(
    int batchId,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatchs SET is_selected = true WHERE id = $batchId');
    print("selectBatch: $resUpdate");
    return resUpdate;
  }

  //dejar guardado el index de la lista de productos en el batch
  Future<int?> updateIndexList(int batchId, int indexList) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatchs SET index_list = $indexList WHERE id = $batchId');
    print("updateIndexList: $resUpdate");
    return resUpdate;
  }

  Future<int?> updateNovedad(
    int batchId,
    int productId,
    String novedad,
    int idMove,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        " UPDATE tblbatch_products SET observation = '$novedad' WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove");
    print("updateNovedad: $resUpdate");
    return resUpdate;
  }

  //sumamos la cantidad de productos separados en la tabla de tblbatch
  Future<int?> incrementProductSeparateQty(int batchId) async {
    final db = await database;

    // Usamos una transacción para asegurar que la operación sea atómica
    return await db!.transaction((txn) async {
      // Primero, obtenemos el valor actual de product_separate_qty
      final result = await txn.query(
        'tblbatchs',
        columns: ['product_separate_qty'],
        where: 'id = ?',
        whereArgs: [batchId],
      );

      if (result.isNotEmpty) {
        // Extraemos el valor actual
        int currentQty = (result.first['product_separate_qty'] as int?) ?? 0;

        // Incrementamos la cantidad
        int newQty = currentQty + 1;

        // Actualizamos la tabla
        return await txn.update(
          'tblbatchs',
          {'product_separate_qty': newQty},
          where: 'id = ?',
          whereArgs: [batchId],
        );
      }

      return null; // No se encontró el batch con el batchId proporcionado
    });
  }

  //incrementar la cantidad de productos separados en la tabla de tblbatch_products
  Future<int?> incremenQtytProductSeparate(int batchId, int productId) async {
    final db = await database;
    return await db!.transaction((txn) async {
      // Primero, obtenemos el valor actual de product_separate_qty
      final result = await txn.query(
        'tblbatch_products',
        columns: ['quantity_separate'],
        where: 'batch_id = $batchId AND id_product = $productId',
        whereArgs: [batchId, productId],
      );

      if (result.isNotEmpty) {
        // Extraemos el valor actual
        int currentQty = (result.first['quantity_separate'] as int?) ?? 0;

        // Incrementamos la cantidad
        int newQty = currentQty + 1;

        // Actualizamos la tabla
        return await txn.update(
          'tblbatch_products',
          {'quantity_separate': newQty},
          where: 'batch_id = $batchId AND id_product = $productId',
          whereArgs: [batchId, productId],
        );
      }

      return null; // No se encontró el batch con el batchId proporcionado
    });
  }

  Future<int?> updateQtyProductSeparate(
    int batchId,
    int productId,
    int quantity,
    int idMove,
  ) async {
    final db = await database;

    final resUpdate = await db!.rawUpdate(
      ' UPDATE tblbatch_products SET quantity_separate = $quantity WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove',
    );
    print("updateQtyProductSeparate: $resUpdate");
    return resUpdate;
  }

  //actualozar el index de la lista de productos

  Future<List> getProductBacth(
    int batchId,
    int productId,
  ) async {
    final db = await database;

    final res = await db!.rawQuery('''
      SELECT * FROM tblbatch_products WHERE batch_id = $batchId AND id_product = $productId  LIMIT 1
    ''');
    return res;
  }

  Future<List> getBacth(
    int batchId,
  ) async {
    final db = await database;

    final res = await db!.rawQuery('''
      SELECT * FROM tblbatchs WHERE id = $batchId   LIMIT 1
    ''');
    return res;
  }

  //actualziar en el tabla tblbatch_products el campo de product_is_ok en "true"
  Future<void> updateProductIsOk(
    int batchId,
    int productId,
    int idMove,
  ) async {
    final db = await database;
    await db?.update(
      'tblbatch_products',
      {'product_is_ok': 'true'},
      where: 'batch_id = ? AND product_id = ? AND id_move = ?',
      whereArgs: [batchId, productId, idMove],
    );
  }
}
