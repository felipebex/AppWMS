// ignore_for_file: avoid_print

import 'package:wms_app/src/api/api.dart';

class EntrepriceApiModule {
  //*obtenemos el listado de las base de datos
  static Future<List> searchEnterprice(String enterprice) async {
    try {
      const String baseUrl = "integracionwms.bexsoluciones.com";
      final response = await Api.searchEnterprice(enterprice, baseUrl);
      return response;
    } catch (e, s) {
      print("Error en searchEnterprice: $e $s");
    }
    return [];
  }
}
