import 'dart:convert';

import 'package:wms_app/src/presentation/views/global/login/models/user_model_response.dart';
import 'package:wms_app/src/utils/prefs/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  PrefUtils();



  static setEnterprise(String enterprise) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(PrefKeys.enterprise, enterprise);
  }

  static Future<String> getEnterprise() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(PrefKeys.enterprise) ?? "";
  }

  static setIsLoggedIn(bool isLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(PrefKeys.isLoggedIn, isLoggedIn);
  }

  static Future<bool> getIsLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(PrefKeys.isLoggedIn) ?? false;
  }


//todo guardamos los datos del usuario
//*nombre
static Future<void> setUserName(String name) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString(PrefKeys.user, name);
}
//*correo
static Future<void> setUserEmail(String email) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString(PrefKeys.email, email);
}
//*rol
static Future<void> setUserRol(String rol) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString(PrefKeys.rol, rol);
}

//*obtenemos los datos del usuario
static Future<String> getUserName() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(PrefKeys.user) ?? "";
}
static Future<String> getUserEmail() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(PrefKeys.email) ?? "";
}
static Future<String> getUserRol() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(PrefKeys.rol) ?? "";
}

  static clearPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

}
