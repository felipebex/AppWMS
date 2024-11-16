// ignore_for_file: avoid_print, unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

class WmsPackingRepository {
  Future<List<BatchPackingModel>> resBatchsPacking() async {
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

      var response =
          await ApiRequestService().post(endpoint: 'batch_packing', body: {
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
            List<dynamic> batchs = data['result'];
            // Mapea los datos decodificados a una lista de BatchsModel
            List<BatchPackingModel> batch =
                batchs.map((data) => BatchPackingModel.fromMap(data)).toList();
            return batch;
          }
        }
      } else {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          print("data: $data");
          //mostramos alerta del error
          Get.snackbar(
            'Error en batch_packing : ${data['code']}',
            data['msg'],
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        print('Error resBatchsPacking: response is null');
      }
    } on SocketException catch (e) {
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores
      print('Error resBatchsPacking: $e, $s');
    }
    return [];
  }
}
