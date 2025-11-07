// ignore_for_file: avoid_print, depend_on_referenced_packages, unnecessary_string_interpolations, unnecessary_brace_in_string_interps, unrelated_type_equality_checks, unnecessary_null_comparison, prefer_conditional_assignment

import 'package:wms_app/src/presentation/providers/db/conteo/tbl_categories_orden_conteo/categories_orden_repository.dart';
import 'package:wms_app/src/presentation/providers/db/conteo/tbl_categories_orden_conteo/categories_orden_table.dart';
import 'package:wms_app/src/presentation/providers/db/conteo/tbl_ordenes/orden_repository.dart';
import 'package:wms_app/src/presentation/providers/db/conteo/tbl_ordenes/orden_table.dart';
import 'package:wms_app/src/presentation/providers/db/conteo/tbl_products_ordenes_conteo/product_orden_conteo_repository.dart';
import 'package:wms_app/src/presentation/providers/db/conteo/tbl_products_ordenes_conteo/product_orden_conteo_table.dart';
import 'package:wms_app/src/presentation/providers/db/conteo/tbl_ubicaciones_orden_conteo/ubicaciones_conteo_repository.dart';
import 'package:wms_app/src/presentation/providers/db/conteo/tbl_ubicaciones_orden_conteo/ubicaciones_conteo_table.dart';
import 'package:wms_app/src/presentation/providers/db/devoluciones/tbl_product/product_devolucion_repository.dart';
import 'package:wms_app/src/presentation/providers/db/devoluciones/tbl_product/product_devolucion_table.dart';
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
import 'package:wms_app/src/presentation/providers/db/packing/packing_consolidade/tbl_batchs_packing_consolidate/batch_packing_repository.dart';
import 'package:wms_app/src/presentation/providers/db/packing/packing_consolidade/tbl_batchs_packing_consolidate/batch_table.dart';
import 'package:wms_app/src/presentation/providers/db/packing/packing_consolidade/tbl_pedidos_pack_consolidate/pedidos_pack_repository.dart';
import 'package:wms_app/src/presentation/providers/db/packing/packing_consolidade/tbl_pedidos_pack_consolidate/pedidos_pack_table.dart';
import 'package:wms_app/src/presentation/providers/db/packing/packing_pedido/tbl_packing_pedido/packing_pedido_repository.dart';
import 'package:wms_app/src/presentation/providers/db/packing/packing_pedido/tbl_packing_pedido/packing_pedido_table.dart';
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
import 'package:wms_app/src/presentation/providers/db/others/tbl_doc_origin/doc_origin_repository.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_doc_origin/doc_origin_table.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_pick/picking_pick_repository.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_pick/picking_pick_table.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_pick_products/pick_products_repository.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_pick_products/pick_products_table.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_submuelles/submuelles_repository.dart';
import 'package:wms_app/src/presentation/providers/db/picking/tbl_submuelles/submuelles_table.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_urlrecientes/urlrecientes_repository.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_urlrecientes/urlrecientes_table.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_entradas/entradas_repository.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_entradas/entradas_table.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_entradas_batch/entrada_batch_repository.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_entradas_batch/entrada_batch_table.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_product_entrada/product_entrada_repository.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_product_entrada/product_entrada_table.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_product_entrada_batch/product_entrada_batch_table.dart';
import 'package:wms_app/src/presentation/providers/db/recepcion/entradas/tbl_product_entrada_batch/product_entrada_repository.dart';
import 'package:wms_app/src/presentation/providers/db/transferencia/create_transfer/tbl_create_transfer_products/product_create_transfer_repository.dart';
import 'package:wms_app/src/presentation/providers/db/transferencia/create_transfer/tbl_create_transfer_products/product_create_transfer_table.dart';
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
      version: 14,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
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
    //table de documentos de origen de picking
    await db.execute(DocOriginTable.createTable());
    //tabla de picking por pick
    await db.execute(PickingPickTable.createTable());
    //tabla de productos por pick
    await db.execute(PickProductsTable.createTable());
    //tabla de recepciones por batch
    await db.execute(EntradaBatchTable.createTable());
    //tabal de productos de recepcion por batch
    await db.execute(ProductRecepcionBatchTable.createTable());
    //tabla de pedidos por packing
    await db.execute(PedidoPackTable.createTable());
    //tabla de prductos de una devolucion
    await db.execute(ProductDevolucionTable.createTable());
    // tabla de ordenes de conteo
    await db.execute(OrdenTable.createTable());

    //tabla de productos de un conteo
    await db.execute(ProductosOrdenConteoTable.createTable());

    //* tabla de categorias de un conteo
    await db.execute(CategoriasConteoTable.createTable());

    //* tabla de ubicaciones de un conteo
    await db.execute(UbicacionesConteoTable.createTable());

    //*tabla de los productos para crear una transferencia
    await db.execute(ProductCreateTransferTable.createTable());

    //* tabla de productos de un batch packing consolidade
    await db.execute(BatchPackingConsolidateTable.createTable());

    await db.execute(PedidosPackingConsolidateTable.createTable());

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
        origin VARCHAR(255),
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
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Migración para la versión 9
    if (oldVersion < 9) {
      // ✅ Solución: Añade la columna 'origin_type' a la tabla 'tbldoc_origin'
      try {
        await db.execute('''
          ALTER TABLE ${DocOriginTable.tableName}
          ADD COLUMN ${DocOriginTable.columnOriginType} TEXT;
        ''');
        print(
            '✅ Columna ${DocOriginTable.columnOriginType} añadida a ${DocOriginTable.tableName}.');
      } catch (e) {
        print(
            '❌ Error al añadir la columna origin_type, es posible que ya exista.');
      }

      // Aquí también puedes mantener tu migración anterior
      try {
        await db.execute('''
           ALTER TABLE ${ProductosPedidosTable.tableName}
           ADD COLUMN ${ProductosPedidosTable.columnProductCode} TEXT NOT NULL DEFAULT '';
         ''');
        print(
            '✅ Columna product_code añadida a ${ProductosPedidosTable.tableName}.');
      } catch (e) {
        print(
            '❌ Error al añadir la columna product_code, es posible que ya exista.');
      }
    }

    if (oldVersion < 10) {
      print('Migrando la base de datos a la versión 10...');
      try {
        // ✅ Solución: Añade la nueva columna a la tabla OrdenTable
        await db.execute('''
        ALTER TABLE ${OrdenTable.tableName}
        ADD COLUMN ${OrdenTable.columnObservationGeneral} TEXT NOT NULL DEFAULT '';
      ''');
        print(
            '✅ Columna ${OrdenTable.columnObservationGeneral} añadida a ${OrdenTable.tableName}.');
      } catch (e) {
        print(
            '❌ Error al añadir la columna ${OrdenTable.columnObservationGeneral}, es posible que ya exista.');
      }
    }

    if (oldVersion < 11) {
      print('Migrando la base de datos a la versión 11...');
      try {
        // ✅ Solución: Añade la nueva columna a la tabla PickProductsTable
        await db.execute('''
        ALTER TABLE ${PickProductsTable.tableName}
        ADD COLUMN ${PickProductsTable.columnProductTracking} TEXT NOT NULL DEFAULT '';
      ''');
        print(
            '✅ Columna ${PickProductsTable.columnProductTracking} añadida a ${PickProductsTable.tableName}.');
      } catch (e) {
        print(
            '❌ Error al añadir la columna ${PickProductsTable.columnProductTracking}, es posible que ya exista.');
      }
    }


    if(oldVersion <12){
      //solucion para cuando la version no tiene la tabla de productos para crear transferencia
      print('Migrando la base de datos a la versión 12...');
      try {
        // Crear la tabla ProductCreateTransferTable si no existe
        await db.execute(ProductCreateTransferTable.createTable());
        print(
            '✅ Tabla ${ProductCreateTransferTable.tableName} creada correctamente.');
      } catch (e) {
        print(
            '❌ Error al crear la tabla ${ProductCreateTransferTable.tableName}, es posible que ya exista.');
      }
    }

    if(oldVersion <13){
      //solucion para cuando la version no tiene la tabla de batch packing consolidade
      print('Migrando la base de datos a la versión 13...');
      try {
        // Crear la tabla BatchPackingConsolidateTable si no existe
        await db.execute(BatchPackingConsolidateTable.createTable());
        //crear la tabla de pedidos de packing consolidade
        await db.execute(PedidosPackingConsolidateTable.createTable());
       
        print(
            '✅ Tabla ${BatchPackingConsolidateTable.tableName} creada correctamente.');
        print(
            '✅ Tabla ${PedidosPackingConsolidateTable.tableName} creada correctamente.');
      } catch (e) {
        print(
            '❌ Error al crear la tabla ${BatchPackingConsolidateTable.tableName}, es posible que ya exista.');
      }
    }


    if(oldVersion <14){
      //solucion para cuando la version no tiene la tabla de maestra de productos de inventario
      print('Migrando la base de datos a la versión 14...');
      try {
        // Añadir la columna 'category' a la tabla ProductInventarioTable
        await db.execute('''
          ALTER TABLE ${ProductInventarioTable.tableName}
          ADD COLUMN ${ProductInventarioTable.columnCategory} TEXT;
        ''');
        print(
            '✅ Columna ${ProductInventarioTable.columnCategory} añadida a ${ProductInventarioTable.tableName}.');
      } catch (e) {
        print(
            '❌ Error al añadir la columna ${ProductInventarioTable.columnCategory}, es posible que ya exista.');
      }
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

  DocOriginRepository get docOriginRepository => DocOriginRepository();

  //metodo  para obtener una instancia del repositorio  de picking por pick
  PickingPickRepository get pickRepository => PickingPickRepository();

  PickProductsRepository get pickProductsRepository => PickProductsRepository();
  //metodo para obtener una instancia del repositorio de entrada por batch
  EntradaBatchRepository get entradaBatchRepository => EntradaBatchRepository();
  //metodo pra obtener una instancia del repositorio de productos de recepcion por batch
  ProductsEntradaBatchRepository get productsEntradaBatchRepository =>
      ProductsEntradaBatchRepository();

//metodo para onteer una instancia del repositorio de packig por pedido
  PedidoPackRepository get pedidoPackRepository =>
      PedidoPackRepository(_instance);

  ProductDevolucionRepository get devolucionRepository =>
      ProductDevolucionRepository(_instance);

  OrdenConteoRepository get ordenRepository => OrdenConteoRepository();

  ProductoOrdenConteoRepository get productoOrdenConteoRepository =>
      ProductoOrdenConteoRepository();

  UbicacionesConteoRepository get ubicacionesConteoRepository =>
      UbicacionesConteoRepository();

  CategoriasConteoRepository get categoriasConteoRepository =>
      CategoriasConteoRepository();

  //repositorio de productos para crear transferencia
  ProductCreateTransferRepository get productCreateTransferRepository =>
      ProductCreateTransferRepository();

  //repositorio de pedidos de packing consolidade
  PedidosPackingConsolidateRepository get pedidosPackingConsolidateRepository =>
      PedidosPackingConsolidateRepository();

  //repositorio de batchs de packing consolidade
  BatchPackingConsolidateRepository get batchPackingConsolidateRepository =>
      BatchPackingConsolidateRepository();

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
      if (db == null) return;

      await db.transaction((txn) async {
        final batch = txn.batch();

        // Obtener todos los registros existentes una sola vez
        final existing = await txn.query('tblbatch_products');
        final existingSet = existing
            .map((e) => '${e['id_product']}_${e['batch_id']}_${e['id_move']}')
            .toSet();

        for (var product in productsBatchList) {
          final key =
              '${product.idProduct}_${product.batchId}_${product.idMove}';

          final data = {
            "id_product": product.idProduct,
            "batch_id": product.batchId,
            "expire_date":
                product.expireDate == false ? "" : product.expireDate,
            "product_id": product.productId?[1],
            "location_id": product.locationId?[1],
            "lot_id": product.lotId == "" ? "" : product.lotId?[1],
            "rimoval_priority": product.rimovalPriority,
            "barcode_location_dest": product.barcodeLocationDest == false
                ? ""
                : product.barcodeLocationDest,
            "barcode_location":
                product.barcodeLocation == false ? "" : product.barcodeLocation,
            "lote_id": product.loteId,
            "id_move": product.idMove,
            "location_dest_id": product.locationDestId?[1],
            "id_location_dest": product.locationDestId?[0],
            "quantity": product.quantity,
            "unidades": product.unidades,
            "muelle_id": product.locationDestId?[0],
            "barcode": product.barcode == false ? "" : product.barcode,
            "weight": product.weigth,
            "origin": product.origin,
            "is_separate": product.isSeparate.toString(),
            //si el producto esta separado en la hora de insertarlo quiere decir que ya esta en el wms (odoo)
            "is_send_odoo": product.isSeparate == 0 ? null : product.isSeparate,
            "time_separate": _parseDurationToSeconds(product.timeSeparate),

            "observation":
                product.observation == false ? "" : product.observation,
            "quantity_separate": product.quantitySeparate,
            'fecha_transaccion': product.fechaTransaccion == false
                ? ""
                : product.fechaTransaccion,
          };

          if (existingSet.contains(key)) {
            // Actualizar si ya existe
            batch.update(
              'tblbatch_products',
              data,
              where: 'id_product = ? AND batch_id = ? AND id_move = ?',
              whereArgs: [
                product.idProduct,
                product.batchId,
                product.idMove,
              ],
            );
          } else {
            // Insertar si no existe
            batch.insert(
              'tblbatch_products',
              data,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        await batch.commit(noResult: true); // Mejor rendimiento
      });
    } catch (e, s) {
      print('Error insertBatchProducts: $e => $s');
    }
  }

  double? _parseDurationToSeconds(dynamic time) {
    try {
      if (time is String && time.contains(':')) {
        final parts = time.split(':').map(int.parse).toList();
        if (parts.length == 3) {
          final duration = Duration(
            hours: parts[0],
            minutes: parts[1],
            seconds: parts[2],
          );
          return duration.inSeconds.toDouble();
        }
      }
    } catch (e) {
      print('Error parsing time_separate: $e');
    }
    return null; // Si no es válido, devuelve null
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
  //* Obtener un batch con sus productos

  //Todo: Eliminar todos los registros

  //metodo para eliminar lo de conteo
  Future<void> deleConteo() async {
    final db = await getDatabaseInstance();
    await db.delete(OrdenTable.tableName);
    await db.delete(ProductosOrdenConteoTable.tableName);
    await db.delete(CategoriasConteoTable.tableName);
    await db.delete(UbicacionesConteoTable.tableName);
    await deleBarcodes("orden");
  }

  Future<void> delePicking() async {
    final db = await getDatabaseInstance();
    await db.delete(BatchPickingTable.tableName);
    await db.delete('tblbatch_products');
    await db.delete(BarcodesPackagesTable.tableName);
    await db.delete(SubmuellesTable.tableName);
    await deleOrigin("picking");
    // await db.delete(DocOriginTable.tableName);
  }

  Future<void> delePick(String typPick) async {
    final db = await getDatabaseInstance();
    await db.delete(PickingPickTable.tableName,
        where: '${PickingPickTable.columnTypePick} = ?', whereArgs: [typPick]);
    await db.delete(PickProductsTable.tableName,
        where: '${PickProductsTable.columnTypePick} = ?', whereArgs: [typPick]);
    await deleBarcodes(typPick);
  }

  Future<void> delePickAll() async {
    final db = await getDatabaseInstance();
    await db.delete(PickingPickTable.tableName);
    await db.delete(PickProductsTable.tableName);
    await deleBarcodes("pick");
    await deleBarcodes("picking");
  }

  Future<void> deleReceptionBatch() async {
    final db = await getDatabaseInstance();
    await db.delete(EntradaBatchTable.tableName);
    await db.delete(ProductRecepcionBatchTable.tableName);
    await deleBarcodes("reception-batch");
  }

  Future<void> delePacking(String type) async {
    final db = await getDatabaseInstance();
    if (type == "packing-batch") {
      await deleOrigin("packing");
      await db.delete(BatchPackingTable.tableName);
    }
    if (type == "packing-pack") {
      await db.delete(PedidoPackTable.tableName);
    }
    if (type == "packing-batch-consolidate-") {
      await db.delete(BatchPackingConsolidateTable.tableName);
      await db.delete(PedidosPackingConsolidateTable.tableName);
    }



    await db.delete(PedidosPackingTable.tableName,
        where: '${PedidosPackingTable.columnType} = ?', whereArgs: [type]);
    await db.delete(ProductosPedidosTable.tableName,
        where: '${ProductosPedidosTable.columnType} = ?', whereArgs: [type]);
    await db.delete(PackagesTable.tableName,
        where: '${PackagesTable.columnType} = ?', whereArgs: [type]);
    await deleBarcodes(type);
  }

  Future<void> delePackingAll() async {
    final db = await getDatabaseInstance();
    await db.delete(BatchPackingTable.tableName);
    await db.delete(PedidosPackingTable.tableName);
    await db.delete(ProductosPedidosTable.tableName);
    await db.delete(PackagesTable.tableName);
    await deleBarcodes("packing-batch");
    await deleBarcodes("packing");
  }

  Future<void> deleRecepcion(String type) async {
    final db = await getDatabaseInstance();
    await db.delete(
      ProductRecepcionTable.tableName,
      where: '${ProductRecepcionTable.columnType} = ?',
      whereArgs: [type],
    );
    await db.delete(
      EntradasRepeccionTable.tableName,
      where: '${EntradasRepeccionTable.columnType} = ?',
      whereArgs: [type],
    );
    await deleBarcodes("reception");
  }

  Future<void> deleInventario() async {
    final db = await getDatabaseInstance();
    await db.delete(ProductInventarioTable.tableName);
    await db.delete(BarcodesInventarioTable.tableName);
  }

  Future<void> deleTrasnferencia(String type) async {
    final db = await getDatabaseInstance();
    //transferencia
    await db.delete(
      TransferenciaTable.tableName,
      where: '${TransferenciaTable.columnType} = ?',
      whereArgs: [type],
    );
    await db.delete(
      ProductTransferenciaTable.tableName,
      where: '${ProductTransferenciaTable.columnType} = ?',
      whereArgs: [type],
    );
    await deleBarcodes("transfer");
  }

  Future<void> deleAllTrasnferencia() async {
    final db = await getDatabaseInstance();
    //transferencia
    await db.delete(
      TransferenciaTable.tableName,
    );
    await db.delete(
      ProductTransferenciaTable.tableName,
    );
    await deleBarcodes("transfer");
  }

  Future<void> deleOthers() async {
    final db = await getDatabaseInstance();
    await db.delete(ConfigurationsTable.tableName);
    await db.delete(NovedadesTable.tableName);
    await db.delete(UbicacionesTable.tableName);
    await db.delete(WarehouseTable.tableName);
  }

  Future<void> deleBarcodes(String barcodeType) async {
    final db = await getDatabaseInstance();
    //eliminamos los codigos de barras que tienen el mismo tipo
    await db.delete(BarcodesPackagesTable.tableName,
        where: '${BarcodesPackagesTable.columnBarcodeType} = ?',
        whereArgs: [barcodeType]);
  }

  Future<void> deleOrigin(String originType) async {
    final db = await getDatabaseInstance();
    //eliminamos los codigos de barras que tienen el mismo tipo
    await db.delete(DocOriginTable.tableName,
        where: '${DocOriginTable.columnOriginType} = ?',
        whereArgs: [originType]);
  }

  Future<void> deleAllBarcodes() async {
    final db = await getDatabaseInstance();
    //eliminamos todos los codigos de barras
    await db.delete(BarcodesPackagesTable.tableName);
  }

  Future<void> deleAllRecepcion() async {
    final db = await getDatabaseInstance();
    await db.delete(
      ProductRecepcionTable.tableName,
    );
    await db.delete(
      EntradasRepeccionTable.tableName,
    );
    await deleBarcodes("reception");
  }

  Future<void> deleteBDCloseSession() async {
    await delePicking();
    await delePickAll();
    await delePackingAll();
    await deleAllRecepcion();
    await deleAllTrasnferencia();
    await deleInventario();
    await deleOthers();
    await deleReceptionBatch();
    await deleAllBarcodes();
    await deleConteo();
  }

  //*metodo para actualizar la tabla de productos de un batch
  Future<int?> setFieldTableBatchProducts(int batchId, int productId,
      String field, dynamic setValue, int idMove) async {
    final db = await getDatabaseInstance();
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET $field = $setValue WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("update tblbatch_products ($field): $resUpdate");

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
        dynamic currentQty = (result.first['product_separate_qty']) ?? 0;

        // Incrementamos la cantidad
        dynamic newQty = currentQty + 1;

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
      int batchId, int productId, int idMove, dynamic quantity) async {
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
        dynamic currentQtySeparate = (result.first['quantity_separate']) ?? 0;
        dynamic currentQty = (result.first['quantity']) ?? 0;

        // Incrementamos la cantidad de quantity_separate
        dynamic newQtySeparate = currentQtySeparate + quantity;

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
