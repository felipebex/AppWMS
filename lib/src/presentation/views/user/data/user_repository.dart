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
        Get.snackbar('Error', 'Error al obtener las configuraciones');
        return Configurations();
      }
    } catch (e, s) {
      print('Error en configurations.dart: $e $s');
    }
    return Configurations();
  }
}
