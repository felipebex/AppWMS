// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

class UserRepository {


  Future<Configurations> configurations() async {
    try {
           final String userEmail = await PrefUtils.getUserEmail();
      final String pass = await PrefUtils.getUserPass();
      final String dataBd = Preferences.nameDatabase;

      var response = await ApiRequestService().post(
          endpoint: 'configurations',
          body: {
            "url_rpc": "http://34.30.1.186:8069",
            "db_rpc": dataBd,
            "email_rpc": userEmail,
            "clave_rpc": pass,
          },
          isLoadinDialog: false);

      if (response.statusCode < 400) {
        return Configurations.fromMap(jsonDecode(response.body));
       
      } else {
        return Configurations();
      }
    } catch (e, s) {
      print('Error en configurations.dart: $e $s');
    }
    return Configurations();
  }

  
}
