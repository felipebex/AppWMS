import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_barcodes/barcodes_table.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

class BarcodesRepository {
  // Método para obtener todos los barcodes de un producto

  Future<List<Barcodes>> getBarcodesProduct(
      int batchId, int productId, int idMove, String barcodeType) async {
    try {
      // Obtiene la instancia de la base de datos
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realizamos la consulta para obtener los barcodes
      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesPackagesTable.tableName,
        where: '${BarcodesPackagesTable.columnBatchId} = ? AND '
            '${BarcodesPackagesTable.columnIdMove} = ? AND'
            '${BarcodesPackagesTable.columnBarcodeType} = ? ',
        whereArgs: [batchId, idMove, barcodeType],
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
      int batchId, int productId, String barcodeType) async {
    try {
      // Obtiene la instancia de la base de datos
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realizamos la consulta para obtener los barcodes
      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesPackagesTable.tableName,
        where: '${BarcodesPackagesTable.columnBatchId} = ? AND '
            '${BarcodesPackagesTable.columnIdProduct} = ? AND '
            '${BarcodesPackagesTable.columnBarcodeType} = ?',
        whereArgs: [batchId, productId, barcodeType],
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
              barcodeType: map[BarcodesPackagesTable.columnBarcodeType],
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

  Future<void> insertOrUpdateBarcodes(
      List<Barcodes> barcodesList, String barcodeType) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();

      await db.transaction((txn) async {
        final Batch batch = txn.batch();

        // Claves únicas para comparar (idProduct-idMove-idBatch-barcode)
        final Set<String> barcodeKeys = barcodesList
            .map((b) => '${b.idProduct}-${b.idMove}-${b.batchId}-${b.barcode}')
            .toSet();

        // Obtener solo los registros necesarios (solo columnas clave)
        final List<Map<String, dynamic>> existing = await txn.query(
          BarcodesPackagesTable.tableName,
          columns: [
            BarcodesPackagesTable.columnIdProduct,
            BarcodesPackagesTable.columnIdMove,
            BarcodesPackagesTable.columnBatchId,
            BarcodesPackagesTable.columnBarcode,
            BarcodesPackagesTable.columnBarcodeType
          ],
          where:
              '${BarcodesPackagesTable.columnIdProduct} IN (${List.filled(barcodesList.length, '?').join(',')})',
          whereArgs: barcodesList.map((b) => b.idProduct).toList(),
        );

        // Crear conjunto de claves existentes
        final Set<String> existingKeys = existing
            .map((e) =>
                '${e[BarcodesPackagesTable.columnIdProduct]}-${e[BarcodesPackagesTable.columnIdMove]}-${e[BarcodesPackagesTable.columnBatchId]}-${e[BarcodesPackagesTable.columnBarcode]}')
            .toSet();

        for (final b in barcodesList) {
          final key = '${b.idProduct}-${b.idMove}-${b.batchId}-${b.barcode}';

          final data = {
            BarcodesPackagesTable.columnIdProduct: b.idProduct,
            BarcodesPackagesTable.columnBatchId: b.batchId,
            BarcodesPackagesTable.columnIdMove: b.idMove,
            BarcodesPackagesTable.columnBarcode: b.barcode,
            BarcodesPackagesTable.columnCantidad: b.cantidad ?? 1,
            BarcodesPackagesTable.columnBarcodeType: barcodeType,
          };

          if (existingKeys.contains(key)) {
            batch.update(
              BarcodesPackagesTable.tableName,
              data,
              where: '${BarcodesPackagesTable.columnIdProduct} = ? AND '
                  '${BarcodesPackagesTable.columnBatchId} = ? AND '
                  '${BarcodesPackagesTable.columnIdMove} = ? AND '
                  '${BarcodesPackagesTable.columnBarcode} = ? AND '
                  '${BarcodesPackagesTable.columnBarcodeType} = ?',
              whereArgs: [
                b.idProduct,
                b.batchId,
                b.idMove,
                b.barcode,
                barcodeType
              ],
            );
          } else {
            batch.insert(
              BarcodesPackagesTable.tableName,
              data,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        await batch.commit(noResult: true);
      });
    } catch (e, s) {
      print("Error en insertOrUpdateBarcodes: $e => $s");
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
          barcodeType: map[BarcodesPackagesTable.columnBarcodeType],
        );
      }).toList();

      return barcodes;
    } catch (e) {
      print("Error al obtener los barcodes: $e");
      return [];
    }
  }
}
