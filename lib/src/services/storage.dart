import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static GetStorage? _preferences;

  static Future<LocalStorageService?> getInstance({ bool testing  = false}) async {
    _instance ??= LocalStorageService();
    await GetStorage.init();
    _preferences ??= GetStorage();
    return _instance;
  }

  String? getString(key) {
    if (_preferences == null) return null;
    return _preferences!.read(key);
  }

  Map<String, dynamic>? getObject(key) {
    if (_preferences == null) return null;
    final objectString = _preferences?.read(key);
    if (objectString != null) {
      return const JsonDecoder().convert(objectString);
    }
    return null;

  }

  int? getInt(key) {
    if (_preferences == null) return null;
    return _preferences!.read(key);
  }

  double? getDouble(key) {
    if (_preferences == null) return null;
    return _preferences!.read(key);
  }

  bool? getBool(key) {
    if (_preferences == null) return null;
    return _preferences!.read(key);
  }

  void setString(key, value) {
    if (_preferences == null) return;
    if(value == null) return;
    _preferences!.write(key, value);
  }

  void setObject(key, object){
    if(_preferences == null) return;
    if(object == null) return;
    final string = const JsonEncoder().convert(object);
    _preferences?.write(key, string);
  }

  void setInt(key, value) {
    if (_preferences == null) return;
    if(value == null) return;
    _preferences!.write(key, value);
  }

  void setDouble(key, value) {
    if (_preferences == null) return;
    if(value == null) return;
    _preferences!.write(key, value);
  }

  void setBool(key, value) {
    if (_preferences == null) return;
    if(value == null) return;
    _preferences!.write(key, value);
  }

  void remove(key) {
    if (_preferences == null) return;
    _preferences!.remove(key);
  }

  Future<void> clear() async {
    if (_preferences == null) return;
    await _preferences!.erase();
  }
}
