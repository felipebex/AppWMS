import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/inventario/tbl_barcode/barcodes_inventario_table.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';

class BarcodesInventarioRepository {
  Future<void> insertOrUpdateBarcodes(
      List<BarcodeInventario> barcodesList) async {
    int insertedCount = 0; // Contador de registros insertados
    int updatedCount = 0; // Contador de registros actualizados

    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Inicia la transacción
      await db.transaction((txn) async {
        for (var barcode in barcodesList) {
          // Realizamos la consulta para verificar si ya existe el producto con este barcode
          final List<Map<String, dynamic>> existingProduct = await txn.query(
            BarcodesInventarioTable.tableName,
            where: '${BarcodesInventarioTable.columnIdProduct} = ? AND '
                '${BarcodesInventarioTable.columnIdQuant} = ? AND '
                '${BarcodesInventarioTable.columnBarcode} = ?',
            whereArgs: [barcode.idProduct, barcode.idQuant, barcode.barcode],
          );

          if (existingProduct.isNotEmpty) {
            // Si el producto ya existe, lo actualizamos
            await txn.update(
              BarcodesInventarioTable.tableName,
              {
                BarcodesInventarioTable.columnIdProduct: barcode.idProduct,
                BarcodesInventarioTable.columnIdQuant: barcode.idQuant,
                BarcodesInventarioTable.columnBarcode: barcode.barcode,
                BarcodesInventarioTable.columnCantidad: barcode.cantidad ?? 1,
              },
              where: '${BarcodesInventarioTable.columnIdProduct} = ? AND '
                  '${BarcodesInventarioTable.columnIdQuant} = ? AND '
                  '${BarcodesInventarioTable.columnBarcode} = ?',
              whereArgs: [
                barcode.idProduct,
                barcode.idQuant,
                barcode.barcode,
              ],
            );
            updatedCount++; // Incrementamos el contador de actualizaciones
          } else {
            // Si el producto no existe, lo insertamos
            await txn.insert(
              BarcodesInventarioTable.tableName,
              {
                BarcodesInventarioTable.columnIdProduct: barcode.idProduct,
                BarcodesInventarioTable.columnIdQuant: barcode.idQuant,
                BarcodesInventarioTable.columnBarcode: barcode.barcode,
                BarcodesInventarioTable.columnCantidad: barcode.cantidad ?? 1,
              },
              conflictAlgorithm: ConflictAlgorithm
                  .replace, // Reemplaza si hay conflicto en la clave primaria
            );
            insertedCount++; // Incrementamos el contador de inserciones
          }
        }
      });

      // Imprimimos el número de registros insertados y actualizados
      print("Total de registros insertOrUpdateBarcodes: $insertedCount");
      print("Total de registros insertOrUpdateBarcodes: $updatedCount");
    } catch (e, s) {
      print("Error al insertar/actualizar barcodes: $e => $s");
    }
  }

  Future<List<BarcodeInventario>> getAllBarcodes() async {
    try {
      //mostrar todos los barcodes

      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realizamos la consulta para obtener los barcodes
      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesInventarioTable.tableName,
      );

      // Convertimos los resultados de la consulta en objetos Barcodes
      final List<BarcodeInventario> barcodes = maps.map((map) {
        return BarcodeInventario(
          idProduct: map[BarcodesInventarioTable.columnIdProduct],
          idQuant: map[BarcodesInventarioTable.columnIdQuant],
          barcode: map[BarcodesInventarioTable.columnBarcode],
          cantidad: map[BarcodesInventarioTable.columnCantidad],
        );
      }).toList();

      return barcodes;
    } catch (e) {
      print("Error al obtener los barcodes: $e");
      return [];
    }
  }

  Future<List<BarcodeInventario>> getBarcodesProduct(
      int productId, int quantId) async {
    try {
      // Obtiene la instancia de la base de datos
      Database db = await DataBaseSqlite().getDatabaseInstance();

      // Realizamos la consulta para obtener los barcodes
      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesInventarioTable.tableName,
        where: '${BarcodesInventarioTable.columnIdProduct} = ? AND '
            '${BarcodesInventarioTable.columnIdQuant} = ? ',
        whereArgs: [productId, quantId],
      );

      // Verificamos si la consulta ha devuelto resultados
      if (maps.isEmpty) {
        print("No se encontraron barcodes para los parámetros proporcionados.");
        return [];
      }

      // Convertimos los resultados de la consulta en objetos Barcodes
      final List<BarcodeInventario> barcodes = maps.map((map) {
        return BarcodeInventario(
          idProduct: map[BarcodesInventarioTable.columnIdProduct],
          barcode: map[BarcodesInventarioTable.columnBarcode],
          idQuant: map[BarcodesInventarioTable.columnIdQuant],
          cantidad: map[BarcodesInventarioTable.columnCantidad]
              ?.toDouble(), // Asegúrate de convertir el tipo correctamente
        );
      }).toList();

      return barcodes;
    } catch (e) {
      print("Error al obtener los barcodes: $e");
      return [];
    }
  }
}
