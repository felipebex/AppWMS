// ignore_for_file: unused_element, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:wms_app/src/api/dialog_loading.dart';
import 'package:wms_app/src/api/http_response_handler.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
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

  // //todo: post

  // Realiza la solicitud POST
  // Future<http.Response> post({
  //   required String endpoint,
  //   required Map<String, dynamic>? body,
  // }) async {
  //   // Convertir el cuerpo a JSON si no es nulo
  //   final bodyJson = jsonEncode(body);

  //   try {
  //     // Intentar hacer la solicitud HTTP
  //     return await httpHandler.handleHttpResponse(
  //       http.post(Uri.http(authority, '$unencodePath/$endpoint'),
  //           body: bodyJson, // Usar el JSON como cuerpo
  //           headers: {
  //             HttpHeaders.contentTypeHeader: 'application/json',
  //           }),
  //     );
  //   } on SocketException catch (e) {
  //     // Manejo de error de red
  //     print('Error de red: $e');
  //     Get.snackbar('Error de red', 'No se pudo conectar al servidor',
  //         backgroundColor: white,
  //         colorText: primaryColorApp,
  //         duration: const Duration(seconds: 5),
  //         leftBarIndicatorColor: yellow,
  //         icon: const Icon(
  //           Icons.error,
  //           color: primaryColorApp,
  //         ));
  //     rethrow; // Re-lanzamos la excepción para que sea manejada en el repositorio
  //   } catch (e) {
  //     // Manejo de otros errores
  //     print('Error desconocido en la solicitud: $e');
  //     rethrow; // Re-lanzamos la excepción para manejarla en el repositorio
  //   }
  // }

  Future<http.Response> post({
    required String endpoint,
    required Map<String, dynamic>? body,
  }) async {
    // Convertir el cuerpo a JSON si no es nulo
    final bodyJson = jsonEncode(body);

    try {
      // Mostrar el diálogo de carga con Get.dialog
      Get.dialog(
        const DialogLoadingNetwork(),
        barrierDismissible: false, // No permitir cerrar tocando fuera del diálogo
      );

      // Intentar hacer la solicitud HTTP
      final response = await http.post(
        Uri.http(authority, '$unencodePath/$endpoint'),
        body: bodyJson,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      // Cerrar el diálogo de carga cuando la solicitud se haya completado
      Get.back();

      return response;
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      Get.snackbar(
        'Error de red',
        'No se pudo conectar al servidor',
        backgroundColor: white,
        colorText: primaryColorApp,
        duration: const Duration(seconds: 5),
        leftBarIndicatorColor: yellow,
        icon: const Icon(
          Icons.error,
          color: primaryColorApp,
        ),
      );
      // Cerrar el diálogo de carga incluso en caso de error de red
      Get.back();
      rethrow; // Re-lanzamos la excepción para que sea manejada en el repositorio
    } catch (e) {
      // Manejo de otros errores
      print('Error desconocido en la solicitud: $e');
      // Cerrar el diálogo de carga incluso en caso de otros errores
      Get.back();
      rethrow; // Re-lanzamos la excepción para manejarla en el repositorio
    }
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

    // Parámetros de la consulta
    Map<String, dynamic> queryParameters = {
      'url_rpc': company,
    };

    // Tiempo de espera de 10 segundos
    final timeout = Future.delayed(const Duration(seconds: 10), () {
      throw TimeoutException('La búsqueda ha tardado más de 10 segundos.');
    });

    // Verificar conectividad
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

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

      // Espera el resultado de la solicitud o del timeout
      final response = await Future.any([responseFuture, timeout]);

      // Procesar la respuesta
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
    } on SocketException catch (e) {
      // Manejo de errores de red (falta de conexión)
      print("Error de red: $e");
      Get.snackbar('Error de red', 'No se pudo conectar al servidor',
          backgroundColor: white,
          colorText: primaryColorApp,
          duration: const Duration(seconds: 5),
          leftBarIndicatorColor: yellow,
          icon: const Icon(
            Icons.error,
            color: primaryColorApp,
          ));
      return [];
    } on TimeoutException catch (e) {
      // Manejo de errores de tiempo de espera
      print("Error de Timeout: ${e.message}");
      return [];
    } catch (e, s) {
      // Captura de otros errores
      print("Error al obtener las bases de datos: $e\nStackTrace: $s");
      return [];
    }
  }
}
