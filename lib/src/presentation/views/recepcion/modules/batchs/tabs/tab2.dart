// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, prefer_is_empty

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_batch_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/batchs/bloc/recepcion_batch_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab2ScreenRecepBatch extends StatefulWidget {
  const Tab2ScreenRecepBatch({
    super.key,
    required this.ordenCompra,
  });

  final ReceptionBatch? ordenCompra;

  @override
  State<Tab2ScreenRecepBatch> createState() => _Tab2ScreenRecepState();
}

class _Tab2ScreenRecepState extends State<Tab2ScreenRecepBatch> {
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
    // final bloc = context.read<RecepcionBatchBloc>();

    // String scan = bloc.scannedValue5.trim().toLowerCase() == ""
    //     ? value.trim().toLowerCase()
    //     : bloc.scannedValue5.trim().toLowerCase();

    // _controllerToDo.text = "";

    // // Obtener la lista de productos desde el Bloc
    // final listOfProducts = bloc.listProductsEntrada.where((element) {
    //   return (element.isSeparate == 0 || element.isSeparate == null) &&
    //       (element.isDoneItem == 0 || element.isDoneItem == null);
    // }).toList();

    // // Buscar el producto que coincide con el código de barras escaneado
    // final LineasTransferencia product = listOfProducts.firstWhere(
    //   (product) => product.productBarcode == scan.trim(),
    //   orElse: () =>
    //       LineasTransferencia(), // Devuelve null si no se encuentra ningún producto
    // );

    // if (product.idMove != null) {
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return const DialogLoading(
    //         message: 'Cargando información del producto...',
    //       );
    //     },
    //   );
    //   // Si el producto existe, ejecutar los estados necesarios

    //   bloc.add(ValidateFieldsOrderEvent(field: "product", isOk: true));

    //   bloc.add(ChangeQuantitySeparate(
    //     0,
    //     int.parse(product.productId),
    //     product.idRecepcion ?? 0,
    //     product.idMove ?? 0,
    //   ));
    //   bloc.add(ChangeProductIsOkEvent(
    //     product.idRecepcion ?? 0,
    //     true,
    //     int.parse(product.productId),
    //     0,
    //     product.idMove ?? 0,
    //   ));

    //   if (bloc.configurations.result?.result
    //           ?.scanDestinationLocationReception ==
    //       false) {
    //     print('con permiso de muelle desde tab 2');
    //     bloc.add(ChangeIsOkQuantity(product.idRecepcion ?? 0, true,
    //         int.parse(product.productId), product.idMove ?? 0));
    //   }

    //   context.read<RecepcionBloc>().add(FetchPorductOrder(
    //         product,
    //       ));

    //   Future.delayed(const Duration(milliseconds: 1000), () {
    //     Navigator.pop(context);
    //     Navigator.pushReplacementNamed(
    //       context,
    //       'scan-product-order',
    //       arguments: [widget.ordenCompra, product],
    //     );
    //   });
    //   print(product.toMap());
    //   // Limpiar el valor escaneado
    //   bloc.add(ClearScannedValueOrderEvent('toDo'));
    // } else {
    //   // Mostrar alerta de error si el producto no se encuentra
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: const Text("Código erroneo"),
    //     backgroundColor: Colors.red[200],
    //     duration: const Duration(milliseconds: 500),
    //   ));
    //   bloc.add(ClearScannedValueOrderEvent('toDo'));
    // }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocConsumer<RecepcionBatchBloc, RecepcionBatchState>(
        listener: (context, state) {
          

          // if (state is SendProductToOrderFailure) {
          //   Get.defaultDialog(
          //     title: '360 Software Informa',
          //     titleStyle: TextStyle(color: Colors.red, fontSize: 18),
          //     middleText: state.error,
          //     middleTextStyle: TextStyle(color: black, fontSize: 14),
          //     backgroundColor: Colors.white,
          //     radius: 10,
          //     actions: [
          //       ElevatedButton(
          //         onPressed: () {
          //           Get.back();
          //         },
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: primaryColorApp,
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //         ),
          //         child: Text('Aceptar', style: TextStyle(color: white)),
          //       ),
          //     ],
          //   );
          // }
        },
        builder: (context, state) {
          final recepcionBloc = context.read<RecepcionBatchBloc>();
          return Scaffold(
            backgroundColor: white,
            body: Container(
              margin: const EdgeInsets.only(top: 5),
              width: double.infinity,
              height: size.height * 0.8,
              child: Column(
                children: [
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
                              hintStyle:
                                  const TextStyle(fontSize: 14, color: black),
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
                                // validateBarcode(
                                //     context.read<RecepcionBatchBloc>().scannedValue5,
                                //     context);
                                return KeyEventResult.handled;
                              } else {
                                // context.read<RecepcionBloc>().add(
                                //     UpdateScannedValueOrderEvent(
                                //         event.data.keyLabel, 'toDo'));
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: Container()),

                  (recepcionBloc.listProductsEntrada.where((element) {
                            return (element.isSeparate == 0 ||
                                    element.isSeparate == null) &&
                                (element.isDoneItem == 0 ||
                                    element.isDoneItem == null);
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
                      :
                      // :
                      Expanded(
                          child: ListView.builder(
                            itemCount: recepcionBloc.listProductsEntrada
                                .where((element) {
                              return (element.isSeparate == 0 ||
                                      element.isSeparate == null) &&
                                  (element.isDoneItem == 0 ||
                                      element.isDoneItem == null);
                            }).length,
                            itemBuilder: (context, index) {
                              final product = recepcionBloc
                                  .listProductsEntrada //recepcionBloc.listProductsEntrada
                                  .where((element) {
                                return (element.isSeparate == 0 ||
                                        element.isSeparate == null) &&
                                    (element.isDoneItem == 0 ||
                                        element.isDoneItem == null);
                              }).elementAt(index);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Card(
                                  // color: white,
                                  // Cambia el color de la tarjeta si el producto está seleccionado
                                  color: product.isSelected == 1
                                      ? primaryColorAppLigth // Color amarillo si está seleccionado
                                      : Colors
                                          .white, // Color blanco si no está seleccionado
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
                                        //     .read<RecepcionBloc>()
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
                                        //     'scan-product-order',
                                        //     arguments: [
                                        //       widget.ordenCompra,
                                        //       product
                                        //     ],
                                        //   );
                                        // });
                                        print(product.toMap());
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
                                                  "Cantidad: ",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: primaryColorApp,
                                                  ),
                                                ),
                                                Text(
                                                    "${product.cantidadFaltante}",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: black)),
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
          );
        },
      ),
    );
  }
}
