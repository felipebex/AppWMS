// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_lotes_product_model.dart';

import 'package:wms_app/src/presentation/views/recepcion/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/widgets/dropdowbutton_widget.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/widgets/product/product_card_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_barcodes_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class ScanProductOrderScreen extends StatefulWidget {
  const ScanProductOrderScreen({
    super.key,
    required this.ordenCompra,
    required this.currentProduct,
  });

  final ResultEntrada? ordenCompra;
  final LineasTransferencia? currentProduct;

  @override
  State<ScanProductOrderScreen> createState() => _ScanProductOrderScreenState();
}

class _ScanProductOrderScreenState extends State<ScanProductOrderScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Añadimos el observer para escuchar el ciclo de vida de la app.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        // Aquí se ejecutan las acciones solo si la pantalla aún está montada
        showDialog(
          context: context,
          builder: (context) {
            return const DialogLoading(
              message: "Espere un momento...",
            );
          },
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    }
  }

//focus para escanear

  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfieldƒ

  String? selectedLocation;
  String? selectedMuelle;

  //controller
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleDependencies();
  }

  void _handleDependencies() {
    final batchBloc = context.read<RecepcionBloc>();

    if (!batchBloc.productIsOk && //false
        !batchBloc.quantityIsOk) //true
    {
      print('❤️‍🔥 product');
      FocusScope.of(context).requestFocus(focusNode2);
      focusNode3.unfocus();
      focusNode4.unfocus();
    }
    //validamso si el producto tiene lote

    if (batchBloc.productIsOk && //true
            batchBloc.quantityIsOk && //ttrue
            !batchBloc.viewQuantity //false
        ) //false
    {
      print('❤️‍🔥 quantity');
      FocusScope.of(context).requestFocus(focusNode3);
      focusNode2.unfocus();
      focusNode4.unfocus();
    }
  }

  @override
  void dispose() {
    focusNode2.dispose(); //product
    focusNode3.dispose(); //quantity
    super.dispose();
  }

  void validateProduct(String value) {
    final bloc = context.read<RecepcionBloc>();

    String scan = bloc.scannedValue2.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue2.trim().toLowerCase();

    _controllerProduct.text = "";
    final currentProduct = bloc.currentProduct;

    if (scan == currentProduct.productBarcode?.toLowerCase()) {
      bloc.add(ValidateFieldsOrderEvent(field: "product", isOk: true));

      bloc.add(ChangeQuantitySeparate(
        0,
        int.parse(currentProduct.productId),
        currentProduct.idRecepcion ?? 0,
        currentProduct.idMove ?? 0,
      ));
      bloc.add(ChangeProductIsOkEvent(
        currentProduct.idRecepcion ?? 0,
        true,
        int.parse(currentProduct.productId),
        0,
        currentProduct.idMove ?? 0,
      ));

      bloc.add(ChangeIsOkQuantity(
        currentProduct.idRecepcion ?? 0,
        true,
        int.parse(currentProduct.productId),
        currentProduct.idMove ?? 0,
      ));

      bloc.add(ClearScannedValueOrderEvent('product'));
    } else {
      final isok =
          validateScannedBarcode(scan.trim(), bloc.currentProduct, bloc, true);
      if (!isok) {
        bloc.add(ValidateFieldsOrderEvent(field: "product", isOk: false));
        bloc.add(ClearScannedValueOrderEvent('product'));
      }
    }
  }

  void validateQuantity(String value) {
    final bloc = context.read<RecepcionBloc>();

    String scan = bloc.scannedValue3.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue3.trim().toLowerCase();

    _controllerQuantity.text = "";
    final currentProduct = bloc.currentProduct;

    if (bloc.quantitySelected == currentProduct.cantidadFaltante.toInt()) {
      return;
    }
    if (scan == currentProduct.productBarcode?.toLowerCase()) {
      bloc.add(AddQuantitySeparate(
        currentProduct.idRecepcion,
        int.parse(currentProduct.productId),
        currentProduct.idMove ?? 0,
        1,
      ));
      bloc.add(ClearScannedValueOrderEvent('quantity'));
    } else {
      validateScannedBarcode(scan.trim(), currentProduct, bloc, false);
      bloc.add(ClearScannedValueOrderEvent('quantity'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocBuilder<RecepcionBloc, RecepcionState>(
        builder: (context, state) {
          final recepcionBloc = context.read<RecepcionBloc>();
          return Scaffold(
           
            backgroundColor: Colors.white,
            body: SizedBox(
              width: size.width * 1,
              height: size.height * 1,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 20),
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
                      child: BlocConsumer<RecepcionBloc, RecepcionState>(
                          listener: (context, state) {
                        print('STATE ❤️‍🔥 $state');

                        //*estado cuando el producto es leido ok
                        if (state is ChangeProductOrderIsOkState) {
                          //pasamos al foco de lote
                          Future.delayed(const Duration(seconds: 1), () {
                            FocusScope.of(context).requestFocus(focusNode2);
                          });
                          _handleDependencies();
                        }

                        if (state is ChangeQuantitySeparateState) {
                          if (state.quantity != 0) {
                            if (state.quantity ==
                                recepcionBloc.currentProduct.cantidadFaltante
                                    .toInt()) {
                              //termianmso el proceso
                              _finishSeprateProductOrder(
                                  context, state.quantity);
                            }
                          }
                        }
                      }, builder: (context, status) {
                        return Column(
                          children: [
                            const WarningWidgetCubit(),
                            Padding(
                              padding: EdgeInsets.only(
                                  // bottom: 5,
                                  top: status != ConnectionStatus.online
                                      ? 0
                                      : 35),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: white),
                                    onPressed: () {
                                      termiateProcess();

                                      Navigator.pushReplacementNamed(
                                          context, 'recepcion',
                                          arguments: [widget.ordenCompra, 1]);
                                    },
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: size.width * 0.2),
                                    child: Text(widget.ordenCompra?.name ?? '',
                                        style: TextStyle(
                                            color: white, fontSize: 18)),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.only(top: 2),
                        child: SingleChildScrollView(
                          child: Column(children: [
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
                                      color: green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.green[100],
                                  elevation: 5,
                                  child: Container(
                                      // color: Colors.amber,
                                      width: size.width * 0.85,
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 10,
                                          bottom: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Ubicación de origen',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              Spacer(),
                                              Image.asset(
                                                "assets/icons/ubicacion.png",
                                                color: primaryColorApp,
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Text(
                                                  recepcionBloc.currentProduct
                                                          .locationName ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            ),

                            //todo : producto
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
                                        horizontal: 10),
                                    child: context
                                            .read<UserBloc>()
                                            .fabricante
                                            .contains("Zebra")
                                        ? Column(
                                            children: [
                                              ProductDropdownOrderWidget(
                                                selectedProduct:
                                                    selectedLocation,
                                                listOfProductsName:
                                                    recepcionBloc
                                                        .listOfProductsName,
                                                currentProductId: (recepcionBloc
                                                            .currentProduct
                                                            .productId ??
                                                        0)
                                                    .toString(),
                                                currentProduct: recepcionBloc
                                                    .currentProduct,
                                                isPDA: false,
                                              ),
                                              TextFormField(
                                                showCursor: false,
                                                enabled: //true
                                                    !recepcionBloc
                                                            .productIsOk && //false
                                                        !recepcionBloc
                                                            .quantityIsOk,

                                                controller:
                                                    _controllerProduct, // Controlador que maneja el texto
                                                focusNode: focusNode2,
                                                onChanged: (value) {
                                                  validateProduct(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: recepcionBloc
                                                          .currentProduct
                                                          .productName ??
                                                      ''.toString(),
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  hintMaxLines: 2,
                                                  hintStyle: const TextStyle(
                                                      fontSize: 12,
                                                      color: black),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                              // CODIGO DE BARRAS DEL PRODUCTO
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
                                                      recepcionBloc.currentProduct
                                                                      .productBarcode ==
                                                                  false ||
                                                              recepcionBloc
                                                                      .currentProduct
                                                                      .productBarcode ==
                                                                  null ||
                                                              recepcionBloc
                                                                      .currentProduct
                                                                      .productBarcode ==
                                                                  ""
                                                          ? "Sin codigo de barras"
                                                          : recepcionBloc
                                                                  .currentProduct
                                                                  .productBarcode ??
                                                              "",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: recepcionBloc.currentProduct
                                                                          .productBarcode ==
                                                                      false ||
                                                                  recepcionBloc
                                                                          .currentProduct
                                                                          .productBarcode ==
                                                                      null ||
                                                                  recepcionBloc
                                                                          .currentProduct
                                                                          .productBarcode ==
                                                                      ""
                                                              ? red
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
                                                                      recepcionBloc
                                                                          .listOfBarcodes);
                                                            });
                                                      },
                                                      child: Visibility(
                                                        visible: recepcionBloc
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
                                                  validateProduct(recepcionBloc
                                                      .scannedValue2);
                                                  return KeyEventResult.handled;
                                                } else {
                                                  recepcionBloc.add(
                                                      UpdateScannedValueOrderEvent(
                                                          event.data.keyLabel,
                                                          'product'));
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
                                                    listOfProductsName:
                                                        recepcionBloc
                                                            .listOfProductsName,
                                                    currentProductId: (recepcionBloc
                                                                .currentProduct
                                                                .productId ??
                                                            0)
                                                        .toString(),
                                                    currentProduct:
                                                        recepcionBloc
                                                            .currentProduct,
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
                                                          recepcionBloc
                                                                  .currentProduct
                                                                  .productName ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  color: black),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
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
                                                                recepcionBloc
                                                                                .currentProduct.productBarcode ==
                                                                            false ||
                                                                        recepcionBloc.currentProduct.productBarcode ==
                                                                            null ||
                                                                        recepcionBloc.currentProduct.productBarcode ==
                                                                            ""
                                                                    ? "Sin codigo de barras"
                                                                    : recepcionBloc
                                                                            .currentProduct
                                                                            .productBarcode ??
                                                                        "",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: recepcionBloc.currentProduct.productBarcode == false ||
                                                                            recepcionBloc.currentProduct.productBarcode ==
                                                                                null ||
                                                                            recepcionBloc.currentProduct.productBarcode ==
                                                                                ""
                                                                        ? red
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
                                                                                recepcionBloc.listOfBarcodes);
                                                                      });
                                                                },
                                                                child:
                                                                    Visibility(
                                                                  visible: recepcionBloc
                                                                      .listOfBarcodes
                                                                      .isNotEmpty,
                                                                  child: Image.asset(
                                                                      "assets/icons/package_barcode.png",
                                                                      color:
                                                                          primaryColorApp,
                                                                      width:
                                                                          20),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),

                            //todo: lotes

                            Visibility(
                              visible: recepcionBloc
                                      .currentProduct.productTracking ==
                                  "lot",
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: recepcionBloc.loteIsOk
                                            ? green
                                            : yellow,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Card(
                                    color: recepcionBloc.isLoteOk
                                        ? recepcionBloc.loteIsOk
                                            ? Colors.green[100]
                                            : Colors.grey[300]
                                        : Colors.red[200],
                                    elevation: 5,
                                    child: Container(
                                        width: size.width * 0.85,
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10, bottom: 10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Lote del producto',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: primaryColorApp),
                                                ),
                                                Spacer(),
                                                Image.asset(
                                                  "assets/icons/barcode.png",
                                                  color: primaryColorApp,
                                                  width: 20,
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      Navigator
                                                          .pushReplacementNamed(
                                                        context,
                                                        'new-lote',
                                                        arguments: [
                                                          widget.ordenCompra,
                                                          widget.currentProduct
                                                        ],
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: primaryColorApp,
                                                      size: 20,
                                                    ))
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Lote: ',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: black),
                                                      ),
                                                      Text(
                                                        recepcionBloc
                                                                .lotesProductCurrent
                                                                .name ??
                                                            "",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                primaryColorApp),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Fechan caducidad: ',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: black),
                                                      ),
                                                      Text(
                                                        recepcionBloc
                                                                .lotesProductCurrent
                                                                .expirationDate ??
                                                            "",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: black),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),

                            //todo: ubicacion destino

                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.green[100],
                                  elevation: 5,
                                  child: Container(
                                      // color: Colors.amber,
                                      width: size.width * 0.85,
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 10,
                                          bottom: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Ubicación destino',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              Spacer(),
                                              Image.asset(
                                                "assets/icons/packing.png",
                                                color: primaryColorApp,
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Text(
                                                  recepcionBloc.currentProduct
                                                          .locationDestName ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
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
                            context
                                .read<UserBloc>()
                                .fabricante
                                .contains("Zebra")
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
                                    //*mostramos la cantidad a recoger si la configuracion lo permite
                                    Visibility(
                                      visible: recepcionBloc
                                              .configurations
                                              .result
                                              ?.result
                                              ?.hideExpectedQty ==
                                          false,
                                      child: Row(
                                        children: [
                                          const Text('Recoger:',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14)),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text(
                                                recepcionBloc.currentProduct
                                                        .cantidadFaltante
                                                        ?.toString() ??
                                                    "",
                                                style: TextStyle(
                                                  color: primaryColorApp,
                                                  fontSize: 14,
                                                ),
                                              )),
                                          Text(
                                              recepcionBloc
                                                      .currentProduct.uom ??
                                                  "",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),

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
                                                          .productIsOk && //true
                                                      recepcionBloc
                                                          .quantityIsOk //true

                                                  ,
                                                  // showCursor: false,
                                                  controller:
                                                      _controllerQuantity, // Controlador que maneja el texto
                                                  focusNode: focusNode3,
                                                  onChanged: (value) {
                                                    validateQuantity(value);
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
                                                        validateQuantity(
                                                            recepcionBloc
                                                                .scannedValue3);

                                                        return KeyEventResult
                                                            .handled;
                                                      } else {
                                                        recepcionBloc.add(
                                                            UpdateScannedValueOrderEvent(
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
                                                      recepcionBloc
                                                          .quantitySelected
                                                          .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14)),
                                                )),
                                    ),
                                    IconButton(
                                        onPressed: recepcionBloc.quantityIsOk &&
                                                    recepcionBloc
                                                            .quantitySelected >=
                                                        0
                                                ? () {
                                                    recepcionBloc.add(
                                                        ShowQuantityOrderEvent(
                                                            !recepcionBloc
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
                                decoration:
                                    InputDecorations.authInputDecoration(
                                  hintText: 'Cantidad',
                                  labelText: 'Cantidad',
                                  suffixIconButton: IconButton(
                                    onPressed: () {
                                      recepcionBloc.add(ShowQuantityOrderEvent(
                                          !recepcionBloc.viewQuantity));
                                      _cantidadController.clear();
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
                              onPressed: recepcionBloc.quantityIsOk &&
                                      recepcionBloc.quantitySelected >= 0
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
                          visible: recepcionBloc.viewQuantity &&
                              context
                                  .read<UserBloc>()
                                  .fabricante
                                  .contains("Zebra"),
                          child: CustomKeyboardNumber(
                            controller: _cantidadController,
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
            ),
          );
        },
      ),
    );
  }

  bool validateScannedBarcode(
      String scannedBarcode,
      LineasTransferencia currentProduct,
      RecepcionBloc batchBloc,
      bool isProduct) {
    // Buscar el barcode que coincida con el valor escaneado
    Barcodes? matchedBarcode = context
        .read<RecepcionBloc>()
        .listOfBarcodes
        .firstWhere(
            (barcode) => barcode.barcode?.toLowerCase() == scannedBarcode.trim(),
            orElse: () =>
                Barcodes() // Si no se encuentra ningún match, devuelve null
            );
    if (matchedBarcode.barcode != null) {
      if (isProduct) {
        batchBloc.add(ValidateFieldsOrderEvent(field: "product", isOk: true));

        batchBloc.add(ChangeQuantitySeparate(
          0,
          int.parse(currentProduct.productId),
          currentProduct.idRecepcion ?? 0,
          currentProduct.idMove ?? 0,
        ));

        batchBloc.add(ChangeProductIsOkEvent(
            currentProduct.idRecepcion ?? 0,
            true,
            int.parse(currentProduct.productId),
            0,
            currentProduct.idMove ?? 0));

        batchBloc.add(ChangeIsOkQuantity(
          currentProduct.idRecepcion ?? 0,
          true,
          int.parse(currentProduct.productId),
          currentProduct.idMove ?? 0,
        ));

        return true;
      } else {
        //valisamos si la suma de la cantidad del paquete es correcta con lo que se pide
        if (matchedBarcode.cantidad.toInt() + batchBloc.quantitySelected >
            currentProduct.cantidadFaltante!) {
          return false;
        }

        batchBloc.add(AddQuantitySeparate(
          currentProduct.idRecepcion,
          int.parse(currentProduct.productId),
          currentProduct.idMove ?? 0,
          matchedBarcode.cantidad.toInt(),
        ));
      }
      return false;
    }
    return false;
  }

  void _validatebuttonquantity() {
    final batchBloc = context.read<RecepcionBloc>();
    final currentProduct = batchBloc.currentProduct;

    //validamos que tengamos un lote seleccionado

    if (currentProduct.productTracking == 'lot') {
      if (context.read<RecepcionBloc>().lotesProductCurrent.id == null) {
        Get.snackbar(
          'Error',
          "Seleccione un lote",
          backgroundColor: white,
          colorText: primaryColorApp,
          icon: Icon(Icons.error, color: Colors.amber),
        );
        return;
      }
    }

    int cantidad = int.parse(_cantidadController.text.isEmpty
        ? batchBloc.quantitySelected.toString()
        : _cantidadController.text);

    if (cantidad == currentProduct.cantidadFaltante) {
      batchBloc.add(ChangeQuantitySeparate(
          cantidad,
          int.parse(currentProduct.productId),
          currentProduct.idRecepcion ?? 0,
          currentProduct.idMove ?? 0));
    } else {
      FocusScope.of(context).unfocus();
      if (cantidad < (currentProduct.cantidadFaltante ?? 0).toInt()) {
        showDialog(
            context: context,
            builder: (context) {
              return DialogOrderAdvetenciaCantidadScreen(
                  currentProduct: currentProduct,
                  cantidad: cantidad,
                 
                 
                  onAccepted: () async {
                    batchBloc.add(ChangeQuantitySeparate(
                        cantidad,
                        int.parse(currentProduct.productId),
                        currentProduct.idRecepcion ?? 0,
                        currentProduct.idMove ?? 0));
                    _cantidadController.clear();
                    _finishSeprateProductOrder(context, cantidad);

                    Navigator.pushReplacementNamed(context, 'recepcion',
                        arguments: [widget.ordenCompra, 1]);
                  },


                  onSplit: () {
                    batchBloc.add(ChangeQuantitySeparate(
                        cantidad,
                        int.parse(currentProduct.productId),
                        currentProduct.idRecepcion ?? 0,
                        currentProduct.idMove ?? 0));
                    _cantidadController.clear();
                    Navigator.pushReplacementNamed(context, 'recepcion',
                        arguments: [widget.ordenCompra, 1]);

                    _finishSeprateProductOrderSplit(context, cantidad);
                  });
            });
      } else if (cantidad > (currentProduct.cantidadFaltante ?? 0).toInt()) {
        batchBloc.add(ChangeQuantitySeparate(
            cantidad,
            int.parse(currentProduct.productId),
            currentProduct.idRecepcion ?? 0,
            currentProduct.idMove ?? 0));

        _finishSeprateProductOrder(context, cantidad);
      }
    }
  }

  void _finishSeprateProductOrder(BuildContext context, int cantidad) {
    if (context.read<RecepcionBloc>().currentProduct.productTracking == "lot") {
        print(context.read<RecepcionBloc>().lotesProductCurrent.toMap());
      if (context.read<RecepcionBloc>().selectLote == "") {
        Get.snackbar(
          'Error',
          "Seleccione un lote",
          backgroundColor: white,
          colorText: primaryColorApp,
          icon: Icon(Icons.error, color: Colors.amber),
        );
        return;
      }
    }

    context.read<RecepcionBloc>().add(FinalizarRecepcionProducto());
    context.read<RecepcionBloc>().add(SendProductToOrder(false, cantidad));
    termiateProcess();

    Navigator.pushReplacementNamed(context, 'recepcion',
        arguments: [widget.ordenCompra, 1]);
  }

  void _finishSeprateProductOrderSplit(
    BuildContext context,
    int cantidad,
  ) {
    if (context.read<RecepcionBloc>().currentProduct.productTracking == "lot") {
      if (context.read<RecepcionBloc>().currentProduct.loteId == "") {
        Get.snackbar(
          'Error',
          "Seleccione un lote",
          backgroundColor: white,
          colorText: primaryColorApp,
          icon: Icon(Icons.error, color: Colors.amber),
        );
        return;
      }
    }
    context
        .read<RecepcionBloc>()
        .add(FinalizarRecepcionProductoSplit(cantidad));
    context.read<RecepcionBloc>().add(SendProductToOrder(true, cantidad));
    termiateProcess();
  }

  void termiateProcess() {
    FocusScope.of(context).unfocus();
    context.read<RecepcionBloc>().selectLote = "";
    context.read<RecepcionBloc>().loteIsOk = false;

    context
        .read<RecepcionBloc>()
        .add(GetPorductsToEntrada(widget.ordenCompra?.id ?? 0));
  }
}
