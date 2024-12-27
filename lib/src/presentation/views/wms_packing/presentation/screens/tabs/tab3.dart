// ignore_for_file: unrelated_type_equality_checks, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/dialog_confirmated_packing_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab3Screen extends StatelessWidget {
  const Tab3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<WmsPackingBloc, WmsPackingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: context
                  .read<WmsPackingBloc>()
                  .productsDone
                  .isEmpty
              ? null
              : Stack(
                  children: [
                    Positioned(
                      bottom:
                          0.0, // Ajusta según sea necesario para colocar en la parte inferior
                      right:
                          0.0, // Ajusta según sea necesario para colocar en la parte derecha
                      child: FloatingActionButton(
                        onPressed:
                            context.read<WmsPackingBloc>().productsDone.isEmpty
                                ? null
                                : () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DialogConfirmatedPacking(
                                            productos: context
                                                .read<WmsPackingBloc>()
                                                .productsDone,
                                            isCertificate: true,
                                          );
                                        });
                                  },
                        backgroundColor: primaryColorApp,
                        child: Image.asset(
                          'assets/icons/packing.png',
                          width: 30,
                          height: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40.0, // Posición hacia arriba
                      right: 0.0, // Posición hacia la derecha
                      child: context
                              .read<WmsPackingBloc>()
                              .productsDone
                              .isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                context
                                    .read<WmsPackingBloc>()
                                    .productsDone
                                    .length
                                    .toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : const SizedBox
                              .shrink(), // No mostrar el número si no hay productos seleccionados
                    ),
                  ],
                ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                width: double.infinity,
                height: size.height * 0.7,
                child: (context.read<WmsPackingBloc>().productsDone.isEmpty)
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
                        itemCount:
                            context.read<WmsPackingBloc>().productsDone.length,
                        itemBuilder: (context, index) {
                          final product = context
                              .read<WmsPackingBloc>()
                              .productsDone[index];
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
                                                  fontSize: 14,
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
                                                        " ${product.idProduct}",
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: black))),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Card(
                                          elevation: 3,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Cantidad: ",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColorApp,
                                                      ),
                                                    ),
                                                    Text("${product.quantity}",
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: black)),
                                                    const Spacer(),
                                                    Text(
                                                      "Unidades: ",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColorApp,
                                                      ),
                                                    ),
                                                    Text("${product.unidades}",
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: black)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Cantidades Separadas : ",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColorApp,
                                                      ),
                                                    ),
                                                    Text(
                                                        "${product.quantitySeparate}",
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: black)),
                                                  ],
                                                ),
                                                if (product.observation != null)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Novedades : ",
                                                        style: TextStyle(
                                                          fontSize: 14,
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
                                                                        14,
                                                                    color:
                                                                        black)),
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
                                                  fontSize: 14,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              Text("${product.tracking}",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                            ],
                                          ),

                                        Row(
                                          children: [
                                            Text(
                                              "Peso: ",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Text("${product.weight}",
                                                style: const TextStyle(
                                                    fontSize: 14,
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
