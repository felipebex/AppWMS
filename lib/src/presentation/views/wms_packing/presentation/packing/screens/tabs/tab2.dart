// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/widgets/dialog_confirmated_packing_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab2Screen extends StatefulWidget {
  const Tab2Screen({super.key, this.packingModel, this.batchModel});

  final PedidoPacking? packingModel;
  final BatchPackingModel? batchModel;

  @override
  State<Tab2Screen> createState() => _Tab2ScreenState();
}

class _Tab2ScreenState extends State<Tab2Screen> {
  FocusNode focusNode1 = FocusNode(); //cantidad textformfield

  final TextEditingController _controllerToDo = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(focusNode1);
  }

  @override
  void dispose() {
    focusNode1.dispose();
    super.dispose();
  }

  void validateBarcode(String value, BuildContext context) {
    final bloc = context.read<WmsPackingBloc>();

    String scan = bloc.scannedValue5.toLowerCase() == ""
        ? value.toLowerCase()
        : bloc.scannedValue5.toLowerCase();

    _controllerToDo.text = "";

    // Obtener la lista de productos desde el Bloc
    final listOfProducts = bloc.listOfProductosProgress;

    // Buscar el producto que coincide con el código de barras escaneado
    final product = listOfProducts.firstWhere(
      (product) => product.barcode.toLowerCase() == scan,
      orElse: () =>
          PorductoPedido(), // Devuelve null si no se encuentra ningún producto
    );

    if (product.idMove != null) {
      // Si el producto existe, ejecutar los estados necesarios
      bloc.add(
          FetchProductEvent(product)); // Pasar el producto encontrado al evento

      showDialog(
        context: context,
        builder: (context) {
          return const DialogLoading(
            message: 'Cargando información del producto...',
          );
        },
      );

      bloc.add(ChangeProductIsOkEvent(true, product.idProduct ?? 0,
          product.pedidoId ?? 0, 0, product.idMove ?? 0));

      bloc.add(ChangeIsOkQuantity(true, product.idProduct ?? 0,
          product.pedidoId ?? 0, product.idMove ?? 0));

      Future.delayed(const Duration(seconds: 1), () {
        // Cerrar el diálogo de carga
        Navigator.of(context, rootNavigator: true).pop();
        // Ahora navegar a la vista "batch"
        Navigator.pushReplacementNamed(
          context,
          'Packing',
          arguments: [widget.packingModel, widget.batchModel],
        );
      });

      // Limpiar el valor escaneado
      bloc.add(ClearScannedValuePackEvent('toDo'));
    } else {
      // Mostrar alerta de error si el producto no se encuentra
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Código erroneo"),
        backgroundColor: Colors.red[200],
        duration: const Duration(milliseconds: 500),
      ));
      bloc.add(ClearScannedValuePackEvent('toDo'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<WmsPackingBloc, WmsPackingState>(
      listener: (context, state) {
        if (state is WmsPackingErrorState) {
          //mostramos el error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red[200],
          ));
        }
        if (state is WmsPackingSuccessState) {
          //mostramos el error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green[200],
          ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: context
                      .read<WmsPackingBloc>()
                      .isKeyboardVisible ||
                  context.read<WmsPackingBloc>().listOfProductosProgress.isEmpty
              ? null
              : Stack(
                  children: [
                    // El FloatingActionButton
                    Positioned(
                      bottom:
                          0.0, // Ajusta según sea necesario para colocar en la parte inferior
                      right:
                          0.0, // Ajusta según sea necesario para colocar en la parte derecha
                      child: FloatingActionButton(
                        onPressed: context
                                .read<WmsPackingBloc>()
                                .listOfProductosProgress
                                .isEmpty
                            ? null
                            : () {
                                //cerramos el teclado
                                context
                                    .read<WmsPackingBloc>()
                                    .add(ChangeStickerEvent(false));

                                FocusScope.of(context).unfocus();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return DialogConfirmatedPacking(
                                        productos: context
                                            .read<WmsPackingBloc>()
                                            .listOfProductsForPacking,
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
                    ),
                    // El número de productos seleccionados
                    Positioned(
                      bottom: 40.0, // Posición hacia arriba
                      right: 0.0, // Posición hacia la derecha
                      child: context
                              .read<WmsPackingBloc>()
                              .listOfProductsForPacking
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
                                    .listOfProductsForPacking
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
          body: BlocBuilder<WmsPackingBloc, WmsPackingState>(
            builder: (context, state) {
              return Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: double.infinity,
                  height: size.height * 0.8,
                  child: Column(
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 10,
                      //   ),
                      //   child: Card(
                      //     color: Colors.white,
                      //     elevation: 2,
                      //     child: TextFormField(
                      //       readOnly: context
                      //               .read<UserBloc>()
                      //               .fabricante
                      //               .contains("Zebra")
                      //           ? true
                      //           : false,
                      //       textAlignVertical: TextAlignVertical.center,
                      //       onChanged: (value) {
                      //         context
                      //             .read<WmsPackingBloc>()
                      //             .add(SearchProductPackingEvent(value));
                      //       },
                      //       onTap: !context
                      //               .read<UserBloc>()
                      //               .fabricante
                      //               .contains("Zebra")
                      //           ? null
                      //           : () {
                      //               context
                      //                   .read<WmsPackingBloc>()
                      //                   .add(ShowKeyboardEvent(true));
                      //             },
                      //       controller: context
                      //           .read<WmsPackingBloc>()
                      //           .searchControllerProduct,
                      //       decoration: InputDecoration(
                      //         prefixIcon: const Icon(Icons.search, color: grey),
                      //         suffixIcon: IconButton(
                      //             onPressed: () {
                      //               context
                      //                   .read<WmsPackingBloc>()
                      //                   .add(SearchProductPackingEvent(""));
                      //               context
                      //                   .read<WmsPackingBloc>()
                      //                   .searchControllerProduct
                      //                   .clear();
                      //               //cerramo el teclado
                      //               FocusScope.of(context).unfocus();
                      //               context
                      //                   .read<WmsPackingBloc>()
                      //                   .add(ShowKeyboardEvent(false));
                      //             },
                      //             icon: const Icon(Icons.close, color: grey)),
                      //         disabledBorder: const OutlineInputBorder(),
                      //         hintText: "Buscar productos",
                      //         hintStyle:
                      //             const TextStyle(color: Colors.grey, fontSize: 12),
                      //         border: InputBorder.none,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      //*espacio para escanear y buscar el producto
                      context.read<UserBloc>().fabricante.contains("Zebra")
                          ? Container(
                              height: 15,
                              margin: const EdgeInsets.only(bottom: 5),
                              child: TextFormField(
                                autofocus: true,
                                showCursor: false,
                                controller: _controllerToDo,
                                focusNode: focusNode1,
                                onChanged: (value) {
                                  // Llamamos a la validación al cambiar el texto
                                  validateBarcode(value, context);
                                },
                                decoration: InputDecoration(
                                  // hintText:
                                  //     batchBloc.currentProduct.locationId.toString(),
                                  disabledBorder: InputBorder.none,
                                  hintStyle: const TextStyle(
                                      fontSize: 14, color: black),
                                  border: InputBorder.none,
                                ),
                              ),
                            )
                          :

                          //*focus para leer los productos
                          Focus(
                              focusNode: focusNode1,
                              autofocus: true,
                              onKey: (FocusNode node, RawKeyEvent event) {
                                if (event is RawKeyDownEvent) {
                                  if (event.logicalKey ==
                                      LogicalKeyboardKey.enter) {
                                    validateBarcode(
                                        context
                                            .read<WmsPackingBloc>()
                                            .scannedValue5,
                                        context);
                                    return KeyEventResult.handled;
                                  } else {
                                    context.read<WmsPackingBloc>().add(
                                        UpdateScannedValuePackEvent(
                                            event.data.keyLabel, 'toDo'));
                                    return KeyEventResult.handled;
                                  }
                                }
                                return KeyEventResult.ignored;
                              },
                              child: Container()),

                      (context
                              .read<WmsPackingBloc>()
                              .listOfProductosProgress
                              .isEmpty)
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
                                itemCount: context
                                    .read<WmsPackingBloc>()
                                    .listOfProductosProgress
                                    .length,
                                itemBuilder: (context, index) {
                                  final product = context
                                      .read<WmsPackingBloc>()
                                      .listOfProductosProgress[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Card(
                                      // Cambia el color de la tarjeta si el producto está seleccionado
                                      color: context
                                              .read<WmsPackingBloc>()
                                              .listOfProductsForPacking
                                              .contains(product)
                                          ? primaryColorAppLigth // Color amarillo si está seleccionado
                                          : Colors
                                              .white, // Color blanco si no está seleccionado
                                      elevation: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        child: Row(
                                          children: [
                                            //* Checkbox para seleccionar o deseleccionar el producto
                                            //* se activa segun el permiso
                                            Visibility(
                                              visible: context
                                                      .read<WmsPackingBloc>()
                                                      .configurations
                                                      .result
                                                      ?.result
                                                      ?.scanProduct ??
                                                  false,
                                              child: Checkbox(
                                                value: context
                                                    .read<WmsPackingBloc>()
                                                    .listOfProductsForPacking
                                                    .contains(product),
                                                onChanged: (bool? selected) {
                                                  if (selected == true) {
                                                    // Seleccionar producto
                                                    context
                                                        .read<WmsPackingBloc>()
                                                        .add(
                                                            SelectProductPackingEvent(
                                                                product));
                                                  } else {
                                                    // Deseleccionar producto
                                                    context
                                                        .read<WmsPackingBloc>()
                                                        .add(
                                                            UnSelectProductPackingEvent(
                                                                product));
                                                  }
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  print(
                                                      "Producto seleccionado: ${product.toMap()}");
                                                  // validamos si este articulo se encuentra en la lista de productos preparados
                                                  if (context
                                                      .read<WmsPackingBloc>()
                                                      .productsDone
                                                      .any((doneProduct) =>
                                                          doneProduct.idMove ==
                                                          product.idMove)) {
                                                    // Mostramos el error
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: const Text(
                                                          "Este producto se encuentra en estado preparado, por favor seleccione otro"),
                                                      backgroundColor:
                                                          Colors.red[200],
                                                    ));
                                                    return;
                                                  }

                                                  context
                                                      .read<WmsPackingBloc>()
                                                      .add(FetchProductEvent(
                                                          product));

                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const DialogLoading(
                                                        message:
                                                            'Cargando información del producto...',
                                                      );
                                                    },
                                                  );

                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 1), () {
                                                    // Cerrar el diálogo de carga
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();

                                                    // Ahora navegar a la vista "batch"
                                                    Navigator
                                                        .pushReplacementNamed(
                                                      context,
                                                      'Packing',
                                                      arguments: [
                                                        widget.packingModel,
                                                        widget.batchModel
                                                      ],
                                                    );
                                                  });
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        "Producto:",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              primaryColorApp,
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        " ${product.productId}",
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: black),
                                                      ),
                                                    ),
                                                    Text(
                                                      "Ubicación: ",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColorApp,
                                                      ),
                                                    ),

                                                    Row(
                                                      children: [
                                                        Text(
                                                            "${product.locationId}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color:
                                                                        black)),
                                                      ],
                                                    ),


                                                    


                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Pedido: ",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                primaryColorApp,
                                                          ),
                                                        ),
                                                        Text(
                                                            "${product.pedidoId}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color:
                                                                        black)),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Cantidad: ",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                primaryColorApp,
                                                          ),
                                                        ),
                                                        Text(
                                                            product.isProductSplit ==
                                                                        1 &&
                                                                    product.isSeparate ==
                                                                        1
                                                                ? "${product.pendingQuantity}"
                                                                : "${product.quantity}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        black)),
                                                        const Spacer(),
                                                        Text(
                                                          "Unidad de medida: ",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                primaryColorApp,
                                                          ),
                                                        ),
                                                        Text(
                                                            "${product.unidades}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        black)),
                                                      ],
                                                    ),
                                                    if (product.tracking !=
                                                        false)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Número de serie/lote: ",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  primaryColorApp,
                                                            ),
                                                          ),
                                                          Text(
                                                              "${product.lotId}",
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color:
                                                                          black)),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      Visibility(
                        visible:
                            context.read<WmsPackingBloc>().isKeyboardVisible &&
                                context
                                    .read<UserBloc>()
                                    .fabricante
                                    .contains("Zebra"),
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
                  ));
            },
          ),
        );
      },
    );
  }
}
