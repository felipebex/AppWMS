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

  static getUserPass() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(PrefKeys.pass) ?? "";
  }

//guardamos la cookie de la ultima petición
  static Future<void> setCookie(String cookie) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(PrefKeys.cookie, cookie);
  }

//obtenemos la cookie de la ultima petición
  static Future<String> getCookie() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(PrefKeys.cookie) ?? "";
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

//user id
  static Future<void> setUserId(int id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt(PrefKeys.userId, id);
  }

//obtenemos el id del usuario
  static Future<int> getUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(PrefKeys.userId) ?? 0;
  }

//*contraseña
  static Future<void> setUserPass(String pass) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(PrefKeys.pass, pass);
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

  //METODO PARA ELIMINAR LOS DATOS DEL USUARIO
  static Future<void> clearUserData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(PrefKeys.user);
    await preferences.remove(PrefKeys.email);
    await preferences.remove(PrefKeys.pass);
    await preferences.remove(PrefKeys.userId);
    await preferences.remove(PrefKeys.rol);
    await preferences.remove(PrefKeys.isLoggedIn);
  }
}
