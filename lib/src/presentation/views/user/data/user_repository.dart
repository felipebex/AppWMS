// ignore_for_file: avoid_print, use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';

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
          context: context);

      if (response.statusCode < 400) {
        
        return Configurations.fromMap(jsonDecode(response.body));
      } else {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          Map<String, dynamic> data = jsonResponse['data'];
          print("data: $data");
          //mostramos alerta del error
          Get.snackbar(
            'Error en configurations : ${data['code']}',
            data['msg'],
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }

        return Configurations();
      }
    } catch (e, s) {
      print('Error en configurations.dart: $e $s');
    }
    return Configurations();
  }
}
