// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/home/domain/models/app_version_model.dart';

class HomeRepository {
  Future<AppVersion> getAppVersion(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return AppVersion(); // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().get(
          endpoint: 'last-version',
          isunecodePath: true,
          isLoadinDialog: true,
          context: context);

      if (response.statusCode < 400) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Decodifica la respuesta JSON a un mapa
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 400) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Error : ${jsonResponse['result']['msg']}',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
          } else if (jsonResponse['result']['code'] == 200) {
            return AppVersion.fromMap(jsonDecode(response.body));
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
            return AppVersion();
          }
        }
        return AppVersion();
      } else {
        return AppVersion();
      }
    } catch (e, s) {
      print('Error en get last version: $e => $s');
      return AppVersion();
    }
  }
}
