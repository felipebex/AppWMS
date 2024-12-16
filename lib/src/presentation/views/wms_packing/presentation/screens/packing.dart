// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_element, avoid_print, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/dialog_loading_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/dropdowbutton_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class PackingScreen extends StatefulWidget {
  const PackingScreen({
    super.key,
  });

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';

  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfield
  FocusNode focusNode5 = FocusNode(); //cantidad textformfield

  String? selectedLocation;
  bool viewQuantity = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final batchBloc = context.read<WmsPackingBloc>();
    if (!batchBloc.locationIsOk && //false
        !batchBloc.productIsOk && //false
        !batchBloc.quantityIsOk && //false
        !batchBloc.locationDestIsOk) //false
    {
      print("focus ubicacion");

      FocusScope.of(context).requestFocus(focusNode1);
    }

    if (batchBloc.locationIsOk && //true
        !batchBloc.productIsOk && //false
        !batchBloc.quantityIsOk && //false
        !batchBloc.locationDestIsOk) //false
    {
      print("focus producto");

      FocusScope.of(context).requestFocus(focusNode2);
    }
    if (batchBloc.locationIsOk && //true
        batchBloc.productIsOk && //true
        batchBloc.quantityIsOk && //ttrue
        !batchBloc.locationDestIsOk && //false
        !viewQuantity) //false
    {
      print("focus cantidad");

      FocusScope.of(context).requestFocus(focusNode3);
    }

    if (batchBloc.locationIsOk &&
        batchBloc.productIsOk &&
        !batchBloc.quantityIsOk &&
        !batchBloc.locationDestIsOk) {
      print("focus muelle");

      FocusScope.of(context).requestFocus(focusNode5);
    }
  }

  @override
  void dispose() {
    // Limpiar todos los FocusNode
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
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
                              child: Center(
                                child: Text(
                                  "Certificación de Packing",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
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
                                                print(scannedValue1);
                                                if (scannedValue1
                                                        .toLowerCase() ==
                                                    packinghBloc.currentProduct
                                                        .barcodeLocation
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
                                                  hint: Text(
                                                    'Ubicación de origen',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColorApp),
                                                  ),
                                                  icon: Image.asset(
                                                    "assets/icons/ubicacion.png",
                                                    color: primaryColorApp,
                                                    width: 20,
                                                  ),
                                                  value: selectedLocation,
                                                  items: packinghBloc.positions
                                                      .map((String location) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: location,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: packinghBloc
                                                                        .currentProduct
                                                                        .locationId
                                                                        .toString() ==
                                                                    location
                                                                ? Colors
                                                                    .green[100]
                                                                : Colors.white),
                                                        width: size.width * 0.9,
                                                        height: 45,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 5,
                                                          vertical: 3,
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(location,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          14)),
                                                        ),
                                                      ),
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
                                                          fontSize: 14,
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
                                                    packinghBloc.currentProduct
                                                            .idMove ??
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
                                                    packinghBloc.currentProduct
                                                            .idMove ??
                                                        0,
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
                                                    packinghBloc.currentProduct
                                                            .idMove ??
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
                                                  hint: Text(
                                                    'Producto',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColorApp),
                                                  ),
                                                  icon: Image.asset(
                                                    "assets/icons/producto.png",
                                                    color: primaryColorApp,
                                                    width: 20,
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
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: (packinghBloc
                                                                            .currentProduct
                                                                            .idProduct ==
                                                                        product
                                                                            .idProduct &&
                                                                    packinghBloc
                                                                            .currentProduct
                                                                            .idMove ==
                                                                        product
                                                                            .idMove)
                                                                ? Colors
                                                                    .green[100]
                                                                : Colors.white),
                                                        width: size.width * 0.9,
                                                        height: 45,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 5,
                                                          vertical: 3,
                                                        ),
                                                        child: Text(
                                                            product.idProduct ??
                                                                "",
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    color:
                                                                        black,
                                                                    fontSize:
                                                                        14)),
                                                      ),
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
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .idMove ??
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
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .idMove ??
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
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .idMove ??
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
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start, //alineamos el texto a la izquierda
                                                  children: [
                                                    Text(
                                                      packinghBloc
                                                          .currentProduct
                                                          .idProduct
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: black),
                                                    ),
                                                    Visibility(
                                                      visible: packinghBloc
                                                                  .currentProduct
                                                                  .barcode ==
                                                              false ||
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .barcode ==
                                                              null ||
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .barcode ==
                                                              "",
                                                      child: const Text(
                                                        "Sin codigo de barras",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              if (packinghBloc
                                                      .currentProduct.loteId !=
                                                  null)
                                                Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'Lote/Numero de serie ',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                primaryColorApp),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        packinghBloc
                                                                .currentProduct
                                                                .lotId ??
                                                            '',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: black),
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
                                            color: Colors.black, fontSize: 14)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        packinghBloc.currentProduct.quantity
                                                ?.toString() ??
                                            "",
                                        style: TextStyle(
                                            color: primaryColorApp,
                                            fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                        packinghBloc.currentProduct.unidades ??
                                            "",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14)),
                                    const Spacer(),
                                    Expanded(
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          alignment: Alignment.center,
                                          child: Focus(
                                            focusNode: focusNode3,
                                            onKey: (FocusNode node,
                                                RawKeyEvent event) {
                                              if (event is RawKeyDownEvent) {
                                                if (event.logicalKey ==
                                                    LogicalKeyboardKey.enter) {
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
                                                              field: "quantity",
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
                                                        packinghBloc.add(
                                                            ChangeQuantitySeparate(
                                                          packinghBloc
                                                              .quantitySelected,
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .productId ??
                                                              0,
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .productId ??
                                                              0,
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .idMove ??
                                                              0,
                                                        ));

                                                        packinghBloc.add(
                                                            SetPickingsEvent(
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .productId ??
                                                              0,
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .pedidoId ??
                                                              0,
                                                          packinghBloc
                                                                  .currentProduct
                                                                  .idMove ??
                                                              0,
                                                        ));

                                                        cantidadController
                                                            .clear();

                                                        setState(() {
                                                          viewQuantity = false;
                                                        });

                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder: (context) {
                                                              return const DialogLoadingPacking();
                                                            });
                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 1),
                                                            () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                          packinghBloc.add(
                                                              LoadAllProductsFromPedidoEvent(
                                                                  packinghBloc
                                                                          .currentProduct
                                                                          .pedidoId ??
                                                                      0));
                                                        });
                                                      }
                                                    } else {
                                                      setState(() {
                                                        scannedValue3 =
                                                            ""; //limpiamos el valor escaneado
                                                      });
                                                    }
                                                  }

                                                  return KeyEventResult.handled;
                                                } else {
                                                  setState(() {
                                                    scannedValue3 +=
                                                        event.data.keyLabel;
                                                  });
                                                  return KeyEventResult.handled;
                                                }
                                              }
                                              return KeyEventResult.ignored;
                                            },
                                            child: Text(
                                                packinghBloc.quantitySelected
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14)),
                                          )),
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
                                        icon: Icon(Icons.edit_note_rounded,
                                            color: primaryColorApp, size: 30)),
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
                                  // Verifica si el valor no está vacío y si es un número válido
                                  if (value.isNotEmpty) {
                                    try {
                                      packinghBloc.quantitySelected =
                                          int.parse(value);
                                    } catch (e) {
                                      // Manejo de errores si la conversión falla
                                      print('Error al convertir a entero: $e');
                                      // Aquí puedes mostrar un mensaje al usuario o manejar el error de otra forma
                                    }
                                  } else {
                                    // Si el valor está vacío, puedes establecer un valor por defecto
                                    packinghBloc.quantitySelected =
                                        0; // O cualquier valor que consideres adecuado
                                  }
                                },
                                controller: cantidadController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    InputDecorations.authInputDecoration(
                                  hintText: 'Cantidad',
                                  labelText: 'Cantidad',
                                  suffixIconButton: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        viewQuantity = !viewQuantity;
                                      });
                                      cantidadController.clear();

                                      //cambiamos el foco pa leer por pda la cantidad
                                      Future.delayed(
                                          const Duration(milliseconds: 100),
                                          () {
                                        FocusScope.of(context)
                                            .requestFocus(focusNode3);
                                      });
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
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
                                          print("cantidad correcta");

                                          //guardamos la cantidad en la bd
                                          packinghBloc
                                              .add(ChangeQuantitySeparate(
                                            int.parse(value),
                                            packinghBloc
                                                    .currentProduct.productId ??
                                                0,
                                            packinghBloc
                                                    .currentProduct.pedidoId ??
                                                0,
                                            packinghBloc
                                                    .currentProduct.idMove ??
                                                0,
                                          ));

                                          packinghBloc.add(SetPickingsEvent(
                                            packinghBloc
                                                    .currentProduct.productId ??
                                                0,
                                            packinghBloc
                                                    .currentProduct.pedidoId ??
                                                0,
                                            packinghBloc
                                                    .currentProduct.idMove ??
                                                0,
                                          ));

                                          cantidadController.clear();
                                          setState(() {
                                            viewQuantity = false;
                                          });

                                          showDialog(
                                              barrierDismissible: false,
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
                                                        packinghBloc
                                                                .currentProduct
                                                                .idMove ??
                                                            0,
                                                      ));

                                                      packinghBloc
                                                          .add(SetPickingsEvent(
                                                        packinghBloc
                                                                .currentProduct
                                                                .productId ??
                                                            0,
                                                        packinghBloc
                                                                .currentProduct
                                                                .pedidoId ??
                                                            0,
                                                        packinghBloc
                                                                .currentProduct
                                                                .idMove ??
                                                            0,
                                                      ));

                                                      cantidadController
                                                          .clear();
                                                      setState(() {
                                                        viewQuantity = false;
                                                      });

                                                      showDialog(
                                                          barrierDismissible:
                                                              false,
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
                                        //*cantidad correcta
                                        //guardamos la cantidad en la bd
                                        packinghBloc.add(ChangeQuantitySeparate(
                                          packinghBloc.currentProduct.quantity,
                                          packinghBloc
                                                  .currentProduct.productId ??
                                              0,
                                          packinghBloc
                                                  .currentProduct.pedidoId ??
                                              0,
                                          packinghBloc.currentProduct.idMove ??
                                              0,
                                        ));

                                        packinghBloc.add(SetPickingsEvent(
                                          packinghBloc
                                                  .currentProduct.productId ??
                                              0,
                                          packinghBloc
                                                  .currentProduct.pedidoId ??
                                              0,
                                          packinghBloc.currentProduct.idMove ??
                                              0,
                                        ));

                                        cantidadController.clear();
                                        setState(() {
                                          viewQuantity = false;
                                        });

                                        showDialog(
                                            barrierDismissible: false,
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
                                      } else {
                                        if (cantidad <
                                            (packinghBloc.currentProduct
                                                        .quantity ??
                                                    0)
                                                .toInt()) {
                                          //*cantidad menor a la cantidad pedida
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return DialogPackingAdvetenciaCantidadScreen(
                                                    currentProduct: packinghBloc
                                                        .currentProduct,
                                                    cantidad: int.parse(
                                                        cantidadController
                                                                .text.isEmpty
                                                            ? '0'
                                                            : cantidadController
                                                                .text),
                                                    onAccepted: () {
                                                      packinghBloc.add(
                                                          ChangeQuantitySeparate(
                                                        int.parse(cantidadController
                                                                .text.isEmpty
                                                            ? '0'
                                                            : cantidadController
                                                                .text),
                                                        packinghBloc
                                                                .currentProduct
                                                                .productId ??
                                                            0,
                                                        packinghBloc
                                                                .currentProduct
                                                                .pedidoId ??
                                                            0,
                                                        packinghBloc
                                                                .currentProduct
                                                                .idMove ??
                                                            0,
                                                      ));

                                                      packinghBloc
                                                          .add(SetPickingsEvent(
                                                        packinghBloc
                                                                .currentProduct
                                                                .productId ??
                                                            0,
                                                        packinghBloc
                                                                .currentProduct
                                                                .pedidoId ??
                                                            0,
                                                        packinghBloc
                                                                .currentProduct
                                                                .idMove ??
                                                            0,
                                                      ));

                                                      cantidadController
                                                          .clear();
                                                      setState(() {
                                                        viewQuantity = false;
                                                      });

                                                      showDialog(
                                                          barrierDismissible:
                                                              false,
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
                                    color: Colors.white, fontSize: 14),
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
