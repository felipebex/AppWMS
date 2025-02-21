// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/widgets/dropdowbutton_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/widgets/location/location_card_packing_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/widgets/product/product_packing_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_barcodes_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/expiredate_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';

import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class PackingScreen extends StatefulWidget {
  const PackingScreen({
    super.key,
    this.packingModel,
    this.batchModel,
  });

  final PedidoPacking? packingModel;
  final BatchPackingModel? batchModel;

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfield

  String? selectedLocation;

  //controller
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleDependencies();
  }

  void _handleDependencies() {
    final batchBloc = context.read<WmsPackingBloc>();
    if (!batchBloc.locationIsOk && //false
        !batchBloc.productIsOk && //false
        !batchBloc.quantityIsOk && //false
        !batchBloc.locationDestIsOk) //false
    {
      print('❤️‍🔥 location');
      FocusScope.of(context).requestFocus(focusNode1);
      focusNode2.unfocus();
      focusNode3.unfocus();
      focusNode4.unfocus();
    }
    if (batchBloc.locationIsOk && //true
        !batchBloc.productIsOk && //false
        !batchBloc.quantityIsOk && //false
        !batchBloc.locationDestIsOk) //false
    {
      print('❤️‍🔥 product');
      FocusScope.of(context).requestFocus(focusNode2);
      focusNode1.unfocus();
      focusNode3.unfocus();
      focusNode4.unfocus();
    }
    if (batchBloc.locationIsOk && //true
        batchBloc.productIsOk && //true
        batchBloc.quantityIsOk && //ttrue
        !batchBloc.locationDestIsOk && //false
        !batchBloc.viewQuantity) //false
    {
      print('❤️‍🔥 quantity');
      FocusScope.of(context).requestFocus(focusNode3);
      focusNode1.unfocus();
      focusNode2.unfocus();
      focusNode4.unfocus();
    }
  }

  @override
  void dispose() {
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    super.dispose();
  }

  void validateLocation(String value) {
    final batchBloc = context.read<WmsPackingBloc>();

    String scan = batchBloc.scannedValue1.toLowerCase() == ""
        ? value.toLowerCase()
        : batchBloc.scannedValue1.toLowerCase();

    _controllerLocation.text = "";
    final currentProduct = batchBloc.currentProduct;
    if (scan == currentProduct.barcodeLocation.toString().toLowerCase()) {
      batchBloc.add(ValidateFieldsPackingEvent(field: "location", isOk: true));
      batchBloc.add(ChangeLocationIsOkEvent(currentProduct.idProduct ?? 0,
          currentProduct.pedidoId ?? 0, currentProduct.idMove ?? 0));
      batchBloc.add(ClearScannedValuePackEvent('location'));
    } else {
      batchBloc.add(ValidateFieldsPackingEvent(field: "location", isOk: false));

      batchBloc.add(ClearScannedValuePackEvent('location'));
    }
  }

  void validateProduct(String value) {
    final batchBloc = context.read<WmsPackingBloc>();

    String scan = batchBloc.scannedValue2.toLowerCase() == ""
        ? value.toLowerCase()
        : batchBloc.scannedValue2.toLowerCase();

    _controllerProduct.text = "";
    final currentProduct = batchBloc.currentProduct;

    if (scan == currentProduct.barcode?.toLowerCase()) {
      batchBloc.add(ValidateFieldsPackingEvent(field: "product", isOk: true));

      batchBloc.add(ChangeQuantitySeparate(0, currentProduct.idProduct ?? 0,
          currentProduct.pedidoId ?? 0, currentProduct.idMove ?? 0));
      batchBloc.add(ChangeProductIsOkEvent(true, currentProduct.idProduct ?? 0,
          currentProduct.pedidoId ?? 0, 0, currentProduct.idMove ?? 0));
      batchBloc.add(ChangeIsOkQuantity(true, currentProduct.idProduct ?? 0,
          currentProduct.pedidoId ?? 0, currentProduct.idMove ?? 0));
      batchBloc.add(ClearScannedValuePackEvent('product'));
    } else {
      final isok = validateScannedBarcode(
          scan, batchBloc.currentProduct, batchBloc, true);
      if (!isok) {
        batchBloc
            .add(ValidateFieldsPackingEvent(field: "product", isOk: false));
        batchBloc.add(ClearScannedValuePackEvent('product'));
      }
    }
  }

  void validateQuantity(String value) {
    final batchBloc = context.read<WmsPackingBloc>();

    String scan = batchBloc.scannedValue3.toLowerCase() == ""
        ? value.toLowerCase()
        : batchBloc.scannedValue3.toLowerCase();

    _controllerQuantity.text = "";
    final currentProduct = batchBloc.currentProduct;
    if (scan == currentProduct.barcode?.toLowerCase()) {
      batchBloc.add(AddQuantitySeparate(1, currentProduct.idMove ?? 0,
          currentProduct.idProduct ?? 0, currentProduct.pedidoId ?? 0));
      batchBloc.add(ClearScannedValuePackEvent('quantity'));
    } else {
      validateScannedBarcode(scan, batchBloc.currentProduct, batchBloc, false);
      batchBloc.add(ClearScannedValuePackEvent('quantity'));
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
        if ((matchedBarcode.cantidad.toInt() + batchBloc.quantitySelected) >
            currentProduct.quantity!) {
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
                          print('❤️‍🔥 state: $state ');

                          if (state is ChangeQuantitySeparateState) {
                            if (state.quantity ==
                                packinghBloc.currentProduct.quantity.toInt()) {
                              _finichPackingProduct(context);
                              Navigator.pushReplacementNamed(
                                context,
                                'packing-detail',
                                arguments: [
                                  widget.packingModel,
                                  widget.batchModel
                                ],
                              );
                            }
                          }

                          if (state is SetPickingPackingOkState) {
                            //Mensaje de confirmacion
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: const Duration(milliseconds: 1000),
                              content: const Text(
                                  'Producto certificado, revisa en preparados'),
                              backgroundColor: Colors.green[200],
                            ));
                            Navigator.pushReplacementNamed(
                              context,
                              'packing-detail',
                              arguments: [
                                widget.packingModel,
                                widget.batchModel
                              ],
                            );
                          }

                          if (state is ChangeLocationPackingIsOkState) {
                            Future.delayed(const Duration(seconds: 1), () {
                              FocusScope.of(context).requestFocus(focusNode2);
                            });
                            _handleDependencies();
                          }

                          if (state is ChangeProductPackingIsOkState) {
                            Future.delayed(const Duration(seconds: 1), () {
                              FocusScope.of(context).requestFocus(focusNode3);
                            });
                            _handleDependencies();
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
                                        Navigator.pushReplacementNamed(
                                          context,
                                          'packing-detail',
                                          arguments: [
                                            widget.packingModel,
                                            widget.batchModel
                                          ],
                                        );
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
                                          horizontal: 10, vertical: 2),
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
                                                      validateLocation(
                                                          _controllerLocation
                                                              .text);
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
                                                    validateLocation(
                                                        packinghBloc
                                                            .scannedValue1);
                                                    return KeyEventResult
                                                        .handled;
                                                  } else {
                                                    packinghBloc.add(
                                                        UpdateScannedValuePackEvent(
                                                            event.data.keyLabel,
                                                            'location'));
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
                                          horizontal: 10, vertical: 2),
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
                                                TextFormField(
                                                  showCursor: false,
                                                  enabled: packinghBloc
                                                          .locationIsOk && //true
                                                      !packinghBloc
                                                          .productIsOk && //false
                                                      !packinghBloc
                                                          .quantityIsOk,

                                                  controller:
                                                      _controllerProduct, // Controlador que maneja el texto
                                                  focusNode: focusNode2,
                                                  onChanged: (value) {
                                                    validateProduct(value);
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText: packinghBloc
                                                        .currentProduct
                                                        .productId
                                                        .toString(),
                                                    disabledBorder:
                                                        InputBorder.none,
                                                    hintMaxLines: 2,
                                                    hintStyle: const TextStyle(
                                                        fontSize: 12,
                                                        color: black),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                                // Lote/Numero de serie
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        "assets/icons/barcode.png",
                                                        color: primaryColorApp,
                                                        width: 20,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        packinghBloc
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
                                                                    ""
                                                            ? "Sin codigo de barras"
                                                            : packinghBloc
                                                                .currentProduct
                                                                .barcode,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: packinghBloc.currentProduct
                                                                            .barcode ==
                                                                        false ||
                                                                    packinghBloc
                                                                            .currentProduct
                                                                            .barcode ==
                                                                        null ||
                                                                    packinghBloc
                                                                            .currentProduct
                                                                            .barcode ==
                                                                        ""
                                                                ? red
                                                                : black),
                                                      ),
                                                    ],
                                                  ),
                                                ),
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
                                                    if (packinghBloc
                                                            .currentProduct
                                                            .loteId !=
                                                        null)
                                                      Row(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Lote/serie',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color:
                                                                      primaryColorApp),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
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
                                                                          13,
                                                                      color:
                                                                          black),
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return DialogBarcodes(
                                                                        listOfBarcodes:
                                                                            packinghBloc.listOfBarcodes);
                                                                  });
                                                            },
                                                            child: Visibility(
                                                              visible: packinghBloc
                                                                  .listOfBarcodes
                                                                  .isNotEmpty,
                                                              child: Image.asset(
                                                                  "assets/icons/package_barcode.png",
                                                                  color:
                                                                      primaryColorApp,
                                                                  width: 20),
                                                            ),
                                                          ),
                                                        ],
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
                                                    validateProduct(packinghBloc
                                                        .scannedValue2);
                                                    return KeyEventResult
                                                        .handled;
                                                  } else {
                                                    packinghBloc.add(
                                                        UpdateScannedValuePackEvent(
                                                            event.data.keyLabel,
                                                            'product'));
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
                    height: packinghBloc.viewQuantity == true &&
                            context
                                .read<UserBloc>()
                                .fabricante
                                .contains("Zebra")
                        ? 345
                        : !packinghBloc.viewQuantity
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
                                            fontSize: 14,
                                          ),
                                        )),
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
                                                        validateQuantity(
                                                            packinghBloc
                                                                .scannedValue3);

                                                        return KeyEventResult
                                                            .handled;
                                                      } else {
                                                        packinghBloc.add(
                                                            UpdateScannedValuePackEvent(
                                                                event.data
                                                                    .keyLabel,
                                                                'quantity'));
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
                                        onPressed: packinghBloc
                                                    .configurations
                                                    .result
                                                    ?.result
                                                    ?.manualQuantityPack ==
                                                false
                                            ? null
                                            : packinghBloc.quantityIsOk &&
                                                    packinghBloc
                                                            .quantitySelected >=
                                                        0
                                                ? () {
                                                    packinghBloc.add(
                                                        ShowQuantityPackEvent(
                                                            !packinghBloc
                                                                .viewQuantity));
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
                          visible: packinghBloc.viewQuantity,
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
                                readOnly: context
                                        .read<UserBloc>()
                                        .fabricante
                                        .contains("Zebra")
                                    ? true
                                    : false,
                                decoration:
                                    InputDecorations.authInputDecoration(
                                  hintText: 'Cantidad',
                                  labelText: 'Cantidad',
                                  suffixIconButton: IconButton(
                                    onPressed: () {
                                      packinghBloc.add(ShowQuantityPackEvent(
                                          !packinghBloc.viewQuantity));
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
                          visible: packinghBloc.viewQuantity &&
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

  void _finichPackingProduct(BuildContext context) async {
    
    
    //cerramos el foco
    FocusScope.of(context).unfocus();
    //marcamos el producto como terminado

    final batchBloc = context.read<WmsPackingBloc>();
    batchBloc.add(SetPickingsEvent(
        batchBloc.currentProduct.idProduct ?? 0,
        batchBloc.currentProduct.pedidoId ?? 0,
        batchBloc.currentProduct.idMove ?? 0));
  }

  void _finichPackingProductSplit(BuildContext context, int cantidad) async {
    //marcamos el producto como terminado
    print('Entramos a _finichPackingProductSplit -----');
    final batchBloc = context.read<WmsPackingBloc>();

    batchBloc.add(SetPickingSplitEvent(
      batchBloc.currentProduct,
      batchBloc.currentProduct.idMove ?? 0,
      cantidad,
      batchBloc.currentProduct.idProduct ?? 0,
      batchBloc.currentProduct.pedidoId ?? 0,
    ));

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
                  },
                  onSplit: () {
                    batchBloc.add(ChangeQuantitySeparate(
                        cantidad,
                        currentProduct.idProduct ?? 0,
                        currentProduct.pedidoId ?? 0,
                        currentProduct.idMove ?? 0));
                    cantidadController.clear();
                    _finichPackingProductSplit(context, cantidad);
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
