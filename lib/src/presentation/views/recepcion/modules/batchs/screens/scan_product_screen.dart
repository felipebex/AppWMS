// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_batch_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_lotes_product_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/batchs/bloc/recepcion_batch_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/batchs/widgets/dropdowbutton_widget.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/batchs/widgets/product/product_card_widget.dart';

import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_barcodes_widget.dart';

import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';

import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class ScanProductRceptionBatchScreen extends StatefulWidget {
  const ScanProductRceptionBatchScreen({
    super.key,
    required this.ordenCompra,
    required this.currentProduct,
  });

  final ReceptionBatch? ordenCompra;
  final LineasRecepcionBatch? currentProduct;

  @override
  State<ScanProductRceptionBatchScreen> createState() =>
      _ScanProductOrderScreenState();
}

class _ScanProductOrderScreenState extends State<ScanProductRceptionBatchScreen>
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
        _handleDependencies();
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
  FocusNode focusNode5 = FocusNode(); //ubicacion destino
  FocusNode focusNode6 = FocusNode(); //lote

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

  void _unfocusAll({required FocusNode except}) {
    for (final node in [
      focusNode2,
      focusNode3,
      focusNode4,
      focusNode5,
      focusNode6
    ]) {
      if (node != except) node.unfocus();
    }
  }

  void _requestOnly(FocusNode node, String tag) {
    print("🎯 Enfocando: $tag");
    FocusScope.of(context).requestFocus(node);
    _unfocusAll(except: node);
  }

  void _handleDependencies() {
    print('🚼 _handleDependencies');
    final bloc = context.read<RecepcionBatchBloc>();

    final hasLote = bloc.currentProduct.productTracking == "lot";
    final configMuelle =
        bloc.configurations.result?.result?.scanDestinationLocationReception ??
            false;

    if (!bloc.productIsOk && !bloc.quantityIsOk) {
      _requestOnly(focusNode2, 'product');
      return;
    }

    if (hasLote) {
      print('--- CON LOTE ---');
      print('productIsOk: ${bloc.productIsOk}');
      print('quantityIsOk: ${bloc.quantityIsOk}');
      print('loteIsOk: ${bloc.loteIsOk}');
      print('viewQuantity: ${bloc.viewQuantity}');
      print('locationsDestIsok: ${bloc.locationsDestIsok}');

      if (bloc.productIsOk &&
          !bloc.loteIsOk &&
          !bloc.quantityIsOk &&
          !bloc.viewQuantity) {
        _requestOnly(focusNode6, 'lote');
        return;
      }

      if (configMuelle) {
        if (bloc.productIsOk && !bloc.quantityIsOk && !bloc.locationsDestIsok) {
          _requestOnly(focusNode5, 'muelle');
          return;
        }
        if (bloc.productIsOk &&
            bloc.quantityIsOk &&
            bloc.locationsDestIsok &&
            !bloc.viewQuantity) {
          _requestOnly(focusNode3, 'quantity');
          return;
        }
      } else {
        if (bloc.productIsOk && bloc.quantityIsOk && !bloc.viewQuantity) {
          _requestOnly(focusNode3, 'quantity');
          return;
        }
      }
    } else {
      // SIN LOTE
      print('--- SIN LOTE ---');
      if (configMuelle) {
        if (bloc.productIsOk && !bloc.quantityIsOk && !bloc.locationsDestIsok) {
          _requestOnly(focusNode5, 'muelle');
          return;
        }
        if (bloc.productIsOk &&
            bloc.quantityIsOk &&
            bloc.locationsDestIsok &&
            !bloc.viewQuantity) {
          _requestOnly(focusNode3, 'quantity');
          return;
        }
      } else {
        if (bloc.productIsOk && bloc.quantityIsOk && !bloc.viewQuantity) {
          _requestOnly(focusNode3, 'quantity');
          return;
        }
      }
    }
  }

  @override
  void dispose() {
    focusNode2.dispose(); //product
    focusNode3.dispose(); //quantity
    super.dispose();
  }

  void validateProduct(String value) {
    final bloc = context.read<RecepcionBatchBloc>();

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

  void validateLote(String value) {
    final bloc = context.read<RecepcionBatchBloc>();
    String scan = bloc.scannedValue4.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue4.trim().toLowerCase();
    print('scan lote: $scan');
    bloc.loteController.clear();
    //tengo una lista de lotes el cual quiero validar si el scan es igual a alguno de los lotes
    LotesProduct? matchedLote = bloc.listLotesProduct.firstWhere(
        (lotes) => lotes.name?.toLowerCase() == scan.trim(),
        orElse: () =>
            LotesProduct() // Si no se encuentra ningún match, devuelve null
        );

    if (matchedLote.name != null) {
      print('lote encontrado: ${matchedLote.name}');
      bloc.add(ValidateFieldsOrderEvent(field: "lote", isOk: true));
      bloc.add(SelectecLoteEvent(matchedLote));
      bloc.add(ClearScannedValueOrderEvent('lote'));
    } else {
      print('lote no encontrado');
      bloc.add(ValidateFieldsOrderEvent(field: "lote", isOk: false));
      bloc.add(ClearScannedValueOrderEvent('lote'));
    }
  }

  void validateQuantity(String value) {
    final bloc = context.read<RecepcionBatchBloc>();

    String scan = bloc.scannedValue3.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue3.trim().toLowerCase();

    _controllerQuantity.text = "";
    final currentProduct = bloc.currentProduct;

    if (bloc.quantitySelected == currentProduct.cantidadFaltante) {
      return;
    }
    if (scan == currentProduct.productBarcode?.toLowerCase()) {
      bloc.add(AddQuantitySeparate(
        currentProduct.idRecepcion ?? 0,
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

  void validateLocationDest(String value) {
    final bloc = context.read<RecepcionBatchBloc>();
    final currentProduct = bloc.currentProduct;
    String scan = bloc.scannedValue6.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue6.trim().toLowerCase();
    print('scan location: $scan');
    bloc.locationDestController.clear();
    ResultUbicaciones? matchedUbicacion = bloc.ubicaciones.firstWhere(
        (ubicacion) => ubicacion.barcode?.toLowerCase() == scan.trim(),
        orElse: () =>
            ResultUbicaciones() // Si no se encuentra ningún match, devuelve null
        );
    if (matchedUbicacion.barcode != null) {
      print('Ubicacion encontrada: ${matchedUbicacion.name}');
      bloc.add(ValidateFieldsOrderEvent(field: "locationDest", isOk: true));
      bloc.add(ChangeLocationDestIsOkEvent(
          currentProduct.idRecepcion ?? 0,
          true,
          int.parse(currentProduct.productId),
          currentProduct.idMove ?? 0,
          matchedUbicacion));

      bloc.add(ChangeIsOkQuantity(
        currentProduct.idRecepcion ?? 0,
        true,
        int.parse(currentProduct.productId),
        currentProduct.idMove ?? 0,
      ));
      bloc.add(ClearScannedValueOrderEvent('locationDest'));
    } else {
      print('Ubicacion no encontrada');
      bloc.add(ValidateFieldsOrderEvent(field: "locationDest", isOk: false));
      bloc.add(ClearScannedValueOrderEvent('locationDest'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocBuilder<RecepcionBatchBloc, RecepcionBatchState>(
        builder: (context, state) {
          final recepcionBloc = context.read<RecepcionBatchBloc>();
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
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
                    child:
                        BlocConsumer<RecepcionBatchBloc, RecepcionBatchState>(
                            listener: (context, state) {
                      print('STATE ❤️‍🔥 $state');

                      //*estado cuando el producto es leido ok
                      if (state is ChangeProductOrderIsOkState) {
                        //pasamos al foco de lote
                        Future.delayed(const Duration(seconds: 1), () {
                          if (!mounted) return; // ← Añade esta verificación
                          if (context
                                  .read<RecepcionBatchBloc>()
                                  .currentProduct
                                  .productTracking ==
                              "lot") {
                            FocusScope.of(context).requestFocus(focusNode6);
                          } else {
                            if (context
                                    .read<RecepcionBatchBloc>()
                                    .configurations
                                    .result
                                    ?.result
                                    ?.scanDestinationLocationReception ==
                                false) {
                              FocusScope.of(context).requestFocus(focusNode3);
                            } else {
                              FocusScope.of(context).requestFocus(focusNode5);
                            }
                          }
                        });
                        _handleDependencies();
                      }

                      if (state is ChangeLoteOrderIsOkState) {
                        Future.delayed(const Duration(seconds: 1), () {
                          if (context
                                  .read<RecepcionBatchBloc>()
                                  .configurations
                                  .result
                                  ?.result
                                  ?.scanDestinationLocationReception ==
                              false) {
                            FocusScope.of(context).requestFocus(focusNode3);
                          } else {
                            FocusScope.of(context).requestFocus(focusNode5);
                          }
                        });
                        _handleDependencies();
                      }

                      if (state is ChangeLocationDestIsOkState) {
                        //pasamos al foco de lote
                        Future.delayed(const Duration(seconds: 1), () {
                          FocusScope.of(context).requestFocus(focusNode3);
                        });
                        _handleDependencies();
                      }

                      if (state is ChangeQuantitySeparateState) {
                        // if (state.quantity != 0.0) {
                        if (state.quantity ==
                            recepcionBloc.currentProduct.cantidadFaltante) {
                          //termianmso el proceso
                          _finishSeprateProductOrder(context, state.quantity);
                        }
                        // }
                      }
                    }, builder: (context, status) {
                      return Column(
                        children: [
                          const WarningWidgetCubit(),
                          Padding(
                            padding: EdgeInsets.only(
                                // bottom: 5,
                                top:
                                    status != ConnectionStatus.online ? 0 : 35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: white),
                                  onPressed: () {
                                    termiateProcess();

                                    Navigator.pushReplacementNamed(
                                        context, 'recepcion-batch',
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
                      child: Column(
                        children: [
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
                                                    fontSize: 14, color: black),
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
                                      horizontal: 10),
                                  child: context
                                          .read<UserBloc>()
                                          .fabricante
                                          .contains("Zebra")
                                      ? Column(
                                          children: [
                                            ProductDropdownReceptionBatchWidget(
                                              selectedProduct: selectedLocation,
                                              listOfProductsName: recepcionBloc
                                                  .listOfProductsName,
                                              currentProductId: (recepcionBloc
                                                          .currentProduct
                                                          .productId ??
                                                      0)
                                                  .toString(),
                                              currentProduct:
                                                  recepcionBloc.currentProduct,
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
                                                    fontSize: 12, color: black),
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
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: recepcionBloc.currentProduct.productBarcode ==
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
                                                ProductDropdownReceptionBatchWidget(
                                                  selectedProduct:
                                                      selectedLocation,
                                                  listOfProductsName:
                                                      recepcionBloc
                                                          .listOfProductsName,
                                                  currentProductId:
                                                      (recepcionBloc
                                                                  .currentProduct
                                                                  .productId ??
                                                              0)
                                                          .toString(),
                                                  currentProduct: recepcionBloc
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
                                                        style: const TextStyle(
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
                                                                              .currentProduct
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
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                  fontSize: 12,
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
                            visible:
                                recepcionBloc.currentProduct.productTracking ==
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
                                          left: 10, right: 10, bottom: 5),
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
                                                      'new-lote-recep-batch',
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
                                              context
                                                      .read<UserBloc>()
                                                      .fabricante
                                                      .contains("Zebra")
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 0,
                                                          vertical: 5),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            height: 20,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 5,
                                                                    top: 5),
                                                            child:
                                                                TextFormField(
                                                              autofocus: true,
                                                              showCursor: false,
                                                              controller:
                                                                  recepcionBloc
                                                                      .loteController, // Asignamos el controlador
                                                              enabled: recepcionBloc
                                                                      .productIsOk && //true
                                                                  !recepcionBloc
                                                                      .loteIsOk && //false
                                                                  !recepcionBloc
                                                                      .quantityIsOk && //false
                                                                  !recepcionBloc
                                                                      .viewQuantity,

                                                              focusNode:
                                                                  focusNode6,
                                                              onChanged:
                                                                  (value) {
                                                                // Llamamos a la validación al cambiar el texto
                                                                validateLote(
                                                                    value);
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText: recepcionBloc.lotesProductCurrent.name ==
                                                                            "" ||
                                                                        recepcionBloc.lotesProductCurrent.name ==
                                                                            null
                                                                    ? 'Esperando escaneo'
                                                                    : recepcionBloc
                                                                            .lotesProductCurrent
                                                                            .name ??
                                                                        "",
                                                                disabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                                hintStyle:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            black),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Focus(
                                                      focusNode: focusNode6,
                                                      onKey: (FocusNode node,
                                                          RawKeyEvent event) {
                                                        if (event
                                                            is RawKeyDownEvent) {
                                                          if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .enter) {
                                                            validateLote(
                                                                recepcionBloc
                                                                    .scannedValue4);

                                                            return KeyEventResult
                                                                .handled;
                                                          } else {
                                                            recepcionBloc.add(
                                                                UpdateScannedValueOrderEvent(
                                                                    event.data
                                                                        .keyLabel,
                                                                    'lote'));

                                                            return KeyEventResult
                                                                .handled;
                                                          }
                                                        }
                                                        return KeyEventResult
                                                            .ignored;
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 0,
                                                                vertical: 5),
                                                        child: Column(
                                                          children: [
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    'Lote: ',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            black),
                                                                  ),
                                                                  Text(
                                                                    recepcionBloc
                                                                            .lotesProductCurrent
                                                                            .name ??
                                                                        "Esperando escaneo",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            black),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                              Align(
                                                alignment: Alignment.centerLeft,
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

                          (recepcionBloc.configurations.result?.result
                                      ?.scanDestinationLocationReception ==
                                  false)
                              ? Row(
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
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(context,
                                            'search-location-recep-batch',
                                            arguments: [
                                              widget.ordenCompra,
                                              widget.currentProduct,
                                            ]);
                                      },
                                      child: Card(
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
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        recepcionBloc
                                                                .currentProduct
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
                                    ),
                                  ],
                                )
                              :

                              //todo : ubicacion destino
                              Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: recepcionBloc.locationsDestIsok
                                              ? green
                                              : yellow,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Card(
                                      color: recepcionBloc.isLocationDestOk
                                          ? recepcionBloc.locationsDestIsok
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
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: !recepcionBloc
                                                                  .locationsDestIsok && //false
                                                              recepcionBloc
                                                                  .productIsOk && //false
                                                              !recepcionBloc
                                                                  .quantityIsOk
                                                          ? () {
                                                              Navigator.pushReplacementNamed(
                                                                  context,
                                                                  'search-location-recep-batch',
                                                                  arguments: [
                                                                    widget
                                                                        .ordenCompra,
                                                                    widget
                                                                        .currentProduct
                                                                  ]);
                                                            }
                                                          : null,
                                                      child: Row(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Ubicación destino',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color:
                                                                    primaryColorApp,
                                                              ),
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Image.asset(
                                                            "assets/icons/ubicacion.png",
                                                            color:
                                                                primaryColorApp,
                                                            width: 20,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 20,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 5,
                                                              top: 5),
                                                      child: TextFormField(
                                                        autofocus: true,
                                                        showCursor: false,
                                                        controller: recepcionBloc
                                                            .locationDestController, // Asignamos el controlador
                                                        enabled: !recepcionBloc
                                                                .locationsDestIsok && // false
                                                            recepcionBloc
                                                                .productIsOk && // false
                                                            !recepcionBloc
                                                                .quantityIsOk,

                                                        focusNode: focusNode5,
                                                        onChanged: (value) {
                                                          // Llamamos a la validación al cambiar el texto
                                                          validateLocationDest(
                                                              value);
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: recepcionBloc
                                                                          .currentUbicationDest
                                                                          ?.name ==
                                                                      "" ||
                                                                  recepcionBloc
                                                                          .currentUbicationDest
                                                                          ?.name ==
                                                                      null
                                                              ? 'Esperando escaneo'
                                                              : recepcionBloc
                                                                  .currentUbicationDest
                                                                  ?.name,
                                                          disabledBorder:
                                                              InputBorder.none,
                                                          hintStyle:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  color: black),
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Focus(
                                                focusNode: focusNode5,
                                                onKey: (FocusNode node,
                                                    RawKeyEvent event) {
                                                  if (event
                                                      is RawKeyDownEvent) {
                                                    if (event.logicalKey ==
                                                        LogicalKeyboardKey
                                                            .enter) {
                                                      validateLocationDest(
                                                          //validamos la ubicacion
                                                          recepcionBloc
                                                              .scannedValue6);

                                                      return KeyEventResult
                                                          .handled;
                                                    } else {
                                                      recepcionBloc.add(
                                                          UpdateScannedValueOrderEvent(
                                                              event.data
                                                                  .keyLabel,
                                                              'locationDest'));

                                                      return KeyEventResult
                                                          .handled;
                                                    }
                                                  }
                                                  return KeyEventResult.ignored;
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: !recepcionBloc
                                                                    .locationsDestIsok && //false
                                                                recepcionBloc
                                                                    .productIsOk && //false
                                                                !recepcionBloc
                                                                    .quantityIsOk
                                                            ? () {
                                                                Navigator.pushReplacementNamed(
                                                                    context,
                                                                    'search-location-recep-batch',
                                                                    arguments: [
                                                                      widget
                                                                          .ordenCompra,
                                                                      widget
                                                                          .currentProduct
                                                                    ]);
                                                              }
                                                            : null,
                                                        child: Row(
                                                          children: [
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Ubicación destino',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  color:
                                                                      primaryColorApp,
                                                                ),
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            Image.asset(
                                                              "assets/icons/ubicacion.png",
                                                              color:
                                                                  primaryColorApp,
                                                              width: 20,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            recepcionBloc.currentUbicationDest
                                                                            ?.name ==
                                                                        "" ||
                                                                    recepcionBloc
                                                                            .currentUbicationDest
                                                                            ?.name ==
                                                                        null
                                                                ? 'Esperando escaneo'
                                                                : recepcionBloc
                                                                        .currentUbicationDest
                                                                        ?.name ??
                                                                    "",
                                                            style: TextStyle(
                                                                color: black,
                                                                fontSize: 14),
                                                          ))
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
                                  //*mostramos la cantidad a recoger si la configuracion lo permite
                                  Visibility(
                                    visible: recepcionBloc.configurations.result
                                            ?.result?.hideExpectedQty ==
                                        false,
                                    child: Row(
                                      children: [
                                        const Text('Recoger:',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14)),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                            recepcionBloc.currentProduct.uom ??
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
                                      onPressed: recepcionBloc.quantityIsOk &&
                                              recepcionBloc.quantitySelected >=
                                                  0
                                          ? () {
                                              print('press');
                                              recepcionBloc.add(
                                                  ShowQuantityOrderEvent(
                                                      !recepcionBloc
                                                          .viewQuantity));
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
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
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
                                    recepcionBloc.add(ShowQuantityOrderEvent(
                                        !recepcionBloc.viewQuantity));
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
                            _validatebuttonquantity();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool validateScannedBarcode(
      String scannedBarcode,
      LineasRecepcionBatch currentProduct,
      RecepcionBatchBloc batchBloc,
      bool isProduct) {
    // Buscar el barcode que coincida con el valor escaneado
    Barcodes? matchedBarcode = context
        .read<RecepcionBatchBloc>()
        .listOfBarcodes
        .firstWhere(
            (barcode) =>
                barcode.barcode?.toLowerCase() == scannedBarcode.trim(),
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
        if (matchedBarcode.cantidad + batchBloc.quantitySelected >
            currentProduct.cantidadFaltante!) {
          return false;
        }

        batchBloc.add(AddQuantitySeparate(
          currentProduct.idRecepcion ?? 0,
          int.parse(currentProduct.productId),
          currentProduct.idMove ?? 0,
          matchedBarcode.cantidad,
        ));
      }
      return false;
    }
    return false;
  }

  void _validatebuttonquantity() {
    final batchBloc = context.read<RecepcionBatchBloc>();
    final currentProduct = batchBloc.currentProduct;

    //validamos que tengamos un lote seleccionado

    if (currentProduct.productTracking == 'lot') {
      if (context.read<RecepcionBatchBloc>().lotesProductCurrent.id == null) {
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

    if (batchBloc
            .configurations.result?.result?.scanDestinationLocationReception ==
        true) {
      if (context.read<RecepcionBatchBloc>().currentUbicationDest?.id == null) {
        Get.snackbar(
          'Error',
          "Seleccione o escanee una ubicacion",
          backgroundColor: white,
          colorText: primaryColorApp,
          icon: Icon(Icons.error, color: Colors.amber),
        );
        return;
      }
    }

    String input = _cantidadController.text.trim();

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

    // Intentar convertir a double
    double? cantidad = double.tryParse(input);
    if (cantidad == null) {
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

    if (cantidad == currentProduct.cantidadFaltante) {
      batchBloc.add(ChangeQuantitySeparate(
          cantidad,
          int.parse(currentProduct.productId),
          currentProduct.idRecepcion ?? 0,
          currentProduct.idMove ?? 0));
    } else {
      FocusScope.of(context).unfocus();

      if (cantidad < (currentProduct.cantidadFaltante ?? 0)) {
        showDialog(
            context: context,
            builder: (context) {
              return DialogRecepBatchAdvetenciaCantidadScreen(
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

                    Navigator.pushReplacementNamed(context, 'recepcion-batch',
                        arguments: [widget.ordenCompra, 1]);
                  },
                  onSplit: () {
                    batchBloc.add(ChangeQuantitySeparate(
                        cantidad,
                        int.parse(currentProduct.productId),
                        currentProduct.idRecepcion ?? 0,
                        currentProduct.idMove ?? 0));
                    _cantidadController.clear();
                    Navigator.pushReplacementNamed(context, 'recepcion-batch',
                        arguments: [widget.ordenCompra, 1]);

                    _finishSeprateProductOrderSplit(context, cantidad);
                  });
            });
      } else if (cantidad > (currentProduct.cantidadFaltante ?? 0)) {
        //validamos si tiene el permiso de mover mas de lo planteado

        if (batchBloc.configurations.result?.result?.allowMoveExcess == true) {
          batchBloc.add(ChangeQuantitySeparate(
              cantidad,
              int.parse(currentProduct.productId),
              currentProduct.idRecepcion ?? 0,
              currentProduct.idMove ?? 0));

          _finishSeprateProductOrder(context, cantidad);
        } else {
          Get.snackbar(
            'Error',
            "No tiene el permiso de mover mas de lo planteado",
            backgroundColor: white,
            colorText: primaryColorApp,
            icon: Icon(Icons.error, color: Colors.red),
          );
        }
      }
    }
  }

  void _finishSeprateProductOrder(BuildContext context, dynamic cantidad) {
    if (context.read<RecepcionBatchBloc>().currentProduct.productTracking ==
        "lot") {
      print(context.read<RecepcionBatchBloc>().lotesProductCurrent.toMap());
      if (context.read<RecepcionBatchBloc>().lotesProductCurrent.name == "") {
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

    context.read<RecepcionBatchBloc>().add(FinalizarRecepcionProducto());
    context.read<RecepcionBatchBloc>().add(SendProductToOrder(false, cantidad));
    termiateProcess();

    Navigator.pushReplacementNamed(context, 'recepcion-batch',
        arguments: [widget.ordenCompra, 1]);
  }

  void _finishSeprateProductOrderSplit(
    BuildContext context,
    dynamic cantidad,
  ) {
    if (context.read<RecepcionBatchBloc>().currentProduct.productTracking ==
        "lot") {
      if (context.read<RecepcionBatchBloc>().currentProduct.lotId == "") {
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
        .read<RecepcionBatchBloc>()
        .add(FinalizarRecepcionProductoSplit(cantidad));
    context.read<RecepcionBatchBloc>().add(SendProductToOrder(true, cantidad));
    termiateProcess();
  }

  void termiateProcess() {
    FocusScope.of(context).unfocus();

    context.read<RecepcionBatchBloc>().add(CleanFieldsEvent());
    context
        .read<RecepcionBatchBloc>()
        .add(GetPorductsToEntradaBatch(widget.ordenCompra?.id ?? 0));
  }
}
