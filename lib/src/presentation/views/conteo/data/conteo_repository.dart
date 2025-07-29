// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ConteoRepository {
//metodo para traer todos los conteos
  Future<ResultConteo> fetchAllConteos(
      bool isLoadinDialog, ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return ResultConteo(
        code: 0,
        msg: "No hay conexión a Internet",
        data: [],
      ); // Si no hay conexión, retornar un ResultConteo vacío
    }

    try {
      var response = await ApiRequestService().get(
        endpoint: 'inventory/all_orders',
        isunecodePath: true,
        isLoadinDialog: isLoadinDialog,
      );

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          List<dynamic> response = jsonResponse['result']['data'];
          // Mapea los datos decodificados a una lista de BatchsModel
          
          return ResultConteo(
            code: jsonResponse['result']['code'],
            msg: jsonResponse['result']['msg'],
            data: response.map((item) => DatumConteo.fromMap(item)).toList(),
          );
        

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
            return ResultConteo(
              code: 0,
              msg: "Sesion expirada, por favor inicie sesión nuevamente",
              data: [],
            ); //
          }
        }
      } else {}
    } on SocketException catch (e) {
      print('Error de red: $e');
      return ResultConteo();
    } catch (e, s) {
      // Manejo de otros errores
      print('Error conteo fisico: $e, $s');
    }
    return ResultConteo();
  }
}
