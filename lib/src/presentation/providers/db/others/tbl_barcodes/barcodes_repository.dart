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

  // Método para insertar o actualizar los barcodes de los productos
  Future<void> insertOrUpdateBarcodes(List<Barcodes> barcodesList) async {
    int insertedCount = 0; // Contador de registros insertados
    int updatedCount = 0; // Contador de registros actualizados

    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Inicia la transacción
      await db.transaction((txn) async {
        for (var barcode in barcodesList) {
          // Realizamos la consulta para verificar si ya existe el producto con este barcode
          final List<Map<String, dynamic>> existingProduct = await txn.query(
            BarcodesPackagesTable.tableName,
            where: '${BarcodesPackagesTable.columnIdProduct} = ? AND '
                '${BarcodesPackagesTable.columnBatchId} = ? AND '
                '${BarcodesPackagesTable.columnIdMove} = ? AND '
                '${BarcodesPackagesTable.columnBarcode} = ?',
            whereArgs: [
              barcode.idProduct,
              barcode.batchId,
              barcode.idMove,
              barcode.barcode
            ],
          );

          if (existingProduct.isNotEmpty) {
            // Si el producto ya existe, lo actualizamos
            await txn.update(
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
                barcode.barcode
              ],
            );
            updatedCount++; // Incrementamos el contador de actualizaciones
          } else {
            // Si el producto no existe, lo insertamos
            await txn.insert(
              BarcodesPackagesTable.tableName,
              {
                BarcodesPackagesTable.columnIdProduct: barcode.idProduct,
                BarcodesPackagesTable.columnBatchId: barcode.batchId,
                BarcodesPackagesTable.columnIdMove: barcode.idMove,
                BarcodesPackagesTable.columnBarcode: barcode.barcode,
                BarcodesPackagesTable.columnCantidad: barcode.cantidad ?? 1,
              },
              conflictAlgorithm: ConflictAlgorithm
                  .replace, // Reemplaza si hay conflicto en la clave primaria
            );
            insertedCount++; // Incrementamos el contador de inserciones
          }
        }
      });

      // Imprimimos el número de registros insertados y actualizados
      print("Total de registros insertados: $insertedCount");
      print("Total de registros actualizados: $updatedCount");
    } catch (e, s) {
      print("Error al insertar/actualizar barcodes: $e => $s");
    }
  }

  //metodo para obtener todos los barcodes
  Future<List<Barcodes>> getAllBarcodes() async {
    try {
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
