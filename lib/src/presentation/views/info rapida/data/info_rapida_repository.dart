import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/info_rapida_model.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class InfoRapidaRepository {
  Future<InfoRapida> getInfoQuick(bool isLoadinDialog, String barcode) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return InfoRapida(); // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().getInfo(
        endpoint: 'transferencias/quickinfo',
        body: {
          "params": {
            "barcode": barcode,
          }
        },
        isLoadinDialog: isLoadinDialog,
      );

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          return InfoRapida.fromMap(jsonResponse);
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            Get.defaultDialog(
              title: 'Alerta',
              titleStyle: TextStyle(color: Colors.red, fontSize: 18),
              middleText: 'Sesion expirada, por favor inicie sesión nuevamente',
              middleTextStyle: TextStyle(color: black, fontSize: 14),
              backgroundColor: Colors.white,
              radius: 10,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Aceptar', style: TextStyle(color: white)),
                ),
              ],
            );
            return InfoRapida();
          }
        }
      } else {}
    } on SocketException catch (e) {
      print('Error de red: $e');
      return InfoRapida();
    } catch (e, s) {
      // Manejo de otros errores
      print('Error getInfoQuick: $e, $s');
    }
    return InfoRapida();
  }
}
