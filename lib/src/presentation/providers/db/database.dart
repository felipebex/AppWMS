// ignore_for_file: avoid_print, depend_on_referenced_packages, unnecessary_string_interpolations, unnecessary_brace_in_string_interps, unrelated_type_equality_checks, unnecessary_null_comparison, prefer_conditional_assignment

import 'package:wms_app/src/presentation/providers/db/inventario/tbl_barcode/barcodes_inventario_repository.dart';
import 'package:wms_app/src/presentation/providers/db/inventario/tbl_barcode/barcodes_inventario_table.dart';
import 'package:wms_app/src/presentation/providers/db/inventario/tbl_product/product_inventario_repository.dart';
import 'package:wms_app/src/presentation/providers/db/inventario/tbl_product/product_inventario_table.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_barcodes/barcodes_repository.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_barcodes/barcodes_table.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_ubicaciones/ubicaciones_repository.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_ubicaciones/ubicaciones_table.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_warehouses/tbl_warehouse_table.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_warehouses/warehouse_repository.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_batchs_packing/batch_packing_repository.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_batchs_packing/batch_table.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_package_pack/package_repository.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_package_pack/package_table.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_products_pedido/productos_pedido_pack_repository.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_products_pedido/productos_pedido_pack_table.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_batch/batch_picking_repository.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_batch/batch_picking_table.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_configurations/configuration_repository.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_configurations/configuration_table.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_novedades/novedades_repoisitory.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_novedades/novedades_table.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_pedidos_pack/pedidos_pack_repository.dart';
import 'package:wms_app/src/presentation/providers/db/packing/tbl_pedidos_pack/pedidos_pack_table.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_submuelles/submuelles_repository.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_submuelles/submuelles_table.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_urlrecientes/urlrecientes_repository.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_urlrecientes/urlrecientes_table.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_entradas/entradas_repository.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_entradas/entradas_table.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_product_entrada/product_entrada_repository.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_product_entrada/product_entrada_table.dart';
import 'package:wms_app/src/presentation/providers/db/transferencia/tbl_product_transferencia/product_transferencia_repository.dart';
import 'package:wms_app/src/presentation/providers/db/transferencia/tbl_product_transferencia/product_transferencia_table.dart';
import 'package:wms_app/src/presentation/providers/db/transferencia/tbl_transferencias/transferencia_repository.dart';
import 'package:wms_app/src/presentation/providers/db/transferencia/tbl_transferencias/transferencia_table.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

