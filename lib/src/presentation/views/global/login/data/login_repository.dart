// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/global/login/models/user_model_response.dart';
import 'package:wms_app/src/services/preferences.dart';

class LoginRepository {
  Future<UserModelResponse> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final String dataBd = Preferences.nameDatabase;

      var response = await ApiRequestService().post(
          endpoint: 'web/session/authenticate',
          isunecodePath: false,
          body: {
            "params": {"login": email, "password": password, "db": dataBd}
          },
          isLoadinDialog: true,
          context: context);

      print('Response status code: ${response.statusCode}');
      if (response.statusCode < 400) {

        return UserModelResponse.fromMap(jsonDecode(response.body));
      } else {
        print(response.body);
        if (response.body.contains('jsonrpc')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('"Error en el metodo de la peticion de la API"'),
              duration: Duration(seconds: 5),
            ),
          );
        }
        return UserModelResponse();
      }
    } catch (e, s) {
      print('Error en login_repository.dart: $e $s');
    }
    return UserModelResponse();
  }
}
