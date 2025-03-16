// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/widgets/location/location_card_widget.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/widgets/muelle/muelle_card_widget.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/widgets/product/product_card_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class ScanProductOrderScreen extends StatefulWidget {
  const ScanProductOrderScreen(
      {Key? key, required this.ordenCompra, required this.currentProduct})
      : super(key: key);

  final ResultEntrada? ordenCompra;
  final LineasRecepcion? currentProduct;

  @override
  State<ScanProductOrderScreen> createState() => _ScanProductOrderScreenState();
}

class _ScanProductOrderScreenState extends State<ScanProductOrderScreen> {
//focus para escanear

  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfieldƒ
  FocusNode focusNode5 = FocusNode(); //ubicacion destino

  String? selectedLocation;
  String? selectedMuelle;

  //controller
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _controllerLocationDest = TextEditingController();

  @override
  void dispose() {
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<RecepcionBloc, RecepcionState>(
      builder: (context, state) {
        final recepcionBloc = context.read<RecepcionBloc>();
        return Scaffold(
          body: SizedBox(
            width: size.width * 1,
            height: size.height * 1,
            child: Column(
              children: [
                AppBar(size: size, ordenCompra: widget.ordenCompra),
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(top: 2),
                      child: SingleChildScrollView(
                        child: Column(children: [
                          //todo : ubicacion de origen
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: recepcionBloc.locationIsOk
                                        ? green
                                        : yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Card(
                                color: recepcionBloc.isLocationOk
                                    ? recepcionBloc.locationIsOk
                                        ? Colors.green[100]
                                        : Colors.grey[300]
                                    : Colors.red[200],
                                elevation: 5,
                                child: Container(
                                  // color: Colors.amber,
                                  width: size.width * 0.85,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: context
                                          .read<UserBloc>()
                                          .fabricante
                                          .contains("Zebra")
                                      ? Column(
                                          children: [
                                            LocationOrderDropdownWidget(
                                                isPDA: false,
                                                selectedLocation:
                                                    selectedLocation,
                                                positionsOrigen: [
                                                  widget.currentProduct
                                                          ?.locationName ??
                                                      ''
                                                ],
                                                currentLocationId: widget
                                                        .currentProduct
                                                        ?.locationName ??
                                                    '',
                                                currentProduct:
                                                    widget.currentProduct!),
                                            Container(
                                              height: 15,
                                              margin: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: TextFormField(
                                                autofocus: true,
                                                showCursor: false,
                                                controller:
                                                    _controllerLocation, // Asignamos el controlador
                                                enabled: !recepcionBloc
                                                        .locationIsOk && // false
                                                    !recepcionBloc
                                                        .productIsOk && // false
                                                    !recepcionBloc
                                                        .quantityIsOk && // false
                                                    !recepcionBloc
                                                        .locationDestIsOk,

                                                focusNode: focusNode1,
                                                onChanged: (value) {
                                                  // Llamamos a la validación al cambiar el texto
                                                  // validateLocation(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: widget
                                                          .currentProduct
                                                          ?.locationName ??
                                                      '',
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  hintStyle: const TextStyle(
                                                      fontSize: 14,
                                                      color: black),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Focus(
                                          focusNode: focusNode1,
                                          onKey: (FocusNode node,
                                              RawKeyEvent event) {
                                            if (event is RawKeyDownEvent) {
                                              if (event.logicalKey ==
                                                  LogicalKeyboardKey.enter) {
                                                // validateLocation(
                                                //     //validamos la ubicacion
                                                //     context
                                                //         .read<RecepcionBloc>()
                                                //         .scannedValue1);

                                                return KeyEventResult.handled;
                                              } else {
                                                // context.read<BatchBloc>().add(
                                                //     UpdateScannedValueEvent(
                                                //         event.data.keyLabel,
                                                //         'location'));

                                                return KeyEventResult.handled;
                                              }
                                            }
                                            return KeyEventResult.ignored;
                                          },
                                          child: LocationOrderDropdownWidget(
                                              isPDA: true,
                                              selectedLocation:
                                                  selectedLocation,
                                              positionsOrigen: [
                                                widget.currentProduct
                                                        ?.locationName ??
                                                    ''
                                              ],
                                              currentLocationId: widget
                                                      .currentProduct
                                                      ?.locationName ??
                                                  '',
                                              currentProduct:
                                                  widget.currentProduct!),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          //todo : producto
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: recepcionBloc.productIsOk
                                        ? green
                                        : yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Card(
                                color: recepcionBloc.isProductOk
                                    ? recepcionBloc.productIsOk
                                        ? Colors.green[100]
                                        : Colors.grey[300]
                                    : Colors.red[200],
                                elevation: 5,
                                child: Container(
                                  width: size.width * 0.85,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: context
                                          .read<UserBloc>()
                                          .fabricante
                                          .contains("Zebra")
                                      ? Column(
                                          children: [
                                            ProductDropdownOrderWidget(
                                              selectedProduct: selectedLocation,
                                              listOfProductsName: [],
                                              currentProductId: (widget
                                                          .currentProduct
                                                          ?.productId ??
                                                      0)
                                                  .toString(),
                                              currentProduct:
                                                  widget.currentProduct!,
                                              isPDA: false,
                                            ),
                                            TextFormField(
                                              showCursor: false,
                                              enabled: recepcionBloc
                                                      .locationIsOk && //true
                                                  !recepcionBloc
                                                      .productIsOk && //false
                                                  !recepcionBloc.quantityIsOk,

                                              controller:
                                                  _controllerProduct, // Controlador que maneja el texto
                                              focusNode: focusNode2,
                                              onChanged: (value) {
                                                // validateProduct(value);
                                              },
                                              decoration: InputDecoration(
                                                hintText: widget.currentProduct
                                                        ?.productName ??
                                                    ''.toString(),
                                                disabledBorder:
                                                    InputBorder.none,
                                                hintMaxLines: 2,
                                                hintStyle: const TextStyle(
                                                    fontSize: 12, color: black),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                            // Lote/Numero de serie
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/icons/barcode.png",
                                                    color: primaryColorApp,
                                                    width: 20,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    widget.currentProduct
                                                                    ?.productBarcode ==
                                                                false ||
                                                            widget.currentProduct
                                                                    ?.productBarcode ==
                                                                null ||
                                                            widget.currentProduct
                                                                    ?.productBarcode ==
                                                                ""
                                                        ? "Sin codigo de barras"
                                                        : widget.currentProduct
                                                                ?.productBarcode ??
                                                            "",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: widget.currentProduct?.productBarcode ==
                                                                    false ||
                                                                widget.currentProduct
                                                                        ?.productBarcode ==
                                                                    null ||
                                                                widget.currentProduct
                                                                        ?.productBarcode ==
                                                                    ""
                                                            ? red
                                                            : black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                // ExpiryDateWidget(
                                                //     expireDate: packinghBloc
                                                //                 .currentProduct
                                                //                 .expireDate ==
                                                //             ""
                                                //         ? DateTime.now()
                                                //         : DateTime.parse(
                                                //             packinghBloc
                                                //                 .currentProduct
                                                //                 .expireDate),
                                                //     size: size,
                                                //     isDetaild: false,
                                                //     isNoExpireDate: packinghBloc
                                                //                 .currentProduct
                                                //                 .expireDate ==
                                                //             ""
                                                //         ? true
                                                //         : false),
                                                // if (widget.currentProduct
                                                //         .loteId !=
                                                //     null)
                                                //   Row(
                                                //     children: [
                                                //       Align(
                                                //         alignment: Alignment
                                                //             .centerLeft,
                                                //         child: Text(
                                                //           'Lote/serie',
                                                //           style: TextStyle(
                                                //               fontSize: 14,
                                                //               color:
                                                //                   primaryColorApp),
                                                //         ),
                                                //       ),
                                                //       const SizedBox(width: 5),
                                                //       Align(
                                                //         alignment: Alignment
                                                //             .centerLeft,
                                                //         child: Text(
                                                //           packinghBloc
                                                //                   .currentProduct
                                                //                   .lotId ??
                                                //               '',
                                                //           style:
                                                //               const TextStyle(
                                                //                   fontSize: 13,
                                                //                   color: black),
                                                //         ),
                                                //       ),
                                                //       const Spacer(),
                                                //       GestureDetector(
                                                //         onTap: () {
                                                //           showDialog(
                                                //               context: context,
                                                //               builder:
                                                //                   (context) {
                                                //                 return DialogBarcodes(
                                                //                     listOfBarcodes:
                                                //                         packinghBloc
                                                //                             .listOfBarcodes);
                                                //               });
                                                //         },
                                                //         child: Visibility(
                                                //           visible: packinghBloc
                                                //               .listOfBarcodes
                                                //               .isNotEmpty,
                                                //           child: Image.asset(
                                                //               "assets/icons/package_barcode.png",
                                                //               color:
                                                //                   primaryColorApp,
                                                //               width: 20),
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Focus(
                                          focusNode: focusNode2,
                                          onKey: (FocusNode node,
                                              RawKeyEvent event) {
                                            if (event is RawKeyDownEvent) {
                                              if (event.logicalKey ==
                                                  LogicalKeyboardKey.enter) {
                                                // validateProduct(
                                                //     packinghBloc.scannedValue2);
                                                return KeyEventResult.handled;
                                              } else {
                                                // packinghBloc.add(
                                                //     UpdateScannedValuePackEvent(
                                                //         event.data.keyLabel,
                                                //         'product'));
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
                                                ProductDropdownOrderWidget(
                                                  selectedProduct:
                                                      selectedLocation,
                                                  listOfProductsName: [],
                                                  currentProductId: (widget
                                                              .currentProduct
                                                              ?.productId ??
                                                          0)
                                                      .toString(),
                                                  currentProduct:
                                                      widget.currentProduct!,
                                                  isPDA: true,
                                                ),
                                                const SizedBox(height: 10),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start, //alineamos el texto a la izquierda
                                                    children: [
                                                      Text(
                                                        widget.currentProduct
                                                                ?.productName ??
                                                            '',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: black),
                                                      ),
                                                      Visibility(
                                                        visible: widget
                                                                    .currentProduct
                                                                    ?.productBarcode ==
                                                                false ||
                                                            widget.currentProduct
                                                                    ?.productBarcode ==
                                                                null ||
                                                            widget.currentProduct
                                                                    ?.productBarcode ==
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
                                                //informacion del lote:
                                                // if (packinghBloc.currentProduct
                                                //         .loteId !=
                                                //     null)
                                                //   Column(
                                                //     children: [
                                                //       Align(
                                                //         alignment: Alignment
                                                //             .centerLeft,
                                                //         child: Text(
                                                //           'Lote/Numero de serie ',
                                                //           style: TextStyle(
                                                //               fontSize: 14,
                                                //               color:
                                                //                   primaryColorApp),
                                                //         ),
                                                //       ),
                                                //       Align(
                                                //         alignment: Alignment
                                                //             .centerLeft,
                                                //         child: Text(
                                                //           packinghBloc
                                                //                   .currentProduct
                                                //                   .lotId ??
                                                //               '',
                                                //           style:
                                                //               const TextStyle(
                                                //                   fontSize: 14,
                                                //                   color: black),
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // ExpiryDateWidget(
                                                //     expireDate: packinghBloc
                                                //                 .currentProduct
                                                //                 .expireDate ==
                                                //             ""
                                                //         ? DateTime.now()
                                                //         : DateTime.parse(
                                                //             packinghBloc
                                                //                     .currentProduct
                                                //                     .expireDate ??
                                                //                 '',
                                                //           ),
                                                //     size: size,
                                                //     isDetaild: false,
                                                //     isNoExpireDate: packinghBloc
                                                //                 .currentProduct
                                                //                 .expireDate ==
                                                //             ""
                                                //         ? true
                                                //         : false),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          //todo: ubicacion destino

                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: recepcionBloc.locationDestIsOk
                                        ? green
                                        : yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Card(
                                color: recepcionBloc.isLocationDestOk
                                    ? recepcionBloc.locationDestIsOk
                                        ? Colors.green[100]
                                        : Colors.grey[300]
                                    : Colors.red[200],
                                elevation: 5,
                                child: Container(
                                  width: size.width * 0.85,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: context
                                          .read<UserBloc>()
                                          .fabricante
                                          .contains("Zebra")
                                      ? Column(
                                          children: [
                                            MuelleOrderDropdownWidget(
                                              selectedMuelle: selectedMuelle,
                                              currentProduct:
                                                  widget.currentProduct!,
                                              isPda: false,
                                            ),
                                            Container(
                                              height: 15,
                                              margin: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: TextFormField(
                                                showCursor: false,
                                                enabled: recepcionBloc
                                                        .locationIsOk &&
                                                    recepcionBloc.productIsOk &&
                                                    !recepcionBloc
                                                        .quantityIsOk &&
                                                    !recepcionBloc
                                                        .locationDestIsOk,
                                                controller:
                                                    _controllerLocationDest, // Controlador que maneja el texto
                                                focusNode: focusNode5,
                                                onChanged: (value) {
                                                  // validateMuelle(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: widget
                                                          .currentProduct
                                                          ?.locationDestName ??
                                                      "",
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  hintStyle: const TextStyle(
                                                      fontSize: 14,
                                                      color: black),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Focus(
                                          focusNode: focusNode5,
                                          onKey: (FocusNode node,
                                              RawKeyEvent event) {
                                            if (event is RawKeyDownEvent) {
                                              if (event.logicalKey ==
                                                  LogicalKeyboardKey.enter) {
                                                // validateMuelle(context
                                                //     .read<BatchBloc>()
                                                //     .scannedValue4);
                                                return KeyEventResult.handled;
                                              } else {
                                                // context.read<BatchBloc>().add(
                                                //     UpdateScannedValueEvent(
                                                //         event.data.keyLabel,
                                                //         'muelle'));
                                                return KeyEventResult.handled;
                                              }
                                            }
                                            return KeyEventResult.ignored;
                                          },
                                          child: MuelleOrderDropdownWidget(
                                            selectedMuelle: selectedMuelle,
                                            currentProduct:
                                                widget.currentProduct!,
                                            isPda: true,
                                          )),
                                ),
                              ),
                            ],
                          ),
                        ]),
                      )),
                ),

                //todo: cantidad
                SizedBox(
                  width: size.width,
                  height: recepcionBloc.viewQuantity == true &&
                          context.read<UserBloc>().fabricante.contains("Zebra")
                      ? 345
                      : !recepcionBloc.viewQuantity
                          ? 110
                          : 150,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Card(
                          color: recepcionBloc.isQuantityOk
                              ? recepcionBloc.quantityIsOk
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
                                        widget.currentProduct?.quantityOrdered
                                                ?.toString() ??
                                            "",
                                        style: TextStyle(
                                          color: primaryColorApp,
                                          fontSize: 14,
                                        ),
                                      )),
                                  Text(widget.currentProduct?.uom ?? "",
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14)),
                                  const Spacer(),
                                  Expanded(
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        alignment: Alignment.center,
                                        child: context
                                                .read<UserBloc>()
                                                .fabricante
                                                .contains("Zebra")
                                            ? TextFormField(
                                                showCursor: false,
                                                textAlign: TextAlign.center,
                                                enabled: recepcionBloc
                                                        .locationIsOk && //true
                                                    recepcionBloc
                                                        .productIsOk && //true
                                                    recepcionBloc
                                                        .quantityIsOk && //true

                                                    !recepcionBloc
                                                        .locationDestIsOk,
                                                // showCursor: false,
                                                controller:
                                                    _controllerQuantity, // Controlador que maneja el texto
                                                focusNode: focusNode3,
                                                onChanged: (value) {
                                                  // validateQuantity(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: recepcionBloc
                                                      .quantitySelected
                                                      .toString(),
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  hintStyle: const TextStyle(
                                                      fontSize: 14,
                                                      color: black),
                                                  border: InputBorder.none,
                                                ),
                                              )
                                            : Focus(
                                                focusNode: focusNode3,
                                                onKey: (FocusNode node,
                                                    RawKeyEvent event) {
                                                  if (event
                                                      is RawKeyDownEvent) {
                                                    if (event.logicalKey ==
                                                        LogicalKeyboardKey
                                                            .enter) {
                                                      // validateQuantity(
                                                      //     packinghBloc
                                                      //         .scannedValue3);

                                                      return KeyEventResult
                                                          .handled;
                                                    } else {
                                                      // packinghBloc.add(
                                                      //     UpdateScannedValuePackEvent(
                                                      //         event.data
                                                      //             .keyLabel,
                                                      //         'quantity'));
                                                      return KeyEventResult
                                                          .handled;
                                                    }
                                                  }
                                                  return KeyEventResult.ignored;
                                                },
                                                child: Text(
                                                    recepcionBloc
                                                        .quantitySelected
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14)),
                                              )),
                                  ),
                                  IconButton(
                                      onPressed: recepcionBloc
                                                  .configurations
                                                  .result
                                                  ?.result
                                                  ?.manualQuantityPack ==
                                              false
                                          ? null
                                          : recepcionBloc.quantityIsOk &&
                                                  recepcionBloc
                                                          .quantitySelected >=
                                                      0
                                              ? () {
                                                  // packinghBloc.add(
                                                  //     ShowQuantityPackEvent(
                                                  //         !packinghBloc
                                                  //             .viewQuantity));
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 100),
                                                      () {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            focusNode4);
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
                        visible: recepcionBloc.viewQuantity,
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
                              showCursor: true,
                              onChanged: (value) {
                                // Verifica si el valor no está vacío y si es un número válido
                                if (value.isNotEmpty) {
                                  try {
                                    recepcionBloc.quantitySelected =
                                        int.parse(value);
                                  } catch (e) {
                                    // Manejo de errores si la conversión falla
                                    print('Error al convertir a entero: $e');
                                    // Aquí puedes mostrar un mensaje al usuario o manejar el error de otra forma
                                  }
                                } else {
                                  // Si el valor está vacío, puedes establecer un valor por defecto
                                  recepcionBloc.quantitySelected =
                                      0; // O cualquier valor que consideres adecuado
                                }
                              },
                              controller: _cantidadController,
                              keyboardType: TextInputType.number,
                              readOnly: context
                                      .read<UserBloc>()
                                      .fabricante
                                      .contains("Zebra")
                                  ? true
                                  : false,
                              decoration: InputDecorations.authInputDecoration(
                                hintText: 'Cantidad',
                                labelText: 'Cantidad',
                                suffixIconButton: IconButton(
                                  onPressed: () {
                                    // packinghBloc.add(ShowQuantityPackEvent(
                                    //     !packinghBloc.viewQuantity));
                                    _cantidadController.clear();
                                    //cambiamos el foco pa leer por pda la cantidad
                                    Future.delayed(
                                        const Duration(milliseconds: 100), () {
                                      FocusScope.of(context)
                                          .requestFocus(focusNode3);
                                    });
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: ElevatedButton(
                            onPressed: recepcionBloc.quantityIsOk &&
                                    recepcionBloc.quantitySelected >= 0
                                ? () {
                                    //cerramos el teclado
                                    FocusScope.of(context).unfocus();
                                    // _validatebuttonquantity();
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          )),
                      Visibility(
                        visible: recepcionBloc.viewQuantity &&
                            context
                                .read<UserBloc>()
                                .fabricante
                                .contains("Zebra"),
                        child: CustomKeyboardNumber(
                          controller: _cantidadController,
                          onchanged: () {
                            // _validatebuttonquantity();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppBar extends StatelessWidget {
  const AppBar({
    super.key,
    required this.size,
    required this.ordenCompra,
  });

  final Size size;
  final ResultEntrada? ordenCompra;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColorApp,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      width: double.infinity,
      child: BlocProvider(
        create: (context) => ConnectionStatusCubit(),
        child: BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
            builder: (context, status) {
          return Column(
            children: [
              const WarningWidgetCubit(),
              Padding(
                padding: EdgeInsets.only(
                    bottom: 10,
                    top: status != ConnectionStatus.online ? 0 : 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: white),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, 'recepcion',
                            arguments: [ordenCompra]);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.2),
                      child: Text(ordenCompra?.name ?? '',
                          style: TextStyle(color: white, fontSize: 18)),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