import 'package:sqflite/sqflite.dart';

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

  // Método para inicializar la base de datos si no está inicializada
  Future<Database> initDB() async {
    if (_database != null) return _database!;

    // Si la base de datos no está inicializada, la inicializas aquí
    _database = await openDatabase(
      'wmsapp.db',
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
    // Crear tablas

    //* tabla de productos de un batch picking
    await db.execute('''
      CREATE TABLE tblbatch_products (
        id INTEGER PRIMARY KEY,
        id_product INTEGER,
        batch_id INTEGER,
        expire_date VARCHAR(255),
        product_id INTEGER,
        picking_id TEXT,
        lot_id TEXT,
        lote_id INTEGER,
        id_move INTEGER,
        location_id TEXT,
        location_dest_id TEXT,
        id_location_dest INTEGER,
        quantity INTEGER,
        barcode TEXT,
        rimoval_priority INTEGER,
        barcode_location_dest TEXT,
        barcode_location TEXT,
        quantity_separate INTEGER,
        is_selected INTEGER,
        is_separate INTEGER,
        is_pending INTEGER,
        order_product INTEGER,

        time_separate DECIMAL(10,2),
        time_separate_start VARCHAR(255),
        time_separate_end VARCHAR(255),

        observation TEXT,
        unidades TEXT,
        weight INTEGER,
        is_muelle INTEGER,
        muelle_id INTEGER,
        is_location_is_ok INTEGER,
        product_is_ok INTEGER,
        is_quantity_is_ok INTEGER,
        location_dest_is_ok INTEGER,
        fecha_transaccion VARCHAR(255),
        is_send_odoo INTEGER,
        is_send_odoo_date VARCHAR(255),
        FOREIGN KEY (batch_id) REFERENCES tblbatchs (id)
          )
     ''');

    //* tabla de batchs de packing
    await db.execute(BatchPackingTable.createTable());
    //*tabla de productos de un pedido de packing
    await db.execute(ProductosPedidosTable.createTable());
    //*tabla de barcodes de los productos
    await db.execute(BarcodesPackagesTable.createTable());
    //* tabla de paquetes de packing
    await db.execute(PackagesTable.createTable());
    //* tabla de batchs de picking
    await db.execute(BatchPickingTable.createTable());
    //* tabla de pedidos de packing
    await db.execute(PedidosPackingTable.createTable());
    //tabla de configuracion del usuario
    await db.execute(ConfigurationsTable.createTable());
    //tabla de urls recientes
    await db.execute(UrlsRecientesTable.createTable());
    //tabla para submuelles
    await db.execute(SubmuellesTable.createTable());
    //tabla para novedades
    await db.execute(NovedadesTable.createTable());

    //tabla para las entradas de mercancia
    await db.execute(ProductRecepcionTable.createTable());
    //tabla para las entradas de mercancia
    await db.execute(EntradasRepeccionTable.createTable());
    //tabla para las transferencias
    await db.execute(TransferenciaTable.createTable());
    //tabla para los productos de una transferencia
    await db.execute(ProductTransferenciaTable.createTable());
    //table para las ubicaciones
    await db.execute(UbicacionesTable.createTable());
    //table para las barcodes inventario
    await db.execute(BarcodesInventarioTable.createTable());

    //table para las producto de inventario
    await db.execute(ProductInventarioTable.createTable());

    //tabla para crear los almacenes
    await db.execute(WarehouseTable.createTable());
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      // await db.execute('ALTER TABLE tblbatchs ADD COLUMN id_muelle INTEGER');
    }
  }

  //todo repositorios de las tablas
  // Método para obtener una instancia del repositorio de novedades
  NovedadesRepository get novedadesRepository => NovedadesRepository();
  // Método para obtener una instancia del repositorio de batchs
  BatchPickingRepository get batchPickingRepository => BatchPickingRepository();
  // Método para obtener una instancia del repositorio de submuelles
  SubmuellesRepository get submuellesRepository => SubmuellesRepository();
  //metodo  para obtener una instancia del repositorio de URLs recientes
  UrlsRecientesRepository get urlsRecientesRepository =>
      UrlsRecientesRepository();
  //metodo  para obtener una instancia del repositorio de configuraciones
  ConfigurationsRepository get configurationsRepository =>
      ConfigurationsRepository();
  //metodo  para obtener una instancia del repositorio de pedidos packing
  PedidosPackingRepository get pedidosPackingRepository =>
      PedidosPackingRepository();
  //metodo  para obtener una instancia del repositorio de paquetes
  PackagesRepository get packagesRepository => PackagesRepository();
  //metodo  para obtener una instancia del repositorio de barcodes
  BarcodesRepository get barcodesPackagesRepository => BarcodesRepository();
  //metodo  para obtener una instancia del repositorio de productos de un pedido
  ProductosPedidosRepository get productosPedidosRepository =>
      ProductosPedidosRepository();
  //metodo  para obtener una instancia del repositorio de batchs para packing
  BatchPackingRepository get batchPackingRepository => BatchPackingRepository();
  //metodo  para obtener una instancia del repositorio de productos de entradas de recepcion
  ProductsEntradaRepository get productEntradaRepository =>
      ProductsEntradaRepository();
  //metodo  para obtener una instancia del repositorio  de entradas de recepcion
  EntradasRepository get entradasRepository => EntradasRepository();
  //metodo  para obtener una instancia del repositorio  de transferencias
  TransferenciaRepository get transferenciaRepository =>
      TransferenciaRepository();
  //metodo  para obtener una instancia del repositorio  de prodcutos de una transferencia
  ProductTransferenciaRepository get productTransferenciaRepository =>
      ProductTransferenciaRepository();
  //metodo  para obtener una instancia del repositorio  de ubicaciones
  UbicacionesRepository get ubicacionesRepository => UbicacionesRepository();

  //metodo  para obtener una instancia del repositorio  de barcodes de inventario
  BarcodesInventarioRepository get barcodesInventarioRepository =>
      BarcodesInventarioRepository();

  //metodo  para obtener una instancia del repositorio  de productos de inventario
  ProductInventarioRepository get productoInventarioRepository =>
      ProductInventarioRepository();

  WarehouseRepository get warehouseRepository => WarehouseRepository();

  Future<Database> getDatabaseInstance() async {
    if (_database != null) {
      return _database!; // Si la base de datos ya está abierta, retornarla
    }
    _database = await initDB(); // Intenta abrir la base de datos
    return _database!;
  }

  //Todo: Métodos para batchs_products

  Future<void> insertBatchProducts(
      List<ProductsBatch> productsBatchList) async {
    try {
      final db = await getDatabaseInstance();

      // Inicia la transacción
      await db!.transaction((txn) async {
        for (var productBatch in productsBatchList) {
          // Realizamos la consulta para verificar si ya existe el producto
          final List<Map<String, dynamic>> existingProduct = await txn.query(
            'tblbatch_products',
            where: 'id_product = ? AND batch_id =? AND id_move = ?',
            whereArgs: [
              productBatch.idProduct,
              productBatch.batchId,
              productBatch.idMove
            ],
          );

          if (existingProduct.isNotEmpty) {
            // Si el producto ya existe, lo actualizamos
            await txn.update(
              'tblbatch_products',
              {
                "id_product": productBatch.idProduct,
                "batch_id": productBatch.batchId,
                "location_id": productBatch.locationId?[1],
                "expire_date": productBatch.expireDate == false
                    ? ""
                    : productBatch.expireDate,
                "lot_id":
                    productBatch.lotId == "" ? "" : productBatch.lotId?[1],
                "lote_id": productBatch.loteId,
                "rimoval_priority": productBatch.rimovalPriority,
                "id_move": productBatch.idMove,
                "barcode_location_dest":
                    productBatch.barcodeLocationDest == false
                        ? ""
                        : productBatch.barcodeLocationDest,
                "barcode_location": productBatch.barcodeLocation == false
                    ? ""
                    : productBatch.barcodeLocation,
                "location_dest_id": productBatch.locationDestId?[1],
                "id_location_dest": productBatch.locationDestId?[0],
                "quantity": productBatch.quantity,
                "unidades": productBatch.unidades,
                "muelle_id": productBatch.locationDestId?[0],
                "barcode":
                    productBatch.barcode == false ? "" : productBatch.barcode,
                "weight": productBatch.weigth,
              },
              where: 'id_product = ? AND batch_id = ? AND id_move = ?',
              whereArgs: [
                productBatch.idProduct,
                productBatch.batchId,
                productBatch.idMove
              ],
            );
          } else {
            // Si el producto no existe, insertamos un nuevo registro
            await txn.insert(
              'tblbatch_products',
              {
                "id_product": productBatch.idProduct,
                "batch_id": productBatch.batchId,
                "expire_date": productBatch.expireDate == false
                    ? ""
                    : productBatch.expireDate,
                "product_id":
                    productBatch.productId?[1], // Usar el valor correcto
                "location_id": productBatch.locationId?[1],
                "lot_id":
                    productBatch.lotId == "" ? "" : productBatch.lotId?[1],
                "rimoval_priority": productBatch.rimovalPriority,

                "barcode_location_dest":
                    productBatch.barcodeLocationDest == false
                        ? ""
                        : productBatch.barcodeLocationDest,
                "barcode_location": productBatch.barcodeLocation == false
                    ? ""
                    : productBatch.barcodeLocation,
                "lote_id": productBatch.loteId,
                "id_move": productBatch.idMove,
                "location_dest_id": productBatch.locationDestId?[1],
                "id_location_dest": productBatch.locationDestId?[0],
                "quantity": productBatch.quantity,
                "unidades": productBatch.unidades,
                "muelle_id": productBatch.locationDestId?[0],
                "barcode":
                    productBatch.barcode == false ? "" : productBatch.barcode,
                "weight": productBatch.weigth,
              },
              conflictAlgorithm: ConflictAlgorithm
                  .replace, // Reemplaza si hay conflicto en la clave primaria
            );
          }
        }
      });
    } catch (e, s) {
      print('Error insertBatchProducts: $e => $s');
    }
  }

  //metodo para traer un producto de un batch de la tabla tblbatch_products
  Future<ProductsBatch?> getProductBatch(
      int batchId, int productId, int idMove) async {
    final db = await getDatabaseInstance();
    final List<Map<String, dynamic>> maps = await db!.query(
      'tblbatch_products',
      where: 'batch_id = ? AND id_product = ? AND id_move = ?',
      whereArgs: [batchId, productId, idMove],
    );

    if (maps.isNotEmpty) {
      return ProductsBatch.fromMap(maps.first);
    }
    return null;
  }

  //* Obtener todos los productos de tblbatch_products
  Future<List<ProductsBatch>> getProducts() async {
    final db = await getDatabaseInstance();
    final List<Map<String, dynamic>> maps =
        await db!.query('tblbatch_products');
    return maps.map((map) => ProductsBatch.fromMap(map)).toList();
  }

  //* Obtener un batch con sus productos
  Future<BatchWithProducts?> getBatchWithProducts(int batchId) async {
    try {
      final db = await getDatabaseInstance();
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

  Future<void> deleteAdmin() async {
    delePicking();
    delePacking();
    deleRecepcion();
    deleTrasnferencia();
    deleInventario();
  }

  Future<void> delePicking() async {
    final db = await getDatabaseInstance();
    //picking
    await db.delete(BatchPickingTable.tableName);
    await db.delete('tblbatch_products');
    await db.delete(BarcodesPackagesTable.tableName);
  }

  Future<void> delePacking() async {
    final db = await getDatabaseInstance();
    //packing
    await db.delete(BatchPackingTable.tableName);
    await db.delete(PedidosPackingTable.tableName);
    await db.delete(ProductosPedidosTable.tableName);
    await db.delete(PackagesTable.tableName);
    await db.delete(BarcodesPackagesTable.tableName);
  }

  Future<void> deleRecepcion() async {
    final db = await getDatabaseInstance();
    //recepcion
    await db.delete(ProductRecepcionTable.tableName);
    await db.delete('tbl_entradas_recepcion');
  }

  Future<void> deleInventario() async {
    final db = await getDatabaseInstance();
    //inventario
    await db.delete(ProductInventarioTable.tableName);
    await db.delete(BarcodesInventarioTable.tableName);
  }

  Future<void> deleTrasnferencia() async {
    final db = await getDatabaseInstance();
    //transferencia
    await db.delete(TransferenciaTable.tableName);
    await db.delete(ProductTransferenciaTable.tableName);
  }

  Future<void> deleteBDCloseSession() async {
    final db = await getDatabaseInstance();
    // others
    await db.delete(ConfigurationsTable.tableName);
    await db.delete(NovedadesTable.tableName);
    await db.delete(UbicacionesTable.tableName);
    await db.delete(SubmuellesTable.tableName);

    deleInventario();
    deleTrasnferencia();
    delePacking();
    delePicking();
    deleRecepcion();
    

  }

  //*metodo para actualizar la tabla de productos de un batch
  Future<int?> setFieldTableBatchProducts(int batchId, int productId,
      String field, dynamic setValue, int idMove) async {
    final db = await getDatabaseInstance();
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET $field = $setValue WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    // print("update tblbatch_products ($field): $resUpdate");

    return resUpdate;
  }

  Future<int?> setFieldStringTableBatchProducts(int batchId, int productId,
      String field, dynamic setValue, int idMove) async {
    final db = await getDatabaseInstance();
    final resUpdate = await db!.rawUpdate(
        " UPDATE tblbatch_products SET $field = '$setValue' WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove");
    // print("update tblbatch_products ($field): $resUpdate");

    return resUpdate;
  }

  //obtener el tiempo de inicio de la separacion de la tabla product
  Future<String> getFieldTableProducts(
      int batchId, int productId, int moveId, String field) async {
    try {
      final db = await getDatabaseInstance();
      final res = await db!.rawQuery('''
      SELECT $field FROM tblbatch_products WHERE batch_id = $batchId AND  id_product = $productId AND id_move = $moveId LIMIT 1
    ''');
      if (res.isNotEmpty) {
        String responsefield = res[0]['${field}'].toString();
        return responsefield;
      }
      return "";
    } catch (e, s) {
      print("error getFieldTableProducts: $e => $s");
    }
    return "";
  }

  //todo: Metodos para realizar el picking de un producto

  Future<int?> startStopwatch(
      int batchId, int productId, int moveId, String date) async {
    final db = await getDatabaseInstance();
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatch_products SET time_separate_start = '$date' WHERE batch_id = $batchId AND id_product = $productId AND id_move = $moveId ");
    print("startStopwatch: $resUpdate");
    return resUpdate;
  }

  Future<int?> totalStopwatchProduct(
      int batchId, int productId, int moveId, double time) async {
    final db = await getDatabaseInstance();
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatch_products SET time_separate = $time WHERE batch_id = $batchId AND id_product = $productId AND id_move = $moveId ");
    print("startStopwatch: $resUpdate");
    return resUpdate;
  }

  Future<int?> endStopwatchProduct(
      int batchId, String date, int productId, int moveId) async {
    final db = await getDatabaseInstance();
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatch_products SET time_separate_end = '$date' WHERE batch_id = $batchId AND id_product = $productId AND id_move = $moveId");

    print("endStopwatchProduct: $resUpdate");
    return resUpdate;
  }

  Future<int?> dateTransaccionProduct(
      int batchId, String date, int productId, int moveId) async {
    final db = await getDatabaseInstance();
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatch_products SET fecha_transaccion = '$date' WHERE batch_id = $batchId AND id_product = $productId AND id_move = $moveId");

    print("dateTransaccionProduct: $resUpdate");
    return resUpdate;
  }

  Future<int?> updateNovedad(
    int batchId,
    int productId,
    String novedad,
    int idMove,
  ) async {
    final db = await getDatabaseInstance();
    final resUpdate = await db!.rawUpdate(
        " UPDATE tblbatch_products SET observation = '$novedad' WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove");
    print("updateNovedad: $resUpdate");
    return resUpdate;
  }

  //sumamos la cantidad de productos separados en la tabla de tblbatch
  Future<int?> incrementProductSeparateQty(int batchId) async {
    final db = await getDatabaseInstance();

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
  Future<int?> incremenQtytProductSeparate(
      int batchId, int productId, int idMove, int quantity) async {
    final db = await getDatabaseInstance();
    return await db!.transaction((txn) async {
      // Primero, obtenemos el valor actual de quantity_separate y quantity
      final result = await txn.query(
        'tblbatch_products',
        columns: ['quantity_separate', 'quantity'],
        where: 'batch_id = ? AND id_product = ? AND id_move = ?',
        whereArgs: [
          batchId,
          productId,
          idMove
        ], // Usamos whereArgs para los parámetros
      );

      if (result.isNotEmpty) {
        // Extraemos los valores actuales
        int currentQtySeparate =
            (result.first['quantity_separate'] as int?) ?? 0;
        int currentQty = (result.first['quantity'] as int?) ?? 0;

        // Incrementamos la cantidad de quantity_separate
        int newQtySeparate = currentQtySeparate + quantity;

        // Validamos que quantity_separate no sea mayor que quantity
        if (newQtySeparate > currentQty) {
          newQtySeparate = currentQty; // Si es mayor, lo igualamos a quantity
        }

        // Actualizamos la tabla
        return await txn.update(
          'tblbatch_products',
          {'quantity_separate': newQtySeparate},
          where: 'batch_id = ? AND id_product = ? AND id_move = ?',
          whereArgs: [
            batchId,
            productId,
            idMove
          ], // Usamos whereArgs para los parámetros
        );
      }

      return null; // No se encontró el batch con el batchId proporcionado
    });
  }

  //actualozar el index de la lista de productos

  Future<List> getProductBacth(
    int batchId,
    int productId,
  ) async {
    final db = await getDatabaseInstance();

    final res = await db!.rawQuery('''
      SELECT * FROM tblbatch_products WHERE batch_id = $batchId AND id_product = $productId  LIMIT 1
    ''');
    return res;
  }

  Future<List> getBacth(
    int batchId,
  ) async {
    final db = await getDatabaseInstance();

    final res = await db!.rawQuery('''
      SELECT * FROM tblbatchs WHERE id = $batchId   LIMIT 1
    ''');
    return res;
  }
}
