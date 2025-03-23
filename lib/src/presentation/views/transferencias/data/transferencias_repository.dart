// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class TransferenciasRepository {
  Future<List<ResultTransFerencias>> fetAllTransferencias(
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
        endpoint: 'transferencias',
        isunecodePath: true,
        isLoadinDialog: isLoadinDialog,
      );
      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          List<dynamic> batches = jsonResponse['result']['result'];
          // Mapea los datos decodificados a una lista de BatchsModel
          List<ResultTransFerencias> transferencias = batches
              .map((data) => ResultTransFerencias.fromMap(data))
              .toList();

          if (transferencias.isNotEmpty) {
            print('Transferencias: ${transferencias.length}');
            return transferencias;
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
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores
      print('Error fetAllTransferencias: $e, $s');
    }
    return [];
  }




  Future<bool> sendTime(int idTransfer, String field, String date,
      bool isLoadingDialog,  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return true; // Si no hay conexión, terminamos la ejecución
    }

    try {
      var response = await ApiRequestService().postPacking(
        endpoint:
            'update_time_transfer', // Cambiado para que sea el endpoint correspondiente
        body: {
          "params": {
            "transfer_id": idTransfer,
            "time": date,
            "field_name": field
            // "field_name": "end_time_reception"
          }
        },
        isLoadinDialog: false,
      );
      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 200) {
            return true;
          } else {
            return false;
          }
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            //mostramos una alerta de get
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

            return false;
          }
        }
      } else {
        // Manejo de error si la respuesta no es exitosa
        // ...
      }
    } on SocketException catch (e) {
      print('Error de red: $e');
      return false; // Retornamos un objeto vacío en caso de error de red
    } catch (e, s) {
      // Manejo de otros errores
      print('Error en sendTransferRequest: $e, $s');
      return false; // Retornamos un objeto vacío en caso de error de red
    }
    return false; // Retornamos un objeto vacío en caso de error de red
  }




  //metodo para asignar un usuario a una orden de compra
  Future<bool> assignUserToTransfer(
    bool isLoadinDialog,
    int idUser,
    int idTransfer,
  
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return false; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().postPacking(
          endpoint: 'transferencias/asignar',
          isLoadinDialog: isLoadinDialog,
          body: {
            "params": {
              "id_transferencia": idTransfer,
              "id_responsable": idUser,
            }
          });

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 200) {
            return true;
          } else {
            return false;
          }
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            //mostramos una alerta de get
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

            return false;
          }
        }
      } else {}
    } on SocketException catch (e) {
      print('Error de red: $e');
      return false;
    } catch (e, s) {
      // Manejo de otros errores
      print('Error assignUserToTransfer: $e, $s');
    }
    return false;
  }


}
