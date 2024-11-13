// // ignore_for_file: avoid_print

// ignore_for_file: unrelated_type_equality_checks, avoid_print

// import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/item_picking_request.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'dart:io';

import 'package:wms_app/src/presentation/views/wms_picking/models/response_send_picking.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

class WmsPickingRepository {
  Future<List<BatchsModel>> resBatchs() async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      final String userEmail = await PrefUtils.getUserEmail();
      final String pass = await PrefUtils.getUserPass();
      final String dataBd = Preferences.nameDatabase;

      var response = await ApiRequestService().post(endpoint: 'batchs', body: {
        "url_rpc": "http://34.30.1.186:8069",
        "db_rpc": dataBd,
        "email_rpc": userEmail,
        "clave_rpc": pass,
      });

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          // Asegúrate de que 'result' exista y sea una lista
          if (data.containsKey('result') && data['result'] is List) {
            List<dynamic> batches = data['result'];
            // Mapea los datos decodificados a una lista de BatchsModel
            List<BatchsModel> products =
                batches.map((data) => BatchsModel.fromMap(data)).toList();
            return products;
          }
        }
      } else {
        print('Error resBatchs: response is null');
      }
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores
      print('Error resBatchs: $e, $s');
    }
    return [];
  }

  Future<SendPickingResponse> sendPicking({
    required int idBatch,
    required double timeTotal,
    required int cantItemsSeparados,
    required List<Item> listItem, //
  }) async {
    final String userEmail = await PrefUtils.getUserEmail();
    final String pass = await PrefUtils.getUserPass();
    final String dataBd = Preferences.nameDatabase;

    var headers = {
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      "url_rpc": "http://34.30.1.186:8069",
      "db_rpc": dataBd,
      "email_rpc": userEmail,
      "clave_rpc": pass,
      "id_batch": idBatch,
      "time_total": timeTotal,
      "cant_items_separados": cantItemsSeparados,
      "list_item": listItem.map((item) => item.toJson()).toList(),
    });

    try {
      var response = await ApiRequestService()
          .sendPicking(endpoint: 'send_batch', body: body, headers: headers);

      print('Response sendPicking: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Picking enviado correctamente');
        print("Response sendPicking: ${response.body}");
        //actualizamos el estado de envio de odoo de los productos
        return SendPickingResponse.fromJson(response.body);

        //volver a enviar los represados
      } else {
        print('Error sendPicking: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
    } catch (e, s) {
      // Manejo de otros errores
      print('Error sendPicking: $e, $s');
    }
    return SendPickingResponse();
  }
}
