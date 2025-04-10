// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/presentation/views/inventario/models/request_sendProducr_model.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_senProduct_mode.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_lotes_product_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_new_lote_model.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class InventarioRepository {
  Future<List<Product>> fetAllProducts(
    bool isLoadinDialog,
    int idWarehouse,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().getInventario(
        endpoint: 'quant',
        isunecodePath: true,
        idWarehouse: idWarehouse,
        isLoadinDialog: isLoadinDialog,
      );
      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"
        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          List<dynamic> products = jsonResponse['result']['data'];
          // Mapea los datos decodificados a una lista de BatchsModel
          List<Product> productsResponse =
              products.map((data) => Product.fromMap(data)).toList();

          return productsResponse;
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            Get.defaultDialog(
              title: 'Alerta',
              titleStyle: TextStyle(color: Colors.red, fontSize: 18),
              middleText: 'Sesion expirada, por favor inicie sesión nuevamente',
              middleTextStyle: TextStyle(color: black, fontSize: 14),
              backgroundColor: Colors.white,
              radius: 10,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Aceptar', style: TextStyle(color: white)),
                ),
              ],
            );
            return [];
          }
        }
      } else {}
    } on SocketException catch (e) {
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores
      print('Error getProductosInventario: $e, $s');
    }
    return [];
  }

  Future<List<LotesProduct>> fetchAllLotesProduct(
      bool isLoadinDialog, int productId) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return []; // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().get(
        endpoint: 'lotes/$productId',
        isunecodePath: true,
        isLoadinDialog: isLoadinDialog,
      );

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          List<dynamic> response = jsonResponse['result']['result'];
          // Mapea los datos decodificados a una lista de BatchsModel
          List<LotesProduct> lotes =
              response.map((data) => LotesProduct.fromMap(data)).toList();

          if (lotes.isNotEmpty) {
            return lotes;
          }
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            Get.defaultDialog(
              title: 'Alerta',
              titleStyle: TextStyle(color: Colors.red, fontSize: 18),
              middleText: 'Sesion expirada, por favor inicie sesión nuevamente',
              middleTextStyle: TextStyle(color: black, fontSize: 14),
              backgroundColor: Colors.white,
              radius: 10,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Aceptar', style: TextStyle(color: white)),
                ),
              ],
            );
            return [];
          }
        }
      } else {}
    } on SocketException catch (e) {
      print('Error de red: $e');
      return [];
    } catch (e, s) {
      // Manejo de otros errores
      print('Error lotes de un producto: $e, $s');
    }
    return [];
  }

  Future<ResponseSendProduct> sendProduct(
      SendProductInventario request, bool isLoadinDialog) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return ResponseSendProduct();
    }

    try {
      print(request.toMap());

      var response = await ApiRequestService().postInventario(
          endpoint: 'quant_post',
          isunecodePath: true,
          isLoadinDialog: isLoadinDialog,
          body: {
            "params": {
              "location_id": request.locationId,
              "product_id": request.productId,
              "lot_id": request.lotId,
              "quantity": request.quantity,
              'user_id': request.userId,
            }
          });
      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"
        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          return ResponseSendProduct.fromMap(jsonResponse);
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            Get.defaultDialog(
              title: 'Alerta',
              titleStyle: TextStyle(color: Colors.red, fontSize: 18),
              middleText: 'Sesion expirada, por favor inicie sesión nuevamente',
              middleTextStyle: TextStyle(color: black, fontSize: 14),
              backgroundColor: Colors.white,
              radius: 10,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Aceptar', style: TextStyle(color: white)),
                ),
              ],
            );
            return ResponseSendProduct();
          }
        }
      }
      return ResponseSendProduct();
    } catch (e, s) {
      print("Error en el senProduct inventario : $e =>$s");
      return ResponseSendProduct();
    }
  }

  Future<ResponseNewLote> createLote(
    bool isLoadinDialog,
    int idProduct,
    String nameLote,
    String dateLote,
  ) async {
    // Verificar si el dispositivo tiene acceso a Internet
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      print("Error: No hay conexión a Internet.");
      return ResponseNewLote(); // Si no hay conexión, retornar una lista vacía
    }

    try {
      var response = await ApiRequestService().postPacking(
          endpoint: 'create_lote',
          isLoadinDialog: isLoadinDialog,
          body: {
            "params": {
              "id_producto": idProduct,
              "nombre_lote": nameLote,
              "fecha_vencimiento": dateLote,
            }
          });

      if (response.statusCode < 400) {
        // Decodifica la respuesta JSON a un mapa
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Accede a la clave "data" y luego a "result"

        // Asegúrate de que 'result' exista y sea una lista
        if (jsonResponse.containsKey('result')) {
          if (jsonResponse['result']['code'] == 200) {
            return ResponseNewLote(
              jsonrpc: jsonResponse['jsonrpc'],
              id: jsonResponse['id'],
              result: jsonResponse['result'] != null
                  ? ResponseNewLoteResult.fromMap(jsonResponse['result'])
                  : null,
            );
          }
        } else if (jsonResponse.containsKey('error')) {
          if (jsonResponse['error']['code'] == 100) {
            //mostramos una alerta de get
            Get.defaultDialog(
              title: 'Alerta',
              titleStyle: TextStyle(color: Colors.red, fontSize: 18),
              middleText: 'Sesion expirada, por favor inicie sesión nuevamente',
              middleTextStyle: TextStyle(color: black, fontSize: 14),
              backgroundColor: Colors.white,
              radius: 10,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Aceptar', style: TextStyle(color: white)),
                ),
              ],
            );

            return ResponseNewLote();
          }
        }
      }
    } on SocketException catch (e) {
      print('Error de red: $e');
      return ResponseNewLote();
    } catch (e, s) {
      // Manejo de otros errores
      print('Error resBatchsPacking: $e, $s');
    }
    return ResponseNewLote();
  }
}
