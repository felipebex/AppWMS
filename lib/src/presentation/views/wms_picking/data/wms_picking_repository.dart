// // ignore_for_file: avoid_print

// ignore_for_file: unrelated_type_equality_checks, avoid_print, use_build_context_synchronously

// import 'package:wms_app/src/api/api_request_service.dart';

import 'package:flutter/material.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/history/models/batch_history_id_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/history/models/hisotry_done_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/item_picking_request.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'dart:io';

import 'package:wms_app/src/presentation/views/wms_picking/models/response_send_picking.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/submeuelle_model.dart';

class WmsPickingRepository {
  //metodo para pedir los batchs
  Future<List<BatchsModel>> resBatchs(
    bool isLoadinDialog,
    BuildContext context,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().get(
          endpoint: 'batchs',
          isunecodePath: true,
          isLoadinDialog: isLoadinDialog,
          context: context);

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 400) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Error : ${jsonResponse['result']['msg']}',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
          } else if (jsonResponse['result']['code'] == 200) {
            if (jsonResponse['result'].containsKey('result')) {
              // Si contiene 'result', se procede con el mapeo
              List<dynamic> batches = jsonResponse['result']['result'];
              List<BatchsModel> products =
                  batches.map((data) => BatchsModel.fromMap(data)).toList();
              return products;
            } else if (jsonResponse['result'].containsKey('msg')) {
              // Si contiene 'msg', podrías manejar el mensaje de alguna forma
              String msg = jsonResponse['result']['msg'];
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.amber[200],
                  content: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Text(
                        msg,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  )));
              return [];
            }
          }
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Sesion expirada, por favor inicie sesión nuevamente',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
            return [];
          }
        }
      } else {}
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[200],
          content: SizedBox(
            width: double.infinity,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                'Error en resBatchs: $e $s',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
          behavior: SnackBarBehavior
              .floating, // Hace que no se cierre automáticamente
          duration:
              const Duration(seconds: 5), // Esto hace que no se cierre solo
        ),
      );

      print('Error resBatchs: $e, $s');
    }
    return [];
  }

  Future<List<HistoryBatch>> resBatchsHistory(
    bool isLoadinDialog,
    BuildContext context,
    String date,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().getHistory(
          endpoint: 'batchs_done',
          isunecodePath: true,
          isLoadinDialog: isLoadinDialog,
          context: context,
          date: date);

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 400) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Error : ${jsonResponse['result']['msg']}',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
          } else if (jsonResponse['result']['code'] == 200) {
            if (jsonResponse['result'].containsKey('result')) {
              // Si contiene 'result', se procede con el mapeo
              List<dynamic> batches = jsonResponse['result']['result'];
              List<HistoryBatch> products =
                  batches.map((data) => HistoryBatch.fromMap(data)).toList();
              return products;
            } else if (jsonResponse['result'].containsKey('msg')) {
              // Si contiene 'msg', podrías manejar el mensaje de alguna forma
              String msg = jsonResponse['result']['msg'];
              // Aquí puedes manejar el mensaje de error o información según sea necesario

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.amber[200],
                  content: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Text(
                        msg,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  )));
              return [];
            }
          }
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Sesion expirada, por favor inicie sesión nuevamente',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
            return [];
          }
        }
      } else {}
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[200],
          content: SizedBox(
            width: double.infinity,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                'Error en resBatchs: $e $s',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),

          behavior: SnackBarBehavior
              .floating, // Hace que no se cierre automáticamente
          duration:
              const Duration(seconds: 5), // Esto hace que no se cierre solo
        ),
      );

      print('Error resBatchs: $e, $s');
    }
    return [];
  }

  //metodo para pedir los batchs por id
  Future<HistoryBatchId> getBatchById(
      bool isLoadinDialog, BuildContext context, int batchId) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return HistoryBatchId(); // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().get(
          endpoint: 'batch/$batchId',
          isunecodePath: true,
          isLoadinDialog: isLoadinDialog,
          context: context);

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          Map<String, dynamic> batches = jsonResponse['result']['result'];

          // Mapea los datos decodificados a una lista de BatchsModel
          HistoryBatchId historyBatchId = HistoryBatchId.fromMap(batches);
          return historyBatchId;
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Sesion expirada, por favor inicie sesión nuevamente',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
            return HistoryBatchId();
          }
        }
      } else {}
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return HistoryBatchId();
    } catch (e, s) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[200],
          content: SizedBox(
            width: double.infinity,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                'Error en getBatchById: $e $s',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),

          behavior: SnackBarBehavior
              .floating, // Hace que no se cierre automáticamente
          duration:
              const Duration(seconds: 5), // Esto hace que no se cierre solo
        ),
      );

      // Manejo de otros errores
      print('Error getBatchById: $e, $s');
    }
    return HistoryBatchId();
  }

  //metodo para pedir los submuelles
  Future<List<Muelles>> getmuelles(
    bool isLoadinDialog,
    BuildContext context,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().get(
          endpoint: 'muelles',
          isunecodePath: true,
          isLoadinDialog: isLoadinDialog,
          context: context);

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          List<dynamic> batches = jsonResponse['result']['result'];
          // Mapea los datos decodificados a una lista de BatchsModel
          List<Muelles> muelles =
              batches.map((data) => Muelles.fromMap(data)).toList();
          return muelles;
        }
      } else {}
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[200],
          content: SizedBox(
            width: double.infinity,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                'Error en getBatchById: $e $s',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),

          behavior: SnackBarBehavior
              .floating, // Hace que no se cierre automáticamente
          duration:
              const Duration(seconds: 5), // Esto hace que no se cierre solo
        ),
      );
      // Manejo de otros errores
      print('Error getmuelles: $e, $s');
    }
    return [];
  }

  Future<SendPickingResponse> sendPicking(
      {required int idBatch,
      required double timeTotal,
      required int cantItemsSeparados,
      required List<Item> listItem,
      required BuildContext context //
      }) async {
    try {
      var response = await ApiRequestService().postPicking(
          endpoint: 'send_batch',
          isunecodePath: true,
          body: {
            "params": {
              "id_batch": idBatch,
              "time_total": timeTotal,
              "cant_items_separados": cantItemsSeparados,
              "list_item": listItem.map((item) => item.toJson()).toList(),
            }
          },
          isLoadinDialog: false,
          context: context);
      if (response.statusCode < 400) {
        return SendPickingResponse.fromJson(response.body);
      } else {
        print('Error sendPicking: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
    } catch (e, s) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[200],
          content: SizedBox(
            width: double.infinity,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                'Error en sendPicking: $e $s',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),

          behavior: SnackBarBehavior
              .floating, // Hace que no se cierre automáticamente
          duration:
              const Duration(seconds: 5), // Esto hace que no se cierre solo
        ),
      );
      // Manejo de otros errores
      print('Error sendPicking: $e, $s');
    }
    return SendPickingResponse();
  }

  //metod para obtener las novedades:
  Future<List<Novedad>> getnovedades(
    bool isLoadinDialog,
    BuildContext context,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().get(
        endpoint: 'picking_novelties',
        isunecodePath: true,
        isLoadinDialog: isLoadinDialog,
        context: context,
      );

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          List<dynamic> result = jsonResponse['result']['result'];
          // Mapea los datos decodificados a una lista de BatchsModel
          List<Novedad> novedades =
              result.map((data) => Novedad.fromMap(data)).toList();
          return novedades;
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Sesion expirada, por favor inicie sesión nuevamente',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
            return [];
          }
        }
      } else {
        print('Error getnovedades: response is null');
      }
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[200],
          content: SizedBox(
            width: double.infinity,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                'Error en getnovedades: $e $s',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
          // action: SnackBarAction(
          //   label: 'Cerrar', // Este es el texto del botón de acción
          //   textColor: Colors.black, // Color del texto de la acción
          //   onPressed: () {
          //     // Esto se ejecuta cuando el usuario presiona "Cerrar"
          //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
          //   },
          // ),
          behavior: SnackBarBehavior
              .floating, // Hace que no se cierre automáticamente
          duration:
              const Duration(seconds: 5), // Esto hace que no se cierre solo
        ),
      );
      // Manejo de otros errores
      print('Error getnovedades: $e, $s');
    }
    return [];
  }

  Future<bool> timePickingUser(int batchId, BuildContext context, String time,
      String endpoint, String type, int userId) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return false; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().postPicking(
          endpoint: endpoint,
          isunecodePath: true,
          isLoadinDialog: false,
          context: context,
          body: {
            "params": {
              "id_batch": "$batchId",
              "user_id": "$userId",
              type: time,
              "operation_type": "picking"
            }
          });

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 400) {
            return false;
          } else if (jsonResponse['result']['code'] == 200) {
            return true;
          }
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Sesion expirada, por favor inicie sesión nuevamente',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
            return false;
          }
        }
      } else {}
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return false;
    } catch (e, s) {
      // Manejo de otros errores

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[200],
          content: SizedBox(
            width: double.infinity,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                'Error en resBatchs: $e $s',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
          // action: SnackBarAction(
          //   label: 'Cerrar', // Este es el texto del botón de acción
          //   textColor: Colors.black, // Color del texto de la acción
          //   onPressed: () {
          //     // Esto se ejecuta cuando el usuario presiona "Cerrar"
          //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
          //   },
          // ),
          behavior: SnackBarBehavior
              .floating, // Hace que no se cierre automáticamente
          duration:
              const Duration(seconds: 5), // Esto hace que no se cierre solo
        ),
      );

      print('Error resBatchs: $e, $s');
    }
    return false;
  }

  Future<bool> timePickingBatch(int batchId, BuildContext context, String time,
      String endpoint, String field, String type) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return false; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().postPicking(
          endpoint: endpoint,
          isunecodePath: true,
          isLoadinDialog: false,
          context: context,
          body: {
            "params": {
              "picking_id": "$batchId",
              type: time,
              "field_name": field,
            }
          });

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 400) {
            return false;
          } else if (jsonResponse['result']['code'] == 200) {
            return true;
          }
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[200],
                content: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Sesion expirada, por favor inicie sesión nuevamente',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                )));
            return false;
          }
        }
      } else {}
    } on SocketException catch (e) {
      // Manejo de error de red
      print('Error de red: $e');
      return false;
    } catch (e, s) {
      // Manejo de otros errores

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[200],
          content: SizedBox(
            width: double.infinity,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                'Error en resBatchs: $e $s',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
         
          behavior: SnackBarBehavior
              .floating, // Hace que no se cierre automáticamente
          duration:
              const Duration(seconds: 5), // Esto hace que no se cierre solo
        ),
      );

      print('Error resBatchs: $e, $s');
    }
    return false;
  }
}
