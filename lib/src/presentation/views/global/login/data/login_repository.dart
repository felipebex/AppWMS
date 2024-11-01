import 'dart:convert';

import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/global/login/models/user_model_response.dart';

class LoginRepository {
  Future<UserModelResponse> login(
    String email,
    String password,
  ) async {
    try {
      var response = await ApiRequestService().post(endpoint: 'login', body: {
        "url_rpc": "http://34.30.1.186:8069",
        "db_rpc": "paisapan",
        "email_rpc": "felipe.bedoya@bexsoluciones.com",
        "clave_rpc": "Desarrollo"
      });

      return UserModelResponse.fromMap(jsonDecode(response.body));
    } catch (e, s) {
      print('Error en login_repository.dart: $e $s');
    }
    return UserModelResponse();
  }
}
