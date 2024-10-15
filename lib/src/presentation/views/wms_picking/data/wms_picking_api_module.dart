// ignore_for_file: avoid_print

import 'package:wms_app/src/api/api.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
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
            // ['lot_id', '!=', false],
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

  //*metodo para obtener los batchs en estado in_progress
  static Future<List<BatchsModel>> resBatchs() async {
    try {
      final response = await Api.callKW(
        model: "stock.picking.batch",
        method: "search_read",
        args: [],
        kwargs: {
          'context': {},
          'domain': [
          ],
          'fields': ['id', 'name', 'scheduled_date', 'picking_type_id', 'state', 'user_id'],
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







}
