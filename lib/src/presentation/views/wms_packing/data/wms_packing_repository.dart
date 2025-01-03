// ignore_for_file: avoid_print, unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/new_package_response.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/response_sedn_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/sen_packing_request.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

class WmsPackingRepository {
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
      final String urlRpc = Preferences.urlWebsite;
      final String userEmail = await PrefUtils.getUserEmail();
      final String pass = await PrefUtils.getUserPass();
      final String dataBd = Preferences.nameDatabase;

      var response = await ApiRequestService().post(
          endpoint: 'batch_packing',
          isunecodePath: true,
          body: {
            "url_rpc": urlRpc,
            "db_rpc": dataBd,
            "email_rpc": userEmail,
            "clave_rpc": pass,
          },
          isLoadinDialog: isLoadinDialog,
          context: context);

      if (response.statusCode < 400) {
        Preferences.setIntList = [0];
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
        Preferences.setIntList = [1];
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

  //endpoint para crear un nuevo paquete
  Future<NewPackageResponse> newPackage(
    bool isLoadinDialog,
    BuildContext context,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return NewPackageResponse(); // Si no hay conexión, retornar un objeto vacío
    }

    try {
      final String urlRpc = Preferences.urlWebsite;
      final String userEmail = await PrefUtils.getUserEmail();
      final String pass = await PrefUtils.getUserPass();
      final String dataBd = Preferences.nameDatabase;

      var response = await ApiRequestService().post(
        endpoint: 'create_packaing', // Endpoint actualizado
        isunecodePath: true,
        body: {
          "url_rpc": urlRpc,
          "db_rpc": dataBd,
          "email_rpc": userEmail,
          "clave_rpc": pass,
        },
        isLoadinDialog: isLoadinDialog,
        context: context,
      );

      if (response.statusCode < 400) {
        Preferences.setIntList = [0];
        // Decodificamos la respuesta JSON
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Verificamos que la respuesta contiene la clave 'data' y que 'data' es un mapa
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];

          // Si contiene la clave 'packaging' y es una lista
          if (data.containsKey('packaging') && data['packaging'] is List) {
            List<dynamic> packagingList = data['packaging'];

            // Mapeamos los datos de la lista a objetos NewPackaging
            List<NewPackage> packaging =
                packagingList.map((item) => NewPackage.fromMap(item)).toList();

            // Retornamos el modelo NewPackage con la información
            return NewPackageResponse(
              data: DataPackage(
                code: data['code'],
                msg: data['msg'],
                packaging: packaging,
              ),
            );
          }
        }
      } else {
        Preferences.setIntList = [1];
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          print("data: $data");

          // Mostramos alerta del error
          Get.snackbar(
            'Error en create_packaing : ${data['code']}',
            data['msg'],
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        print('Error en create_packaing: respuesta errónea');
      }
    } on SocketException catch (e) {
      print('Error de red: $e');
      return NewPackageResponse(); // Retornamos un objeto vacío en caso de error de red
    } catch (e, s) {
      // Manejo de otros errores
      print('Error en create_packaing: $e, $s');
    }

    return NewPackageResponse(); // Retornamos un objeto vacío si no hay resultados
  }

  Future<ResponseSendPacking> sendPackingRequest(PackingRequest packingRequest,
      bool isLoadingDialog, BuildContext context) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return ResponseSendPacking(); // Si no hay conexión, terminamos la ejecución
    }
    final String urlRpc = Preferences.urlWebsite;
    final String userEmail = await PrefUtils.getUserEmail();
    final String pass = await PrefUtils.getUserPass();
    final String dataBd = Preferences.nameDatabase;
    // final int userId = await PrefUtils.getUserId();

    try {
      var headers = {
        'Content-Type': 'application/json',
      };

      var body = json.encode(
        {
          "url_rpc": urlRpc,
          "db_rpc": dataBd,
          "email_rpc": userEmail,
          "clave_rpc": pass,
          "id_batch": packingRequest.idBatch,
          "id_paquete": packingRequest.idPaquete,
          "is_package": packingRequest.isPackage,
          "peso_total_paquete": packingRequest.pesoTotalPaquete,
          "list_item":
              packingRequest.listItem.map((item) => item.toMap()).toList(),
        },
      );
      print("=====================================");
      print("body: $body");
      print("=====================================");
      print("list_item: ${packingRequest.listItem.map((item) => item.toMap()).toList()}");
      print("list_item_length: ${packingRequest.listItem.length}");
      print("=====================================");

      var response = await ApiRequestService().sendPacking(
        headers: headers,
        endpoint:
            'send_packing', // Cambiado para que sea el endpoint correspondiente
        body: body,
      );
      print("response.statusCode: ${response}");
      if (response.statusCode < 400) {
        // Si la respuesta es exitosa, procesamos los datos
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];

          // Verificamos si la respuesta contiene 'code' y si es un éxito (por ejemplo, código 200)
          if (data['code'] == 200) {
            return ResponseSendPacking(
              data: DataResponsePacking.fromMap(data),
            );
          } else {
            // Si no es un éxito, mostramos el mensaje de error
            Get.snackbar(
              'Error',
              data['msg'],
              duration: const Duration(seconds: 5),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );

            return ResponseSendPacking();
          }
        }
      } else {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          print("data: $data");

          Get.snackbar(
            'Error en sendPackingRequest : ${data['code']}',
            data['msg'],
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return ResponseSendPacking();
        }
        print('Error en sendPackingRequest: respuesta errónea');
        return ResponseSendPacking();
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
}
