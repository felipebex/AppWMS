// ignore_for_file: unused_element, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wms_app/src/api/http_response_handler.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

class ApiRequestService {
  static final ApiRequestService _instance = ApiRequestService._internal();

  factory ApiRequestService() {
    return _instance;
  }

  ApiRequestService._internal();

  late String authority = "34.133.172.135:5009";
  late String unencodePath;
  late HttpResponseHandler httpHandler;

  // Agregar un método de inicialización para configurar los parámetros requeridos.
  void initialize({
    // required String authority,
    required String unencodePath,
    required HttpResponseHandler httpHandler,
  }) {
    // this.authority = authority;
    this.unencodePath = unencodePath;
    this.httpHandler = httpHandler;
  }

  //todo: _setHeaders
  Future<Map<String, String>> _setHeaders(Map<String, String>? headers) async {
    headers ??= <String, String>{};

    headers.putIfAbsent('X-localization', () => "es");
    headers.putIfAbsent(HttpHeaders.acceptHeader, () => 'application/json');
    return headers;
  }

  //todo: post
  Future<http.Response> post({
    required String endpoint,
    required Map<String, dynamic>? body,
  }) async {

    // Convertir el cuerpo a JSON si no es nulo
    final bodyJson = jsonEncode(body);

    return await httpHandler.handleHttpResponse(
      http.post(
        Uri.http(authority, '$unencodePath/$endpoint'),
        body: bodyJson, // Usar el JSON como cuerpo
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        }
      ),
    );
  }

  //todo: get
  Future<http.Response> get({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    var headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'x-lang': 'es'
    };
    return await httpHandler.handleHttpResponse(http.get(
        Uri.https(
          authority,
          '$unencodePath/$endpoint',
        ),
        headers: headers));
  }

  //todo: postWithToken
  Future<http.Response> postWithToken(
      {required String endpoint,
      required Map<String, dynamic>? body,
      Map<String, String>? headers}) async {
    print("METHOD POST");
    print("BODY: $body");
    print("ENDPOINT: $endpoint");

    headers = await _setHeaders(headers);
    return await httpHandler.handleHttpResponse(http.post(
        Uri.https(authority, '$unencodePath/$endpoint'),
        body: body,
        headers: headers));
  }

  // Future<http.Response> postWithToken2(
  //     {required String endpoint,
  //     required Map<String, Object?>? body,
  //     Map<String, String>? headers}) async {
  //   print('Body: $body');

  //   var headers = {
  //     'Accept': 'application/json',
  //     'Content-Type': 'application/json',
  //     'x-lang': 'es'
  //   };
  //   String jsonBody = jsonEncode(body); // Convierte el body a JSON

  //   headers = await _setHeaders(headers);
  //   return await httpHandler.handleHttpResponse(http.post(
  //       Uri.https(authority, '$unencodePath/$endpoint'),
  //       body: jsonBody,
  //       headers: headers));
  // }
  // Future<http.Response> putWithToken3(
  //     {required String endpoint,
  //     required Map<String, Object?>? body,
  //     Map<String, String>? headers}) async {
  //   print('Body: $body');

  //   var headers = {
  //     'Accept': 'application/json',
  //     'Content-Type': 'application/json',
  //     'x-lang': 'es'
  //   };
  //   String jsonBody = jsonEncode(body); // Convierte el body a JSON

  //   headers = await _setHeaders(headers);
  //   return await httpHandler.handleHttpResponse(http.put(
  //       Uri.https(authority, '$unencodePath/$endpoint'),
  //       body: jsonBody,
  //       headers: headers));
  // }

  //todo: getWithToken
  Future<http.Response> getWithToken({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    headers = await _setHeaders(headers);

    print("url: https://$authority$unencodePath/$endpoint");

    return await httpHandler.handleHttpResponse(http.get(
        Uri.https(
          authority,
          '$unencodePath/$endpoint',
        ),
        headers: headers));
  }

  //hacer un metodo patch con token
  Future<http.Response> putWithToken({
    required String endpoint,
    required Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    print("METHOD PUT");
    print("BODY: $body");
    print("ENDPOINT: $endpoint");

    headers = await _setHeaders(headers);
    return await httpHandler.handleHttpResponse(http.put(
        Uri.https(authority, '$unencodePath/$endpoint'),
        body: body,
        headers: headers));
  }

  // Future<http.Response> putWithToken2({
  //   required String endpoint,
  //   required String? body,
  //   Map<String, String>? headers,
  // }) async {
  //   print('body: $body');

  //   headers = await _setHeaders(headers);
  //   print('headers: $headers');
  //   return await httpHandler.handleHttpResponse(http.put(
  //       Uri.https(authority, '$unencodePath/$endpoint'),
  //       body: body,
  //       headers: headers));
  // }

  //hacer un metodo delete con token
  Future<http.Response> deleteWithToken({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    headers = await _setHeaders(headers);
    return await httpHandler.handleHttpResponse(http.delete(
        Uri.https(authority, '$unencodePath/$endpoint'),
        headers: headers));
  }

  static Future<List> searchEnterprice(
      String enterprice, String baseUrl) async {
    print("searchEnterprice $enterprice");
    String company = enterprice;
    print(company);

    if (baseUrl.isEmpty) {
      throw Exception('baseUrl no puede ser null o vacío.');
    }

    Map<String, dynamic> queryParameters = {
      'url_rpc': company,
    };

    final timeout = Future.delayed(const Duration(seconds: 10), () {
      throw TimeoutException('La búsqueda ha tardado más de 10 segundos.');
    });

    try {
      final String url = Uri.http(baseUrl, 'api/database').toString();

      print("--------------------");
      print("url: $url");
      print("data: $queryParameters");
      print("baseUrl: $baseUrl");
      print("enterprice: $enterprice");
      print("--------------------");

      // Realiza la solicitud POST usando el paquete http
      final responseFuture = http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(queryParameters),
      );

      final response = await Future.any([responseFuture, timeout]);

      if (response is http.Response && response.statusCode == 200) {
        PrefUtils.getEnterprise().then((value) {
          if (value != company) {
            PrefUtils.setEnterprise(company);
          }
        });

        List listDB = [];
        Map<String, dynamic> result = jsonDecode(response.body);

        result.forEach((key, value) {
          for (var element in value) {
            listDB.add(element);
          }
        });

        print(listDB);
        return listDB.isNotEmpty ? listDB : [];
      } else {
        print("Error en la solicitud: ${response.statusCode}");
        return [];
      }
    } catch (e, s) {
      if (e is TimeoutException) {
        print("Error: ${e.message}");
      } else {
        print("Error al obtener las bases de datos: $e\nStackTrace: $s");
      }
      return [];
    }
  }
}
