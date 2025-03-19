// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, prefer_is_empty

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/wms_packing_bloc.dart';
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
                    (recepcionBloc.listProductsEntrada.where((element) {
                            return element.isSeparate == 1 ;
                          }).length ==
                          0)
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
                              itemCount: recepcionBloc.listProductsEntrada
                                  .where((element) => element.isSeparate == 1)
                                  .length,
                              itemBuilder: (context, index) {
                                final product = recepcionBloc
                                    .listProductsEntrada
                                    .where((element) {
                                  return element.isSeparate == 1;
                                }).elementAt(index);

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
                                            Text(
                                              "Ubicación de origen: ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Text("${product.locationName}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: black)),
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
                                                          color:
                                                              primaryColorApp,
                                                        ),
                                                      ),
                                                      Text(
                                                          "${product.quantityOrdered}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)),
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
                                                        "${product.quantitySeparate}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black)),
                                                  ],
                                                ),
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
            ),
          );
        },
      ),
    );
  }
}
