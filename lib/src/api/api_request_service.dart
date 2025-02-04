// ignore_for_file: unused_element, avoid_print, unrelated_type_equality_checks, use_build_context_synchronously, unnecessary_string_interpolations, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:wms_app/src/utils/widgets/dialog_loading.dart';
import 'package:wms_app/src/api/http_response_handler.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

class ApiRequestService {
  static final ApiRequestService _instance = ApiRequestService._internal();

  factory ApiRequestService() {
    return _instance;
  }

  ApiRequestService._internal();

  late String unencodePath;
  late HttpResponseHandler httpHandler;

  // Agregar un método de inicialización para configurar los parámetros requeridos.
  void initialize({
    required String unencodePath,
    required HttpResponseHandler httpHandler,
  }) {
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

  Future<http.Response> post({
    required String endpoint,
    required Map<String, dynamic>? body,
    required bool isLoadinDialog,
    required BuildContext context,
    required bool isunecodePath,
  }) async {
    // Convertir el cuerpo a JSON si no es nulo
    final bodyJson = jsonEncode(body);

    var url = await PrefUtils.getEnterprise();

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Si no hay conexión, retornar una lista vacía
        Get.snackbar('Error de red', 'No se pudo conectar al servidor',
            backgroundColor: white,
            colorText: primaryColorApp,
            duration: const Duration(seconds: 5),
            leftBarIndicatorColor: yellow,
            icon: Icon(
              Icons.error,
              color: primaryColorApp,
            ));
      } else {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          if (isLoadinDialog) {
            // Mostrar el diálogo de carga con Get.dialog
            Get.dialog(
              const DialogLoadingNetwork(),
              barrierDismissible:
                  false, // No permitir cerrar tocando fuera del diálogo
            );
          }

          url =
              url + (isunecodePath ? '$unencodePath/$endpoint' : '/$endpoint');

          Map<String, String> headers = {
            'Content-Type': 'application/json',
          };

          // Intentar hacer la solicitud HTTP
          final response =
              await http.post(Uri.parse(url), body: bodyJson, headers: headers);

          // Cerrar el diálogo de carga cuando la solicitud se haya completado
          if (isLoadinDialog) {
            Get.back();
          }
          if (response.headers.containsKey('set-cookie')) {
            print("set-cookie: ${response.headers['set-cookie']}");
            await PrefUtils.setCookie(response.headers['set-cookie']!);
          }

          print("--------------------------------------------");
          print('Petición POST a $endpoint');
          print('Cuerpo de la solicitud: $url');
          print('headers: $headers');
          print('status code: ${response.statusCode}');
          print("--------------------------------------------");

          return response;
        } else {
          Get.snackbar(
            'Error de red',
            'No se pudo conectar al servidor',
            backgroundColor: white,
            colorText: primaryColorApp,
            duration: const Duration(seconds: 5),
            leftBarIndicatorColor: yellow,
            icon: Icon(
              Icons.error,
              color: primaryColorApp,
            ),
          );
        }
      }
      return http.Response('Error de red', 404);
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
        icon: Icon(
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

  Future<http.Response> postPicking({
    required String endpoint,
    required Map<String, dynamic>? body,
    required bool isLoadinDialog,
    required BuildContext context,
    required bool isunecodePath,
  }) async {
    var url = await PrefUtils.getEnterprise();
    var cookie = await PrefUtils.getCookie();

    // Extraer el session_id de la cookie
    String sessionId = '';
    List<String> cookies = cookie.split(',');
    for (var c in cookies) {
      if (c.contains('session_id=')) {
        sessionId = c.split(';')[0].trim();
        break; // Detener la búsqueda después de encontrar el session_id
      }
    }

    print("body: $body");

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': '$sessionId',
    };

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Si no hay conexión, retornar una lista vacía
        Get.snackbar('Error de red', 'No se pudo conectar al servidor',
            backgroundColor: white,
            colorText: primaryColorApp,
            duration: const Duration(seconds: 5),
            leftBarIndicatorColor: yellow,
            icon: Icon(
              Icons.error,
              color: primaryColorApp,
            ));
      } else {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          if (isLoadinDialog) {
            // Mostrar el diálogo de carga con Get.dialog
            Get.dialog(
              const DialogLoadingNetwork(),
              barrierDismissible:
                  false, // No permitir cerrar tocando fuera del diálogo
            );
          }

          url =
              url + (isunecodePath ? '$unencodePath/$endpoint' : '/$endpoint');

          // Intentar hacer la solicitud HTTP
          var request = http.Request('POST', Uri.parse(url));
          request.body = json.encode(body);
          request.headers.addAll(headers);

          final response =
              await request.send().timeout(const Duration(seconds: 100));

          // Cerrar el diálogo de carga cuando la solicitud se haya completado
          if (isLoadinDialog) {
            Get.back();
          }

          print("--------------------------------------------");
          print('Petición POST a $endpoint');
          print('url: $url');
          print('Cuerpo de la solicitud: ${jsonDecode(request.body)}');
          print('headers: $headers');
          print('status code: ${response.statusCode}');
          print("--------------------------------------------");

          return http.Response.fromStream(response);
        } else {
          Get.snackbar(
            'Error de red',
            'No se pudo conectar al servidor',
            backgroundColor: white,
            colorText: primaryColorApp,
            duration: const Duration(seconds: 5),
            leftBarIndicatorColor: yellow,
            icon: Icon(
              Icons.error,
              color: primaryColorApp,
            ),
          );
        }
      }
      return http.Response('Error de red', 404);
    } on TimeoutException catch (e,s ) {
      print('La solicitud superó el tiempo de espera: $e');
      return http.Response('La solicitud superó el tiempo de espera', 408);
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
        icon: Icon(
          Icons.error,
          color: primaryColorApp,
        ),
      );
      // Cerrar el diálogo de carga incluso en caso de error de red
      Get.back();
      rethrow; // Re-lanzamos la excepción para que sea manejada en el repositorio
    } catch (e, s) {
      // Manejo de otros errores
      print('Error desconocido en la solicitud: $e \n $s');
      // Cerrar el diálogo de carga incluso en caso de otros errores
      Get.back();
      rethrow; // Re-lanzamos la excepción para manejarla en el repositorio
    }
  }

  Future<http.Response> postPacking({
    required String endpoint,
    required Map<String, dynamic>? body,
    required bool isLoadinDialog,
    required BuildContext context,
  }) async {
    var url = await PrefUtils.getEnterprise();
    var cookie = await PrefUtils.getCookie();

    // Extraer el session_id de la cookie
    String sessionId = '';
    List<String> cookies = cookie.split(',');
    for (var c in cookies) {
      if (c.contains('session_id=')) {
        sessionId = c.split(';')[0].trim();
        break; // Detener la búsqueda después de encontrar el session_id
      }
    }

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': '$sessionId',
    };

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Si no hay conexión, retornar una lista vacía
        Get.snackbar('Error de red', 'No se pudo conectar al servidor',
            backgroundColor: white,
            colorText: primaryColorApp,
            duration: const Duration(seconds: 5),
            leftBarIndicatorColor: yellow,
            icon: Icon(
              Icons.error,
              color: primaryColorApp,
            ));
      } else {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          if (isLoadinDialog) {
            // Mostrar el diálogo de carga con Get.dialog
            Get.dialog(
              const DialogLoadingNetwork(),
              barrierDismissible:
                  false, // No permitir cerrar tocando fuera del diálogo
            );
          }

          url = '$url$unencodePath/$endpoint';

          // Intentar hacer la solicitud HTTP
          var request = http.Request('POST', Uri.parse(url));
          request.body = json.encode(body);
          request.headers.addAll(headers);

          final response = await request.send();

          // Cerrar el diálogo de carga cuando la solicitud se haya completado
          if (isLoadinDialog) {
            Get.back();
          }

          print("--------------------------------------------");
          print('Petición POST a $endpoint');
          print('url: $url');
          print('Cuerpo de la solicitud: ${jsonDecode(request.body)}');
          print('headers: $headers');
          print('status code: ${response.statusCode}');
          print("--------------------------------------------");

          return http.Response.fromStream(response);
        } else {
          Get.snackbar(
            'Error de red',
            'No se pudo conectar al servidor',
            backgroundColor: white,
            colorText: primaryColorApp,
            duration: const Duration(seconds: 5),
            leftBarIndicatorColor: yellow,
            icon: Icon(
              Icons.error,
              color: primaryColorApp,
            ),
          );
        }
      }
      return http.Response('Error de red', 404);
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
        icon: Icon(
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

  Future<http.Response> get({
    required String endpoint,
    required bool isLoadinDialog,
    required BuildContext context,
    required bool isunecodePath,
  }) async {
    var url = await PrefUtils.getEnterprise();
    var cookie = await PrefUtils.getCookie();

    // Extraer el session_id de la cookie
    String sessionId = '';
    List<String> cookies = cookie.split(',');
    for (var c in cookies) {
      if (c.contains('session_id=')) {
        sessionId = c.split(';')[0].trim();
        break; // Detener la búsqueda después de encontrar el session_id
      }
    }

    if (sessionId == "" || sessionId == null) {
      Get.snackbar('Error de red', 'No se pudo conectar al servidor',
          backgroundColor: white,
          colorText: primaryColorApp,
          duration: const Duration(seconds: 5),
          leftBarIndicatorColor: yellow,
          icon: Icon(
            Icons.error,
            color: primaryColorApp,
          ));
      return http.Response('Error de red', 404);
    }

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': '$sessionId',
    };

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Si no hay conexión, retornar una lista vacía
        Get.snackbar('Error de red', 'No se pudo conectar al servidor',
            backgroundColor: white,
            colorText: primaryColorApp,
            duration: const Duration(seconds: 5),
            leftBarIndicatorColor: yellow,
            icon: Icon(
              Icons.error,
              color: primaryColorApp,
            ));
      } else {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          if (isLoadinDialog) {
            // Mostrar el diálogo de carga con Get.dialog
            Get.dialog(
              const DialogLoadingNetwork(),
              barrierDismissible:
                  false, // No permitir cerrar tocando fuera del diálogo
            );
          }

          url =
              url + (isunecodePath ? '$unencodePath/$endpoint' : '/$endpoint');

          //

          // Intentar hacer la solicitud HTTP

          var request = http.Request('GET', Uri.parse(url));
          request.body = json.encode({"params": {}});

          request.headers.addAll(headers);

          final response = await request.send();

          // Cerrar el diálogo de carga cuando la solicitud se haya completado
          if (isLoadinDialog) {
            Get.back();
          }

          print("--------------------------------------------");
          print('Petición GET a $endpoint');
          print('Cuerpo de la solicitud: $url');
          print('headers: $headers');
          print('status code: ${response.statusCode}');
          print("--------------------------------------------");
          return http.Response.fromStream(response);
        } else {
          Get.snackbar(
            'Error de red',
            'No se pudo conectar al servidor',
            backgroundColor: white,
            colorText: primaryColorApp,
            duration: const Duration(seconds: 5),
            leftBarIndicatorColor: yellow,
            icon: Icon(
              Icons.error,
              color: primaryColorApp,
            ),
          );
        }
      }
      return http.Response('Error de red', 404);
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
        icon: Icon(
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
      if (response.statusCode == 200) {
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
          icon: Icon(
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

  Future<dynamic> sendPacking({
    required Map<String, String> headers,
    required String body,
    required String endpoint,
  }) async {
    try {
      var url = await PrefUtils.getEnterprise();

// le quitamos el http:// o https:// para que no de error
      if (url.contains('http://')) {
        url = url.replaceAll('http://', ''); // Asignar el nuevo valor a 'url'
      } else if (url.contains('https://')) {
        url = url.replaceAll('https://', ''); // Asignar el nuevo valor a 'url'
      }
      var request = http.post(
        Uri.http(url, '$unencodePath/$endpoint'),
        body: body,
        headers: headers,
      );
      print("body: $body");
      print('Petición enviada: $request');

      return request;
    } catch (e) {
      print('Error en la petición: $e');
    }
  }
}
