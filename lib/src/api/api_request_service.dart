// ignore_for_file: unused_element, avoid_print, unrelated_type_equality_checks, unnecessary_string_interpolations, unnecessary_null_comparison

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

import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p; // Para extraer la extensión del filename

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
    // 'Cache-Control': 'no-cache',
    headers.putIfAbsent('Pragma', () => 'no-cache');
    headers.putIfAbsent('Expires', () => '0');
    return headers;
  }

  // //todo: post

  Future<http.Response> post({
    required String endpoint,
    required Map<String, dynamic>? body,
    required bool isLoadinDialog,
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
              DialogLoadingNetwork(titel: endpoint),
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

  Future<http.Response> searchEnterprice({required String enterprice}) async {
    var url = "$enterprice/web/database/list";

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
        return http.Response('Error de red', 404);
      }

      // Opción 1: Si el servidor espera JSON en el body
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"params": {}}), // Convertir a JSON string
      );
      return response;
    } on SocketException catch (e) {
      print('Error de red: $e');
      _showNetworkErrorSnackbar();
      rethrow;
    } catch (e, s) {
      print('Error desconocido en la solicitud: $e - $s');
      _showNetworkErrorSnackbar();
      rethrow;
    }
  }

  Future<http.Response> postMultipartImage({
    required String endpoint,
    required File imageFile,
    required bool isLoadinDialog,
  }) async {
    final urlBase = 'http://34.127.73.152:5005';
    final fullUrl = Uri.parse('$urlBase/$endpoint');

    try {
      // 1) Verificar conexión de red
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        Get.snackbar(
          'Error de red',
          'No se pudo conectar al servidor',
          backgroundColor: white,
          colorText: primaryColorApp,
          duration: const Duration(seconds: 5),
          leftBarIndicatorColor: yellow,
          icon:  Icon(Icons.error, color: primaryColorApp),
        );
        return http.Response('Error de red', 404);
      }

      // 2) Verificar resolución de DNS
      final result = await InternetAddress.lookup('example.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        return http.Response('No se pudo resolver DNS', 404);
      }

      // 3) Mostrar diálogo de carga (si aplica)
      if (isLoadinDialog) {
        Get.dialog(
          DialogLoadingNetwork(titel: endpoint),
          barrierDismissible: false,
        );
      }

      // 4) Extraer extensión de la imagen para definir el MIME
      final extension = p.extension(imageFile.path).toLowerCase(); // ej: ".jpg"
      String subtype;
      if (extension == '.png') {
        subtype = 'png';
      } else {
        // Por defecto asumimos JPEG para .jpg o .jpeg
        subtype = 'jpeg';
      }

      // 5) Crear MultipartRequest y forzar el contentType correcto
      final request = http.MultipartRequest('POST', fullUrl);
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      // 6) Enviar la petición
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 7) Cerrar diálogo de carga
      if (isLoadinDialog) {
        Get.back();
      }

      // 8) Imprimir para debugging
      print('--------------------------------------------');
      print('Petición MULTIPART a $endpoint');
      print('status code: ${response.statusCode}');
      print('respuesta: ${response.body}');
      print('--------------------------------------------');

      return response;
    } catch (e, s) {
      // 9) En caso de error, cerrar diálogo y loguear
      if (isLoadinDialog) Get.back();
      print("Error en postMultipartImage: $e\n$s");
      return http.Response('Error en la solicitud: $e', 500);
    }
  }
  
