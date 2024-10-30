// ignore_for_file: avoid_print, invalid_return_type_for_catch_error, constant_identifier_names, unnecessary_type_check, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/api/api_end_points.dart';
import 'package:wms_app/src/api/dio_factory.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;

enum ApiEnvironment { UAT, Dev, Prod }

extension APIEnvi on ApiEnvironment {
  String get endpoint {
    switch (this) {
      case ApiEnvironment.UAT:
        return Preferences.urlWebsite;
      case ApiEnvironment.Dev:
        return Preferences.urlWebsite;
      case ApiEnvironment.Prod:
        return Preferences.urlWebsite;
    }
  }
}

enum HttpMethod { delete, get, patch, post, put }

extension HttpMethods on HttpMethod {
  String get value {
    switch (this) {
      case HttpMethod.delete:
        return 'DELETE';
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
    }
  }
}

class Api {
  Api._();

  static const catchError = _catchError;

  static void _catchError(e, stackTrace, OnError onError) {
    if (!kReleaseMode) {
      print(e);
    }
    if (e is dio.DioException) {
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout ||
          e.type == dio.DioExceptionType.unknown) {
        onError('Server unreachable', {});
      } else if (e.type == dio.DioExceptionType.badResponse) {
        final response = e.response;
        if (response != null) {
          final data = response.data;
          if (data != null && data is Map<String, dynamic>) {
            showSessionDialog();
            onError('Failed to get response: ${e.message}', data);
            return;
          }
        }
        onError('Failed to get response: ${e.message}', {});
      } else {
        onError('Request cancelled', {});
      }
    } else {
      onError(e?.toString() ?? 'Unknown error occurred', {});
    }
  }

  static Future<dynamic> request({
    required HttpMethod method,
    required String path,
    required Map params,
    required BuildContext context,
  }) async {
    try {
      if (DioFactory.dio == null) {
        throw Exception('Dio no está inicializado.');
      }

      String? token = await PrefUtils.getToken();
      if (token.isNotEmpty) {
        DioFactory.dio!.options.headers['Cookie'] = token;
      }

      Future.delayed(const Duration(microseconds: 1), () {
        if (path != ApiEndPoints.getVersionInfo &&
            path != ApiEndPoints.getDb &&
            path != ApiEndPoints.getDb9 &&
            path != ApiEndPoints.getDb10) showLoading();
      });

      dio.Response response = await DioFactory.dio!.post(path, data: params);

      hideLoading();

      print(response.data);

      // Verificar si la sesión ha expirado
      if (response.data["error"] != null &&
          response.data["error"]["message"] == "Odoo Session Expired") {
        await handleSessionExpired(
            context); // Muestra el diálogo de sesión expirada
        return null; // Detiene la ejecución y evita devolver un valor
      }

      if (response.data["result"] != null) {
        print(response.data);
        if (path == ApiEndPoints.authenticate) {
          _updateCookies(response.headers);
        }
        print("--------------------");
        print("Request: $path");
        print("Params: $params");
        print("Method: ${method.value}");
        print("status: ${response.statusCode}");
        print("--------------------");
        return response.data["result"];
      } else {
        // Aquí puedes lanzar una excepción o manejar otros errores
      }
    } catch (error, s) {
      hideLoading();
      // Si el error es de sesión expirada en el bloque catch
      if (error.toString().contains("Session expired")) {
        await handleSessionExpired(context);
      }
      print("Error en request: $error\nStackTrace: $s");
    }
  }

  // Función para actualizar las cookies y guardar la fecha de expiración
  static _updateCookies(dio.Headers headers) async {
    List<String>? rawCookies = headers['set-cookie'];
    if (rawCookies != null && rawCookies.isNotEmpty) {
      for (var rawCookie in rawCookies) {
        // Guarda la cookie
        await PrefUtils.setToken(rawCookie);

        // Extrae y guarda la fecha de expiración
        RegExp expiringRegExp = RegExp(r'Expires=([^;]+)');
        Match? match = expiringRegExp.firstMatch(rawCookie);
        if (match != null) {
          String expiresString = match.group(1)!;

          DateTime expires =
              DateFormat("EEE, dd MMM yyyy HH:mm:ss zzz").parse(expiresString);

          await PrefUtils.setExpirationDate(expires);
        }
      }
    }
  }

  // Función para manejar sesión expirada
  static Future<void> handleSessionExpired(BuildContext context) async {
    await Get.dialog(
      AlertDialog(
        title: const Center(
            child: Text("Sesión Expirada",
                style: TextStyle(color: Colors.red, fontSize: 20))),
        content: const Text(
          "Tu sesión ha expirado. Por favor, inicia sesión nuevamente.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Get.back(); // Cerrar el diálogo
              // _logout(context); // Llamar a la función de cierre de sesión
              Navigator.pop(context);
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
      barrierDismissible: false, // Impide cerrar el diálogo al tocar fuera
    );
  }

  // Función para cerrar sesión
  static Future<void> logout(BuildContext context) async {
    PrefUtils.clearPrefs();
    Preferences.removeUrlWebsite();
    await DataBaseSqlite().deleteAll();
    PrefUtils.setIsLoggedIn(false);
    Navigator.pushNamedAndRemoveUntil(context, 'enterprice', (route) => false);
  }

// Función para manejar sesión expirada

  static Map getContext() {
    return {"lang": "es_CO", "tz": "America/Bogota", "uid": const Uuid().v1()};
  }

  static Future<dynamic> callKW({
    required String model,
    required String method,
    required List args,
    required BuildContext context,
    dynamic kwargs,
  }) async {
    var params = {
      "model": model,
      "method": method,
      "args": args,
      "kwargs": kwargs ?? {},
      "context": getContext(),
    };

    try {
      var response = await request(
        method: HttpMethod.post,
        path: ApiEndPoints.getCallKWEndPoint(model, method),
        params: createPayload(params),
        context: context,
      );
      return response;
    } catch (error) {
      print("Error en callKW: $error");
      throw Exception("Error en callKW: $error");
    }
  }

  static Future<dynamic> destroy(BuildContext context) async {
    try {
      // Llamada al método `request` usando `await`
      final response = await request(
        method: HttpMethod.post,
        path: ApiEndPoints.destroy,
        context: context,
        params: createPayload({}),
      );
      // Retorna la respuesta en caso de éxito
      return response;
    } catch (error) {
      // Manejo de errores
      print("Error en destroy: $error");
      throw Exception("Error al destruir el recurso: $error");
    }
  }

  static Map createPayload(Map params) {
    return {
      "id": const Uuid().v1(),
      "jsonrpc": "2.0",
      "method": "call",
      "params": params,
    };
  }

  // /// Método dedicado para la petición de `searchEnterprice`
  // static Future<List> searchEnterprice(
  //     String enterprice, String baseUrl) async {
  //   print("searchEnterprice $enterprice");
  //   String company = enterprice;
  //   print(company);

  //   Map<String, dynamic> queryParameters = {
  //     'url_rpc': company,
  //   };

  //   try {
  //     // Construimos la URL como antes, pero usando Dio
  //     final String url = Uri.http(baseUrl, 'api/database').toString();

  //     // Realiza la solicitud a la ruta específica para la búsqueda de empresas
  //     final response = await DioFactory.dio!.post(
  //       url, // Usamos la URL dinámica aquí
  //       data: queryParameters, // Envía los parámetros
  //       options: Options(headers: {
  //         "Content-Type": "application/json",
  //       }), // Añadir headers si es necesario
  //     );

  //     // Manejo de respuesta
  //     if (response.statusCode == 200) {
  //       Preferences.urlWebsite = company;
  //       List listDB = [];
  //       Map<String, dynamic> result = response.data;

  //       result.forEach((key, value) {
  //         for (var element in value) {
  //           listDB.add(element);
  //         }
  //       });

  //       print(listDB);
  //       return listDB.isNotEmpty ? listDB : [];
  //     } else {
  //       print("Error en la solicitud: ${response.statusCode}");
  //       return [];
  //     }
  //   } catch (e) {
  //     print("Error al obtener las bases de datos: $e");
  //     return [];
  //   }
  // }
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
