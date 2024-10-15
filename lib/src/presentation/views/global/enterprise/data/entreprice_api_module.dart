import 'package:wms_app/src/api/api.dart';

class EntrepriceApiModule {
  //*obtenemos el listado de las base de datos
  static Future<List> searchEnterprice(String enterprice) async {
    const String baseUrl = "integracionwms.bexsoluciones.com";
    print("Buscando empresa: $enterprice");
    final response = await Api.searchEnterprice(enterprice, baseUrl);
    return response;
  }
}
