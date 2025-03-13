// ignore_for_file: avoid_print, unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/response_sedn_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/sen_packing_request.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/un_packing_request.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/unpacking_response_model.dart';

class WmsPackingRepository {
  //metodo para obtener todos los batch de packing con sus pedidos y productos
  Future<List<BatchPackingModel>> resBatchsPacking(
    bool isLoadinDialog,
    BuildContext context,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().get(
        endpoint: 'batch_packing',
        isunecodePath: true,
        isLoadinDialog: isLoadinDialog,
        context: context,
      );

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          List<dynamic> batches = jsonResponse['result']['result'];
          // Mapea los datos decodificados a una lista de BatchsModel
          List<BatchPackingModel> batchs =
              batches.map((data) => BatchPackingModel.fromMap(data)).toList();

          if (batchs.isNotEmpty) {
            return batchs;
          } else {

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      "No tienes batches de packing asignados",
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
            return [];
          }
        }
         else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Sesion expirada, por favor inicie sesión nuevamente',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
            return [];
          }
        }
      } else {}
    } on SocketException catch (e) {
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores
      print('Error resBatchsPacking: $e, $s');
    }
    return [];
  }

//endpoint para desempacar productos de su caja
  Future<UnPacking> unPacking(
    UnPackingRequest request,
    BuildContext context,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return UnPacking(); // Si no hay conexión, terminamos la ejecución
    }

    try {
      var response = await ApiRequestService().postPacking(
        endpoint:
            'unpacking', // Cambiado para que sea el endpoint correspondiente
        body: {
          "params": {
            "id_batch": request.idBatch,
            "id_paquete": request.idPaquete,
            "list_item": request.listItem.map((item) => item.toMap()).toList(),
          },
        },
        isLoadinDialog: true,
        context: context,
      );
      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Verifica si la respuesta contiene la clave 'result' y convierte la lista correctamente
        var resultData = jsonResponse['result'];

        return UnPacking(
            jsonrpc: jsonResponse['jsonrpc'],
            id: jsonResponse['id'],
            result: UnPackingResult(
              code: resultData['code'],
              result: resultData['result'] != null
                  ? List<UnPackingElement>.from(resultData['result']
                      .map((x) => UnPackingElement.fromMap(x)))
                  : [], // Si no hay elementos en 'result', se retorna una lista vacía
            ));
      } else {
        // Manejo de error si la respuesta no es exitosa
        // ...
      }
    } on SocketException catch (e) {
      print('Error de red: $e');
      return UnPacking(); // Retornamos un objeto vacío en caso de error de red
    } catch (e, s) {
      // Manejo de otros errores
      print('Error en unPacking: $e, $s');
      return UnPacking(); // Retornamos un objeto vacío en caso de error de red
    }
    return UnPacking(); // Retornamos un objeto vacío en caso de error de red
  }

  //endpoint para enviar los productos dentro del paquete anteriormente creado
  Future<ResponseSendPacking> sendPackingRequest(PackingRequest packingRequest,
      bool isLoadingDialog, BuildContext context) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return ResponseSendPacking(); // Si no hay conexión, terminamos la ejecución
    }

    try {
      var response = await ApiRequestService().postPacking(
        endpoint:
            'send_packing', // Cambiado para que sea el endpoint correspondiente
        body: {
          "params": {
            "id_batch": packingRequest.idBatch,
            "is_sticker": packingRequest.isSticker,
            "is_certificate": packingRequest.isCertificate,
            "peso_total_paquete": packingRequest.pesoTotalPaquete,
            "list_item":
                packingRequest.listItem.map((item) => item.toMap()).toList(),
          },
        },
        isLoadinDialog: true,
        context: context,
      );
      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Verifica si la respuesta contiene la clave 'result' y convierte la lista correctamente
        var resultData = jsonResponse['result'];

        return ResponseSendPacking(
          jsonrpc: jsonResponse['jsonrpc'],
          id: jsonResponse['id'],
          result: resultData != null
              ? ResponseSendPackingResult(
                  code: resultData['code'],
                  result: resultData['result'] != null
                      ? List<ResultElement>.from(resultData['result']
                          .map((x) => ResultElement.fromMap(x)))
                      : [], // Si no hay elementos en 'result', se retorna una lista vacía
                )
              : null, // Si 'result' no existe, asigna null a 'result'
        );
      } else {
        // Manejo de error si la respuesta no es exitosa
        // ...
      }
    } on SocketException catch (e) {
      print('Error de red: $e');
      return ResponseSendPacking(); // Retornamos un objeto vacío en caso de error de red
    } catch (e, s) {
      // Manejo de otros errores
      print('Error en sendPackingRequest: $e, $s');
      return ResponseSendPacking(); // Retornamos un objeto vacío en caso de error de red
    }
    return ResponseSendPacking(); // Retornamos un objeto vacío en caso de error de red
  }




  Future<bool> timePackingUser(int batchId, BuildContext context, String time,
      String endpoint, String type, int userId) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return false; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().postPicking(
          endpoint: endpoint,
          isunecodePath: true,
          isLoadinDialog: false,
          context: context,
          body: {
            "params": {
              "id_batch": "$batchId",
              "user_id": "$userId",
              type: time,
              "operation_type": "packing"
            }
          });

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 400) {
            return false;
          } else if (jsonResponse['result']['code'] == 200) {
            return true;
          }
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Sesion expirada, por favor inicie sesión nuevamente',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
            return false;
          }
        }
      } else {}
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return false;
    } catch (e, s) {
      // Manejo de otros errores

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[200],
          content: SizedBox(
            width: double.infinity,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                'Error en resBatchs: $e $s',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
          
          behavior: SnackBarBehavior
              .floating, // Hace que no se cierre automáticamente
          duration:
              const Duration(seconds: 5), // Esto hace que no se cierre solo
        ),
      );

      print('Error resBatchs: $e, $s');
    }
    return false;
  }

  Future<bool> timePackingBatch(int batchId, BuildContext context, String time,
      String endpoint, String field, String type) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return false; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().postPicking(
          endpoint: endpoint,
          isunecodePath: true,
          isLoadinDialog: false,
          context: context,
          body: {
            "params": {
              "picking_id": "$batchId",
              type: time,
              "field_name": field,
            }
          });

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 400) {
            return false;
          } else if (jsonResponse['result']['code'] == 200) {
            return true;
          }
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Sesion expirada, por favor inicie sesión nuevamente',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
            return false;
          }
        }
      } else {}
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return false;
    } catch (e, s) {
      // Manejo de otros errores

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[200],
          content: SizedBox(
            width: double.infinity,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                'Error en resBatchs: $e $s',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
         
          behavior: SnackBarBehavior
              .floating, // Hace que no se cierre automáticamente
          duration:
              const Duration(seconds: 5), // Esto hace que no se cierre solo
        ),
      );

      print('Error timePackingBatch: $e, $s');
    }
    return false;
  }

}
