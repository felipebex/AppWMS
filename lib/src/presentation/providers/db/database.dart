// ignore_for_file: avoid_print, depend_on_referenced_packages

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
        state VARCHAR(255),
        user_id VARCHAR(255),
        is_wave TEXT,
        is_separate TEXT,  
        product_separate_qty INTEGER,
        product_qty INTEGER,
        time_separate_total VARCHAR(255),
        time_separate_start VARCHAR(255),
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
        location_id TEXT,
        location_dest_id TEXT,
        quantity INTEGER,
        quantity_separate INTEGER,
        is_selected TEXT,
        is_separate TEXT,
        time_separate VARCHAR(255),
        time_separate_start VARCHAR(255),
        observation TEXT,
        is_location_is_ok TEXT,
        product_is_ok TEXT,
        location_dest_is_ok TEXT,
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
      return Products.fromMap(maps.first);
    }
    return null;
  }

  //Todo: Métodos para batches
  //* Insertar un batch
  Future<void> insertBatch(BatchsModel batch) async {
    try {
      final db = await database;
      await db?.insert('tblbatchs', batch.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Error al insertar batch: $e");
    }
  }

  //* Obtener todos los batchs
  Future<List<BatchsModel>> getAllBatchs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('tblbatchs');
    return maps.map((map) => BatchsModel.fromMap(map)).toList();
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
          final List<Map<String, dynamic>> existingProduct = await txn.query(
            'tblbatch_products',
            where: 'product_id = ? AND batch_id = ?',
            whereArgs: [productBatch.productId, productBatch.batchId],
          );

          if (existingProduct.isNotEmpty) {
            // Actualizar producto existente
            await txn.update(
              'tblbatch_products',
              productBatch.toMap(),
              where: 'product_id = ? AND batch_id = ?',
              whereArgs: [productBatch.productId, productBatch.batchId],
            );
          } else {
            // Insertar nuevo producto
            await txn.insert(
              'tblbatch_products',
              productBatch.toMap(),
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
      final db = await database;
      final List<Map<String, dynamic>> batchMaps = await db!.query(
        'tblbatchs',
        where: 'id = ?',
        whereArgs: [batchId],
      );


      print("batchMaps: $batchMaps");
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
  }

  //Todo: Eliminar todos los registros
  Future<void> deleteAll() async {
    final db = await database;
    await db?.delete('tblproducts');
    await db?.delete('tblbatchs');
    await db?.delete('tblbatch_products');
  }
}
