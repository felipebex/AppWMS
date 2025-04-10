import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_barcodes/barcodes_table.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

class BarcodesRepository {
  // Método para obtener todos los barcodes de un producto

  Future<List<Barcodes>> getBarcodesProduct(
      int batchId, int productId, int idMove) async {
    try {
      // Obtiene la instancia de la base de datos
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realizamos la consulta para obtener los barcodes
      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesPackagesTable.tableName,
        where: '${BarcodesPackagesTable.columnBatchId} = ? AND '
            '${BarcodesPackagesTable.columnIdMove} = ? ',
        whereArgs: [batchId, idMove],
      );

      // Verificamos si la consulta ha devuelto resultados
      if (maps.isEmpty) {
        print("No se encontraron barcodes para los parámetros proporcionados.");
        return [];
      }

      // Convertimos los resultados de la consulta en objetos Barcodes
      final List<Barcodes> barcodes = maps.map((map) {
        return Barcodes(
          batchId: map[BarcodesPackagesTable.columnBatchId],
          idMove: map[BarcodesPackagesTable.columnIdMove],
          idProduct: map[BarcodesPackagesTable.columnIdProduct],
          barcode: map[BarcodesPackagesTable.columnBarcode],
          cantidad: map[BarcodesPackagesTable.columnCantidad]
              ?.toDouble(), // Asegúrate de convertir el tipo correctamente
        );
      }).toList();

      return barcodes;
    } catch (e) {
      print("Error al obtener los barcodes: $e");
      return [];
    }
  }

  Future<List<Barcodes>> getBarcodesProductTransfer(
      int batchId, int productId) async {
    try {
      // Obtiene la instancia de la base de datos
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realizamos la consulta para obtener los barcodes
      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesPackagesTable.tableName,
        where: '${BarcodesPackagesTable.columnBatchId} = ? AND '
            '${BarcodesPackagesTable.columnIdProduct} = ?',
        whereArgs: [batchId, productId],
      );

      // Verificamos si la consulta ha devuelto resultados
      if (maps.isEmpty) {
        print("No se encontraron barcodes para los parámetros proporcionados.");
        return [];
      }

      // Utilizamos un Set para evitar duplicados por el campo barcode
      final Set<String> seenBarcodes = {};
      final List<Barcodes> barcodes = [];

      for (final map in maps) {
        final String barcode = map[BarcodesPackagesTable.columnBarcode];

        if (!seenBarcodes.contains(barcode)) {
          seenBarcodes.add(barcode);
          barcodes.add(
            Barcodes(
              batchId: map[BarcodesPackagesTable.columnBatchId],
              idMove: map[BarcodesPackagesTable.columnIdMove],
              idProduct: map[BarcodesPackagesTable.columnIdProduct],
              barcode: barcode,
              cantidad: map[BarcodesPackagesTable.columnCantidad]?.toDouble(),
            ),
          );
        }
      }

      return barcodes;
    } catch (e) {
      print("Error al obtener los barcodes: $e");
      return [];
    }
  }

  // Método para insertar o actualizar los barcodes de los productos

  Future<void> insertOrUpdateBarcodes(List<Barcodes> barcodesList) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      await db.transaction((txn) async {
        Batch batch = txn.batch();

        final List<Map<String, dynamic>> existingProducts = await txn.query(
          BarcodesPackagesTable.tableName,
          columns: [BarcodesPackagesTable.columnId],
          where: '${BarcodesPackagesTable.columnIdProduct} = ? AND '
              '${BarcodesPackagesTable.columnBatchId} = ? AND '
              '${BarcodesPackagesTable.columnIdMove} = ? AND '
              '${BarcodesPackagesTable.columnBarcode} = ?',
          whereArgs: [
            barcodesList.map((barcode) => barcode.idProduct).toList().join(','),
            barcodesList.map((barcode) => barcode.batchId).toList().join(','),
            barcodesList.map((barcode) => barcode.idMove).toList().join(','),
            barcodesList.map((barcode) => barcode.barcode).toList().join(','),
          ],
        );

        // Crear un conjunto de los IDs existentes para facilitar la comprobación
        Set<int> existingIds = Set.from(existingProducts.map((e) {
          return e[BarcodesPackagesTable.columnId];
        }));

        for (var barcode in barcodesList) {
          if (existingIds.contains(barcode.idProduct) &&
              existingIds.contains(barcode.batchId) &&
              existingIds.contains(barcode.idMove) &&
              existingIds.contains(barcode.barcode)) {
            // Si el barcode ya existe, lo actualizamos
            batch.update(
              BarcodesPackagesTable.tableName,
              {
                BarcodesPackagesTable.columnIdProduct: barcode.idProduct,
                BarcodesPackagesTable.columnBatchId: barcode.batchId,
                BarcodesPackagesTable.columnIdMove: barcode.idMove,
                BarcodesPackagesTable.columnBarcode: barcode.barcode,
                BarcodesPackagesTable.columnCantidad: barcode.cantidad ?? 1,
              },
              where: '${BarcodesPackagesTable.columnIdProduct} = ? AND '
                  '${BarcodesPackagesTable.columnBatchId} = ? AND '
                  '${BarcodesPackagesTable.columnIdMove} = ? AND '
                  '${BarcodesPackagesTable.columnBarcode} = ?',
              whereArgs: [
                barcode.idProduct,
                barcode.batchId,
                barcode.idMove,
                barcode.barcode,
              ],
            );
          } else {
            batch.insert(
              BarcodesPackagesTable.tableName,
              {
                BarcodesPackagesTable.columnIdProduct: barcode.idProduct,
                BarcodesPackagesTable.columnBatchId: barcode.batchId,
                BarcodesPackagesTable.columnIdMove: barcode.idMove,
                BarcodesPackagesTable.columnBarcode: barcode.barcode,
                BarcodesPackagesTable.columnCantidad: barcode.cantidad ?? 1,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        await batch.commit();
      });
    } catch (e, s) {
      print("Error al insertar/actualizar barcodes: $e => $s");
    }
  }

  //metodo para obtener todos los barcodes
  Future<List<Barcodes>> getAllBarcodes() async {
    try {
      //mostrar todos los barcodes

      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realizamos la consulta para obtener los barcodes
      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesPackagesTable.tableName,
      );

      // Convertimos los resultados de la consulta en objetos Barcodes
      final List<Barcodes> barcodes = maps.map((map) {
        return Barcodes(
          batchId: map[BarcodesPackagesTable.columnBatchId],
          idMove: map[BarcodesPackagesTable.columnIdMove],
          idProduct: map[BarcodesPackagesTable.columnIdProduct],
          barcode: map[BarcodesPackagesTable.columnBarcode],
          cantidad: map[BarcodesPackagesTable.columnCantidad],
        );
      }).toList();

      return barcodes;
    } catch (e) {
      print("Error al obtener los barcodes: $e");
      return [];
    }
  }
}