Future<http.Response> postMultipart({
  required String endpoint,
  required File imageFile,
  required int idMoveLine,
  required dynamic temperature,
  required bool isLoadinDialog,
}) async {
  final urlBase = await PrefUtils.getEnterprise();
  final fullUrl = Uri.parse('$urlBase/api/$endpoint');
  final cookie = await PrefUtils.getCookie(); // 👈 Obtener cookie almacenada

  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Get.snackbar(
        'Error de red',
        'No se pudo conectar al servidor',
        backgroundColor: white,
        colorText: primaryColorApp,
        duration: const Duration(seconds: 5),
        leftBarIndicatorColor: yellow,
        icon: Icon(Icons.error, color: primaryColorApp),
      );
      return http.Response('Error de red', 404);
    }

    final result = await InternetAddress.lookup('example.com');
    if (result.isEmpty || result[0].rawAddress.isEmpty) {
      return http.Response('No se pudo resolver DNS', 404);
    }

    if (isLoadinDialog) {
      Get.dialog(
        DialogLoadingNetwork(titel: endpoint),
        barrierDismissible: false,
      );
    }

    final extension = p.extension(imageFile.path).toLowerCase();
    final subtype = extension == '.png' ? 'png' : 'jpeg';

    final request = http.MultipartRequest('POST', fullUrl);

    // 🔧 Cambia 'image' por 'image_data' como espera el backend
    request.files.add(await http.MultipartFile.fromPath(
      'image_data',
      imageFile.path,
      contentType: MediaType('image', subtype),
    ));

    // 🔧 Campos con nombres exactos que el backend espera
    request.fields['move_line_id'] = idMoveLine.toString();
    request.fields['temperatura'] = temperature.toString();

    // 🔐 Agrega la cookie (como en Postman)
    request.headers.addAll({
      'Cookie': cookie,
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (isLoadinDialog) {
      Get.back();
    }

    print('--------------------------------------------');
    print('Petición MULTIPART a $endpoint');
    print('status code: ${response.statusCode}');
    print('respuesta: ${response.body}');
    print('--------------------------------------------');

    return response;
  } catch (e, s) {
    if (isLoadinDialog) Get.back();
    print("Error en postMultipart: $e\n$s");
    return http.Response('Error en la solicitud: $e', 500);
  }
}
  Future<http.Response> postPicking({
    required String endpoint,
    required Map<String, dynamic>? body,
    required bool isLoadinDialog,
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
              DialogLoadingNetwork(titel: endpoint),
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
    } on TimeoutException catch (e, s) {
      print('La solicitud superó el tiempo de espera: $e => $s');
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
              DialogLoadingNetwork(titel: endpoint),
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

  void _showNetworkErrorSnackbar() {
    Get.snackbar(
      'Error de red',
      'No se pudo conectar al servidor',
      backgroundColor: white,
      colorText: primaryColorApp,
      duration: const Duration(seconds: 5),
      leftBarIndicatorColor: yellow,
      icon: Icon(Icons.error, color: primaryColorApp),
    );
  }

  Future<http.Response> getInfo({
    required String endpoint,
    required Map<String, dynamic>? body,
    required bool isLoadinDialog,
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
              DialogLoadingNetwork(titel: endpoint),
              barrierDismissible:
                  false, // No permitir cerrar tocando fuera del diálogo
            );
          }

          url = '$url$unencodePath/$endpoint';

          // Intentar hacer la solicitud HTTP
          var request = http.Request('GET', Uri.parse(url));
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
              DialogLoadingNetwork(titel: endpoint),
              barrierDismissible:
                  false, // No permitir cerrar tocando fuera del diálogo
            );
          }

          url =
              url + (isunecodePath ? '$unencodePath/$endpoint' : '/$endpoint');
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

  Future<http.Response> getInventario({
    required String endpoint,
    required bool isLoadinDialog,
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
              DialogLoadingNetwork(titel: endpoint),
              barrierDismissible:
                  false, // No permitir cerrar tocando fuera del diálogo
            );
          }

          url = url +
              (isunecodePath ? '/op$unencodePath/$endpoint' : '/$endpoint');
          // Intentar hacer la solicitud HTTP
          var request = http.Request('GET', Uri.parse(url));
          request.body = json.encode({
            "params": {
              // "warehouse_id": idWarehouse,
            }
          });
          request.headers.addAll(headers);
          final response = await request.send().timeout(
                const Duration(seconds: 100),
              );
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

  Future<http.Response> postInventario({
    required String endpoint,
    required bool isLoadinDialog,
    required bool isunecodePath,
    required Map<String, dynamic>? body,
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
              DialogLoadingNetwork(titel: endpoint),
              barrierDismissible:
                  false, // No permitir cerrar tocando fuera del diálogo
            );
          }

          url = url +
              (isunecodePath ? '/op$unencodePath/$endpoint' : '/$endpoint');
          // Intentar hacer la solicitud HTTP
          var request = http.Request('GET', Uri.parse(url));
          request.body = json.encode(body);
          request.headers.addAll(headers);
          final response = await request.send().timeout(
                const Duration(seconds: 100),
              );
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

  Future<http.Response> getHistory({
    required String endpoint,
    required bool isLoadinDialog,
    required bool isunecodePath,
    required String date,
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
              DialogLoadingNetwork(titel: endpoint),
              barrierDismissible:
                  false, // No permitir cerrar tocando fuera del diálogo
            );
          }

          url =
              url + (isunecodePath ? '$unencodePath/$endpoint' : '/$endpoint');

          //

          // Intentar hacer la solicitud HTTP

          var request = http.Request('GET', Uri.parse(url));
          request.body = json.encode({
            "params": {"fecha_batch": "$date"}
          });

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
}
