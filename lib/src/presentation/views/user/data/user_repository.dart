// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

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

       final String urlRpc =   Preferences.urlWebsite;
      final String userEmail = await PrefUtils.getUserEmail();
      final String pass = await PrefUtils.getUserPass();
      final String dataBd = Preferences.nameDatabase;

      var response = await ApiRequestService().post(
          endpoint: 'configurations',
          body: {
            "url_rpc": urlRpc,
            "db_rpc": dataBd,
            "email_rpc": userEmail,
            "clave_rpc": pass,
          },
          isLoadinDialog: false,
          context: context
          );

      if (response.statusCode < 400) {
        Preferences.setIntList = [0];
        return Configurations.fromMap(jsonDecode(response.body));
      } else {
        Preferences.setIntList = [1];
        return Configurations();
      }
    } catch (e, s) {
      print('Error en configurations.dart: $e $s');
    }
    return Configurations();
  }
}
