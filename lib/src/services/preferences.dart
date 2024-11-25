import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _prefs;

  static String _urlWebsite = '';
  static String _nameDatabase = '';

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String get urlWebsite {
   final response=  _prefs.getString('urlWebsite') ?? _urlWebsite;
    return response;
  }

  static set setUrlWebsite(String urlWebsite) {
    _urlWebsite = urlWebsite;
    _prefs.setString('urlWebsite', urlWebsite);
  }

  static String get nameDatabase {
    return _prefs.getString('nameDatabase') ?? _nameDatabase;
  }

  static set nameDatabase(String nameDatabase) {
    _nameDatabase = nameDatabase;
    _prefs.setString('nameDatabase', nameDatabase);
  }


  //eliminar los datos guardaod s de urlwebsite
  static void removeUrlWebsite() {
    _prefs.remove('urlWebsite');
  }


  //metodo para gyar un arreglo de datos de tipo int
  static List<int> get getIntList {
    return _prefs.getStringList('intList')?.map((e) => int.parse(e)).toList() ?? [];
  }

  //metodo para obtener un arreglo de datos de tipo int
  static set setIntList(List<int> intList) {
    _prefs.setStringList('intList', intList.map((e) => e.toString()).toList());
  }
  


}
