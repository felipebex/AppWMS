// ignore_for_file: unrelated_type_equality_checks, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab4Screen extends StatelessWidget {
  const Tab4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<WmsPackingBloc, WmsPackingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                width: double.infinity,
                height: size.height * 0.7,
                child: (context
                        .read<WmsPackingBloc>()
                        .productsDonePacking
                        .isEmpty)
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No hay productos listos',
                                style: TextStyle(fontSize: 14, color: grey)),
                            Text('Intente con otro pedido o batch',
                                style: TextStyle(fontSize: 12, color: grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: context
                            .read<WmsPackingBloc>()
                            .productsDonePacking
                            .length,
                        itemBuilder: (context, index) {
                          final product = context
                              .read<WmsPackingBloc>()
                              .productsDonePacking[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () {
                                print("Producto: ${product.toJson()}");
                              },
                              child: Card(
                                  color: product.isSeparate == 1
                                      ? Colors.green[100]
                                      : Colors.white,
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              Text(
                                                "Producto:",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.65,
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        " ${product.productId}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black))),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Card(
                                          elevation: 3,
                                          color: product.quantity ==
                                                  product.quantitySeparate
                                              ? white
                                              : Colors.amber[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Cantidad: ",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: primaryColorApp,
                                                      ),
                                                    ),
                                                    Text("${product.quantity}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black)),
                                                    const Spacer(),
                                                    Text(
                                                      "Unidades: ",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: primaryColorApp,
                                                      ),
                                                    ),
                                                    Text("${product.unidades}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Cantidad empacada: ",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: primaryColorApp,
                                                      ),
                                                    ),
                                                    Text(
                                                        product.isCertificate ==
                                                                0
                                                            ? "${product.quantity}"
                                                            : "${product.quantitySeparate}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Paquete: ",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: primaryColorApp,
                                                      ),
                                                    ),
                                                    Text(
                                                       "${product.packageName}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black)),
                                                  ],
                                                ),
                                                if (product.observation !=
                                                        null &&
                                                    product.isProductSplit ==
                                                        null)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Novedad: ",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              primaryColorApp,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.55,
                                                        child: Text(
                                                            "${product.observation}",
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                      ),
                                                    ],
                                                  ),
                                                if (product.observation !=
                                                        null &&
                                                    product.isProductSplit == 1)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Novedad: ",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              primaryColorApp,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.55,
                                                        child: Text(
                                                            "${product.observation}",
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                      ),
                                                    ],
                                                  ),
                                                if (product.isProductSplit == 1)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Novedad: ",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              primaryColorApp,
                                                        ),
                                                      ),
                                                      const Text(
                                                        "Producto en diferentes paquetes",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        if (product.tracking != false)
                                          Row(
                                            children: [
                                              Text(
                                                "Numero de serie/lote: ",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              Text(
                                                  "${product.tracking} / ${product.lotId}",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: black)),
                                            ],
                                          ),

                                        Row(
                                          children: [
                                            Text(
                                              "Peso: ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Text("${product.weight}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: black)),
                                          ],
                                        ),
                                        // if (product.expirationDate != false)
                                        //   Row(
                                        //     children: [
                                        //       const Text(
                                        //         "Fecha de caducidad: ",
                                        //         style: TextStyle(
                                        //           fontSize: 16,
                                        //           color: primaryColorApp,
                                        //         ),
                                        //       ),
                                        //       Text("${product.expirationDate}",
                                        //           style: const TextStyle(
                                        //               fontSize: 16, color: black)),
                                        //     ],
                                        //   )
                                      ],
                                    ),
                                  )),
                            ),
                          );
                        }),
              ),
            ],
          ),
        );
      },
    );
  }
}
