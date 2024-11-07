// ignore_for_file: unrelated_type_equality_checks

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
          floatingActionButton: FloatingActionButton(
            onPressed: context.read<WmsPackingBloc>().productsDone.isEmpty
                ? null
                : () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return DialogConfirmatedPacking(
                            productos:
                                context.read<WmsPackingBloc>().productsDone,
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
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                width: double.infinity,
                height: size.height * 0.75,
                child: (context.read<WmsPackingBloc>().productsDone.isEmpty)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/empty.png',
                                height:
                                    150), // Ajusta la altura según necesites
                            const SizedBox(height: 10),
                            const Text('No hay productos por empacar',
                                style: TextStyle(fontSize: 18, color: grey)),
                            const Text('Selecciona otro pedido',
                                style: TextStyle(fontSize: 14, color: grey)),
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
                                              const Text(
                                                "Producto:",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.7,
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
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
                                                    const Text(
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
                                                    const Text(
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
                                                    const Text(
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
                                                      const Text(
                                                        "Novedades : ",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              primaryColorApp,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: size.width * 0.6,
                                                        child: Text(
                                                            "${product.observation}",
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
                                              const Text(
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
                                            const Text(
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
