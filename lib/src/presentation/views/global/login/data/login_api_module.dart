// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wms_app/src/api/api.dart';
import 'package:wms_app/src/api/api_end_points.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginApiModule {
  final storage = const FlutterSecureStorage();

  //* iniciamos sesion a una base de datos
  static Future<bool> loginUser(String email, String password, BuildContext context) async {
    var params = {
      "db": Preferences.nameDatabase,
      "login": email,
      "password": password,
      "context": {}
    };
    try {
      print("params: $params");
      var response = await Api.request(
        method: HttpMethod.post,
        path: ApiEndPoints.authenticate,
        params: Api.createPayload(params),
        context: context,

      );
      print("params: $params");
      if (response != null) {
        PrefUtils.setUser(jsonEncode(response));
        PrefUtils.setIsLoggedIn(true);
        return true;
      } else {
        return false;
      }
    } catch (error, s) {
      print("Error en loginUser ApiModule: $error $s");
      return false;
    }
  }

  Future logout() async {
    await storage.delete(key: 'emailToken');

    return;
  }

  Future<String> isAutenticate() async {
    return await storage.read(key: 'emailToken') ?? '';
  }
}
