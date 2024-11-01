// ignore_for_file: avoid_print


import 'package:wms_app/src/api/api_request_service.dart';

class EntrepriceRepository {
   Future<List> searchEnterprice(String enterprice) async {
    try {
      const String baseUrl = "integracionwms.bexsoluciones.com";
      final response = await ApiRequestService.searchEnterprice(enterprice, baseUrl);
      return response;
    } catch (e, s) {
      print("Error en searchEnterprice: $e $s");
    }
    return [];
  }
}
