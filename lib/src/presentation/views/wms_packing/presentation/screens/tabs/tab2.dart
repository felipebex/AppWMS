// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/dialog_confirmated_packing_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
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
          floatingActionButton: context.read<WmsPackingBloc>().isKeyboardVisible
              ? null
              : FloatingActionButton(
                  onPressed: context
                          .read<WmsPackingBloc>()
                          .listOfProductosProgress
                          .isEmpty
                      ? null
                      : () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return DialogConfirmatedPacking(
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
              margin: const EdgeInsets.only(top: 5),
              width: double.infinity,
              height: size.height * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (value) {
                          context
                              .read<WmsPackingBloc>()
                              .add(SearchProductPackingEvent(value));
                        },
                        onTap: !context
                                .read<UserBloc>()
                                .fabricante
                                .contains("Zebra")
                            ? null
                            : () {
                                context
                                    .read<WmsPackingBloc>()
                                    .add(ShowKeyboardEvent(true));
                              },
                        controller: context
                            .read<WmsPackingBloc>()
                            .searchControllerProduct,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search, color: grey),
                          suffixIcon: IconButton(
                              onPressed: () {
                                context
                                    .read<WmsPackingBloc>()
                                    .add(SearchProductPackingEvent(""));
                                context
                                    .read<WmsPackingBloc>()
                                    .searchControllerProduct
                                    .clear();
                                //cerramo el teclado
                                FocusScope.of(context).unfocus();
                                context
                                    .read<WmsPackingBloc>()
                                    .add(ShowKeyboardEvent(false));
                              },
                              icon: const Icon(Icons.close, color: grey)),
                          disabledBorder: const OutlineInputBorder(),
                          hintText: "Buscar productos",
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  (context
                          .read<WmsPackingBloc>()
                          .listOfProductosProgress
                          .isEmpty)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (!context
                                  .read<UserBloc>()
                                  .fabricante
                                  .contains("Zebra"))
                                Image.asset('assets/images/empty.png',
                                    height: 100),
                              const SizedBox(height: 50),
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
                              itemCount: context
                                  .read<WmsPackingBloc>()
                                  .listOfProductosProgress
                                  .length,
                              itemBuilder: (context, index) {
                                final product = context
                                    .read<WmsPackingBloc>()
                                    .listOfProductosProgress[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      context
                                          .read<WmsPackingBloc>()
                                          .add(FetchProductEvent(product));

                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return const DialogLoading();
                                          });

                                      // Esperar 3 segundos antes de continuar
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        // Cerrar el diálogo de carga
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();

                                        // Ahora navegar a la vista "batch"
                                        Navigator.pushNamed(
                                          context,
                                          'Packing',
                                        );
                                      });
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
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      " ${product.idProduct}",
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: black))),
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
                                                          fontSize: 16,
                                                          color: black)),
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
                                                          fontSize: 14,
                                                          color: black)),
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
                                                          fontSize: 14,
                                                          color: black)),
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
                  Visibility(
                    visible: context.read<WmsPackingBloc>().isKeyboardVisible &&
                        context.read<UserBloc>().fabricante.contains("Zebra"),
                    child: CustomKeyboard(
                      controller: context
                          .read<WmsPackingBloc>()
                          .searchControllerProduct,
                      onchanged: () {
                        context.read<WmsPackingBloc>().add(
                            SearchProductPackingEvent(context
                                .read<WmsPackingBloc>()
                                .searchControllerProduct
                                .text));
                      },
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}
