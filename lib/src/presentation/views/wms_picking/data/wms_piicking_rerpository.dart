// // ignore_for_file: avoid_print

// ignore_for_file: unrelated_type_equality_checks, avoid_print, use_build_context_synchronously

// import 'package:wms_app/src/api/api_request_service.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/item_picking_request.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'dart:io';

import 'package:wms_app/src/presentation/views/wms_picking/models/response_send_picking.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/submeuelle_model.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

class WmsPickingRepository {

  //metodo para pedir los batchs
  Future<List<BatchsModel>> resBatchs(
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
          endpoint: 'batchs',
          body: {
            "url_rpc": urlRpc,
            "db_rpc": dataBd,
            "email_rpc": userEmail,
            "clave_rpc": pass,
          },
          isLoadinDialog: isLoadinDialog,
          context: context);

      if (response.statusCode < 400) {
        //gardamos la respuesta de la peticion en el arreglo
        Preferences.setIntList = [0];

        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          // Asegúrate de que 'result' exista y sea una lista
          if (data.containsKey('result') && data['result'] is List) {
            List<dynamic> batches = data['result'];
            // Mapea los datos decodificados a una lista de BatchsModel
            List<BatchsModel> products =
                batches.map((data) => BatchsModel.fromMap(data)).toList();
            return products;
          }
        }
      } else {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          print("data: $data");
          //mostramos alerta del error
          Get.snackbar(
            'Error en batchs : ${data['code']}',
            data['msg'],
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }

        print('Error resBatchs: response is null');
      }
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores
      print('Error resBatchs: $e, $s');
    }
    return [];
  }
  
  //metodo para pedir los batchs por id
  Future<List<BatchsModel>> getBatchById(
      bool isLoadinDialog, BuildContext context, int batchId) async {
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
          endpoint: 'batch/$batchId',
          body: {
            "url_rpc": urlRpc,
            "db_rpc": dataBd,
            "email_rpc": userEmail,
            "clave_rpc": pass,
          },
          isLoadinDialog: isLoadinDialog,
          context: context);

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          // Asegúrate de que 'result' exista y sea una lista
          if (data.containsKey('result') && data['result'] is List) {
            List<dynamic> batches = data['result'];
            // Mapea los datos decodificados a una lista de BatchsModel
            List<BatchsModel> products =
                batches.map((data) => BatchsModel.fromMap(data)).toList();
            return products;
          }
        }
      } else {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          print("data: $data");
          //mostramos alerta del error
          Get.snackbar(
            'Error en getBatchById : ${data['code']}',
            data['msg'],
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }

        print('Error getBatchById: response is null');
      }
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores
      print('Error getBatchById: $e, $s');
    }
    return [];
  }

  //metodo para pedir los submuelles
  Future<List<Muelles>> getmuelles(
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
          endpoint: 'muelles',
          body: {
            "url_rpc": urlRpc,
            "db_rpc": dataBd,
            "email_rpc": userEmail,
            "clave_rpc": pass,
          },
          isLoadinDialog: isLoadinDialog,
          context: context);

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result') &&
            jsonResponse['result'] is List) {
          List<dynamic> batches = jsonResponse['result'];
          // Mapea los datos decodificados a una lista de BatchsModel
          List<Muelles> products =
              batches.map((data) => Muelles.fromMap(data)).toList();
          return products;
        }
      } else {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          print("data: $data");
          //mostramos alerta del error
          Get.snackbar(
            'Error en getmuelles : ${data['code']}',
            data['msg'],
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }

        print('Error getmuelles: response is null');
      }
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores
      print('Error getmuelles: $e, $s');
    }
    return [];
  }

  Future<SendPickingResponse> sendPicking({
    required int idBatch,
    required double timeTotal,
    required int cantItemsSeparados,
    required List<Item> listItem, //
  }) async {
    final String urlRpc = Preferences.urlWebsite;
    final String userEmail = await PrefUtils.getUserEmail();
    final String pass = await PrefUtils.getUserPass();
    final int userId = await PrefUtils.getUserId();
    final String dataBd = Preferences.nameDatabase;

    var headers = {
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      "url_rpc": urlRpc,
      "db_rpc": dataBd,
      "email_rpc": userEmail,
      "clave_rpc": pass,
      "id_batch": idBatch,
      "time_total": timeTotal,
      "id_operario": userId,
      "cant_items_separados": cantItemsSeparados,
      "list_item": listItem.map((item) => item.toJson()).toList(),
    });

    print('Body sendPicking: $body');

    try {
      var response = await ApiRequestService()
          .sendPicking(endpoint: 'send_batch', body: body, headers: headers);

      print('Response sendPicking: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Picking enviado correctamente');
        log("Response sendPicking: ${response.body}");
        //actualizamos el estado de envio de odoo de los productos
        return SendPickingResponse.fromJson(response.body);

        //volver a enviar los represados
      } else {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          print("data: $data");
          //mostramos alerta del error
          Get.snackbar(
            'Error en send_batch : ${data['code']}',
            data['msg'],
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        print('Error sendPicking: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
    } catch (e, s) {
      // Manejo de otros errores
      print('Error sendPicking: $e, $s');
    }
    return SendPickingResponse();
  }



  //metod para obtener las novedades: 
  Future<List<Novedad>> getnovedades(
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
          endpoint: 'picking_novelties',
          body: {
            "url_rpc": urlRpc,
            "db_rpc": dataBd,
            "email_rpc": userEmail,
            "clave_rpc": pass,
          },
          isLoadinDialog: isLoadinDialog,
          context: context);

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result') &&
            jsonResponse['result'] is List) {
          List<dynamic> batches = jsonResponse['result'];
          // Mapea los datos decodificados a una lista de BatchsModel
          List<Novedad> products =
              batches.map((data) => Novedad.fromMap(data)).toList();
          return products;
        }
      } else {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          print("data: $data");
          //mostramos alerta del error
          Get.snackbar(
            'Error en getnovedades : ${data['code']}',
            data['msg'],
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }

        print('Error getnovedades: response is null');
      }
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores
      print('Error getnovedades: $e, $s');
    }
    return [];
  }

}
