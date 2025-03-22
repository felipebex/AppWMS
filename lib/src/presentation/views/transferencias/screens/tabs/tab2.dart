// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, prefer_is_empty

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/transferencias/screens/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab2ScreenTrans extends StatelessWidget {
  const Tab2ScreenTrans({
    super.key,
    required this.transFerencia,
  });

  final ResultTransFerencias? transFerencia;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: BlocConsumer<TransferenciaBloc, TransferenciaState>(
        listener: (context, state) {},
        builder: (context, state) {
          final bloc = context.read<TransferenciaBloc>();

          return Scaffold(
            backgroundColor: white,
            body: Container(
              margin: const EdgeInsets.only(top: 5),
              width: double.infinity,
              height: size.height * 0.8,
              child: Column(
                children: [
                  // (recepcionBloc.listProductsEntrada.where((element) {
                  //         return element.isSeparate == 1 ;
                  //       }).length ==
                  //       0)
                  //     ?

                  // Expanded(
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     mainAxisSize: MainAxisSize.max,
                  //     children: [
                  //       const Text('No hay productos',
                  //           style: TextStyle(fontSize: 14, color: grey)),
                  //       const Text('Intente buscar otro producto',
                  //           style: TextStyle(fontSize: 12, color: grey)),
                  //       Visibility(
                  //         visible: context
                  //             .read<UserBloc>()
                  //             .fabricante
                  //             .contains("Zebra"),
                  //         child: Container(
                  //           height: 60,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // )
                  // :
                  Expanded(
                    child: ListView.builder(
                      itemCount: bloc.listProductsTransfer.length ?? 0,
                      // recepcionBloc.listProductsEntrada
                      //     .where((element) => element.isSeparate == 1)
                      //     .length,
                      itemBuilder: (context, index) {
                        // final product = recepcionBloc
                        //     .listProductsEntrada
                        //     .where((element) {
                        //   return element.isSeparate == 1;
                        // }).elementAt(index);

                        final product = bloc.listProductsTransfer?[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              print('product: ${product?.toMap()}');
                            },
                            child: Card(
                              color:
                                  white, // Color blanco si no está seleccionado
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Producto: ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: primaryColorApp,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        product?.productName ?? 'Sin nombre',
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
                                        Text(
                                            product?.productCode ??
                                                'Sin código',
                                            style: const TextStyle(
                                                fontSize: 12, color: black)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Lote: ",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: primaryColorApp,
                                          ),
                                        ),
                                        Text(product?.lotName ?? 'Sin lote',
                                            style: const TextStyle(
                                                fontSize: 12, color: black)),
                                        Text("/${product?.fechaVencimiento}",
                                            style: const TextStyle(
                                                fontSize: 12, color: black)),
                                      ],
                                    ),
                                    Text(
                                      "Ubicación de origen: ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryColorApp,
                                      ),
                                    ),
                                    Text(
                                        product?.locationName ??
                                            'Sin ubicación',
                                        style: const TextStyle(
                                            fontSize: 12, color: black)),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Cantidad pedida: ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Text(
                                                product?.quantityOrdered
                                                        .toString() ??
                                                    '0',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: black)),
                                          ],
                                        ),
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
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
