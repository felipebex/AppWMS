import 'dart:convert';

import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/global/login/models/user_model_response.dart';
import 'package:wms_app/src/services/preferences.dart';

class LoginRepository {
  Future<UserModelResponse> login(
    String email,
    String password,
  ) async {
    try {

      final String dataBd = Preferences.nameDatabase ;


      var response = await ApiRequestService().post(endpoint: 'login', body: {
        "url_rpc": "http://34.30.1.186:8069",
        "db_rpc": dataBd,
        "email_rpc": email,
        "clave_rpc": password,
      },
      isLoadinDialog: true
      );

      if (response.statusCode < 400) {
        return UserModelResponse.fromMap(jsonDecode(response.body));
      } else {
        return UserModelResponse();
      }
    } catch (e, s) {
      print('Error en login_repository.dart: $e $s');
    }
    return UserModelResponse();
  }
}
