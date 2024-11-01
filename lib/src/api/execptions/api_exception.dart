import 'base_api_exception.dart';

class ApiException extends BaseApiException {
  ApiException(
      {required int httpCode,
      required String status,
      String message = "",
      List<String>? errors})
      : super(
            httpCode: httpCode,
            status: status,
            message: message,
            errors: errors);
}
