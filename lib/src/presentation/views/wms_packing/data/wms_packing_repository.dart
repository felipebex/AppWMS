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

class WmsPackingRepository {
  //endpoint para obtener todos los batch de packing con sus pedidos y productos
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
          return batchs;
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
      var response = await ApiRequestService().postPacking(
        endpoint: 'create_package', // Endpoint actualizado
        body: {"params": {}},
        isLoadinDialog: isLoadinDialog,
        context: context,
      );

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          Map<String, dynamic> package = jsonResponse['result']['packaging'];
          print(package);
          return NewPackageResponse(
              result: DataPackage(
                  code: jsonResponse['result']['code'],
                  msg: jsonResponse['result']['msg'],
                  packaging: NewPackage(
                    id: package['id'],
                    name: package['name'],
                    createDate: DateTime.parse(package['create_date']),
                    writeDate: DateTime.parse(package['write_date']),
                  )));
        }
      } else {}
    } on SocketException catch (e) {
      print('Error de red: $e');
      return NewPackageResponse(); // Retornamos un objeto vacío en caso de error de red
    } catch (e, s) {
      // Manejo de otros errores
      print('Error en create_packaing: $e, $s');
    }

    return NewPackageResponse(); // Retornamos un objeto vacío si no hay resultados
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
            "id_paquete": packingRequest.idPaquete,
            "is_sticker": packingRequest.isCertificate,
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
}
