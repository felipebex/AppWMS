import 'dart:convert';

import 'package:wms_app/src/presentation/views/global/login/models/user_model.dart';
import 'package:wms_app/src/utils/prefs/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  PrefUtils();

  static setToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(PrefKeys.token, token);
  }

  static Future<String> getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(PrefKeys.token) ?? "";
  }

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

  static setUser(String userData) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(PrefKeys.user, userData);
  }

  static Future<UserModel> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map<String, dynamic> user =
        jsonDecode(preferences.getString(PrefKeys.user) ?? "{}");
    return UserModel.fromJson(user);
  }

  static clearPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  static Future<void> setExpirationDate(DateTime expirationDate) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
        PrefKeys.expirationDate, expirationDate.toIso8601String());
  }

  static Future<DateTime?> getExpirationDate() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? dateString = preferences.getString(PrefKeys.expirationDate);
    return dateString != null ? DateTime.parse(dateString) : null;
  }
}
