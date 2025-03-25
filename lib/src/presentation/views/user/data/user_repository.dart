// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class UserRepository {
  Future<Configurations> configurations(
    BuildContext context,
  ) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        print("Error: No hay conexión a Internet.");
        return Configurations(); // Si no hay conexión, retornar una lista vacía
      }

      var response = await ApiRequestService().get(
        endpoint: 'configurations',
        isunecodePath: true,
        isLoadinDialog: false,
      );
      if (response.statusCode < 400) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 200) {
            return Configurations.fromMap(jsonDecode(response.body));
          }
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
            return Configurations();
          }
        }
      } else {
        Get.snackbar('Error', 'Error al obtener las configuraciones');
        return Configurations();
      }
    } catch (e, s) {
      print('Error en configurations.dart: $e $s');
    }
    return Configurations();
  }


  //pedimos todas las ubicaciones disponibles para el usuario
  Future<List<ResultUbicaciones>> ubicaciones(
  ) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        print("Error: No hay conexión a Internet.");
        return []; // Si no hay conexión, retornar una lista vacía
      }

      var response = await ApiRequestService().get(
        endpoint: 'ubicaciones',
        isunecodePath: true,
        isLoadinDialog: false,
      );
      if (response.statusCode < 400) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 200) {
             if (jsonResponse['result'].containsKey('result')) {
              // Si contiene 'result', se procede con el mapeo
              List<dynamic> responseUbicaciones = jsonResponse['result']['result'];
              List<ResultUbicaciones> ubicaciones =
                  responseUbicaciones.map((data) => ResultUbicaciones.fromMap(data)).toList();
              return ubicaciones;
            }
          }
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
            return [];
          }
        }
      } else {
        Get.snackbar('Error', 'Error al obtener las configuraciones');
        return [];
      }
    } catch (e, s) {
      print('Error en configurations.dart: $e $s');
    }
    return [];
  }
}
