// // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:wms_app/src/api/api.dart';
// import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_model.dart';
// import 'package:wms_app/src/presentation/views/wms_packing/domain/product_packing_model.dart';

// import '../../wms_picking/models/picking_batch_model.dart';

// class PackingSApiModule {
//   static Future<List<Packing>> restAllPacking(
//       int batchId, BuildContext context) async {
//     try {
//       final response = await Api.callKW(
//         model: "stock.picking",
//         method: "search_read",
//         context: context,
//         args: [],
//         kwargs: {
//           'context': {},
//           'domain': [
//             ['batch_id', '=', batchId],
//           ],
//           'fields': [
//             'id',
//             'name',
//             'reason_return',
//             'picking_type_id',
//             'origin',
//             'location_id',
//             'location_dest_id',
//             'partner_id',
//             'batch_id',
//             'state',
//             'scheduled_date',
//             'date_deadline'
//           ],
//         },
//       );

//       print("response packing : $response");

//       if (response != null && response is List) {
//         List<Packing> packings =
//             (response).map((data) => Packing.fromMap(data)).toList();
//         return packings;
//       } else {
//         print("Error en el restAllPacking: response is null");
//       }
//     } catch (e, s) {
//       print("Error en el  restAllPacking: $e, $s");
//     }
//     return [];
//   }

// //*metodo para obtener los batchs
//   static Future<List<BatchsModel>> resBatchs(BuildContext context) async {
//     try {
//       final response = await Api.callKW(
//         model: "stock.picking.batch",
//         method: "search_read",
//         context: context,
//         args: [],
//         kwargs: {
//           'context': {},
//           'domain': [
//             ['state', '!=', 'cancel'],
//             // ['scheduled_date', 'in', ['2024-01-10', '2024-30-10']]
//           ],
//           'fields': [
//             'id',
//             'name',
//             'scheduled_date',
//             'picking_type_id',
//             'state',
//             'user_id',
//             'is_wave'
//           ],
//           // 'limit': 80,
//         },
//       );

//       if (response != null && response is List) {
//         List<BatchsModel> products =
//             (response).map((data) => BatchsModel.fromMap(data)).toList();
//         return products;
//       } else {
//         print('Error resBatchs: response is null');
//       }
//     } catch (e, s) {
//       print('Error resBatchs: $e, $s');
//     }
//     return [];
//   }

//   //*metodo para obtener todos los productos de un packing
//   static Future<List<ProductPacking>> resProductsPacking(
//       int pickingId, BuildContext context) async {
//     try {
//       final response = await Api.callKW(
//         model: "stock.move.line",
//         method: "search_read",
//         context: context,
//         args: [],
//         kwargs: {
//           'context': {},
//           'domain': [
//             ['picking_id', '=', pickingId],
//           ],
//           'fields': [
//             'product_id',
//             'lot_name',
//             'expiration_date',
//             'location_dest_id',
//             'result_package_id',
//             'quantity',
//             'product_uom_id'
//           ],
//         },
//       );
//       print('response products packing : $response');
//       if (response != null && response is List) {
//         List<ProductPacking> products =
//             (response).map((data) => ProductPacking.fromJson(data)).toList();
//         return products;
//       } else {
//         print('Error resProductsPacking: response is null');
//       }
//     } catch (e, s) {
//       print('Error resProductsPacking: $e, $s');
//     }
//     return [];
//   }
// }
