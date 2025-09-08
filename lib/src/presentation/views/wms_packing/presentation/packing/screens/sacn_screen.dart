// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/utils/sounds_utils.dart';
import 'package:wms_app/src/core/utils/theme/input_decoration.dart';
import 'package:wms_app/src/core/utils/vibrate_utils.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';

import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/packing_pedido_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/widgets/location/location_card_packing_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/widgets/others/dialog_packing_advetencia_cantidad_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/widgets/others/dialog_temperature_manual_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/widgets/others/dialog_temperature_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/widgets/product/product_pack_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_barcodes_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/expiredate_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';

class ScanPackScreen extends StatefulWidget {
  const ScanPackScreen({
    super.key,
  });

  @override
  State<ScanPackScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<ScanPackScreen> {
  final VibrationService _vibrationService = VibrationService();
  final AudioService _audioService = AudioService();
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
    final batchBloc = context.read<PackingPedidoBloc>();
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
    final batchBloc = context.read<PackingPedidoBloc>();

    String scan = batchBloc.scannedValue1.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : batchBloc.scannedValue1.trim().toLowerCase();

    _controllerLocation.text = "";
    final currentProduct = batchBloc.currentProduct;
    if (scan == currentProduct.barcodeLocation.toString().toLowerCase()) {
      batchBloc.add(ValidateFieldsPackingEvent(field: "location", isOk: true));
      batchBloc.add(ChangeLocationIsOkEvent(currentProduct.idProduct ?? 0,
          currentProduct.pedidoId ?? 0, currentProduct.idMove ?? 0));
      batchBloc.add(ClearScannedValuePackEvent('location'));
    } else {
      _audioService.playErrorSound();
      _vibrationService.vibrate();
      batchBloc.add(ValidateFieldsPackingEvent(field: "location", isOk: false));
      batchBloc.add(ClearScannedValuePackEvent('location'));
    }
  }

