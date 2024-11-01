// // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:wms_app/src/api/api.dart';

// class HomeApiModule {




//   //*metodo para contar los batch
//   static Future<int> countBatchDone(BuildContext context) async {
//     try {
//       final response = await Api.callKW(
//         model: "stock.picking.batch",
//         method: "search_count",
//         context: context,
//         args: [],
//          kwargs: {
//           'context': {},
//           'domain': [
//             ['state', '=', 'done'],
//           ],
//         },
//       );

//       if (response != null && response is int) {
//         print('countBatchDone: $response');
//         return response;
//       } else {
//         print('Error countBatchDone: response is null');
//       }
//     } catch (e, s) {
//       print('Error countBatchDone: $e, $s');
//     }
//     return 0;
//   }



//   static Future<int> countBatchInProgress(BuildContext context) async {
//     try {
//       final response = await Api.callKW(
//         model: "stock.picking.batch",
//         method: "search_count",
//         context: context,
//         args: [],
//          kwargs: {
//           'context': {},
//           'domain': [
//             ['state', '=', 'in_progress'],
//           ],
//         },
//       );
//         print("response: $response");
//       if (response != null && response is int) {
//         print('countBatchInProgress: $response');
//         return response;
//       } else {
//         print('Error countBatchInProgress: response is null');
//       }
//     } catch (e, s) {
//       print('Error countBatchInProgress: $e, $s');
//     }
//     return 0;
//   }





//   static Future<int> countAllBatch(BuildContext context) async {
//     try {
//       final response = await Api.callKW(
//         model: "stock.picking.batch",
//         method: "search_count",
//         context: context,
//         args: [],
//          kwargs: {
//           'context': {},
//           'domain': [
//           ],
//         },
//       );
//       if (response != null && response is int) {
//         print('countBatchInProgress: $response');
//         return response;
//       } else {
//         print('Error countAllBatch: response is null');
//       }
//     } catch (e, s) {
//       print('Error countAllBatch: $e, $s');
//     }
//     return 0;
//   }
 


// }