// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

import 'dart:convert'; // Asegúrate de importar esto

class WmsPickingRepository {
  Future<List<BatchsModel>> resBatchs(BuildContext context) async {
    try {
      var response = await ApiRequestService().post(endpoint: 'batchs', body: {
        "url_rpc": "http://34.30.1.186:8069",
        "db_rpc": "paisapan",
        "email_rpc": "felipe.bedoya@bexsoluciones.com",
        "clave_rpc": "Desarrollo"
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
    } catch (e, s) {
      print('Error resBatchs: $e, $s');
    }
    return [];
  }
}
