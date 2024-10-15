// ignore_for_file: avoid_print

import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
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
    final debPath = await getDatabasesPath();
    final path = join(debPath, 'wmsapp.db');

    return await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
      // *tabla para productos
      await db.execute('''
            CREATE TABLE tblproducts(a
              id INTEGER PRIMARY KEY,
              name VARCHAR(255),
              list_price INTEGER, 
              barcode VARCHAR(255),
              brand_name VARCHAR(255)
            )
        ''');

      // *tabla para batchs
      await db.execute('''
              CREATE TABLE tblbatchs(
                id INTEGER PRIMARY KEY,
                name VARCHAR(255),
                scheduled_date VARCHAR(255),
                picking_type_id VARCHAR(255),
                state VARCHAR(255),
                user_id VARCHAR(255)
              )
          ''');

      //*tabla de productos de un batch
      await db.execute('''
              CREATE TABLE tblbatch_products(
                id INTEGER PRIMARY KEY,
                batch_id INTEGER,
                product_id INTEGER,
                picking_id TEXT,
                lot_id TEXT,
                location_id TEXT,
                location_dest_id TEXT,
                quantity INTEGER,
                isSelected VARCHAR(255),
                FOREIGN KEY (batch_id) REFERENCES tblbatchs (id),
                FOREIGN KEY (product_id) REFERENCES tblproducts (id)
              )
          ''');

      // *tabla para urls recientes
      await db.execute('''
              CREATE TABLE tblurlsrecientes(
                id INTEGER PRIMARY KEY,
                url VARCHAR(255),
                fecha VARCHAR(255),
                method VARCHAR(255)
              )
          ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion == 2) {
        // await db.execute(
        //     'ALTER TABLE tblurlsrecientes ADD COLUMN method VARCHAR(255)');
      }
    });
  }

  //todo: metodos para  productos
  Future<void> insertProduct(Products product) async {
    final db = await database;
    await db?.insert('tblproducts', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertProducts(List<Products> products) async {
    final db = await database;
    final batch = db?.batch();
    for (var product in products) {
      batch?.insert('tblproducts', product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch?.commit();
  }

  Future<List<Products>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('tblproducts');

    return List.generate(maps.length, (i) {
      return Products.fromMap(maps[i]);
    });
  }

  //todo: metodos para batchs
  Future<void> insertBatch({
    required int id,
    required String name,
    required String scheduledDate,
    required String pickingTypeId,
    required String state,
    required String userId,
  }) async {
    try {
      final db = await database;
      await db?.insert(
        'tblbatchs',
        {
          'id': id,
          'name': name,
          'scheduled_date': scheduledDate,
          'picking_type_id': pickingTypeId,
          'state': state,
          'user_id': userId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, s) {
      print("Error al insertar batch: $e, $s");
    }
  }

  Future<List<BatchsModel>> getAllBatchs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('tblbatchs');

    return List.generate(maps.length, (i) {
      return BatchsModel.fromMap(maps[i]);
    });
  }

  //todo: metodos para batchs_products
  //* Método para insertar un producto en un batch

  Future<void> insertBatchProduct({
    required int batchId,
    required dynamic productId,
    required dynamic pickingId,
    required dynamic lotId,
    required dynamic locationId,
    required dynamic locationDestId,
    required dynamic quantity,
    required String isSelected,
  }) async {
    try {
      final db = await database;

      // Verificar si el producto ya existe
      final List<Map<String, dynamic>> existingProduct = await db?.query(
            'tblbatch_products',
            where: 'product_id = ?',
            whereArgs: [productId],
          ) ??
          [];

      if (existingProduct.isNotEmpty) {
        // Si existe, actualizar el producto
        await db?.update(
          'tblbatch_products',
          {
            'batch_id': batchId,
            'picking_id': pickingId,
            'lot_id': lotId,
            'location_id': locationId,
            'location_dest_id': locationDestId,
            'quantity': quantity,
            'isSelected': isSelected,
          },
          where: 'product_id = ?',
          whereArgs: [productId],
        );
      } else {
        // Si no existe, insertar el nuevo producto
        await db?.insert(
          'tblbatch_products',
          {
            'batch_id': batchId,
            'product_id': productId,
            'picking_id': pickingId,
            'lot_id': lotId,
            'location_id': locationId,
            'location_dest_id': locationDestId,
            'quantity': quantity,
            'isSelected': isSelected,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e, s) {
      print('Error insertBatchProduct: $e, $s');
    }
  }

//* Método para recuperar todos los productos de un batch
  Future<List<ProductsBatch>> getBatchProducts(int batchId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db!.query('tblbatch_products');

    return List.generate(maps.length, (index) {
      return ProductsBatch.fromMap(maps[index]);
    });
  }

  //* Método para editar un producto de un batch
  Future<void> updateBatchProduct({
    required int batchId,
    required dynamic productId,
    required dynamic isSelected,
  }) async {
    final db = await database;
    await db?.rawUpdate(
        " UPDATE tblbatch_products SET isSelected = '$isSelected' WHERE batch_id = '$batchId' AND product_id = '$productId' ");
  }

  //metodo para eliminar toda la base de datos
  Future<void> deleteAll() async {
    final db = await database;
    await db?.delete('tblproducts');
    await db?.delete('tblbatchs');
    await db?.delete('tblbatch_products');
  }

  //todo metodo para obtener un bacth por id y todos sus productos
  Future<BatchWithProducts?> getBatchWithProducts(int batchId) async {
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
  }
}
