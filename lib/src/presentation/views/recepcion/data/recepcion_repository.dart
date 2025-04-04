// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/repcion_requets_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_lotes_product_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_new_lote_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_send_recepcion_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_validate_model.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class RecepcionRepository {
//metodo para obtener todas las ordenes de compra

  Future<List<ResultEntrada>> resBatchsPacking(
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
        endpoint: 'recepciones',
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
          List<ResultEntrada> ordenes =
              batches.map((data) => ResultEntrada.fromMap(data)).toList();
            return ordenes;
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
      print('Error resBatchsPacking: $e, $s');
    }
    return [];
  }

  Future<List<LotesProduct>> fetchAllLotesProduct(
      bool isLoadinDialog,  int productId) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().get(
        endpoint: 'lotes/$productId',
        isunecodePath: true,
        isLoadinDialog: isLoadinDialog,
      );

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          List<dynamic> response = jsonResponse['result']['result'];
          // Mapea los datos decodificados a una lista de BatchsModel
          List<LotesProduct> lotes =
              response.map((data) => LotesProduct.fromMap(data)).toList();

          if (lotes.isNotEmpty) {
            return lotes;
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
      print('Error lotes de un producto: $e, $s');
    }
    return [];
  }

  //metodo para asignar un usuario a una orden de compra
  Future<bool> assignUserToOrder(
    bool isLoadinDialog,
    int idUser,
    int idRecepcion,
  
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return false; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().postPacking(
          endpoint: 'asignar_responsable',
          isLoadinDialog: isLoadinDialog,
          body: {
            "params": {
              "id_recepcion": idRecepcion,
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
      print('Error assignUserToOrder: $e, $s');
    }
    return false;
  }

  Future<ResponseNewLote> createLote(
    bool isLoadinDialog,
    int idProduct,
    String nameLote,
    String dateLote,
 
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return ResponseNewLote(); // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().postPacking(
          endpoint: 'create_lote',
          isLoadinDialog: isLoadinDialog,
          body: {
            "params": {
              "id_producto": idProduct,
              "nombre_lote": nameLote,
              "fecha_vencimiento": dateLote,
            }
          });

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 200) {
            return ResponseNewLote(
              jsonrpc: jsonResponse['jsonrpc'],
              id: jsonResponse['id'],
              result: jsonResponse['result'] != null
                  ? ResponseNewLoteResult.fromMap(jsonResponse['result'])
                  : null,
            );
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

            return ResponseNewLote();
          }
        }
      }
    } on SocketException catch (e) {
      print('Error de red: $e');
      return ResponseNewLote();
    } catch (e, s) {
      // Manejo de otros errores
      print('Error resBatchsPacking: $e, $s');
    }
    return ResponseNewLote();
  }

//metodo para enviar los productos recepcionados de la orden de entrada
  Future<ResponSendRecepcion> sendProductRecepcion(
      RecepcionRequest recepcionRequest,
      bool isLoadingDialog,
      ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return ResponSendRecepcion(); // Si no hay conexión, terminamos la ejecución
    }

    try {
      var response = await ApiRequestService().postPacking(
        endpoint:
            'send_recepcion', // Cambiado para que sea el endpoint correspondiente
        body: {
          "params": {
            "id_recepcion": recepcionRequest.idRecepcion,
            "list_items":
                recepcionRequest.listItems.map((item) => item.toMap()).toList(),
          },
        },
        isLoadinDialog: true,
      );
      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Verifica si la respuesta contiene la clave 'result' y convierte la lista correctamente
        var resultData = jsonResponse['result'];

        return ResponSendRecepcion(
          jsonrpc: jsonResponse['jsonrpc'],
          id: jsonResponse['id'],
          result: resultData != null
              ? ResponSendRecepcionResult(
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
      return ResponSendRecepcion(); // Retornamos un objeto vacío en caso de error de red
    } catch (e, s) {
      // Manejo de otros errores
      print('Error en sendPackingRequest: $e, $s');
      return ResponSendRecepcion(); // Retornamos un objeto vacío en caso de error de red
    }
    return ResponSendRecepcion(); // Retornamos un objeto vacío en caso de error de red
  }

  Future<bool> sendTime(int idRecepcion, String field, String date,
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
            'update_time_reception', // Cambiado para que sea el endpoint correspondiente
        body: {
          "params": {
            "reception_id": idRecepcion,
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
      print('Error en sendReceptionRequest: $e, $s');
      return false; // Retornamos un objeto vacío en caso de error de red
    }
    return false; // Retornamos un objeto vacío en caso de error de red
  }

  Future<ResponseValidate> validateRecepcion(int idRecepcion, bool isBackorder,
      bool isLoadingDialog, ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return ResponseValidate(); // Si no hay conexión, terminamos la ejecución
    }

    try {
      var response = await ApiRequestService().postPacking(
        endpoint:
            'complete_recepcion', // Cambiado para que sea el endpoint correspondiente
        body: {
          "params": {
            "id_recepcion": idRecepcion,
            "crear_backorder": isBackorder,
          }
        },
        isLoadinDialog: true,
      );
      if (response.statusCode <= 500) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('result')) {
          return ResponseValidate(
            jsonrpc: jsonResponse['jsonrpc'],
            result: jsonResponse['result'] != null
                ? ResultValidate.fromMap(jsonResponse['result'])
                : null,
          );
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

            return ResponseValidate();
          }
        }
      }
    } on SocketException catch (e) {
      print('Error de red: $e');
      return ResponseValidate(); // Retornamos un objeto vacío en caso de error de red
    } catch (e, s) {
      // Manejo de otros errores
      print('Error en sendPackingRequest: $e, $s');
      return ResponseValidate(); // Retornamos un objeto vacío en caso de error de red
    }
    return ResponseValidate(); // Retornamos un objeto vacío en caso de error de red
  }
}
