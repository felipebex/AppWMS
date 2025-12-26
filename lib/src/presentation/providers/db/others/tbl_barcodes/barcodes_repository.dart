

import 'package:sqflite/sqflite.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/db/others/tbl_barcodes/barcodes_table.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

class BarcodesRepository {
  
  // Tamaño del bloque para inserción masiva
  static const int _batchSize = 500;

  /// --------------------------------------------------------------------------
  /// METODO OPTIMIZADO: insertOrUpdateBarcodes (Estrategia Mark & Sweep)
  /// --------------------------------------------------------------------------
  /// 1. Marca todos los registros de este Batch+Type como is_synced = 0.
  /// 2. Inserta los nuevos registros marcándolos como is_synced = 1.
  /// 3. Elimina los registros que quedaron en 0 (ya no vienen del servidor).
  Future<void> insertOrUpdateBarcodes(
      List<Barcodes> barcodesList, String barcodeType) async {
    try {
      final db = await DataBaseSqlite().getDatabaseInstance();
      if (barcodesList.isEmpty) return;

      // Usamos el primer elemento para saber a qué Batch pertenecen estos códigos.
      // ASUMIMOS que toda la lista pertenece al mismo Batch.
      final int currentBatchId = barcodesList.first.batchId!;

      await db.transaction((txn) async {
        
        // PASO 1: MARCA
        // "Reseteamos" el estado solo para los registros de este Lote y Tipo.
        await txn.rawUpdate('''
          UPDATE ${BarcodesPackagesTable.tableName} 
          SET ${BarcodesPackagesTable.columnIsSynced} = 0 
          WHERE ${BarcodesPackagesTable.columnBatchId} = ? 
          AND ${BarcodesPackagesTable.columnBarcodeType} = ?
        ''', [currentBatchId, barcodeType]);

        // PASO 2: UPSERT POR LOTES (Chunking)
        for (var i = 0; i < barcodesList.length; i += _batchSize) {
          final end = (i + _batchSize < barcodesList.length)
              ? i + _batchSize
              : barcodesList.length;
          final batchList = barcodesList.sublist(i, end);

          final batch = txn.batch();

          for (final b in batchList) {
            batch.insert(
              BarcodesPackagesTable.tableName,
              {
                BarcodesPackagesTable.columnIdProduct: b.idProduct,
                BarcodesPackagesTable.columnBatchId: b.batchId,
                BarcodesPackagesTable.columnIdMove: b.idMove,
                BarcodesPackagesTable.columnBarcode: b.barcode,
                BarcodesPackagesTable.columnCantidad:
                    (b.cantidad == null || b.cantidad == 0) ? 1 : b.cantidad,
                BarcodesPackagesTable.columnBarcodeType: barcodeType,
                // ✅ Marcamos como "Vivo / Sincronizado"
                BarcodesPackagesTable.columnIsSynced: 1, 
              },
              // Si existe la combinación única, actualiza. Si no, inserta.
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await batch.commit(noResult: true);
        }

        // PASO 3: BARRIDO
        // Borramos lo que quedó en 0 (solo para este Batch y Tipo)
        int deleted = await txn.delete(
          BarcodesPackagesTable.tableName,
          where: '${BarcodesPackagesTable.columnBatchId} = ? AND ${BarcodesPackagesTable.columnBarcodeType} = ? AND ${BarcodesPackagesTable.columnIsSynced} = ?',
          whereArgs: [currentBatchId, barcodeType, 0],
        );

        print("🔄 Sync Barcodes ($barcodeType): Procesados ${barcodesList.length} | Eliminados Obsoletos: $deleted");
      });
    } catch (e, s) {
      print("❌ Error en insertOrUpdateBarcodes: $e => $s");
    }
  }

  /// --------------------------------------------------------------------------
  /// MÉTODOS DE LECTURA (Sin cambios, solo optimizados por los Índices)
  /// --------------------------------------------------------------------------

  Future<List<Barcodes>> getBarcodesProduct(
      int batchId, int productId, int idMove, String barcodeType) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesPackagesTable.tableName,
        where: '${BarcodesPackagesTable.columnBatchId} = ? AND '
            '${BarcodesPackagesTable.columnIdMove} = ? AND '
            '${BarcodesPackagesTable.columnBarcodeType} = ?', 
        whereArgs: [batchId, idMove, barcodeType],
      );

      if (maps.isEmpty) return [];

      return maps.map((map) {
        return Barcodes(
          batchId: map[BarcodesPackagesTable.columnBatchId],
          idMove: map[BarcodesPackagesTable.columnIdMove],
          idProduct: map[BarcodesPackagesTable.columnIdProduct],
          barcode: map[BarcodesPackagesTable.columnBarcode],
          cantidad: map[BarcodesPackagesTable.columnCantidad]?.toDouble(),
          barcodeType: map[BarcodesPackagesTable.columnBarcodeType],
        );
      }).toList();
    } catch (e, s) {
      print("❌ Error al obtener los barcodes: $e => $s");
      return [];
    }
  }

  Future<List<Barcodes>> getBarcodesProductNotMove(
      int batchId, int productId, String barcodeType) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      
      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesPackagesTable.tableName,
        where: '${BarcodesPackagesTable.columnBatchId} = ? AND '
            '${BarcodesPackagesTable.columnIdProduct} = ? AND '
            '${BarcodesPackagesTable.columnBarcodeType} = ?',
        whereArgs: [batchId, productId, barcodeType],
      );

      if (maps.isEmpty) return [];

      final barcodes = maps
          .fold<Map<String, Barcodes>>({}, (map, item) {
            final barcode = item[BarcodesPackagesTable.columnBarcode];
            if (!map.containsKey(barcode)) {
              map[barcode] = Barcodes(
                batchId: item[BarcodesPackagesTable.columnBatchId],
                idMove: item[BarcodesPackagesTable.columnIdMove],
                idProduct: item[BarcodesPackagesTable.columnIdProduct],
                barcode: barcode,
                cantidad: item[BarcodesPackagesTable.columnCantidad]?.toDouble(),
                barcodeType: item[BarcodesPackagesTable.columnBarcodeType],
              );
            }
            return map;
          })
          .values
          .toList();
      return barcodes;
    } catch (e) {
      print("Error al obtener los barcodes: $e");
      return [];
    }
  }

  Future<List<Barcodes>> getBarcodesProductTransfer(
      int batchId, int productId, String barcodeType) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();

      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesPackagesTable.tableName,
        where: '${BarcodesPackagesTable.columnBatchId} = ? AND '
            '${BarcodesPackagesTable.columnIdProduct} = ? AND '
            '${BarcodesPackagesTable.columnBarcodeType} = ?',
        whereArgs: [batchId, productId, barcodeType],
      );

      if (maps.isEmpty) return [];

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

  Future<List<Barcodes>> getAllBarcodes() async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesPackagesTable.tableName,
      );
      return maps.map((map) {
        return Barcodes(
          batchId: map[BarcodesPackagesTable.columnBatchId],
          idMove: map[BarcodesPackagesTable.columnIdMove],
          idProduct: map[BarcodesPackagesTable.columnIdProduct],
          barcode: map[BarcodesPackagesTable.columnBarcode],
          cantidad: map[BarcodesPackagesTable.columnCantidad],
          barcodeType: map[BarcodesPackagesTable.columnBarcodeType],
        );
      }).toList();
    } catch (e) {
      print("Error al obtener los barcodes: $e");
      return [];
    }
  }

  Future<List<Barcodes>> getBarcodesByBatchIdAndType(
      int batchId, String barcodeType) async {
    try {
      Database db = await DataBaseSqlite().getDatabaseInstance();
      final List<Map<String, dynamic>> maps = await db.query(
        BarcodesPackagesTable.tableName,
        where: '${BarcodesPackagesTable.columnBatchId} = ? AND '
            '${BarcodesPackagesTable.columnBarcodeType} = ?',
        whereArgs: [batchId, barcodeType],
      );
      
      return maps.map((map) {
        return Barcodes(
          batchId: map[BarcodesPackagesTable.columnBatchId],
          idMove: map[BarcodesPackagesTable.columnIdMove],
          idProduct: map[BarcodesPackagesTable.columnIdProduct],
          barcode: map[BarcodesPackagesTable.columnBarcode],
          cantidad: map[BarcodesPackagesTable.columnCantidad]?.toDouble(),
          barcodeType: map[BarcodesPackagesTable.columnBarcodeType],
        );
      }).toList();
    } catch (e) {
      print("Error al obtener los barcodes: $e");
      return [];
    }
  }
}