

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/models/response_pick_model.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class PickingPickRepository {




  Future<List<ResultPick>> resPicks(
    bool isLoadinDialog,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().get(
        endpoint: 'transferencias/pick',
        isunecodePath: true,
        isLoadinDialog: isLoadinDialog,
      );

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 400) {
            Get.snackbar(
              'Error',
              'Error : ${jsonResponse['result']['msg']}',
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: Icon(Icons.check, color: Colors.red),
            );
          } else if (jsonResponse['result']['code'] == 200) {
            if (jsonResponse['result'].containsKey('result')) {
              // Si contiene 'result', se procede con el mapeo
              List<dynamic> batches = jsonResponse['result']['result'];
              List<ResultPick> products =
                  batches.map((data) => ResultPick.fromMap(data)).toList();
              return products;
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
      } else {}
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores

      Get.snackbar(
        'Error',
        'Error en resPicks: $e $s',
        backgroundColor: white,
        colorText: primaryColorApp,
        icon: Icon(Icons.check, color: Colors.red),
      );

      print('Error resPicks: $e, $s');
    }
    return [];
  }
  Future<List<ResultPick>> resPickingComponentes(
    bool isLoadinDialog,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().get(
        endpoint: 'picking/componentes',
        isunecodePath: true,
        isLoadinDialog: isLoadinDialog,
      );

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 400) {
            Get.snackbar(
              'Error',
              'Error : ${jsonResponse['result']['msg']}',
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: Icon(Icons.check, color: Colors.red),
            );
          } else if (jsonResponse['result']['code'] == 200) {
            if (jsonResponse['result'].containsKey('result')) {
              // Si contiene 'result', se procede con el mapeo
              List<dynamic> batches = jsonResponse['result']['result'];
              List<ResultPick> products =
                  batches.map((data) => ResultPick.fromMap(data)).toList();
              return products;
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
      } else {}
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores

      Get.snackbar(
        'Error',
        'Error en resPicks: $e $s',
        backgroundColor: white,
        colorText: primaryColorApp,
        icon: Icon(Icons.check, color: Colors.red),
      );

      print('Error resPicks: $e, $s');
    }
    return [];
  }




}