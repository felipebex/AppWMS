import 'base_exception.dart';

class AppException extends BaseException {
  AppException({String message = "", List<String>? errors})
      : super(message: message, errors: errors);
}
