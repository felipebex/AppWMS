// ignore_for_file: avoid_print, depend_on_referenced_packages, unnecessary_string_interpolations, unnecessary_brace_in_string_interps, unrelated_type_equality_checks

import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

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
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
        singleInstance: true);
  }

  Future<void> _createDB(Database db, int version) async {
    // Crear tablas

    //todo PICKING

    await db.execute('''
      CREATE TABLE tblbatchs (
        id INTEGER PRIMARY KEY,
        name VARCHAR(255),
        scheduled_date VARCHAR(255),
        picking_type_id VARCHAR(255),
        muelle VARCHAR(255),
        state VARCHAR(255),
        user_id VARCHAR(255),
        user_name VARCHAR(255),
        is_wave TEXT,
        is_separate INTEGER, 
        is_selected INTEGER, 
        product_separate_qty INTEGER,
        product_qty INTEGER,
        index_list INTEGER,
        time_separate_total DECIMAL(10,2),

        time_separate_start VARCHAR(255),
        time_separate_end VARCHAR(255),
        is_send_oddo INTEGER,
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
        barcode TEXT,
        quantity_separate INTEGER,
        is_selected INTEGER,
        is_separate INTEGER,

        time_separate DECIMAL(10,2),
        time_separate_start VARCHAR(255),
        time_separate_end VARCHAR(255),

        observation TEXT,
        unidades TEXT,
        weight INTEGER,

        is_location_is_ok INTEGER,
        product_is_ok INTEGER,
        is_quantity_is_ok INTEGER,
        location_dest_is_ok INTEGER,
        is_send_odoo INTEGER,
        is_send_odoo_date VARCHAR(255),
        FOREIGN KEY (batch_id) REFERENCES tblbatchs (id)
      )
    ''');

    //todo PACKING

    await db.execute('''
      CREATE TABLE tblbatchs_packing (

        id INTEGER PRIMARY KEY,
        name VARCHAR(255),
        scheduled_date VARCHAR(255),
        picking_type_id VARCHAR(255),
        state VARCHAR(255),
        user_id INTEGER,

        is_separate INTEGER, 
        is_selected INTEGER, 
        is_packing INTEGER,
        pedido_separate_qty INTEGER,
        index_list INTEGER,

        time_separate_total DECIMAL(10,2),
        time_separate_start VARCHAR(255),
        time_separate_end VARCHAR(255)

      )
    ''');

    //todo tabla de empaque

    await db.execute('''
      CREATE TABLE tblpackages (
        id INTEGER PRIMARY KEY,
        name VARCHAR(255),
        batch_id INTEGER,
        pedido_id INTEGER,
        cantidad_productos INTEGER,
        is_sticker INTEGER,
        FOREIGN KEY (pedido_id) REFERENCES tblpedidos_packing (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE tblpedidos_packing (

        id INTEGER PRIMARY KEY,
        batch_id INTEGER,
        name VARCHAR(255),
        referencia VARCHAR(255),
        fecha VARCHAR(255),
        contacto VARCHAR(255),
        tipo_operacion VARCHAR(255),
        cantidad_productos INTEGER,
        numero_paquetes INTEGER,
        is_selected INTEGER,
        is_packing INTEGER,
        is_terminate INTEGER,
        FOREIGN KEY (batch_id) REFERENCES tblbatchs_packing (id)
      )
    ''');

    await db.execute('''
    CREATE TABLE tblproductos_pedidos (

      id INTEGER PRIMARY KEY,
      product_id INTEGER,
      batch_id INTEGER,
      pedido_id INTEGER,
      id_product TEXT,
      lote_id INTEGER,
      lot_id TEXT,
      location_id TEXT,
      location_dest_id TEXT,
      quantity INTEGER,
      tracking TEXT,
      barcode TEXT,
      weight INTEGER,
      unidades TEXT,

      is_selected INTEGER,
      is_separate INTEGER,
      quantity_separate INTEGER,
      is_certificate INTEGER,

      is_location_is_ok INTEGER,
      product_is_ok INTEGER,
      is_quantity_is_ok INTEGER,
      location_dest_is_ok INTEGER,
      observation TEXT,
      id_package INTEGER,
      is_packing INTEGER,
      FOREIGN KEY (id_package) REFERENCES tblpackages (id)
      FOREIGN KEY (pedido_id) REFERENCES tblpedidos_packing (id)
    )
  ''');

    //tabla de barcodes de los productos
    await db.execute('''
    CREATE TABLE tblbarcodes_packages (
      id INTEGER PRIMARY KEY,
      batch_id INTEGER,
      id_move INTEGER,
      id_product INTEGER,
      barcode TEXT,
      cantidad DECIMAL(10,2),
      FOREIGN KEY (batch_id) REFERENCES tblbatchs (id)
    )
    ''');

    //tabla de configuracion del usuario
    await db.execute('''
    CREATE TABLE tblconfigurations(
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    name TEXT,
    last_name TEXT,
    email TEXT,
    rol TEXT,
    location_picking_manual INTEGER,
    manual_product_selection INTEGER,
    manual_quantity INTEGER,
    manual_spring_selection INTEGER,
    show_detalles_picking INTEGER,
    show_next_locations_in_details INTEGER
    )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE tblbatchs ADD COLUMN is_wave VARCHAR(255)");
    }
  }

  Future<void> insertConfiguration(
      Configurations configuration, int userId) async {
    try {
      final db = await database;
      await db!.transaction((txn) async {
        // Verificar si la configuración ya existe
        final List<Map<String, dynamic>> existingConfiguration =
            await txn.query(
          'tblconfigurations',
          where: 'user_id = ?',
          whereArgs: [userId],
        );

        // Convertir valores booleanos a enteros (0 o 1)
        Map<String, dynamic> configurationData = {
          "user_id": userId,
          "name": configuration.data?.result?.name,
          "last_name": configuration.data?.result?.lastName,
          "email": configuration.data?.result?.email,
          "rol": configuration.data?.result?.rol,
          "location_picking_manual":
              configuration.data?.result?.locationPickingManual == true ? 1 : 0,
          "manual_product_selection":
              configuration.data?.result?.manualProductSelection == true
                  ? 1
                  : 0,
          "manual_quantity":
              configuration.data?.result?.manualQuantity == true ? 1 : 0,
          "manual_spring_selection":
              configuration.data?.result?.manualSpringSelection == true ? 1 : 0,
          "show_detalles_picking":
              configuration.data?.result?.showDetallesPicking == true ? 1 : 0,
          "show_next_locations_in_details":
              configuration.data?.result?.showNextLocationsInDetails == true
                  ? 1
                  : 0,
        };

        if (existingConfiguration.isNotEmpty) {
          // Actualizar la configuración
          await txn.update(
            'tblconfigurations',
            configurationData,
            where: 'user_id = ?',
            whereArgs: [userId],
          );
        } else {
          // Insertar nueva configuración
          await txn.insert(
            'tblconfigurations',
            configurationData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      print("Error al insertar configuración: $e");
    }
  }


  //metodo para obtener la configuracion del usuario
  Future<Configurations> getConfiguration(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'tblconfigurations',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

   final config = Configurations(
    data: DataConfig(
      code: 200,
      result: Result(
        name: maps[0]['name'],
        lastName: maps[0]['last_name'],
        email: maps[0]['email'],
        rol: maps[0]['rol'],
        userId: maps[0]['user_id'],
        locationPickingManual: maps[0]['location_picking_manual'] == 1 ? true : false,
        manualProductSelection: maps[0]['manual_product_selection'] == 1 ? true : false,
        manualQuantity: maps[0]['manual_quantity'] == 1 ? true : false,
        manualSpringSelection: maps[0]['manual_spring_selection'] == 1 ? true : false,
        showDetallesPicking: maps[0]['show_detalles_picking'] == 1 ? true : false,
        showNextLocationsInDetails: maps[0]['show_next_locations_in_details'] == 1 ? true : false,
      ),
    ),


   );
    return config;
  }



  //metodo para obtener todos los tblbarcodes_packages de un producto
  Future<List<Barcodes>> getBarcodesProduct(
      int batchId, int productId, int idMove) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'tblbarcodes_packages',
      where: 'batch_id = ? AND id_product = ? AND id_move = ?',
      whereArgs: [batchId, productId, idMove],
    );

    final List<Barcodes> barcodes = maps.map((map) {
      return Barcodes(
        batchId: map['batch_id'],
        idMove: map['id_move'],
        idProduct: map['id_product'],
        barcode: map['barcode'],
        cantidad: map['cantidad'],
      );
    }).toList();
    return barcodes;
  }

  //todo insertar btach de packing
  Future<void> insertBatchPacking(BatchPackingModel batch) async {
    try {
      final db = await database;

      await db!.transaction((txn) async {
        // Verificar si el batch ya existe
        final List<Map<String, dynamic>> existingBatch = await txn.query(
          'tblbatchs_packing',
          where: 'id = ?',
          whereArgs: [batch.id],
        );

        if (existingBatch.isNotEmpty) {
          // Actualizar el batch
          await txn.update(
            'tblbatchs_packing',
            {
              "id": batch.id,
              "name": batch.name,
              "scheduled_date": batch.scheduleddate.toString(),
              "picking_type_id": batch.pickingTypeId,
              "state": batch.state,
              "user_id": batch.userId,
            },
            where: 'id = ?',
            whereArgs: [batch.id],
          );
        } else {
          // Insertar nuevo batch
          await txn.insert(
            'tblbatchs_packing',
            {
              "id": batch.id,
              "name": batch.name,
              "scheduled_date": batch.scheduleddate.toString(),
              "picking_type_id": batch.pickingTypeId,
              "state": batch.state,
              "user_id": batch.userId,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      print("Error al insertar tblbatchs_packing: $e");
    }
  }

  //todo insertar pedidos del btach de packing

  Future<void> insertPedidosBatchPacking(
      List<PedidoPacking> pedidosList) async {
    try {
      final db = await database;

      // Inicia la transacción
      await db!.transaction((txn) async {
        // Recorre la lista de pedidos
        for (var pedido in pedidosList) {
          // Verificar si el pedido ya existe
          final List<Map<String, dynamic>> existingPedido = await txn.query(
            'tblpedidos_packing',
            where: 'id = ?',
            whereArgs: [pedido.id],
          );

          if (existingPedido.isNotEmpty) {
            // Actualizar el pedido si ya existe
            await txn.update(
              'tblpedidos_packing',
              {
                "id": pedido.id,
                "batch_id": pedido.batchId,
                "name": pedido.name,
                "fecha": pedido.fecha.toString(),
                "referencia": pedido.referencia == false
                    ? ""
                    : pedido.referencia, // Si referencia es false, poner ""
                "contacto": pedido
                    .contacto, // Convierte contacto a JSON si es necesario
                "tipo_operacion": pedido.tipoOperacion.toString(),
                "cantidad_productos": pedido.cantidadProductos,
                "numero_paquetes": pedido.numeroPaquetes,
              },
              where: 'id = ?',
              whereArgs: [pedido.id],
            );
          } else {
            // Insertar el pedido si no existe
            await txn.insert(
              'tblpedidos_packing',
              {
                "id": pedido.id,
                "batch_id": pedido.batchId,
                "name": pedido.name,
                "fecha": pedido.fecha.toString(),
                "referencia": pedido.referencia == false
                    ? ""
                    : pedido.referencia, // Si referencia es false, poner ""
                "contacto": pedido
                    .contacto, // Convierte contacto a JSON si es necesario
                "tipo_operacion": pedido.tipoOperacion.toString(),
                "cantidad_productos": pedido.cantidadProductos,
                "numero_paquetes": pedido.numeroPaquetes,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
    } catch (e, s) {
      print("Error al insertar insertPedidosBatchPacking: $e ==> $s");
    }
  }

  Future<void> insertProductosPedidos(List<ListaProducto> productosList) async {
    try {
      final db = await database;

      // Inicia la transacción
      await db!.transaction((txn) async {
        for (var producto in productosList) {
          // Verificar si el producto ya existe
          final List<Map<String, dynamic>> existingProducto = await txn.query(
            'tblproductos_pedidos',
            where: 'product_id = ? AND batch_id = ? AND pedido_id = ?',
            whereArgs: [
              producto.productId,
              producto.batchId,
              producto.pedidoId
            ],
          );

          if (existingProducto.isNotEmpty) {
            // Actualizar el producto si ya existe
            await txn.update(
              'tblproductos_pedidos',
              {
                "product_id": producto.productId,
                "batch_id": producto.batchId,
                "pedido_id": producto.pedidoId,
                "id_product": producto.idProduct?[1],
                "lote_id": producto.loteId,
                "lot_id": producto.lotId == false ? "" : producto.lotId?[1],
                "location_id": producto.locationId?[1],
                "location_dest_id": producto.locationDestId?[1],
                "quantity": producto.quantity,
                "tracking": producto.tracking == false
                    ? ""
                    : producto.tracking, // Si tracking es false, poner ""
                "barcode": producto.barcode == false
                    ? ""
                    : producto.barcode, // Si barcode es false, poner ""
                "weight": producto.weight == false
                    ? 0
                    : producto.weight, // Si weight es false, poner 0
                "unidades": producto.unidades == false
                    ? ""
                    : producto.unidades, // Si unidades es false, poner ""
              },
              where: 'id = ? AND batch_id = ? AND pedido_id = ?',
              whereArgs: [
                producto.productId,
                producto.batchId,
                producto.pedidoId
              ],
            );
          } else {
            // Insertar el producto si no existe
            await txn.insert(
              'tblproductos_pedidos',
              {
                "product_id": producto.productId,
                "batch_id": producto.batchId,
                "pedido_id": producto.pedidoId,
                "id_product": producto.idProduct?[1],
                "lote_id": producto.loteId,
                "lot_id": producto.lotId == false ? "" : producto.lotId?[1],
                "location_id": producto.locationId?[1],
                "location_dest_id": producto.locationDestId?[1],
                "quantity": producto.quantity,
                "tracking": producto.tracking == false
                    ? ""
                    : producto.tracking, // Si tracking es false, poner ""
                "barcode": producto.barcode == false
                    ? ""
                    : producto.barcode, // Si barcode es false, poner ""
                "weight": producto.weight == false
                    ? 0
                    : producto.weight, // Si weight es false, poner 0
                "unidades": producto.unidades == false
                    ? ""
                    : producto.unidades, // Si unidades es false, poner ""
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
    } catch (e, s) {
      print("Error al insertar productos en productos_pedidos: $e ==> $s");
    }
  }

  //todo meotod para insertar paquete

  Future<void> insertPackage(Paquete package) async {
    try {
      final db = await database;

      await db!.transaction((txn) async {
        // Verificar si el batch ya existe
        final List<Map<String, dynamic>> existingPackage = await txn.query(
          'tblpackages',
          where: 'id = ?',
          whereArgs: [package.id],
        );

        if (existingPackage.isNotEmpty) {
          // Actualizar el batch
          final response = await txn.update(
            'tblpackages',
            {
              "id": package.id,
              "name": package.name,
              "batch_id": package.batchId,
              "pedido_id": package.pedidoId,
              "cantidad_productos": package.cantidadProductos,
              "is_sticker": package.isSticker == true ? 1 : 0,
            },
            where: 'id = ?',
            whereArgs: [package.id],
          );
          print("response update package: $response");
        } else {
          // Insertar nuevo batch
          final response = await txn.insert(
            'tblpackages',
            {
              "id": package.id,
              "name": package.name,
              "batch_id": package.batchId,
              "pedido_id": package.pedidoId,
              "cantidad_productos": package.cantidadProductos,
              "is_sticker": package.isSticker == true ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          print("response insert package: $response");
        }
      });
    } catch (e) {
      print("Error al insertar package: $e");
    }
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
              "user_name": batch.userName,
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
              "user_name": batch.userName,
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

  //* Obtener todos los batchs del packing
  Future<List<BatchPackingModel>> getAllBatchsPacking() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db!.query('tblbatchs_packing');

      final List<BatchPackingModel> batchs = maps.map((map) {
        return BatchPackingModel.fromMap(map);
      }).toList();
      return batchs;
    } catch (e, s) {
      print("Error tblbatchs_packing: $e => $s");
    }
    return [];
  }

  //todo metodos para obtener los pedidos de un packing
  Future<List<PedidoPacking>> getPedidosPacking(int batchId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'tblpedidos_packing',
      where: 'batch_id = ?',
      whereArgs: [batchId],
    );

    final List<PedidoPacking> pedidos = maps.map((map) {
      return PedidoPacking.fromMap(map);
    }).toList();
    return pedidos;
  }

  // //todo metodos para obtener los productos de un pedido
  Future<List<PorductoPedido>> getProductosPedido(int pedidoId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'tblproductos_pedidos',
      where: 'pedido_id = ?',
      whereArgs: [pedidoId],
    );

    final List<PorductoPedido> productos = maps.map((map) {
      return PorductoPedido.fromMap(map);
    }).toList();
    return productos;
  }

  //todo metodos para obtener los paquetes de un pedido

  Future<List<Paquete>> getPackagesPedido(int pedidoId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'tblpackages',
      where: 'pedido_id = ?',
      whereArgs: [pedidoId],
    );
    final List<Paquete> productos = maps.map((map) {
      return Paquete(
        id: map['id'],
        name: map['name'],
        batchId: map['batch_id'],
        pedidoId: map['pedido_id'],
        cantidadProductos: map['cantidad_productos'],
        isSticker: map['is_sticker'] == 1 ? true : false,
      );
    }).toList();
    return productos;
  }

  //Todo: Métodos para batchs_products

  Future<void> insertBatchProducts(
      List<ProductsBatch> productsBatchList) async {
    try {
      final db = await database;

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
                "lot_id": productBatch.lotId?[1],
                "lote_id": productBatch.loteId,
                "id_move": productBatch.idMove,
                "location_dest_id": productBatch.locationDestId?[1],
                "quantity": productBatch.quantity,
                "unidades": productBatch.unidades,
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
                "product_id":
                    productBatch.productId?[1], // Usar el valor correcto
                "location_id": productBatch.locationId?[1],
                "lot_id": productBatch.lotId?[1],
                "lote_id": productBatch.loteId,
                "id_move": productBatch.idMove,
                "location_dest_id": productBatch.locationDestId?[1],
                "quantity": productBatch.quantity,
                "unidades": productBatch.unidades,
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

  ///todo insertar los barcodes de los productos
  Future<void> insertBarcodesPackageProduct(List<Barcodes> barcodesList) async {
    try {
      final db = await database;

      // Inicia la transacción
      await db!.transaction((txn) async {
        for (var barcode in barcodesList) {
          // Realizamos la consulta para verificar si ya existe el producto
          final List<Map<String, dynamic>> existingProduct = await txn.query(
            'tblbarcodes_packages',
            where: 'id_product = ? AND batch_id =? AND id_move = ?',
            whereArgs: [barcode.idProduct, barcode.batchId, barcode.idMove],
          );

          if (existingProduct.isNotEmpty) {
            // Si el producto ya existe, lo actualizamos
            await txn.update(
              'tblbarcodes_packages',
              {
                "id_product": barcode.idProduct,
                "batch_id": barcode.batchId,
                "id_move": barcode.idMove,
                "barcode": barcode.barcode == false ? "" : barcode.barcode,
                "cantidad": barcode.cantidad,
              },
              where: 'id_product = ? AND batch_id = ? AND id_move = ?',
              whereArgs: [barcode.idProduct, barcode.batchId, barcode.idMove],
            );
          } else {
            // Si el producto no existe, insertamos un nuevo registro
            await txn.insert(
              'tblbarcodes_packages',
              {
                "id_product": barcode.idProduct,
                "batch_id": barcode.batchId,
                "id_move": barcode.idMove,
                "barcode": barcode.barcode == false ? "" : barcode.barcode,
                "cantidad": barcode.cantidad,
              },
              conflictAlgorithm: ConflictAlgorithm
                  .replace, // Reemplaza si hay conflicto en la clave primaria
            );
          }
        }
      });
    } catch (e, s) {
      print('Error insertBarcodesPackageProduct: $e => $s');
    }
  }

  //metodo para traer un producto de un batch de la tabla tblbatch_products
  Future<ProductsBatch?> getProductBatch(
      int batchId, int productId, int idMove) async {
    final db = await database;
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
    await db?.delete('tblbatchs');
    await db?.delete('tblbatch_products');
    await db?.delete('tblbatchs_packing');
    await db?.delete('tblpedidos_packing');
    await db?.delete('tblproductos_pedidos');
    await db?.delete('tblpackages');
    await db?.delete('tblbarcodes_packages');
    await db?.delete('tblconfigurations');
  }

  //todo: Metodos para actualizar los campos de las tablas

  //*metodo para actualizar la tabla de productos de un pedido
  Future<int?> setFieldTableProductosPedidos(
      int pedidoId, int productId, String field, dynamic setValue) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblproductos_pedidos SET $field = $setValue WHERE product_id = $productId AND pedido_id = $pedidoId');
    print("update tblproductos_pedidos ($field): $resUpdate");

    return resUpdate;
  }

  //*metodo para actualizar la tabla de pedidos de un batch
  Future<int?> setFieldTablePedidosPacking(
      int batchId, int pedidoId, String field, dynamic setValue) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblpedidos_packing SET $field = $setValue WHERE id = $pedidoId AND batch_id = $batchId');
    print("update tblpedidos_packing ($field): $resUpdate");

    return resUpdate;
  }

  //*metodo para actualizar la tabla de batch de un packing
  Future<int?> setFieldTableBatchPacking(
      int batchId, String field, dynamic setValue) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatchs_packing SET $field = $setValue WHERE id = $batchId');
    print("update tblbatchs_packing ($field): $resUpdate");

    return resUpdate;
  }

  //*metodo para actualizar la tabla tblbatchs
  Future<int?> setFieldTableBatch(
      int batchId, String field, dynamic setValue) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatchs SET $field = $setValue WHERE id = $batchId');
    print("update tblbatchs ($field): $resUpdate");

    return resUpdate;
  }

  //*metodo para actualizar la tabla de productos de un batch
  Future<int?> setFieldTableBatchProducts(int batchId, int productId,
      String field, dynamic setValue, int idMove) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        ' UPDATE tblbatch_products SET $field = $setValue WHERE batch_id = $batchId AND id_product = $productId AND id_move = $idMove');
    print("update tblbatch_products ($field): $resUpdate");

    return resUpdate;
  }

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
      SELECT $field FROM tblbatch_products WHERE batch_id = $batchId AND  id_product = $productId AND id_move = $moveId LIMIT 1
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

  //todo: Metodos para realizar el picking de un producto

  Future<int?> startStopwatch(
      int batchId, int productId, int moveId, String date) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatch_products SET time_separate_start = '$date' WHERE batch_id = $batchId AND id_product = $productId AND id_move = $moveId ");
    print("startStopwatch: $resUpdate");
    return resUpdate;
  }

  Future<int?> totalStopwatchProduct(
      int batchId, int productId, int moveId, double time) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatch_products SET time_separate = $time WHERE batch_id = $batchId AND id_product = $productId AND id_move = $moveId ");
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
        "UPDATE tblbatch_products SET time_separate_end = '$date' WHERE batch_id = $batchId AND id_product = $productId AND id_move = $moveId");

    print("endStopwatchProduct: $resUpdate");
    return resUpdate;
  }

  Future<int?> totalStopwatchBatch(int batchId, double time) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        "UPDATE tblbatchs SET time_separate_total = $time WHERE id = $batchId ");
    print("endStopwatchBatch: $resUpdate");
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

  Future<int?> updateNovedadPacking(
    int pedidoId,
    int productId,
    String novedad,
  ) async {
    final db = await database;
    final resUpdate = await db!.rawUpdate(
        " UPDATE tblproductos_pedidos SET observation = '$novedad' WHERE product_id = $productId AND pedido_id = $pedidoId");
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
  Future<int?> incremenQtytProductSeparate(
      int batchId, int productId, int idMove, int quantity) async {
    final db = await database;
    return await db!.transaction((txn) async {
      // Primero, obtenemos el valor actual de product_separate_qty
      final result = await txn.query(
        'tblbatch_products',
        columns: ['quantity_separate'],
        where: 'batch_id = ? AND id_product = ? AND id_move = ?',
        whereArgs: [
          batchId,
          productId,
          idMove
        ], // Usamos whereArgs para los parámetros
      );

      if (result.isNotEmpty) {
        // Extraemos el valor actual
        int currentQty = (result.first['quantity_separate'] as int?) ?? 0;

        // Incrementamos la cantidad
        int newQty = currentQty + quantity;

        // Actualizamos la tabla
        return await txn.update(
          'tblbatch_products',
          {'quantity_separate': newQty},
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

  Future<int?> incremenQtytProductSeparatePacking(
      int pedidoId, int productId) async {
    final db = await database;
    return await db!.transaction((txn) async {
      // Primero, obtenemos el valor actual de product_separate_qty
      final result = await txn.query(
        'tblproductos_pedidos',
        columns: ['quantity_separate'],
        where: 'pedido_id = $pedidoId AND product_id = $productId',
        whereArgs: [pedidoId, productId],
      );

      if (result.isNotEmpty) {
        // Extraemos el valor actual
        int currentQty = (result.first['quantity_separate'] as int?) ?? 0;

        // Incrementamos la cantidad
        int newQty = currentQty + 1;

        // Actualizamos la tabla
        return await txn.update(
          'tblproductos_pedidos',
          {'quantity_separate': newQty},
          where: 'pedido_id = $pedidoId AND product_id = $productId',
          whereArgs: [pedidoId, productId],
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
}
