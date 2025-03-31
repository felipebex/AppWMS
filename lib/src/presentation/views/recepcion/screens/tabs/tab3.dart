// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, prefer_is_empty

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab3ScreenRecep extends StatelessWidget {
  const Tab3ScreenRecep({
    super.key,
    required this.ordenCompra,
  });

  final ResultEntrada? ordenCompra;

  @override
  Widget build(BuildContext context) {
    final recepcionBloc = context.read<RecepcionBloc>();

    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: BlocConsumer<RecepcionBloc, RecepcionState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            backgroundColor: white,
            body: Container(
              margin: const EdgeInsets.only(top: 5),
              width: double.infinity,
              height: size.height * 0.8,
              child: Column(
                children: [
                  // (recepcionBloc.listProductsEntrada.where((element) {
                  //           return element.isDoneItem == 1;
                  //         }).length ==
                  //         0)
                  //     ? Expanded(
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           mainAxisSize: MainAxisSize.max,
                  //           children: [
                  //             const Text('No hay productos',
                  //                 style: TextStyle(fontSize: 14, color: grey)),
                  //             const Text('Intente buscar otro producto',
                  //                 style: TextStyle(fontSize: 12, color: grey)),
                  //             Visibility(
                  //               visible: context
                  //                   .read<UserBloc>()
                  //                   .fabricante
                  //                   .contains("Zebra"),
                  //               child: Container(
                  //                 height: 60,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       )
                  //     : 
                      Expanded(
                          child: ListView.builder(
                           
                            itemCount: recepcionBloc.listProductsEntrada
                                .where((element) {
                              return element.isDoneItem == 1;
                            }).length,



                            itemBuilder: (context, index) {
                              final product = recepcionBloc.listProductsEntrada
                                  .where((element) {
                                return element.isDoneItem == 1;
                              }).elementAt(index);

                              // final product =
                              //     recepcionBloc.listProductsEntrada[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    print('product: ${product.toMap()}');
                                  },
                                  child: Card(
                                    color: Colors.green[
                                        100], // Color blanco si no está seleccionado
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Producto:",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "${product.productName}",
                                              style: const TextStyle(
                                                  fontSize: 12, color: black),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Codigo: ",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              Text("${product.productCode}",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: black)),
                                            ],
                                          ),
                                          Visibility(
                                            visible: product.productTracking ==
                                                'lot',
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Lote: ",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: primaryColorApp,
                                                  ),
                                                ),
                                                Text("${product.lotName}",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: black)),
                                                Text("/${product.loteDate}",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: black)),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            "Ubicación de origen: ",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: primaryColorApp,
                                            ),
                                          ),
                                          Text("${product.locationName}",
                                              style: const TextStyle(
                                                  fontSize: 12, color: black)),
                                          Row(
                                            children: [
                                              Visibility(
                                                visible: recepcionBloc
                                                        .configurations
                                                        .result
                                                        ?.result
                                                        ?.hideExpectedQty ==
                                                    false,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Cantidad pedida: ",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: primaryColorApp,
                                                      ),
                                                    ),
                                                    Text(
                                                        "${product.quantityOrdered}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black)),
                                                  ],
                                                ),
                                              ),
                                              Spacer(),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Cantidad recibida: ",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: primaryColorApp,
                                                    ),
                                                  ),
                                                  Text(
                                                      (product.isSeparate == 0)
                                                          ? "${product.quantityDone}"
                                                          : "${product.quantitySeparate}",
                                                      // "${product.quantityToReceive}",
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: black)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Tiempo: ",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              Text(
                                                  convertirTiempo(
                                                      product.time.toString()),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: black)),
                                            ],
                                          ),
                                          Visibility(
                                            visible:
                                                product.isProductSplit == 1,
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Novedad: ",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: black,
                                                  ),
                                                ),
                                                Text(
                                                  "Producto dividido",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: primaryColorApp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String convertirTiempo(String tiempoStr) {
    // Convertimos el string a un double
    double segundos = double.tryParse(tiempoStr) ?? 0.0;
    // Calculamos horas, minutos y segundos
    int horas = (segundos / 3600).floor(); // 3600 segundos = 1 hora
    int minutos =
        ((segundos % 3600) / 60).floor(); // Resto de segundos dividido entre 60
    int segundosRestantes = (segundos % 60).round(); // Resto de segundos
    // Formateamos los valores en 2 dígitos (ej. 01, 02, etc.)
    String horasStr = horas.toString().padLeft(2, '0');
    String minutosStr = minutos.toString().padLeft(2, '0');
    String segundosStr = segundosRestantes.toString().padLeft(2, '0');

    return '$horasStr:$minutosStr:$segundosStr';
  }
}
