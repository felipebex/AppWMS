// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/dialog_loading_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/dropdowbutton_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class PackingScreen extends StatefulWidget {
  PackingScreen({
    super.key,
  });

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode(); //cantidad textformfield

  String? selectedLocation;
  bool viewQuantity = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!context.read<WmsPackingBloc>().locationIsOk) {
      FocusScope.of(context).requestFocus(focusNode1);
    }
    if (!context.read<WmsPackingBloc>().productIsOk) {
      FocusScope.of(context).requestFocus(focusNode2);
    }
    if (!context.read<WmsPackingBloc>().quantityIsOk) {
      FocusScope.of(context).requestFocus(focusNode3);
    }
    if (!context.read<WmsPackingBloc>().locationDestIsOk) {
      FocusScope.of(context).requestFocus(focusNode5);
    }
  }

  @override
  void dispose() {
    focusNode4.dispose(); // Limpiar el FocusNode
    super.dispose();
  }

  TextEditingController cantidadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocConsumer<WmsPackingBloc, WmsPackingState>(
        listener: (context, state) {},
        builder: (context, state) {
          final packinghBloc = context.read<WmsPackingBloc>();

          return Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  //*barra de informacion
                  Container(
                    padding: const EdgeInsets.only(top: 30),
                    width: size.width,
                    color: primaryColorApp,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                context.read<WmsPackingBloc>().add(
                                    LoadAllProductsFromPedidoEvent(
                                        packinghBloc.currentProduct.pedidoId ??
                                            0));
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 30),
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Pickin - Packing",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //* todo ubicacion
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Form(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              //todo : ubicacion de origen
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: packinghBloc.locationIsOk
                                            ? green
                                            : yellow,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Card(
                                    color: packinghBloc.isLocationOk
                                        ? packinghBloc.locationIsOk
                                            ? Colors.green[100]
                                            : Colors.grey[300]
                                        : Colors.red[200],
                                    elevation: 5,
                                    child: Container(
                                      width: size.width * 0.85,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Focus(
                                        focusNode: focusNode1,
                                        onKey: (FocusNode node,
                                            RawKeyEvent event) {
                                          if (event is RawKeyDownEvent) {
                                            if (event.logicalKey ==
                                                LogicalKeyboardKey.enter) {
                                              if (scannedValue1.isNotEmpty) {
                                                if (scannedValue1
                                                        .toLowerCase() ==
                                                    packinghBloc.currentProduct
                                                        .locationId
                                                        .toString()
                                                        .toLowerCase()) {
                                                  packinghBloc.add(
                                                      ValidateFieldsPackingEvent(
                                                          field: "location",
                                                          isOk: true));

                                                  packinghBloc.add(
                                                      ChangeLocationIsOkEvent(
                                                    true,
                                                    packinghBloc.currentProduct
                                                            .productId ??
                                                        0,
                                                    packinghBloc.currentProduct
                                                            .pedidoId ??
                                                        0,
                                                  ));

                                                  packinghBloc.oldLocation =
                                                      packinghBloc
                                                          .currentProduct
                                                          .locationId
                                                          .toString();

                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 1), () {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            focusNode2);
                                                  });
                                                } else {
                                                  packinghBloc.add(
                                                      ValidateFieldsPackingEvent(
                                                          field: "location",
                                                          isOk: false));
                                                  setState(() {
                                                    scannedValue1 =
                                                        ""; //limpiamos el valor escaneado
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    duration: const Duration(
                                                        milliseconds: 1000),
                                                    content: const Text(
                                                        'Ubicacion erronea'),
                                                    backgroundColor:
                                                        Colors.red[200],
                                                  ));
                                                }
                                              }

                                              return KeyEventResult.handled;
                                            } else {
                                              setState(() {
                                                scannedValue1 +=
                                                    event.data.keyLabel;
                                              });
                                              return KeyEventResult.handled;
                                            }
                                          }
                                          return KeyEventResult.ignored;
                                        },
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: DropdownButton<String>(
                                                  underline: Container(
                                                    height: 0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  focusColor: Colors.white,
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Ubicación de origen',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: primaryColorApp),
                                                  ),
                                                  icon: Image.asset(
                                                    "assets/icons/ubicacion.png",
                                                    color: primaryColorApp,
                                                    width: 24,
                                                  ),
                                                  value: selectedLocation,
                                                  items: packinghBloc.positions
                                                      .map((String location) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: location,
                                                      child: Text(location),
                                                    );
                                                  }).toList(),
                                                  onChanged: packinghBloc
                                                          .locationIsOk
                                                      ? null
                                                      : (String? newValue) {
                                                          if (newValue ==
                                                              packinghBloc
                                                                  .currentProduct
                                                                  .locationId) {
                                                            packinghBloc.add(
                                                                ValidateFieldsPackingEvent(
                                                                    field:
                                                                        "location",
                                                                    isOk:
                                                                        true));

                                                            packinghBloc.add(
                                                                ChangeLocationIsOkEvent(
                                                              true,
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .productId ??
                                                                  0,
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .pedidoId ??
                                                                  0,
                                                            ));

                                                            packinghBloc
                                                                    .oldLocation =
                                                                packinghBloc
                                                                        .currentProduct
                                                                        .locationId ??
                                                                    "";

                                                            Future.delayed(
                                                                const Duration(
                                                                    seconds: 1),
                                                                () {
                                                              FocusScope.of(
                                                                      context)
                                                                  .requestFocus(
                                                                      focusNode2);
                                                            });
                                                          } else {
                                                            packinghBloc.add(
                                                                ValidateFieldsPackingEvent(
                                                                    field:
                                                                        "location",
                                                                    isOk:
                                                                        false));

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000),
                                                              content: const Text(
                                                                  'Ubicacion erronea'),
                                                              backgroundColor:
                                                                  Colors
                                                                      .red[200],
                                                            ));
                                                          }
                                                        },
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      packinghBloc
                                                              .currentProduct
                                                              .locationId ??
                                                          "",
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          color: black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // todo: Producto

                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: packinghBloc.productIsOk
                                            ? green
                                            : yellow,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Card(
                                    color: packinghBloc.isProductOk
                                        ? packinghBloc.productIsOk
                                            ? Colors.green[100]
                                            : Colors.grey[300]
                                        : Colors.red[200],
                                    elevation: 5,
                                    child: Container(
                                      width: size.width * 0.85,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Focus(
                                        focusNode: focusNode2,
                                        onKey: (FocusNode node,
                                            RawKeyEvent event) {
                                          if (event is RawKeyDownEvent) {
                                            if (event.logicalKey ==
                                                LogicalKeyboardKey.enter) {
                                              if (scannedValue2.isNotEmpty) {
                                                if (scannedValue2
                                                        .toLowerCase() ==
                                                    packinghBloc
                                                        .currentProduct.barcode
                                                        ?.toLowerCase()) {
                                                  packinghBloc.add(
                                                      ValidateFieldsPackingEvent(
                                                          field: "product",
                                                          isOk: true));

                                                  packinghBloc.add(
                                                      ChangeQuantitySeparate(
                                                    1,
                                                    packinghBloc.currentProduct
                                                            .productId ??
                                                        0,
                                                    packinghBloc.currentProduct
                                                            .pedidoId ??
                                                        0,
                                                  ));

                                                  packinghBloc.add(
                                                      ChangeProductIsOkEvent(
                                                    true,
                                                    packinghBloc.currentProduct
                                                            .productId ??
                                                        0,
                                                    packinghBloc.currentProduct
                                                            .pedidoId ??
                                                        0,
                                                    1,
                                                  ));

                                                  packinghBloc
                                                      .add(ChangeIsOkQuantity(
                                                    true,
                                                    packinghBloc.currentProduct
                                                            .productId ??
                                                        0,
                                                    packinghBloc.currentProduct
                                                            .pedidoId ??
                                                        0,
                                                  ));

                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 100),
                                                      () {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            focusNode3);
                                                  });
                                                } else {
                                                  packinghBloc.add(
                                                      ValidateFieldsPackingEvent(
                                                          field: "product",
                                                          isOk: false));
                                                  setState(() {
                                                    scannedValue2 =
                                                        ""; //limpiamos el valor escaneado
                                                  });

                                                  //mostramos alerta de error
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    duration: const Duration(
                                                        milliseconds: 1000),
                                                    content: const Text(
                                                        'Producto erroneo'),
                                                    backgroundColor:
                                                        Colors.red[200],
                                                  ));
                                                }

                                                return KeyEventResult.handled;
                                              }

                                              return KeyEventResult.handled;
                                            } else {
                                              setState(() {
                                                scannedValue2 +=
                                                    event.data.keyLabel;
                                              });
                                              return KeyEventResult.handled;
                                            }
                                          }
                                          return KeyEventResult.ignored;
                                        },
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: DropdownButton<String>(
                                                  underline: Container(
                                                    height: 0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  focusColor: Colors.white,
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Producto',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: primaryColorApp),
                                                  ),
                                                  icon: Image.asset(
                                                    "assets/icons/producto.png",
                                                    color: primaryColorApp,
                                                    width: 24,
                                                  ),
                                                  value: selectedLocation,
                                                  // items: batchBloc.positions
                                                  items: packinghBloc
                                                      .listOfProductos
                                                      .map((PorductoPedido
                                                          product) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: product.idProduct
                                                          .toString(),
                                                      child: Text(product
                                                          .idProduct
                                                          .toString()),
                                                    );
                                                  }).toList(),

                                                  onChanged: packinghBloc
                                                              .locationIsOk &&
                                                          !packinghBloc
                                                              .productIsOk
                                                      ? (String? newValue) {
                                                          if (newValue ==
                                                              packinghBloc
                                                                  .currentProduct
                                                                  .idProduct
                                                                  .toString()) {
                                                            packinghBloc.add(
                                                                ValidateFieldsPackingEvent(
                                                                    field:
                                                                        "product",
                                                                    isOk:
                                                                        true));

                                                            packinghBloc.add(
                                                                ChangeQuantitySeparate(
                                                              0,
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .productId ??
                                                                  0,
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .pedidoId ??
                                                                  0,
                                                            ));

                                                            packinghBloc.add(
                                                                ChangeProductIsOkEvent(
                                                              true,
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .productId ??
                                                                  0,
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .pedidoId ??
                                                                  0,
                                                              0,
                                                            ));

                                                            packinghBloc.add(
                                                                ChangeIsOkQuantity(
                                                              true,
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .productId ??
                                                                  0,
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .pedidoId ??
                                                                  0,
                                                            ));

                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        100),
                                                                () {
                                                              FocusScope.of(
                                                                      context)
                                                                  .requestFocus(
                                                                      focusNode3);
                                                            });
                                                          } else {
                                                            packinghBloc.add(
                                                                ValidateFieldsPackingEvent(
                                                                    field:
                                                                        "product",
                                                                    isOk:
                                                                        false));

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000),
                                                              content: const Text(
                                                                  'Producto erroneo'),
                                                              backgroundColor:
                                                                  Colors
                                                                      .red[200],
                                                            ));
                                                          }
                                                        }
                                                      : null,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  packinghBloc
                                                      .currentProduct.idProduct
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: black),
                                                ),
                                              ),

                                              const SizedBox(height: 10),
                                              // informacion del lote:
                                              // if (batchBloc.product.tracking ==
                                              //         'lot' ||
                                              //     batchBloc.product.tracking ==
                                              //         'serial')
                                              //   const Column(
                                              //     children: [
                                              //       Align(
                                              //         alignment: Alignment.centerLeft,
                                              //         child: Text(
                                              //           'Lote/Numero de serie ',
                                              //           style: TextStyle(
                                              //               fontSize: 16,
                                              //               color: primaryColorApp),
                                              //         ),
                                              //       ),
                                              //       Align(
                                              //         alignment: Alignment.centerLeft,
                                              //         child: Text(
                                              //           "",
                                              //           style: TextStyle(
                                              //               fontSize: 16,
                                              //               color: black),
                                              //         ),
                                              //       ),
                                              //     ],
                                              //   ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  //todo: cantidad
                  SizedBox(
                    width: size.width,
                    height: viewQuantity ? 150 : 110,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Card(
                            color: packinghBloc.isQuantityOk
                                ? packinghBloc.quantityIsOk
                                    ? white
                                    : Colors.grey[300]
                                : Colors.red[200],
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Center(
                                child: Row(
                                  children: [
                                    const Text('Recoger:',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        packinghBloc.currentProduct.quantity
                                                ?.toString() ??
                                            "",
                                        style: const TextStyle(
                                            color: primaryColorApp,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Text(
                                        packinghBloc.currentProduct.unidades ??
                                            "",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 18)),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Expanded(
                                        child: Container(
                                            alignment: Alignment.center,
                                            child: Focus(
                                              focusNode: focusNode3,
                                              onKey: (FocusNode node,
                                                  RawKeyEvent event) {
                                                if (event is RawKeyDownEvent) {
                                                  if (event.logicalKey ==
                                                      LogicalKeyboardKey
                                                          .enter) {
                                                    if (scannedValue3
                                                        .isNotEmpty) {
                                                      if (scannedValue3
                                                              .toLowerCase() ==
                                                          packinghBloc
                                                              .currentProduct
                                                              .barcode
                                                              ?.toLowerCase()) {
                                                        packinghBloc.add(
                                                            ValidateFieldsPackingEvent(
                                                                field:
                                                                    "quantity",
                                                                isOk: true));

                                                        packinghBloc.add(
                                                            AddQuantitySeparate(
                                                          1,
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .productId ??
                                                              0,
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .pedidoId ??
                                                              0,
                                                        ));

                                                        setState(() {
                                                          scannedValue3 =
                                                              ""; //limpiamos el valor escaneado
                                                        });

                                                        //*validamos que la cantidad sea igual a la cantidad del producto
                                                        if (packinghBloc
                                                                .quantitySelected ==
                                                            packinghBloc
                                                                .currentProduct
                                                                .quantity) {
                                                          // _nextProduct(
                                                          //     currentProduct,
                                                          //     batchBloc);
                                                        }
                                                      } else {
                                                        setState(() {
                                                          scannedValue3 =
                                                              ""; //limpiamos el valor escaneado
                                                        });
                                                      }
                                                    }

                                                    return KeyEventResult
                                                        .handled;
                                                  } else {
                                                    setState(() {
                                                      scannedValue3 +=
                                                          event.data.keyLabel;
                                                    });
                                                    return KeyEventResult
                                                        .handled;
                                                  }
                                                }
                                                return KeyEventResult.ignored;
                                              },
                                              child: Text(
                                                  packinghBloc.quantitySelected
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18)),
                                            )),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: packinghBloc.quantityIsOk &&
                                                packinghBloc.quantitySelected >=
                                                    0
                                            ? () {
                                                setState(() {
                                                  viewQuantity = !viewQuantity;
                                                });
                                              }
                                            : null,
                                        icon: const Icon(
                                            Icons.edit_note_rounded,
                                            color: primaryColorApp,
                                            size: 30)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: viewQuantity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            child: SizedBox(
                              height: 40,
                              child: TextFormField(
                                //tmano del campo

                                focusNode: focusNode4,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Solo permite dígitos
                                ],
                                onChanged: (value) {
                                  // // Verifica si el valor no está vacío y si es un número válido
                                  // if (value.isNotEmpty) {
                                  //   try {
                                  //     batchBloc.quantitySelected =
                                  //         int.parse(value);
                                  //   } catch (e) {
                                  //     // Manejo de errores si la conversión falla
                                  //     print('Error al convertir a entero: $e');
                                  //     // Aquí puedes mostrar un mensaje al usuario o manejar el error de otra forma
                                  //   }
                                  // } else {
                                  //   // Si el valor está vacío, puedes establecer un valor por defecto
                                  //   batchBloc.quantitySelected =
                                  //       0; // O cualquier valor que consideres adecuado
                                  // }
                                },
                                controller: cantidadController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    InputDecorations.authInputDecoration(
                                  hintText: 'Cantidad',
                                  labelText: 'Cantidad',
                                ),
                                //al dar enter
                                onFieldSubmitted: (value) {
                                  setState(() {
                                    //validamos que el texto no este vacio
                                    if (value.isNotEmpty) {
                                      if (int.parse(value) >
                                          (packinghBloc.currentProduct
                                                      .quantity ??
                                                  0)
                                              .toInt()) {
                                        //todo: cantidad fuera del rango
                                        packinghBloc.add(
                                            ValidateFieldsPackingEvent(
                                                field: "quantity",
                                                isOk: false));
                                        cantidadController.clear();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          duration: const Duration(seconds: 1),
                                          content:
                                              const Text('Cantidad incorrecta'),
                                          backgroundColor: Colors.red[200],
                                        ));
                                      } else {
                                        //todo: cantidad dentro del rango
                                        if (int.parse(value) ==
                                            packinghBloc
                                                .currentProduct.quantity) {
                                          //*cantidad correcta
                                          //guardamos la cantidad en la bd
                                          packinghBloc
                                              .add(ChangeQuantitySeparate(
                                            int.parse(value),
                                            packinghBloc
                                                    .currentProduct.productId ??
                                                0,
                                            packinghBloc
                                                    .currentProduct.productId ??
                                                0,
                                          ));

                                          packinghBloc.add(SetPickingsEvent(
                                              packinghBloc.currentProduct
                                                      .productId ??
                                                  0,
                                              packinghBloc.currentProduct
                                                      .pedidoId ??
                                                  0));

                                          cantidadController.clear();
                                          setState(() {
                                            viewQuantity = false;
                                          });

                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return const DialogLoadingPacking();
                                              });
                                          Future.delayed(
                                              const Duration(seconds: 1), () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            packinghBloc.add(
                                                LoadAllProductsFromPedidoEvent(
                                                    packinghBloc.currentProduct
                                                            .pedidoId ??
                                                        0));
                                          });
                                          return;

                                          // _nextProduct(currentProduct, batchBloc);
                                        } else {
                                          //todo cantidad menor a la cantidad pedida

                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return DialogPackingAdvetenciaCantidadScreen(
                                                    currentProduct: packinghBloc
                                                        .currentProduct,
                                                    cantidad: int.parse(
                                                        cantidadController
                                                            .text),
                                                    onAccepted: () {
                                                      packinghBloc.add(
                                                          ChangeQuantitySeparate(
                                                        int.parse(value),
                                                        packinghBloc
                                                                .currentProduct
                                                                .productId ??
                                                            0,
                                                        packinghBloc
                                                                .currentProduct
                                                                .pedidoId ??
                                                            0,
                                                      ));

                                                      packinghBloc.add(SetPickingsEvent(
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .productId ??
                                                              0,
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .pedidoId ??
                                                              0));

                                                      cantidadController
                                                          .clear();
                                                      setState(() {
                                                        viewQuantity = false;
                                                      });

                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return const DialogLoadingPacking();
                                                          });
                                                      Future.delayed(
                                                          const Duration(
                                                              seconds: 1), () {
                                                        packinghBloc.add(
                                                            LoadAllProductsFromPedidoEvent(
                                                                packinghBloc
                                                                        .currentProduct
                                                                        .pedidoId ??
                                                                    0));
                                                      });
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      return;
                                                    });
                                              });
                                        }
                                      }
                                    }
                                    viewQuantity = false;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            child: ElevatedButton(
                              onPressed: packinghBloc.quantityIsOk &&
                                      packinghBloc.quantitySelected >= 0
                                  ? () {
                                      int cantidad = int.parse(
                                          cantidadController.text.isEmpty
                                              ? packinghBloc.quantitySelected
                                                  .toString()
                                              : cantidadController.text);

                                      if (cantidad ==
                                          packinghBloc
                                              .currentProduct.quantity) {
                                        packinghBloc.add(ChangeQuantitySeparate(
                                          int.parse(cantidadController.text),
                                          packinghBloc
                                                  .currentProduct.productId ??
                                              0,
                                          packinghBloc
                                                  .currentProduct.productId ??
                                              0,
                                        ));

                                        // _nextProduct(currentProduct, batchBloc);
                                      } else {
                                        if (cantidad <
                                            (packinghBloc.currentProduct
                                                        .quantity ??
                                                    0)
                                                .toInt()) {
                                          // showDialog(
                                          //     context: context,
                                          //     builder: (context) {
                                          //       return DialogAdvetenciaCantidadScreen(
                                          //           currentProduct: currentProduct,
                                          //           cantidad: cantidad,
                                          //           batchId: batchBloc
                                          //                   .batchWithProducts
                                          //                   .batch
                                          //                   ?.id ??
                                          //               0,
                                          //           onAccepted: () async {
                                          //             batchBloc.add(
                                          //                 ChangeQuantitySeparate(
                                          //                     cantidad,
                                          //                     currentProduct
                                          //                             .idProduct ??
                                          //                         0,
                                          //                     currentProduct.idMove ??
                                          //                         0));

                                          //             _nextProduct(
                                          //                 currentProduct, batchBloc);
                                          //             cantidadController.clear();
                                          //           });
                                          //     });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            content:
                                                const Text('Cantidad erronea'),
                                            backgroundColor: Colors.red[200],
                                          ));
                                        }
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColorApp,
                                minimumSize: Size(size.width * 0.93, 35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'APLICAR CANTIDAD',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }
}
