import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/info_rapida_model.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/response_sen_transfer_info_model.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/transfer_info_request.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/update_product_request.dart';

class InfoRapidaRepository {
  Future<InfoRapida> getInfoQuick(bool isLoadinDialog, String barcode) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return InfoRapida(); // Si no hay conexión, retornar una lista vacía
    }

    try {
      print("barcode $barcode");
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

  Future<InfoRapida> getInfoQuickManual(
      bool isLoadinDialog, String id, bool isProduct) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return InfoRapida(); // Si no hay conexión, retornar una lista vacía
    }

    try {
      print("id $id");
      var response = await ApiRequestService().getInfo(
        endpoint: 'transferencias/quickinfo/id',
        body: {
          "params": isProduct ? {"id_product": id} : {"id_location": id}
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

//metodo para enviar los productos recepcionados de la orden de entrada
  Future<SendTransferResponse> sendProductTransferInfo(
    TransferInfoRequest transferInfoRequest,
    bool isLoadingDialog,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return SendTransferResponse(); // Si no hay conexión, terminamos la ejecución
    }

    print("transferRequest ${transferInfoRequest.toMap()}");

    try {
      var response = await ApiRequestService().postPacking(
        endpoint:
            'crear_transferencia', // Cambiado para que sea el endpoint correspondiente
        body: {
          "params": {
            "id_almacen": transferInfoRequest.idAlmacen,
            "id_move": transferInfoRequest.idMove,
            "id_producto": transferInfoRequest.idProducto,
            "id_lote": transferInfoRequest.idLote,
            "id_ubicacion_origen": transferInfoRequest.idUbicacionOrigen,
            "id_ubicacion_destino": transferInfoRequest.idUbicacionDestino,
            "cantidad_enviada": transferInfoRequest.cantidadEnviada,
            "id_operario": transferInfoRequest.idOperario,
            "time_line": transferInfoRequest.timeLine,
            "fecha_transaccion": transferInfoRequest.fechaTransaccion,
            "observacion": transferInfoRequest.observacion,
          },
        },
        isLoadinDialog: true,
      );
      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Verifica si la respuesta contiene la clave 'result' y convierte la lista correctamente
        var resultData = jsonResponse['result'];

        return SendTransferResponse(
          jsonrpc: jsonResponse['jsonrpc'],
          id: jsonResponse['id'],
          result: resultData != null
              ? Result.fromMap(resultData) // Usa el fromMap del resultado
              : null, // Si 'result' no existe, asigna null a 'result'
        );
      } else {
        // Manejo de error si la respuesta no es exitosa
        print("Error en la respuesta: ${response.statusCode}");
        return SendTransferResponse(); // Retornamos un objeto vacío en caso de error
      }
    } on SocketException catch (e) {
      print('Error de red: $e');
      return SendTransferResponse(); // Retornamos un objeto vacío en caso de error de red
    } catch (e, s) {
      // Manejo de otros errores
      print('Error en sendProductTransferInfo: $e, $s');
      return SendTransferResponse(); // Retornamos un objeto vacío en caso de error de red
    }
  }

  Future<InfoRapida> updateProduct(
    UpdateProductRequest request,
    bool isLoadingDialog,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return InfoRapida(); // Si no hay conexión, terminamos la ejecución
    }

    print("request ${request.toMap()}");

    try {
      var response = await ApiRequestService().postPacking(
        endpoint:
            'update_product', // Cambiado para que sea el endpoint correspondiente
        body: {
          "params": {
            "product_id": request.productId,
            'default_code': request.defaultCode,
            "name": request.name,
            "barcode": request.barcode,
            "list_price": request.listPrice,
            "weight": request.weight,
            "volume": request.volume,
          },
        },
        isLoadinDialog: true,
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
      return InfoRapida();
    } on SocketException catch (e) {
      print('Error de red: $e');
      return InfoRapida(); // Retornamos un objeto vacío en caso de error de red
    } catch (e, s) {
      // Manejo de otros errores
      print('Error en updateProduct: $e, $s');
      return InfoRapida(); // Retornamos un objeto vacío en caso de error de red
    }
  }

  Future<InfoRapida> updateLocation(
    int id,
    String name,
    String barcode,
    bool isLoadingDialog,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return InfoRapida(); // Si no hay conexión, terminamos la ejecución
    }

    try {
      var response = await ApiRequestService().postPacking(
        endpoint:
            'update_location', // Cambiado para que sea el endpoint correspondiente
        body: {
          "params": {
            "location_id": id,
            "name": name,
            "barcode": barcode,
          },
        },
        isLoadinDialog: true,
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
      return InfoRapida();
    } on SocketException catch (e) {
      print('Error de red: $e');
      return InfoRapida(); // Retornamos un objeto vacío en caso de error de red
    } catch (e, s) {
      // Manejo de otros errores
      print('Error en updateProduct: $e, $s');
      return InfoRapida(); // Retornamos un objeto vacío en caso de error de red
    }
  }
}
