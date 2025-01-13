// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print, unrelated_type_equality_checks, unnecessary_null_comparison

import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/submeuelle_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/location/location_card_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/muelle/muelle_card_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/cant_lineas_muelle_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_picking_incompleted_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dropdowbutton_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/expiredate_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/popunButton_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/progressIndicatos_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/product/product_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class BatchScreen extends StatefulWidget {
  const BatchScreen({super.key});

  @override
  _BatchDetailScreenState createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchScreen> {
  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';
  String scannedValue6 = '';
  String alerta = "";
  String? focoLocation = 'ubicacion';
  String? selectedLocation;
  String? selectedMuelle;

  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfield
  FocusNode focusNode5 = FocusNode(); //cantidad muelle
  FocusNode focusNode6 = FocusNode(); //Submuelle

  bool viewQuantity = false;

  //controller
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _controllerMuelle = TextEditingController();
  final TextEditingController _controllerSubMuelle = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('🍔 shouldRunDependencies: ${context.read<BatchBloc>().shouldRunDependencies}');
    if (context.read<BatchBloc>().shouldRunDependencies) {
      final batchBloc = context.read<BatchBloc>();
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
  }

  @override
  void dispose() {
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
    focusNode6.dispose();
    super.dispose();
  }

  void validateLocation(String barcode) {
    setState(() {
      scannedValue1 = barcode.toLowerCase();
    });
    _controllerLocation.text = "";
    final batchBloc = context.read<BatchBloc>();
    final currentProduct = batchBloc.currentProduct;
    if (scannedValue1.toLowerCase() ==
        currentProduct.barcodeLocation.toString().toLowerCase()) {
      batchBloc.add(ValidateFieldsEvent(field: "location", isOk: true));
      batchBloc.add(ChangeLocationIsOkEvent(
          currentProduct.idProduct ?? 0,
          batchBloc.batchWithProducts.batch?.id ?? 0,
          currentProduct.idMove ?? 0));
      batchBloc.oldLocation = currentProduct.locationId.toString();
    } else {
      batchBloc.add(ValidateFieldsEvent(field: "location", isOk: false));
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
    final batchBloc = context.read<BatchBloc>();
    final currentProduct = batchBloc.currentProduct;
    if (scannedValue2.toLowerCase() == currentProduct.barcode?.toLowerCase()) {
      batchBloc.add(ValidateFieldsEvent(field: "product", isOk: true));
      batchBloc.add(ChangeQuantitySeparate(
          0, currentProduct.idProduct ?? 0, currentProduct.idMove ?? 0));
      batchBloc.add(ChangeProductIsOkEvent(
          true,
          currentProduct.idProduct ?? 0,
          batchBloc.batchWithProducts.batch?.id ?? 0,
          0,
          currentProduct.idMove ?? 0));
      batchBloc.add(ChangeIsOkQuantity(
          true,
          currentProduct.idProduct ?? 0,
          batchBloc.batchWithProducts.batch?.id ?? 0,
          currentProduct.idMove ?? 0));
    } else {
      final isok = validateScannedBarcode(scannedValue2.toLowerCase(),
          batchBloc.currentProduct, batchBloc, true);
      if (!isok) {
        batchBloc.add(ValidateFieldsEvent(field: "product", isOk: false));
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
    final batchBloc = context.read<BatchBloc>();
    final currentProduct = batchBloc.currentProduct;
    if (scannedValue3.toLowerCase() == currentProduct.barcode?.toLowerCase()) {
      batchBloc.add(ValidateFieldsEvent(field: "quantity", isOk: true));
      batchBloc.add(AddQuantitySeparate(
          currentProduct.idProduct ?? 0, currentProduct.idMove ?? 0, 1, false));
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
    if (batchBloc.index + 1 == batchBloc.filteredProducts.length) {
      batchBloc.add(FetchBatchWithProductsEvent(
          batchBloc.batchWithProducts.batch?.id ?? 0));
    }
  }

  void validateMuelle(String barcode) {
    setState(() {
      scannedValue4 = barcode.toLowerCase();
    });
    _controllerMuelle.text = "";
    final batchBloc = context.read<BatchBloc>();
    final currentProduct = batchBloc.currentProduct;
    if (scannedValue4.toLowerCase() ==
        currentProduct.barcodeLocationDest?.toLowerCase()) {
      validatePicking(batchBloc, context, currentProduct);
    } else {
      batchBloc.add(ValidateFieldsEvent(field: "locationDest", isOk: false));
      setState(() {
        scannedValue4 = ""; //limpiamos el valor escaneado
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1000),
        content: const Text('Ubicaion de destino erronea'),
        backgroundColor: Colors.red[200],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocBuilder<BatchBloc, BatchState>(builder: (context, state) {
        int totalTasks = context.read<BatchBloc>().filteredProducts.length;
        print("🍔 focoLocation: $focoLocation");

        double progress = totalTasks > 0
            ? context.read<BatchBloc>().filteredProducts.where((e) {
                  return e.isSeparate == 1;
                }).length /
                totalTasks
            : 0.0;

        final batchBloc = context.read<BatchBloc>();

        final currentProduct = batchBloc.currentProduct;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              //todo: barra info
              Container(
                width: size.width,
                color: primaryColorApp,
                child: BlocProvider(
                  create: (context) => ConnectionStatusCubit(),
                  child: BlocConsumer<BatchBloc, BatchState>(
                      listener: (context, state) {
                    // Validamos solo después de que el estado haya cambiado
                    if (state is ChangeQuantitySeparateState) {
                      if (state.quantity == currentProduct.quantity.toInt()) {
                        _nextProduct(currentProduct, batchBloc);
                      }
                    }
                    if (state is ChangeLocationIsOkState) {
                      setState(() {
                        focoLocation = 'producto';
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        FocusScope.of(context).requestFocus(focusNode2);
                      });
                    }

                    if (state is ChangeProductIsOkState) {
                      setState(() {
                        focoLocation = 'cantidad';
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        FocusScope.of(context).requestFocus(focusNode3);
                      });
                    }

                    if(state is SubMuelleEditSusses){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content:  Text(state.message),
                        backgroundColor: Colors.green[200],
                      ));
                    }

                    if(state is SubMuelleEditFail){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content:  Text(state.message),
                        backgroundColor: Colors.red[200],
                      ));
                    }


                  }, builder: (context, status) {
                    return Column(
                      children: [
                        const WarningWidgetCubit(),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  batchBloc.index = 0;
                                  batchBloc.quantitySelected = 0;
                                  cantidadController.clear();
                                  batchBloc.oldLocation = "";
                                  context
                                      .read<WMSPickingBloc>()
                                      .add(LoadBatchsFromDBEvent());
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white, size: 30),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  batchBloc.batchWithProducts.batch?.name ?? '',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                              const Spacer(),
                              PopupMenuButtonWidget(
                                  currentProduct: currentProduct),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: ProgressIndicatorWidget(
                            progress: progress,
                            completed: batchBloc.filteredProducts.where((e) {
                              return e.isSeparate == 1;
                            }).length,
                            total: totalTasks,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),
                ),
              ),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Text('Foco: $focoLocation',
                        //     style: const TextStyle(fontSize: 10, color: black)),
                        // Text('Ubicacion: $scannedValue1',
                        //     style: const TextStyle(fontSize: 10, color: black)),
                        // Text('producto: $scannedValue2',
                        //     style: const TextStyle(fontSize: 10, color: black)),

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
                                  color:
                                      batchBloc.locationIsOk ? green : yellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Card(
                              color: batchBloc.isLocationOk
                                  ? batchBloc.locationIsOk
                                      ? Colors.green[100]
                                      : Colors.grey[300]
                                  : Colors.red[200],
                              elevation: 5,
                              child: Container(
                                width: size.width * 0.85,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: batchBloc.isPdaZebra
                                    ? Column(
                                        children: [
                                          LocationDropdownWidget(
                                            isPDA: false,
                                            selectedLocation: selectedLocation,
                                            positionsOrigen:
                                                batchBloc.positionsOrigen,
                                            currentLocationId: batchBloc
                                                .currentProduct.locationId
                                                .toString(),
                                            batchBloc: batchBloc,
                                            currentProduct: currentProduct,
                                          ),
                                          Container(
                                            height: 15,
                                            margin: const EdgeInsets.only(
                                                bottom: 5),
                                            child: TextFormField(
                                              showCursor: false,
                                              controller:
                                                  _controllerLocation, // Asignamos el controlador
                                              enabled: !batchBloc
                                                      .locationIsOk && // false
                                                  !batchBloc
                                                      .productIsOk && // false
                                                  !batchBloc
                                                      .quantityIsOk && // false
                                                  !batchBloc.locationDestIsOk,

                                              focusNode: focusNode1,
                                              onChanged: (value) {
                                                // Llamamos a la validación al cambiar el texto
                                                validateLocation(value);
                                              },
                                              decoration: InputDecoration(
                                                hintText: batchBloc
                                                    .currentProduct.locationId
                                                    .toString(),
                                                disabledBorder:
                                                    InputBorder.none,
                                                hintStyle: const TextStyle(
                                                    fontSize: 14, color: black),
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
                                              if (scannedValue1.isNotEmpty) {
                                                validateLocation(scannedValue1);
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
                                        child: LocationDropdownWidget(
                                          isPDA: true,
                                          selectedLocation: selectedLocation,
                                          positionsOrigen:
                                              batchBloc.positionsOrigen,
                                          currentLocationId: batchBloc
                                              .currentProduct.locationId
                                              .toString(),
                                          batchBloc: batchBloc,
                                          currentProduct: currentProduct,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: batchBloc.productIsOk ? green : yellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Card(
                              color: batchBloc.isProductOk
                                  ? batchBloc.productIsOk
                                      ? Colors.green[100]
                                      : Colors.grey[300]
                                  : Colors.red[200],
                              elevation: 5,
                              child: Container(
                                width: size.width * 0.85,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: batchBloc.isPdaZebra
                                    ? Column(
                                        children: [
                                          ProductDropdownWidget(
                                            selectedProduct: selectedLocation,
                                            listOfProductsName:
                                                batchBloc.listOfProductsName,
                                            currentProductId: batchBloc
                                                .currentProduct.productId
                                                .toString(),
                                            batchBloc: batchBloc,
                                            currentProduct: currentProduct,
                                            isPDA: false,
                                          ),
                                          Container(
                                            height: 15,
                                            margin: const EdgeInsets.only(
                                                bottom: 5),
                                            child: TextFormField(
                                              showCursor: false,
                                              enabled: batchBloc
                                                      .locationIsOk && //true
                                                  !batchBloc
                                                      .productIsOk && //false
                                                  !batchBloc
                                                      .quantityIsOk && //false
                                                  !batchBloc.locationDestIsOk,

                                              controller:
                                                  _controllerProduct, // Controlador que maneja el texto
                                              focusNode: focusNode2,
                                              onChanged: (value) {
                                                validateProduct(value);
                                              },
                                              decoration: InputDecoration(
                                                hintText: batchBloc
                                                    .currentProduct.productId
                                                    .toString(),
                                                disabledBorder:
                                                    InputBorder.none,
                                                hintStyle: const TextStyle(
                                                    fontSize: 14, color: black),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                          // Lote/Numero de serie
                                          Column(
                                            children: [
                                              ExpiryDateWidget(
                                                  expireDate: currentProduct
                                                              .expireDate ==
                                                          ""
                                                      ? DateTime.now()
                                                      : DateTime.parse(
                                                          currentProduct
                                                              .expireDate),
                                                  size: size,
                                                  isDetaild: false,
                                                  isNoExpireDate: currentProduct
                                                              .expireDate ==
                                                          ""
                                                      ? true
                                                      : false),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Visibility(
                                                  visible: currentProduct
                                                              .barcode ==
                                                          false ||
                                                      currentProduct.barcode ==
                                                          null ||
                                                      currentProduct.barcode ==
                                                          "",
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10),
                                                    child: Text(
                                                      "Sin código de barras",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Lote/Numero de serie',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: primaryColorApp),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  currentProduct.lotId ?? '',
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
                                                LogicalKeyboardKey.enter) {
                                              if (scannedValue2.isNotEmpty) {
                                                validateProduct(scannedValue2);
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
                                              ProductDropdownWidget(
                                                selectedProduct:
                                                    selectedLocation,
                                                listOfProductsName: batchBloc
                                                    .listOfProductsName,
                                                currentProductId: batchBloc
                                                    .currentProduct.productId
                                                    .toString(),
                                                batchBloc: batchBloc,
                                                currentProduct: currentProduct,
                                                isPDA: false,
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
                                                      currentProduct.productId
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: black),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          currentProduct
                                                                      .barcode ==
                                                                  false ||
                                                              currentProduct
                                                                      .barcode ==
                                                                  null ||
                                                              currentProduct
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
                                              //informacion del lote:
                                              if (currentProduct.loteId != null)
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
                                                        currentProduct.lotId ??
                                                            '',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: black),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ExpiryDateWidget(
                                                  expireDate: currentProduct
                                                              .expireDate ==
                                                          ""
                                                      ? DateTime.now()
                                                      : DateTime.parse(
                                                          currentProduct
                                                              .expireDate),
                                                  size: size,
                                                  isDetaild: false,
                                                  isNoExpireDate: currentProduct
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

                        //Todo: MUELLE

                        if (batchBloc.batchWithProducts.batch?.indexList ==
                            (batchBloc.filteredProducts.length) - 1)
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: batchBloc.locationDestIsOk
                                        ? green
                                        : yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Card(
                                color: batchBloc.isLocationDestOk
                                    ? batchBloc.locationDestIsOk
                                        ? Colors.green[100]
                                        : Colors.grey[300]
                                    : Colors.red[200],
                                elevation: 5,
                                child: Container(
                                  width: size.width * 0.85,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: batchBloc.isPdaZebra
                                      ? Column(
                                          children: [
                                            MuelleDropdownWidget(
                                              selectedMuelle: selectedMuelle,
                                              batchBloc: batchBloc,
                                              currentProduct: currentProduct,
                                              isPda: false,
                                            ),
                                            Container(
                                              height: 15,
                                              margin: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: TextFormField(
                                                showCursor: false,
                                                enabled: batchBloc
                                                        .locationIsOk &&
                                                    batchBloc.productIsOk &&
                                                    !batchBloc.quantityIsOk &&
                                                    !batchBloc.locationDestIsOk,
                                                controller:
                                                    _controllerMuelle, // Controlador que maneja el texto
                                                focusNode: focusNode5,
                                                onChanged: (value) {
                                                  validateMuelle(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: batchBloc
                                                          .currentProduct
                                                          .locationDestId
                                                          .toString() ??
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
                                          focusNode: focusNode5,
                                          onKey: (FocusNode node,
                                              RawKeyEvent event) {
                                            if (event is RawKeyDownEvent) {
                                              if (event.logicalKey ==
                                                  LogicalKeyboardKey.enter) {
                                                if (scannedValue4.isNotEmpty) {
                                                  validateMuelle(scannedValue4);
                                                }
                                                return KeyEventResult.handled;
                                              } else {
                                                setState(() {
                                                  scannedValue4 +=
                                                      event.data.keyLabel;
                                                });
                                                return KeyEventResult.handled;
                                              }
                                            }
                                            return KeyEventResult.ignored;
                                          },
                                          child: MuelleDropdownWidget(
                                            selectedMuelle: selectedMuelle,
                                            batchBloc: batchBloc,
                                            currentProduct: currentProduct,
                                            isPda: true,
                                          )),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              //todo muelle multiple
              Visibility(
                visible:
                    batchBloc.configurations.result?.result?.muelleOption ==
                        "multiple",
                child: Container(
                    width: size.width,
                    height: 55,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Card(
                        color: Colors.grey[300],
                        elevation: 5,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: Row(children: [
                              CantLineasMuelle(
                                  productsOk:
                                      batchBloc.filteredProducts.where((e) {
                                return e.isMuelle == null && e.isSeparate == 1;
                              }).toList()),
                              const Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: ElevatedButton(
                                    onPressed: batchBloc.filteredProducts
                                            .where((e) {
                                              return e.isMuelle == null &&
                                                  e.isSeparate == 1;
                                            })
                                            .toList()
                                            .isEmpty
                                        ? null
                                        : () {
                                            showModalBottomSheet(
                                              context: context,
                                              isDismissible: false,
                                              enableDrag: false,
                                              builder: (context) {
                                                return BlocBuilder<BatchBloc,
                                                    BatchState>(
                                                  builder: (context, state) {
                                                    return Container(
                                                      height: 400,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                              height: 10),
                                                          Text(
                                                            'Seleccione la sub ubicación de destino para los productos',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    primaryColorApp),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Expanded(
                                                            child: ListView
                                                                .builder(
                                                              itemCount:
                                                                  batchBloc
                                                                      .submuelles
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                final muelle =
                                                                    batchBloc
                                                                            .submuelles[
                                                                        index];
                                                                bool
                                                                    isSelected =
                                                                    muelle ==
                                                                        batchBloc
                                                                            .subMuelleSelected;

                                                                return Card(
                                                                  color: isSelected
                                                                      ? Colors.green[
                                                                          300]
                                                                      : Colors
                                                                          .white, // Cambia el color de la card
                                                                  elevation: 3,
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                      muelle.completeName ??
                                                                          '',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: isSelected
                                                                            ? Colors.white
                                                                            : black,
                                                                      ),
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      muelle.barcode ==
                                                                              ""
                                                                          ? "Sin codigo de barras"
                                                                          : muelle.barcode ??
                                                                              "",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: isSelected
                                                                            ? Colors.white
                                                                            : red,
                                                                      ),
                                                                    ),
                                                                    onTap: () {
                                                                      context
                                                                          .read<
                                                                              BatchBloc>()
                                                                          .add(SelectedSubMuelleEvent(
                                                                              muelle));
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 15,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 5),
                                                            child:
                                                                TextFormField(
                                                              showCursor: false,
                                                              controller:
                                                                  _controllerSubMuelle, // Asignamos el controlador
                                                              enabled: true,
                                                              focusNode:
                                                                  focusNode6,
                                                              onChanged:
                                                                  (value) {},
                                                              decoration:
                                                                  const InputDecoration(
                                                                disabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                                hintStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            black),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                          Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                        batchBloc.subMuelleSelected =
                                                                            Muelles();
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        grey,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Text(
                                                                    'Cancelar',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            white),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 10),
                                                                ElevatedButton(
                                                                  onPressed: batchBloc
                                                                              .subMuelleSelected.completeName ==
                                                                          null
                                                                      ? null
                                                                      : () async {
                                                                        print(
                                                                            "Submuelle seleccionado: ${batchBloc.subMuelleSelected.completeName}");
                                                                          batchBloc.add(AssignSubmuelleEvent(
                                                                              batchBloc.filteredProducts.where((e) {
                                                                                return e.isMuelle == null && e.isSeparate == 1;
                                                                              }).toList(),
                                                                              batchBloc.subMuelleSelected,
                                                                              context));

                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        primaryColorApp,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Text(
                                                                    'Aceptar',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            white),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },

                                    //SCANEO LA UBICACION O SELECCION LA LISTA DE SUBPOCISIONES

                                    //EDITO LAS LINEAS ANTERIORES A CUAL MUELLE VA

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColorAppLigth,
                                      minimumSize: const Size(100, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      batchBloc.batchWithProducts.batch?.muelle
                                              .toString() ??
                                          '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    )),
                              ),
                            ])))),
              ),

              //todo: cantidad

              SizedBox(
                width: size.width,
                height: viewQuantity == true &&
                        context.read<UserBloc>().fabricante.contains("Zebra")
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
                        color: batchBloc.isQuantityOk
                            ? batchBloc.quantityIsOk
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
                                const Text('Cant:',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14)),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    currentProduct.quantity?.toString() ?? "",
                                    style: TextStyle(
                                        color: primaryColorApp, fontSize: 14),
                                  ),
                                ),
                                Visibility(
                                  visible: currentProduct.quantity -
                                          batchBloc.quantitySelected !=
                                      0,
                                  child: const Text('Pdte:',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14)),
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: currentProduct.quantity -
                                                batchBloc.quantitySelected ==
                                            0
                                        ? Container() // Ocultamos el widget si la diferencia es 0

                                        : Text(
                                            (batchBloc.quantitySelected <=
                                                    currentProduct.quantity
                                                ? (currentProduct.quantity -
                                                        batchBloc
                                                            .quantitySelected)
                                                    .toString()
                                                : '0'), // Aquí puedes definir qué mostrar si la condición no se cumple
                                            style: TextStyle(
                                              color: _getColorForDifference(
                                                batchBloc.quantitySelected <=
                                                        currentProduct.quantity
                                                    ? (currentProduct.quantity -
                                                        batchBloc
                                                            .quantitySelected)
                                                    : 0, // Si no cumple, el color será para diferencia 0
                                              ),
                                              fontSize: 14,
                                            ),
                                          )),

                                Text(currentProduct.unidades ?? "",
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14)),
                                // const Spacer(),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Container(
                                        alignment: Alignment.center,
                                        child: batchBloc.isPdaZebra
                                            ? TextFormField(
                                                showCursor: false,
                                                textAlign: TextAlign.center,
                                                enabled: batchBloc
                                                        .locationIsOk && //true
                                                    batchBloc
                                                        .productIsOk && //true
                                                    batchBloc
                                                        .quantityIsOk && //true

                                                    !batchBloc.locationDestIsOk,
                                                // showCursor: false,
                                                controller:
                                                    _controllerQuantity, // Controlador que maneja el texto
                                                focusNode: focusNode3,
                                                onChanged: (value) {
                                                  validateQuantity(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: batchBloc
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
                                                    batchBloc.quantitySelected
                                                        .toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    )),
                                              )),
                                  ),
                                ),
                                IconButton(
                                    onPressed: batchBloc.configurations.result
                                                ?.result?.manualQuantity ==
                                            false
                                        ? null
                                        : batchBloc.quantityIsOk &&
                                                batchBloc.quantitySelected >= 0
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
                                  batchBloc.quantitySelected = int.parse(value);
                                } catch (e) {
                                  // Manejo de errores si la conversión falla
                                  print('Error al convertir a entero: $e');
                                  // Aquí puedes mostrar un mensaje al usuario o manejar el error de otra forma
                                }
                              } else {
                                // Si el valor está vacío, puedes establecer un valor por defecto
                                batchBloc.quantitySelected =
                                    0; // O cualquier valor que consideres adecuado
                              }
                            },
                            controller: cantidadController,
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            decoration: InputDecorations.authInputDecoration(
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
                                      const Duration(milliseconds: 100), () {
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
                                      (currentProduct.quantity ?? 0).toInt()) {
                                    //todo: cantidad fuera del rango
                                    batchBloc.add(ValidateFieldsEvent(
                                        field: "quantity", isOk: false));
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
                                        currentProduct.quantity) {
                                      //*cantidad correcta
                                      //guardamos la cantidad en la bd
                                      batchBloc.add(ChangeQuantitySeparate(
                                          int.parse(value),
                                          currentProduct.idProduct ?? 0,
                                          currentProduct.idMove ?? 0));
                                    } else {
                                      //todo cantidad menor a la cantidad pedida
                                      //preguntar si estamos en la ultima posicion

                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return DialogAdvetenciaCantidadScreen(
                                                currentProduct: currentProduct,
                                                cantidad:
                                                    batchBloc.quantitySelected,
                                                batchId: batchBloc
                                                        .batchWithProducts
                                                        .batch
                                                        ?.id ??
                                                    0,
                                                onAccepted: () {
                                                  batchBloc.add(
                                                      ChangeQuantitySeparate(
                                                          int.parse(value),
                                                          currentProduct
                                                                  .idProduct ??
                                                              0,
                                                          currentProduct
                                                                  .idMove ??
                                                              0));
                                                  _nextProduct(currentProduct,
                                                      batchBloc);
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
                          onPressed: batchBloc.quantityIsOk &&
                                  batchBloc.quantitySelected >= 0
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
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        )),
                    //teclado de la app
                    Visibility(
                      visible: viewQuantity &&
                          context.read<UserBloc>().fabricante.contains("Zebra"),
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
          ),
        );
      }),
    );
  }

  // Función que devuelve el color basado en la diferencia
  Color _getColorForDifference(int difference) {
    if (difference == 0) {
      return Colors.transparent; // Ocultar el texto cuando la diferencia es 0
    } else if (difference > 10) {
      // Si la diferencia es mayor a 10
      return Colors.red; // Rojo para una gran diferencia
    } else if (difference > 5) {
      // Si la diferencia es mayor a 5 pero menor o igual a 10
      return Colors.orange; // Naranja para una diferencia moderada
    } else {
      // Si la diferencia es 5 o menos
      return Colors.green; // Verde cuando esté cerca de la cantidad pedida
    }
  }

  void _validatebuttonquantity() {
    final batchBloc = context.read<BatchBloc>();
    final currentProduct = batchBloc.currentProduct;

    int cantidad = int.parse(cantidadController.text.isEmpty
        ? batchBloc.quantitySelected.toString()
        : cantidadController.text);

    if (cantidad == currentProduct.quantity) {
      batchBloc.add(ChangeQuantitySeparate(
          cantidad, currentProduct.idProduct ?? 0, currentProduct.idMove ?? 0));
    } else {
      FocusScope.of(context).unfocus();
      if (cantidad < (currentProduct.quantity ?? 0).toInt()) {
        showDialog(
            context: context,
            builder: (context) {
              return DialogAdvetenciaCantidadScreen(
                  currentProduct: currentProduct,
                  cantidad: cantidad,
                  batchId: batchBloc.batchWithProducts.batch?.id ?? 0,
                  onAccepted: () async {
                    batchBloc.add(IsShouldRunDependencies(false));
                    batchBloc.add(ChangeQuantitySeparate(
                        cantidad,
                        currentProduct.idProduct ?? 0,
                        currentProduct.idMove ?? 0));
                    _nextProduct(currentProduct, batchBloc);
                    cantidadController.clear();
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

  void _nextProduct(ProductsBatch currentProduct, BatchBloc batchBloc) async {
    DataBaseSqlite db = DataBaseSqlite();
    print("currentProduct ${currentProduct.productId}");
    await db.setFieldTableBatchProducts(
        batchBloc.batchWithProducts.batch?.id ?? 0,
        currentProduct.idProduct ?? 0,
        'is_separate',
        'true',
        currentProduct.idMove ?? 0);

    await db.incrementProductSeparateQty(
        batchBloc.batchWithProducts.batch?.id ?? 0);

    viewQuantity = false;
    setState(() {});

    batchBloc.sortProductsByLocationId();

    if (batchBloc.index + 1 == batchBloc.filteredProducts.length) {
      //ultima posicion de la lista
      context.read<BatchBloc>().add(ChangeCurrentProduct(
          currentProduct: currentProduct, context: context));

      batchBloc.add(ChangeIsOkQuantity(
          false,
          currentProduct.idProduct ?? 0,
          batchBloc.batchWithProducts.batch?.id ?? 0,
          currentProduct.idMove ?? 0));
      await db.setFieldTableBatchProducts(
          batchBloc.batchWithProducts.batch?.id ?? 0,
          currentProduct.idProduct ?? 0,
          'is_quantity_is_ok',
          'false',
          currentProduct.idMove ?? 0);

      context.read<BatchBloc>().add(FetchBatchWithProductsEvent(
          context.read<BatchBloc>().batchWithProducts.batch?.id ?? 0));

      showDialog(
          context: context,
          builder: (context) {
            return const DialogLoading();
          });

      // Esperar 1 segundos y cerrar el diálogo y redirigirel focus
      Future.delayed(const Duration(seconds: 1), () {
        FocusScope.of(context).requestFocus(focusNode5);
        Navigator.pop(context);
      });

      return;
    } else {
      context.read<BatchBloc>().add(ChangeCurrentProduct(
          currentProduct: currentProduct, context: context));
      batchBloc.add(ValidateFieldsEvent(field: "quantity", isOk: true));
      batchBloc.quantitySelected = 0;
      cantidadController.clear();
      showDialog(
          context: context,
          builder: (context) {
            return const DialogLoading();
          });
      // Esperar 1 segundos y cerrar el diálogo y redirigirel focus
      Future.delayed(const Duration(seconds: 1), () {
        if (currentProduct.locationId != batchBloc.oldLocation) {
          FocusScope.of(context).requestFocus(focusNode1);
        } else {
          FocusScope.of(context).requestFocus(focusNode2);
        }
        Navigator.pop(context);
      });
      return;
    }

    //mostramos un modal de cargando que dure 2 segudnos
  }

  bool validateScannedBarcode(String scannedBarcode,
      ProductsBatch currentProduct, BatchBloc batchBloc, bool isProduct) {
    // Buscar el barcode que coincida con el valor escaneado
    Barcodes? matchedBarcode = context
        .read<BatchBloc>()
        .listOfBarcodes
        .firstWhere(
            (barcode) => barcode.barcode?.toLowerCase() == scannedBarcode,
            orElse: () =>
                Barcodes() // Si no se encuentra ningún match, devuelve null
            );
    print(context.read<BatchBloc>().listOfBarcodes);
    if (matchedBarcode.barcode != null) {
      print("Coincidencia encontrada: Cantidad = ${matchedBarcode.cantidad}");

      if (isProduct) {
        batchBloc.add(ValidateFieldsEvent(field: "product", isOk: true));

        batchBloc.add(ChangeQuantitySeparate(
            0, currentProduct.idProduct ?? 0, currentProduct.idMove ?? 0));

        batchBloc.add(ChangeProductIsOkEvent(
            true,
            currentProduct.idProduct ?? 0,
            batchBloc.batchWithProducts.batch?.id ?? 0,
            0,
            currentProduct.idMove ?? 0));

        batchBloc.add(ChangeIsOkQuantity(
            true,
            currentProduct.idProduct ?? 0,
            batchBloc.batchWithProducts.batch?.id ?? 0,
            currentProduct.idMove ?? 0));

        return true;
      } else {
        //valisamos si la suma de la cantidad del paquete es correcta con lo que se pide
        if (matchedBarcode.cantidad.toInt() + batchBloc.quantitySelected >
            currentProduct.quantity!) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 1000),
            content: const Text('Codigo erroneo'),
            backgroundColor: Colors.red[200],
          ));
          return false;
        }

        batchBloc.add(AddQuantitySeparate(
            currentProduct.idProduct ?? 0,
            currentProduct.idMove ?? 0,
            matchedBarcode.cantidad.toInt(),
            false));
      }
      return false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1000),
        content: const Text('Codigo erroneo'),
        backgroundColor: Colors.red[200],
      ));
    }
    return false;
  }

  bool validateScannedSubmuelle(
    String scannedSubmuelle,
    BatchBloc batchBloc,
  ) {
    // Buscar el barcode que coincida con el valor escaneado
    Muelles? matchedSubmuelle = context.read<BatchBloc>().submuelles.firstWhere(
        (submuelle) => submuelle.barcode?.toLowerCase() == scannedSubmuelle,
        orElse: () =>
            Muelles() // Si no se encuentra ningún match, devuelve null
        );
    if (matchedSubmuelle.completeName != null) {
      print(
          "Coincidencia encontrada: subMuelle = ${matchedSubmuelle.completeName}");

      batchBloc.add(AssignSubmuelleEvent(
          batchBloc.filteredProducts.where((e) {
            return e.isMuelle == null && e.isSeparate == 1;
          }).toList(),
          matchedSubmuelle,
          context));

      return true;
    } else {
      print("Coincidencia no encontrada");
      return false;
    }
  }

  void validatePicking(
      BatchBloc batchBloc, BuildContext context, ProductsBatch currentProduct) {
    batchBloc.add(FetchBatchWithProductsEvent(
        batchBloc.batchWithProducts.batch?.id ?? 0));

    //validamos que la cantidad de productos separados sea igual a la cantidad de productos pedidos
//validamos el 100 de las unidades separadas
    final double unidadesSeparadas =
        double.parse(batchBloc.calcularUnidadesSeparadas());
    if (unidadesSeparadas == "100.0" || unidadesSeparadas == 100.0) {
      batchBloc.add(ValidateFieldsEvent(field: "locationDest", isOk: true));
      batchBloc.add(ChangeLocationDestIsOkEvent(
          true,
          currentProduct.idProduct ?? 0,
          batchBloc.batchWithProducts.batch?.id ?? 0,
          currentProduct.idMove ?? 0));

      batchBloc.add(PickingOkEvent(batchBloc.batchWithProducts.batch?.id ?? 0,
          currentProduct.idProduct ?? 0));
      context.read<WMSPickingBloc>().add(LoadBatchsFromDBEvent());
      context.read<BatchBloc>().index = 0;
      context.read<BatchBloc>().isSearch = true;

      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return DialogPickingIncompleted(
                currentProduct: batchBloc.currentProduct,
                cantidad: unidadesSeparadas,
                batchBloc: batchBloc,
                onAccepted: () {
                  Navigator.pop(context);
                  if (batchBloc
                          .configurations.result?.result?.showDetallesPicking ==
                      true) {
                    //cerramos el focus
                    batchBloc.isSearch = false;
                    batchBloc.add(LoadProductEditEvent());
                    batchBloc.add(IsShouldRunDependencies(true));
                    Navigator.pushNamed(
                      context,
                      'batch-detail',
                    ).then((_) {
                      batchBloc.add(IsShouldRunDependencies(true));
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content:
                            const Text('No tienes permisos para ver detalles'),
                        backgroundColor: Colors.red[200],
                      ),
                    );
                  }
                });
          });
    }
  }
}
