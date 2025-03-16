// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab2ScreenRecep extends StatelessWidget {
  const Tab2ScreenRecep({
    super.key,
    required this.ordenCompra,
  });

  final ResultEntrada? ordenCompra;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: BlocBuilder<WmsPackingBloc, WmsPackingState>(
        builder: (context, state) {
          return BlocListener<WmsPackingBloc, WmsPackingState>(
            listener: (context, state) {
              if (state is UnPackignSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(milliseconds: 1000),
                  content: Text(state.message),
                  backgroundColor: Colors.green[200],
                ));
              }
            },
            child: Scaffold(
              backgroundColor: white,
              body: Container(
                margin: const EdgeInsets.only(top: 5),
                width: double.infinity,
                height: size.height * 0.8,
                child: Column(
                  children: [
                    (ordenCompra?.lineasRecepcion?.isEmpty ?? true)
                        ? Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Text('No hay productos',
                                    style:
                                        TextStyle(fontSize: 14, color: grey)),
                                const Text('Intente buscar otro producto',
                                    style:
                                        TextStyle(fontSize: 12, color: grey)),
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
                              itemCount: ordenCompra?.lineasRecepcion?.length,
                              itemBuilder: (context, index) {
                                final product =
                                    ordenCompra?.lineasRecepcion?[index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Card(
                                    color: white,
                                    // Cambia el color de la tarjeta si el producto está seleccionado
                                    // color: context
                                    //         .read<WmsPackingBloc>()
                                    //         .listOfProductsForPacking
                                    //         .contains(product)
                                    //     ? primaryColorAppLigth // Color amarillo si está seleccionado
                                    //     : Colors
                                    //         .white, // Color blanco si no está seleccionado
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            'scan-product-order',
                                            arguments: [ordenCompra, product],
                                          );
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
                                                  fontSize: 14,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${product?.productName}",
                                                style: const TextStyle(
                                                    fontSize: 14, color: black),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Codigo: ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: primaryColorApp,
                                                  ),
                                                ),
                                                Text("${product?.productCode}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: black)),
                                              ],
                                            ),
                                            Text(
                                              "Ubicación: ",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Text("${product?.locationName}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: black)),
                                            Row(
                                              children: [
                                                Text(
                                                  "Cantidad: ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: primaryColorApp,
                                                  ),
                                                ),
                                                Text(
                                                    "${product?.quantityOrdered}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: black)),
                                              ],
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
            ),
          );
        },
      ),
    );
  }
}
