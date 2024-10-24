// ignore_for_file: avoid_print

import 'package:intl/intl.dart';
import 'package:wms_app/src/api/api.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';

class PickingApiModule {
  //*metodo para obtener todos los producto de un batch
  static Future<List<ProductsBatch>> resProductsBatchApi(int batchId) async {
    try {
      final response = await Api.callKW(
        model: "stock.move.line",
        method: "search_read",
        args: [],
        kwargs: {
          'context': {},
          'domain': [
            ['batch_id', '=', batchId],
          ],
          'fields': [
            'id',
            'product_id',
            'picking_id',
            'lot_id',
            'location_id',
            'location_dest_id',
            'quantity'
          ],
        },
      );
      if (response != null && response is List) {
        List<ProductsBatch> products =
            (response).map((data) => ProductsBatch.fromMap(data)).toList();
        return products;
      } else {
        print('Error productsBatch: response is null');
      }
    } catch (e, s) {
      print('Error productsBatch: $e, $s');
    }
    return [];
  }

  //*metodo para obtener todos los productos de la lista de batchs
  static Future<List<ProductsBatch>> resAllProductsBatchApi(
      List<int> idBatchs) async {
    try {
      final response = await Api.callKW(
        model: "stock.move.line",
        method: "search_read",
        args: [],
        kwargs: {
          'context': {},
          'domain': [
            ['batch_id', 'in', idBatchs],
            ['product_id', '!=', null]
            // ['batch_id', '=', 49595],
          ],
          'fields': [
            'id',
            'product_id',
            'batch_id',
            'product_id',
            'picking_id',
            'lot_id',
            'location_id',
            'location_dest_id',
            'quantity'
          ],
        },
      );
      if (response != null && response is List) {

        List<ProductsBatch> products = response.map((data) {
          return ProductsBatch(
            idProduct:
                data['product_id'][0] is int ? data['product_id'][0] : null,
            batchId: data['batch_id'][0],
            productId: data['product_id'][1],
            pickingId: data['picking_id'][1],
            lotId: data['lot_id'] is bool ? null : data['lot_id'][1],
            locationId: data['location_id'][1],
            locationDestId: data['location_dest_id'][1],
            quantity: data['quantity'],
          );
        }).toList();
        return products;
      } else {
        print('Error productsBatch: response is null');
      }
    } catch (e, s) {
      print('Error productsBatch: $e, $s');
    }
    return [];
  }

  // //*metodo para obtener los batchs
  // static Future<List<BatchsModel>> resBatchs() async {
  //   try {
  //     final response = await Api.callKW(
  //       model: "stock.picking.batch",
  //       method: "search_read",
  //       args: [],
  //       kwargs: {
  //         'context': {},
  //         'domain': [
  //           ['state', '!=', 'cancel'],
  //           // "scheduled_date":"2022-12-03 00:02:48",

  //         ],
  //         'fields': [
  //           'id',
  //           'name',
  //           'scheduled_date',
  //           'picking_type_id',
  //           'state',
  //           'user_id',
  //           'is_wave'
  //         ],
  //         // 'limit': 80,
  //       },
  //     );

  //     if (response != null && response is List) {
  //       List<BatchsModel> products =
  //           (response).map((data) => BatchsModel.fromMap(data)).toList();
  //       return products;
  //     } else {
  //       print('Error resBatchs: response is null');
  //     }
  //   } catch (e, s) {
  //     print('Error resBatchs: $e, $s');
  //   }
  //   return [];
  // }

  /// Método para obtener los batchs con filtro de fecha
  static Future<List<BatchsModel>> resBatchs() async {
    try {
      // Obtener la fecha actual y la fecha de tres días atrás
      DateTime now = DateTime.now();
      DateTime threeDaysAgo = now.subtract(Duration(days: 3));

      // Formatear las fechas en el formato que Odoo espera
      String nowFormatted = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);
      String threeDaysAgoFormatted =
          DateFormat("yyyy-MM-dd HH:mm:ss").format(threeDaysAgo);

      final response = await Api.callKW(
        model: "stock.picking.batch",
        method: "search_read",
        args: [],
        kwargs: {
          'context': {},
          'domain': [
            ['state', '=', 'in_progress'],
            // ['scheduled_date', '>=', threeDaysAgoFormatted],
            // ['scheduled_date', '<=', nowFormatted],
          ],
          'fields': [
            'id',
            'name',
            'scheduled_date',
            'picking_type_id',
            'state',
            'user_id',
            'is_wave'
          ],
          // 'limit': 80,
        },
      );

      if (response != null && response is List) {
        List<BatchsModel> products =
            (response).map((data) => BatchsModel.fromMap(data)).toList();
        return products;
      } else {
        print('Error resBatchs: response is null');
      }
    } catch (e, s) {
      print('Error resBatchs: $e, $s');
    }
    return [];
  }

  //metodo para obtener todos los productos
  static Future<List<Products>> resProductsApi() async {
    try {
      final response = await Api.callKW(
        model: "product.product",
        method: "search_read",
        args: [],
        kwargs: {
          'context': {},
          'domain': [
            ['active', '=', true],
            ['detailed_type', '=', 'product']

            //lot y seria
          ],
          'fields': ['id', 'name', 'barcode', 'tracking'],
        },
      );

      if (response != null && response is List) {
        List<Products> products =
            (response).map((data) => Products.fromMap(data)).toList();
        return products;
      } else {
        print('Error resProductsApi: response is null');
      }
    } catch (e, s) {
      print('Error resProductsApi: $e, $s');
    }
    return [];
  }
}
