abstract class BaseException implements Exception {
  final String message;
  final List<String>? errors;
  BaseException({this.message = "", this.errors});
}
