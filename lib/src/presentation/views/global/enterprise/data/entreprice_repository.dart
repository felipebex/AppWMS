// ignore_for_file: avoid_print

import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/global/enterprise/models/response_enterprice_model.dart';

class EntrepriceRepository {
  Future<Enterprice> searchEnterprice(String enterprice) async {
    try {
      final response =
          await ApiRequestService().searchEnterprice(enterprice: enterprice);
      if (response.statusCode < 400) {
        return enterpriceFromMap(response.body);
      }
      
    } catch (e, s) {
      print("Error en searchEnterprice: $e $s");
    }
    return Enterprice();
  }
}