  void validateProduct(String value) {
    final batchBloc = context.read<PackingPedidoBloc>();

    String scan = batchBloc.scannedValue2.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : batchBloc.scannedValue2.trim().toLowerCase();

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
        _audioService.playErrorSound();
        _vibrationService.vibrate();
        batchBloc
            .add(ValidateFieldsPackingEvent(field: "product", isOk: false));
        batchBloc.add(ClearScannedValuePackEvent('product'));
      }
    }
  }

  void validateQuantity(String value) {
    final batchBloc = context.read<PackingPedidoBloc>();

    String scan = batchBloc.scannedValue3.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : batchBloc.scannedValue3.trim().toLowerCase();

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

  bool validateScannedBarcode(
      String scannedBarcode,
      ProductoPedido currentProduct,
      PackingPedidoBloc batchBloc,
      bool isProduct) {
    // Buscar el barcode que coincida con el valor escaneado
    Barcodes? matchedBarcode = context
        .read<PackingPedidoBloc>()
        .listOfBarcodes
        .firstWhere(
            (barcode) =>
                barcode.barcode?.toLowerCase() == scannedBarcode.trim(),
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
        if ((matchedBarcode.cantidad + batchBloc.quantitySelected) >
            currentProduct.quantity!) {
          _audioService.playErrorSound();
          _vibrationService.vibrate();
          return false;
        }
        batchBloc.add(AddQuantitySeparate(
            matchedBarcode.cantidad,
            currentProduct.idMove ?? 0,
            currentProduct.idProduct ?? 0,
            currentProduct.pedidoId ?? 0));
      }
      _audioService.playErrorSound();
      _vibrationService.vibrate();
      return false;
    }
    _audioService.playErrorSound();
    _vibrationService.vibrate();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocBuilder<PackingPedidoBloc, PackingPedidoState>(
        builder: (context, state) {
          final packinghBloc = context.read<PackingPedidoBloc>();

          return Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  //*barra de informacion
                  BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                    builder: (context, status) {
                      return Container(
                        width: size.width,
                        color: primaryColorApp,
                        child:
                            BlocConsumer<PackingPedidoBloc, PackingPedidoState>(
                          listener: (context, state) {
                            print('❤️‍🔥 state: $state ');

                            if (state is ChangeQuantitySeparateState) {
                              if (state.quantity ==
                                  packinghBloc.currentProduct.quantity) {
                                _finichPackingProduct(context);
                              }
                            }

                            if (state is SetPickingPackingLoadingState) {
                              showDialog(
                                context: context,
                                builder: (context) => const DialogLoading(
                                  message: "Separando producto...",
                                ),
                              );
                            }

                            if (state is SetPickingPackingOkState) {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }

                              //validamos si el producto maneja temperatura
                              if (packinghBloc
                                          .currentProduct.manejaTemperatura ==
                                      1 ||
                                  packinghBloc
                                          .currentProduct.manejaTemperatura ==
                                      true) {
                                if (packinghBloc.configurations.result?.result
                                        ?.showPhotoTemperature ==
                                    true) {
                                  showDialog(
                                    barrierDismissible:
                                        false, // Evita que se cierre tocando fuera del diálogo
                                    context: context,
                                    builder: (context) => WillPopScope(
                                      onWillPop: () async =>
                                          false, // Evita que se cierre con la flecha de atrás
                                      child: DialogCapturaTemperaturaPack(
                                        moveLineId: packinghBloc
                                                .currentProduct.idMove ??
                                            0,
                                      ),
                                    ),
                                  );
                                  return;
                                } else {
                                  showDialog(
                                    barrierDismissible:
                                        false, // Evita que se cierre tocando fuera del diálogo
                                    context: context,
                                    builder: (context) => WillPopScope(
                                      onWillPop: () async =>
                                          false, // Evita que se cierre con la flecha de atrás
                                      child: DialogTemperaturaManualPack(
                                        moveLineId: packinghBloc
                                                .currentProduct.idMove ??
                                            0,
                                      ),
                                    ),
                                  );
                                  return;
                                }
                              }

                              Navigator.pushReplacementNamed(
                                context,
                                'detail-packing-pedido',
                                arguments: [1],
                              );
                            }

                            if (state is SendTemperatureSuccess) {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              Navigator.pushReplacementNamed(
                                context,
                                'detail-packing-pedido',
                                arguments: [1],
                              );
                            }

                            if (state is SendTemperatureFailure) {
                              Navigator.pop(context);

                              Get.defaultDialog(
                                title: '360 Software Informa',
                                titleStyle:
                                    TextStyle(color: Colors.red, fontSize: 18),
                                middleText: state.error,
                                middleTextStyle:
                                    TextStyle(color: black, fontSize: 14),
                                backgroundColor: Colors.white,
                                radius: 10,
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColorApp,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text('Aceptar',
                                        style: TextStyle(color: white)),
                                  ),
                                ],
                              );
                            }

                            if (state is SendImageNovedadSuccess) {
                              packinghBloc.add(ChangeQuantitySeparate(
                                  state.cantidad,
                                  packinghBloc.currentProduct.idProduct ?? 0,
                                  packinghBloc.currentProduct.pedidoId ?? 0,
                                  packinghBloc.currentProduct.idMove ?? 0));
                              cantidadController.clear();
                              _finichPackingProduct(context);
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

                                          context.read<PackingPedidoBloc>().add(
                                              LoadPedidoAndProductsEvent(
                                                  packinghBloc.currentProduct
                                                          .pedidoId ??
                                                      0));
                                          Navigator.pushReplacementNamed(
                                            context,
                                            'detail-packing-pedido',
                                            arguments: [1],
                                          );
                                        },
                                        icon: const Icon(Icons.arrow_back,
                                            color: Colors.white, size: 30),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: size.width * 0.2),
                                        child: Text(
                                          "CERTIFICACION",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
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
                                                LocationPackDropdownWidget(
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
                                              child: LocationPackDropdownWidget(
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
                                                ProductDropdownPackWidget(
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
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      "assets/icons/barcode.png",
                                                      color: primaryColorApp,
                                                      width: 20,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      (packinghBloc.currentProduct
                                                                      .barcode ==
                                                                  null ||
                                                              packinghBloc
                                                                  .currentProduct
                                                                  .barcode!
                                                                  .isEmpty ||
                                                              packinghBloc
                                                                      .currentProduct
                                                                      .barcode ==
                                                                  "false")
                                                          ? "Sin codigo de barras"
                                                          : packinghBloc
                                                              .currentProduct
                                                              .barcode!,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: (packinghBloc
                                                                          .currentProduct
                                                                          .barcode ==
                                                                      null ||
                                                                  packinghBloc
                                                                      .currentProduct
                                                                      .barcode!
                                                                      .isEmpty ||
                                                                  packinghBloc
                                                                          .currentProduct
                                                                          .barcode ==
                                                                      "false")
                                                              ? Colors.red
                                                              : black),
                                                    ),
                                                    const Spacer(),
                                                    GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return DialogBarcodes(
                                                                  listOfBarcodes:
                                                                      packinghBloc
                                                                          .listOfBarcodes);
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
                                                              'Lote/serie: ',
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
                                                              packinghBloc.currentProduct
                                                                          .lotId ==
                                                                      ""
                                                                  ? 'N/A'
                                                                  : packinghBloc
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
                                                    ProductDropdownPackWidget(
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
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                          "assets/icons/barcode.png",
                                                          color:
                                                              primaryColorApp,
                                                          width: 20,
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text(
                                                          (packinghBloc.currentProduct
                                                                          .barcode ==
                                                                      null ||
                                                                  packinghBloc
                                                                      .currentProduct
                                                                      .barcode!
                                                                      .isEmpty ||
                                                                  packinghBloc
                                                                          .currentProduct
                                                                          .barcode ==
                                                                      "false")
                                                              ? "Sin codigo de barras"
                                                              : packinghBloc
                                                                  .currentProduct
                                                                  .barcode!,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: (packinghBloc
                                                                              .currentProduct
                                                                              .barcode ==
                                                                          null ||
                                                                      packinghBloc
                                                                          .currentProduct
                                                                          .barcode!
                                                                          .isEmpty ||
                                                                      packinghBloc
                                                                              .currentProduct
                                                                              .barcode ==
                                                                          "false")
                                                                  ? Colors.red
                                                                  : black),
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
                                                                          packinghBloc
                                                                              .listOfBarcodes);
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
                                                    //informacion del lote:

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
                                                              'Lote/serie: ',
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
                                                              packinghBloc.currentProduct
                                                                          .lotId ==
                                                                      ""
                                                                  ? 'N/A'
                                                                  : packinghBloc
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
                                                  .toStringAsFixed(2) ??
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
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]')),
                                ],
                                showCursor: true,
                                onChanged: (value) {
                                  // Verifica si el valor no está vacío y si es un número válido
                                  if (value.isNotEmpty) {
                                    try {
                                      packinghBloc.quantitySelected =
                                          double.parse(value);
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

    final batchBloc = context.read<PackingPedidoBloc>();
    batchBloc.add(SetPickingsEvent(
        batchBloc.currentProduct.idProduct ?? 0,
        batchBloc.currentProduct.pedidoId ?? 0,
        batchBloc.currentProduct.idMove ?? 0));
  }

  void _finichPackingProductSplit(BuildContext context, double cantidad) async {
    //marcamos el producto como terminado
    print('Entramos a _finichPackingProductSplit -----');
    final batchBloc = context.read<PackingPedidoBloc>();

    batchBloc.add(SetPickingSplitEvent(
      batchBloc.currentProduct,
      batchBloc.currentProduct.idMove ?? 0,
      cantidad,
      batchBloc.currentProduct.idProduct ?? 0,
      batchBloc.currentProduct.pedidoId ?? 0,
    ));

    batchBloc.add(
        LoadPedidoAndProductsEvent(batchBloc.currentProduct.pedidoId ?? 0));
  }

  void _validatebuttonquantity() {
    final batchBloc = context.read<PackingPedidoBloc>();
    final currentProduct = batchBloc.currentProduct;

    String input = cantidadController.text.trim();

    // Si está vacío, usar la cantidad seleccionada del bloc
    if (input.isEmpty) {
      input = batchBloc.quantitySelected.toString();
    }

    // Reemplaza coma por punto para manejar formatos decimales europeos
    input = input.replaceAll(',', '.');

    // Expresión regular para validar un número válido
    final isValid = RegExp(r'^\d+([.,]?\d+)?$').hasMatch(input);

    // Validación de formato
    if (!isValid) {
      Get.snackbar(
        'Error',
        'Cantidad inválida',
        backgroundColor: white,
        colorText: primaryColorApp,
        duration: const Duration(milliseconds: 1000),
        icon: Icon(Icons.error, color: Colors.amber),
        snackPosition: SnackPosition.TOP,
      );

      return;
    }

    double cantidad = double.parse(cantidadController.text.isEmpty
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
      if (cantidad < (currentProduct.quantity ?? 0)) {
        showDialog(
            context: context,
            builder: (context) {
              return DialogPackAdvetenciaCantidadScreen(
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
