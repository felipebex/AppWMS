// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/dialog_confirmated_packing_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab2Screen extends StatelessWidget {
  const Tab2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<WmsPackingBloc, WmsPackingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            onPressed:
                context.read<WmsPackingBloc>().listOfProductosProgress.isEmpty
                    ? null
                    : () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return  DialogConfirmatedPacking(
                                productos: context
                                    .read<WmsPackingBloc>()
                                    .listOfProductosProgress,
                                isCertificate: false,
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
          body: Container(
            margin: const EdgeInsets.only(top: 10),
            width: double.infinity,
            height: size.height * 0.8,
            child: (context
                    .read<WmsPackingBloc>()
                    .listOfProductosProgress
                    .isEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/empty.png',
                            height: 150), // Ajusta la altura según necesites
                        const SizedBox(height: 10),
                        const Text('No hay productos por empacar',
                            style: TextStyle(fontSize: 18, color: grey)),
                        const Text('Selecciona otro pedido',
                            style: TextStyle(fontSize: 14, color: grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: context
                        .read<WmsPackingBloc>()
                        .listOfProductosProgress
                        .length,
                    itemBuilder: (context, index) {
                      final product = context
                          .read<WmsPackingBloc>()
                          .listOfProductosProgress[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () {
                            //actualizamos el currentProduct

                            context
                                .read<WmsPackingBloc>()
                                .add(FetchProductEvent(product));

                            Navigator.pushNamed(
                              context,
                              'Packing',
                            );

                            print("Producto seleccionado: ${product.toJson()}");
                          },
                          child: Card(
                              color: product.isSelected == 1
                                  ? primaryColorAppLigth
                                  : Colors.white,
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Column(
                                  children: [
                                     Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Producto:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: primaryColorApp,
                                        ),
                                      ),
                                    ),
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(" ${product.idProduct}",
                                            style: const TextStyle(
                                                fontSize: 14, color: black))),
                                    Row(
                                      children: [
                                         Text(
                                          "pedido: ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: primaryColorApp,
                                          ),
                                        ),
                                        Text("${product.pedidoId}",
                                            style: const TextStyle(
                                                fontSize: 16, color: black)),
                                      ],
                                    ),
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
                                                fontSize: 14, color: black)),
                                        const Spacer(),
                                         Text(
                                          "Unidad de medida: ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: primaryColorApp,
                                          ),
                                        ),
                                        Text("${product.unidades}",
                                            style: const TextStyle(
                                                fontSize: 14, color: black)),
                                      ],
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
                                          Text("${product.lotId}",
                                              style: const TextStyle(
                                                  fontSize: 14, color: black)),
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
        );
      },
    );
  }
}
