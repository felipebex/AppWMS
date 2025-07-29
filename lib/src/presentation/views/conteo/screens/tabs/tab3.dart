// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, prefer_is_empty

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab3ScreenConteo extends StatefulWidget {
  const Tab3ScreenConteo({
    super.key,
    required this.ordenConteo,
  });

  final DatumConteo? ordenConteo;

  @override
  State<Tab3ScreenConteo> createState() => _Tab3ScreenRecepState();
}

class _Tab3ScreenRecepState extends State<Tab3ScreenConteo> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocConsumer<ConteoBloc, ConteoState>(
        listener: (context, state) {},
        builder: (context, state) {
          final conteoBloc = context.read<ConteoBloc>();
          return Scaffold(
            backgroundColor: white,
            body: Container(
              margin: const EdgeInsets.only(top: 5),
              width: double.infinity,
              height: size.height * 0.8,
              child: Column(
                children: [
                  (conteoBloc.lineasContadas.where((element) {
                            return (element.isDoneItem == 1 ||
                                element.isDoneItem == true);
                          }).length ==
                          0)
                      ? Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Text('No hay productos',
                                  style: TextStyle(fontSize: 14, color: grey)),
                              const Text('Intente buscar otro producto',
                                  style: TextStyle(fontSize: 12, color: grey)),
                              Visibility(
                                visible: context
                                    .read<UserBloc>()
                                    .fabricante
                                    .contains("Zebra"),
                                child: Container(
                                  height: 60,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: conteoBloc.lineasContadas
                                ?.where((element) {
                              return (element.isDoneItem == 1 ||
                                  element.isDoneItem == true);
                            }).length,
                            itemBuilder: (context, index) {
                              final product = conteoBloc
                                  .lineasContadas //recepcionBloc.listProductsEntrada
                                  .where((element) {
                                return (element.isDoneItem == 1 ||
                                    element.isDoneItem == true);
                              }).elementAt(index);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Card(
                                  color: white,
                                  // Cambia el color de la tarjeta si el producto está seleccionado
                                  // color: product.isSelected == 1
                                  //     ? primaryColorAppLigth // Color amarillo si está seleccionado
                                  //     : Colors
                                  //         .white, // Color blanco si no está seleccionado
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        // showDialog(
                                        //     context: context,
                                        //     builder: (context) {
                                        //       return const DialogLoading(
                                        //         message:
                                        //             'Cargando información del producto',
                                        //       );
                                        //     });

                                        // context
                                        //     .read<RecepcionBatchBloc>()
                                        //     .add(FetchPorductOrder(
                                        //       product,
                                        //     ));

                                        // // Esperar 3 segundos antes de continuar
                                        // Future.delayed(
                                        //     const Duration(milliseconds: 300),
                                        //     () {
                                        //   Navigator.pop(context);

                                        //   Navigator.pushReplacementNamed(
                                        //     context,
                                        //     'scan-product-reception-batch',
                                        //     arguments: [
                                        //       widget.ordenCompra,
                                        //       product
                                        //     ],
                                        //   );
                                        // });
                                        // print(product.toMap());
                                      },
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
                                          // Visibility(
                                          //   visible: recepcionBloc
                                          //           .configurations
                                          //           .result
                                          //           ?.result
                                          //           ?.hideExpectedQty ==
                                          //       false,
                                          //   child: Row(
                                          //     children: [
                                          //       Text(
                                          //         "Cantidad: ",
                                          //         style: TextStyle(
                                          //           fontSize: 12,
                                          //           color: primaryColorApp,
                                          //         ),
                                          //       ),
                                          //       Text(
                                          //           "${product.cantidadFaltante}",
                                          //           style: const TextStyle(
                                          //               fontSize: 12,
                                          //               color: black)),
                                          //     ],
                                          //   ),
                                          // ),
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
}
