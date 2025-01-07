// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/dialog_loading_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/dropdowbutton_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/location/location_card_packing_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/product/product_packing_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/expiredate_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';

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

  String alerta = "";
  String? focoLocation = 'ubicacion';

  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfield
  FocusNode focusNode5 = FocusNode(); //cantidad muelle

  bool viewQuantity = false;
  String? selectedLocation;

  //controller
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  // final TextEditingController _controllerMuelle = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final batchBloc = context.read<WmsPackingBloc>();
    if (!batchBloc.locationIsOk && //false
        !batchBloc.productIsOk && //false
        !batchBloc.quantityIsOk && //false
        !batchBloc.locationDestIsOk) //false
    {
      setState(() {
        focoLocation = 'ubicacion';
      });
      FocusScope.of(context).requestFocus(focusNode1);
    }
    if (batchBloc.locationIsOk && //true
        !batchBloc.productIsOk && //false
        !batchBloc.quantityIsOk && //false
        !batchBloc.locationDestIsOk) //false
    {
      setState(() {
        focoLocation = 'producto';
      });
      FocusScope.of(context).requestFocus(focusNode2);
    }
    if (batchBloc.locationIsOk && //true
        batchBloc.productIsOk && //true
        batchBloc.quantityIsOk && //ttrue
        !batchBloc.locationDestIsOk && //false
        !viewQuantity) //false
    {
      setState(() {
        focoLocation = 'cantidad';
      });
      FocusScope.of(context).requestFocus(focusNode3);
    }
    if (batchBloc.locationIsOk &&
        batchBloc.productIsOk &&
        !batchBloc.quantityIsOk &&
        !batchBloc.locationDestIsOk) {
      setState(() {
        focoLocation = 'muelle';
      });
      FocusScope.of(context).requestFocus(focusNode5);
    }
  }

  @override
  void dispose() {
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
    super.dispose();
  }

  void validateLocation(String barcode) {
    setState(() {
      scannedValue1 = barcode.toLowerCase();
    });
    _controllerLocation.text = "";
    final batchBloc = context.read<WmsPackingBloc>();
    final currentProduct = batchBloc.currentProduct;
    if (scannedValue1.toLowerCase() ==
        currentProduct.barcodeLocation.toString().toLowerCase()) {
      batchBloc.add(ValidateFieldsPackingEvent(field: "location", isOk: true));
      batchBloc.add(ChangeLocationIsOkEvent(currentProduct.idProduct ?? 0,
          currentProduct.pedidoId ?? 0, currentProduct.idMove ?? 0));
    } else {
      batchBloc.add(ValidateFieldsPackingEvent(field: "location", isOk: false));
      setState(() {
        scannedValue1 = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1000),
        content: const Text('Ubicación errónea'),
        backgroundColor: Colors.red[200],
      ));
    }
  }

  void validateProduct(String barcode) {
    setState(() {
      scannedValue2 = barcode.toLowerCase();
    });

    _controllerProduct.text = "";
    final batchBloc = context.read<WmsPackingBloc>();
    final currentProduct = batchBloc.currentProduct;
    if (scannedValue2.toLowerCase() == currentProduct.barcode?.toLowerCase()) {
      batchBloc.add(ValidateFieldsPackingEvent(field: "product", isOk: true));

      batchBloc.add(ChangeQuantitySeparate(0, currentProduct.idProduct ?? 0,
          currentProduct.pedidoId ?? 0, currentProduct.idMove ?? 0));
      batchBloc.add(ChangeProductIsOkEvent(true, currentProduct.idProduct ?? 0,
          currentProduct.pedidoId ?? 0, 0, currentProduct.idMove ?? 0));
      batchBloc.add(ChangeIsOkQuantity(true, currentProduct.idProduct ?? 0,
          currentProduct.pedidoId ?? 0, currentProduct.idMove ?? 0));
    } else {
      final isok = validateScannedBarcode(scannedValue2.toLowerCase(),
          batchBloc.currentProduct, batchBloc, true);
      if (!isok) {
        batchBloc
            .add(ValidateFieldsPackingEvent(field: "product", isOk: false));
        setState(() {
          scannedValue2 = ""; //limpiamos el valor escaneado
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 1000),
          content: const Text('Producto erroneo'),
          backgroundColor: Colors.red[200],
        ));
      }
    }
  }

  void validateQuantity(String barcode) {
    setState(() {
      scannedValue3 = barcode.toLowerCase();
    });

    _controllerQuantity.text = "";
    final batchBloc = context.read<WmsPackingBloc>();
    final currentProduct = batchBloc.currentProduct;
    if (scannedValue3.toLowerCase() == currentProduct.barcode?.toLowerCase()) {
      batchBloc.add(ValidateFieldsPackingEvent(field: "quantity", isOk: true));
      batchBloc.add(AddQuantitySeparate(1, currentProduct.idMove ?? 0,
          currentProduct.idProduct ?? 0, currentProduct.pedidoId ?? 0));
      setState(() {
        scannedValue3 = ""; //limpiamos el valor escaneado
      });
    } else {
      validateScannedBarcode(scannedValue3.toLowerCase(),
          batchBloc.currentProduct, batchBloc, false);
      setState(() {
        scannedValue3 = ""; //limpiamos el valor escaneado
      });
    }
  }

  bool validateScannedBarcode(String scannedBarcode,
      PorductoPedido currentProduct, WmsPackingBloc batchBloc, bool isProduct) {
    // Buscar el barcode que coincida con el valor escaneado
    Barcodes? matchedBarcode = context
        .read<WmsPackingBloc>()
        .listOfBarcodes
        .firstWhere(
            (barcode) => barcode.barcode?.toLowerCase() == scannedBarcode,
            orElse: () =>
                Barcodes() // Si no se encuentra ningún match, devuelve null
            );
    if (matchedBarcode.barcode != null) {
      if (isProduct) {
        batchBloc.add(ValidateFieldsPackingEvent(field: "product", isOk: true));

        batchBloc.add(ChangeQuantitySeparate(0, currentProduct.idProduct ?? 0,
            currentProduct.pedidoId ?? 0, currentProduct.idMove ?? 0));

        batchBloc.add(ChangeProductIsOkEvent(
            true,
            currentProduct.idProduct ?? 0,
            currentProduct.pedidoId ?? 0,
            0,
            currentProduct.idMove ?? 0));

        batchBloc.add(ChangeIsOkQuantity(true, currentProduct.idProduct ?? 0,
            currentProduct.pedidoId ?? 0, currentProduct.idMove ?? 0));

        return true;
      } else {
        //valisamos si la suma de la cantidad del paquete es correcta con lo que se pide
        if (matchedBarcode.cantidad.toInt() + batchBloc.quantitySelected >
            currentProduct.quantity!) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 1000),
            content: Text(
                'Error, el codigo es para una cantidad de : ${matchedBarcode.cantidad} '),
            backgroundColor: Colors.red[200],
          ));
          return false;
        }
        batchBloc.add(AddQuantitySeparate(
            matchedBarcode.cantidad.toInt(),
            currentProduct.idMove ?? 0,
            currentProduct.idProduct ?? 0,
            currentProduct.pedidoId ?? 0));
      }
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 1000),
      content: const Text('Codigo de cantidad incorrecto'),
      backgroundColor: Colors.red[200],
    ));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocBuilder<WmsPackingBloc, WmsPackingState>(
        builder: (context, state) {
          log("focoLocation: $focoLocation");
          final packinghBloc = context.read<WmsPackingBloc>();

          return Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  //*barra de informacion
                  Container(
                    width: size.width,
                    color: primaryColorApp,
                    child: BlocProvider(
                      create: (context) => ConnectionStatusCubit(),
                      child: BlocConsumer<WmsPackingBloc, WmsPackingState>(
                        listener: (context, state) {
                          if (state is ChangeQuantitySeparateState) {
                            if (state.quantity ==
                                packinghBloc.currentProduct.quantity.toInt()) {
                              _finichPackingProduct(context);
                            }
                          }

                          if (state is ChangeLocationPackingIsOkState) {
                            setState(() {
                              focoLocation = 'producto';
                            });
                            Future.delayed(const Duration(seconds: 1), () {
                              FocusScope.of(context).requestFocus(focusNode2);
                            });
                          }

                          if (state is ChangeProductPackingIsOkState) {
                            setState(() {
                              focoLocation = 'cantidad';
                            });
                            Future.delayed(const Duration(seconds: 1), () {
                              FocusScope.of(context).requestFocus(focusNode3);
                            });
                          }
                        },
                        builder: (context, state) {
                          return Column(
                            children: [
                              const WarningWidgetCubit(),
                              Padding(
                                padding: const EdgeInsets.only(top: 25),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        packinghBloc.quantitySelected = 0;
                                        cantidadController.clear();
                                        packinghBloc.oldLocation = "";

                                        context.read<WmsPackingBloc>().add(
                                            LoadAllProductsFromPedidoEvent(
                                                packinghBloc.currentProduct
                                                        .pedidoId ??
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
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
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
                                      child: context
                                              .read<UserBloc>()
                                              .fabricante
                                              .contains("Zebra")
                                          ? Column(
                                              children: [
                                                LocationPackingDropdownWidget(
                                                  isPDA: false,
                                                  selectedLocation:
                                                      selectedLocation,
                                                  positionsOrigen: packinghBloc
                                                      .currentProduct
                                                      .locationId,
                                                  currentLocationId:
                                                      packinghBloc
                                                          .currentProduct
                                                          .locationId
                                                          .toString(),
                                                  batchBloc: packinghBloc,
                                                  currentProduct: packinghBloc
                                                      .currentProduct,
                                                ),
                                                Container(
                                                  height: 15,
                                                  margin: const EdgeInsets.only(
                                                      bottom: 5),
                                                  child: TextFormField(
                                                    showCursor: false,
                                                    controller:
                                                        _controllerLocation, // Asignamos el controlador
                                                    enabled: !packinghBloc
                                                            .locationIsOk && // false
                                                        !packinghBloc
                                                            .productIsOk && // false
                                                        !packinghBloc
                                                            .quantityIsOk && // false
                                                        !packinghBloc
                                                            .locationDestIsOk,

                                                    focusNode: focusNode1,
                                                    onChanged: (value) {
                                                      // Llamamos a la validación al cambiar el texto
                                                      validateLocation(value);
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText: packinghBloc
                                                          .currentProduct
                                                          .locationId
                                                          .toString(),
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      hintStyle:
                                                          const TextStyle(
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
                                                      LogicalKeyboardKey
                                                          .enter) {
                                                    if (scannedValue1
                                                        .isNotEmpty) {
                                                      validateLocation(
                                                          scannedValue1);
                                                    }

                                                    return KeyEventResult
                                                        .handled;
                                                  } else {
                                                    setState(() {
                                                      scannedValue1 +=
                                                          event.data.keyLabel;
                                                    });
                                                    return KeyEventResult
                                                        .handled;
                                                  }
                                                }
                                                return KeyEventResult.ignored;
                                              },
                                              child:
                                                  LocationPackingDropdownWidget(
                                                isPDA: true,
                                                selectedLocation:
                                                    selectedLocation,
                                                positionsOrigen: packinghBloc
                                                        .currentProduct
                                                        .locationId ??
                                                    "",
                                                currentLocationId: packinghBloc
                                                    .currentProduct.locationId
                                                    .toString(),
                                                batchBloc: packinghBloc,
                                                currentProduct:
                                                    packinghBloc.currentProduct,
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
                                      child: context
                                              .read<UserBloc>()
                                              .fabricante
                                              .contains("Zebra")
                                          ? Column(
                                              children: [
                                                ProductDropdownPackingWidget(
                                                  selectedProduct:
                                                      selectedLocation,
                                                  listOfProductsName:
                                                      packinghBloc
                                                          .listOfProductsName,
                                                  currentProductId: packinghBloc
                                                      .currentProduct.idProduct
                                                      .toString(),
                                                  batchBloc: packinghBloc,
                                                  currentProduct: packinghBloc
                                                      .currentProduct,
                                                  isPDA: false,
                                                ),
                                                Container(
                                                  height: 15,
                                                  margin: const EdgeInsets.only(
                                                      bottom: 5),
                                                  child: TextFormField(
                                                    showCursor: false,
                                                    enabled: packinghBloc
                                                            .locationIsOk && //true
                                                        !packinghBloc
                                                            .productIsOk && //false
                                                        !packinghBloc
                                                            .quantityIsOk && //false
                                                        !packinghBloc
                                                            .locationDestIsOk,

                                                    controller:
                                                        _controllerProduct, // Controlador que maneja el texto
                                                    focusNode: focusNode2,
                                                    onChanged: (value) {
                                                      validateProduct(value);
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText: packinghBloc
                                                          .currentProduct
                                                          .idProduct
                                                          .toString(),
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      hintStyle:
                                                          const TextStyle(
                                                              fontSize: 14,
                                                              color: black),
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                                // Lote/Numero de serie
                                                Column(
                                                  children: [
                                                    ExpiryDateWidget(
                                                        expireDate: packinghBloc
                                                                    .currentProduct
                                                                    .expireDate ==
                                                                ""
                                                            ? DateTime.now()
                                                            : DateTime.parse(
                                                                packinghBloc
                                                                    .currentProduct
                                                                    .expireDate),
                                                        size: size,
                                                        isDetaild: false,
                                                        isNoExpireDate: packinghBloc
                                                                    .currentProduct
                                                                    .expireDate ==
                                                                ""
                                                            ? true
                                                            : false),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Visibility(
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
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10),
                                                          child: Text(
                                                            "Sin código de barras",
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'Lote/Numero de serie',
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
                                            )
                                          : Focus(
                                              focusNode: focusNode2,
                                              onKey: (FocusNode node,
                                                  RawKeyEvent event) {
                                                if (event is RawKeyDownEvent) {
                                                  if (event.logicalKey ==
                                                      LogicalKeyboardKey
                                                          .enter) {
                                                    if (scannedValue2
                                                        .isNotEmpty) {
                                                      validateProduct(
                                                          scannedValue2);
                                                    }
                                                    return KeyEventResult
                                                        .handled;
                                                  } else {
                                                    setState(() {
                                                      scannedValue2 +=
                                                          event.data.keyLabel;
                                                    });
                                                    return KeyEventResult
                                                        .handled;
                                                  }
                                                }
                                                return KeyEventResult.ignored;
                                              },
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ProductDropdownPackingWidget(
                                                      selectedProduct:
                                                          selectedLocation,
                                                      listOfProductsName:
                                                          packinghBloc
                                                              .listOfProductsName,
                                                      currentProductId:
                                                          packinghBloc
                                                              .currentProduct
                                                              .idProduct
                                                              .toString(),
                                                      batchBloc: packinghBloc,
                                                      currentProduct:
                                                          packinghBloc
                                                              .currentProduct,
                                                      isPDA: false,
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
                                                            packinghBloc
                                                                .currentProduct
                                                                .productId
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        black),
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
                                                                  TextAlign
                                                                      .start,
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
                                                    if (packinghBloc
                                                            .currentProduct
                                                            .loteId !=
                                                        null)
                                                      Column(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Lote/Numero de serie ',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color:
                                                                      primaryColorApp),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .lotId ??
                                                                  '',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color:
                                                                          black),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ExpiryDateWidget(
                                                        expireDate: packinghBloc
                                                                    .currentProduct
                                                                    .expireDate ==
                                                                ""
                                                            ? DateTime.now()
                                                            : DateTime.parse(
                                                                packinghBloc
                                                                        .currentProduct
                                                                        .expireDate ??
                                                                    '',
                                                              ),
                                                        size: size,
                                                        isDetaild: false,
                                                        isNoExpireDate: packinghBloc
                                                                    .currentProduct
                                                                    .expireDate ==
                                                                ""
                                                            ? true
                                                            : false),
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
                    height: viewQuantity == true &&
                            context
                                .read<UserBloc>()
                                .fabricante
                                .contains("Zebra")
                        ? 345
                        : !viewQuantity
                            ? 110
                            : 150,
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
                                          child: context
                                                  .read<UserBloc>()
                                                  .fabricante
                                                  .contains("Zebra")
                                              ? TextFormField(
                                                  showCursor: false,
                                                  textAlign: TextAlign.center,
                                                  enabled: packinghBloc
                                                          .locationIsOk && //true
                                                      packinghBloc
                                                          .productIsOk && //true
                                                      packinghBloc
                                                          .quantityIsOk && //true

                                                      !packinghBloc
                                                          .locationDestIsOk,
                                                  // showCursor: false,
                                                  controller:
                                                      _controllerQuantity, // Controlador que maneja el texto
                                                  focusNode: focusNode3,
                                                  onChanged: (value) {
                                                    validateQuantity(value);
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText: packinghBloc
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
                                                        if (scannedValue3
                                                            .isNotEmpty) {
                                                          validateQuantity(
                                                              scannedValue3);
                                                        }

                                                        return KeyEventResult
                                                            .handled;
                                                      } else {
                                                        setState(() {
                                                          scannedValue3 += event
                                                              .data.keyLabel;
                                                        });
                                                        return KeyEventResult
                                                            .handled;
                                                      }
                                                    }
                                                    return KeyEventResult
                                                        .ignored;
                                                  },
                                                  child: Text(
                                                      packinghBloc
                                                          .quantitySelected
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
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 100), () {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusNode4);
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

                                          //guardamos la cantidad en la bd
                                          packinghBloc
                                              .add(ChangeQuantitySeparate(
                                            int.parse(value),
                                            packinghBloc
                                                    .currentProduct.idProduct ??
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
                                                    .currentProduct.idProduct ??
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
                                                                .idProduct ??
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
                                                                .idProduct ??
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
                                      //cerramos el teclado
                                      FocusScope.of(context).unfocus();
                                      _validatebuttonquantity();
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
                        Visibility(
                          visible: viewQuantity &&
                              context
                                  .read<UserBloc>()
                                  .fabricante
                                  .contains("Zebra"),
                          child: CustomKeyboardNumber(
                            controller: cantidadController,
                            onchanged: () {
                              _validatebuttonquantity();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }

  void _finichPackingProduct(BuildContext context) {
    //marcamos el producto como terminado
    final batchBloc = context.read<WmsPackingBloc>();
    batchBloc.add(SetPickingsEvent(
        batchBloc.currentProduct.idProduct ?? 0,
        batchBloc.currentProduct.pedidoId ?? 0,
        batchBloc.currentProduct.idMove ?? 0));

    //cerramos el dialogo de carga
    batchBloc.add(
        LoadAllProductsFromPedidoEvent(batchBloc.currentProduct.pedidoId ?? 0));
    Navigator.pop(context);
  }

  void _validatebuttonquantity() {
    final batchBloc = context.read<WmsPackingBloc>();
    final currentProduct = batchBloc.currentProduct;

    int cantidad = int.parse(cantidadController.text.isEmpty
        ? batchBloc.quantitySelected.toString()
        : cantidadController.text);

    if (cantidad == currentProduct.quantity) {
      batchBloc.add(ChangeQuantitySeparate(
          cantidad,
          currentProduct.idProduct ?? 0,
          currentProduct.pedidoId ?? 0,
          currentProduct.idMove ?? 0));
    } else {
      FocusScope.of(context).unfocus();
      if (cantidad < (currentProduct.quantity ?? 0).toInt()) {
        showDialog(
            context: context,
            builder: (context) {
              return DialogPackingAdvetenciaCantidadScreen(
                  currentProduct: currentProduct,
                  cantidad: cantidad,
                  onAccepted: () async {
                    batchBloc.add(ChangeQuantitySeparate(
                        cantidad,
                        currentProduct.idProduct ?? 0,
                        currentProduct.pedidoId ?? 0,
                        currentProduct.idMove ?? 0));
                    cantidadController.clear();
                    _finichPackingProduct(context);
                  });
            });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 1000),
          content: const Text('Cantidad erronea'),
          backgroundColor: Colors.red[200],
        ));
      }
    }
  }
}
