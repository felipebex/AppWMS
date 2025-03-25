// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print, unrelated_type_equality_checks, unnecessary_null_comparison, unused_element, sort_child_properties_last, no_leading_underscores_for_local_identifiers

import 'dart:async';

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
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_barcodes_widget.dart';
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

class _BatchDetailScreenState extends State<BatchScreen>
    with WidgetsBindingObserver {
  String scannedValue6 = '';
  String? selectedLocation;
  String? selectedMuelle;

  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfield
  FocusNode focusNode5 = FocusNode(); //cantidad muelle
  FocusNode focusNode6 = FocusNode(); //Submuelle

  //controller
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _controllerMuelle = TextEditingController();
  final TextEditingController _controllerSubMuelle = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleDependencies();
  }

  void _handleDependencies() {
    //mostremos que focus estan activos

    final batchBloc = context.read<BatchBloc>();

    if (!batchBloc.locationIsOk && //false
        !batchBloc.productIsOk && //false
        !batchBloc.quantityIsOk && //false
        !batchBloc.locationDestIsOk) //false
    {
      print("🚼 location");
      FocusScope.of(context).requestFocus(focusNode1);
      //cerramos los demas focos
      focusNode2.unfocus();
      focusNode3.unfocus();
      focusNode4.unfocus();
      focusNode5.unfocus();
      focusNode6.unfocus();
    }
    if (batchBloc.locationIsOk && //true
        !batchBloc.productIsOk && //false
        !batchBloc.quantityIsOk && //false
        !batchBloc.locationDestIsOk) //false
    {
      print("🚼 product");
      FocusScope.of(context).requestFocus(focusNode2);
      //cerramos los demas focos
      focusNode1.unfocus();
      focusNode3.unfocus();
      focusNode4.unfocus();
      focusNode5.unfocus();
      focusNode6.unfocus();
    }
    if (batchBloc.locationIsOk && //true
        batchBloc.productIsOk && //true
        batchBloc.quantityIsOk && //true
        !batchBloc.locationDestIsOk && //false
        !batchBloc.viewQuantity) //false
    {
      print("🚼 quantity");
      FocusScope.of(context).requestFocus(focusNode3);
      //cerramos los demas focos
      focusNode1.unfocus();
      focusNode2.unfocus();
      focusNode4.unfocus();
      focusNode5.unfocus();
      focusNode6.unfocus();
    }
    if (batchBloc.locationIsOk &&
        batchBloc.productIsOk &&
        !batchBloc.quantityIsOk &&
        !batchBloc.locationDestIsOk) {
      print("🚼 muelle");
      FocusScope.of(context).requestFocus(focusNode5);
      //cerramos los demas focos
      focusNode1.unfocus();
      focusNode2.unfocus();
      focusNode3.unfocus();
      focusNode4.unfocus();
      focusNode6.unfocus();
    }
    setState(() {});
  }

  @override
  void dispose() {
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
    focusNode6.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void validateLocation(String value) {
    final batchBloc = context.read<BatchBloc>();

    String scan = batchBloc.scannedValue1.toLowerCase() == ""
        ? value.toLowerCase()
        : batchBloc.scannedValue1.toLowerCase();

    _controllerLocation.text = "";
    final currentProduct = batchBloc.currentProduct;
    if (scan == currentProduct.barcodeLocation.toString().toLowerCase()) {
      batchBloc.add(ValidateFieldsEvent(field: "location", isOk: true));
      batchBloc.add(ChangeLocationIsOkEvent(
          currentProduct.idProduct ?? 0,
          batchBloc.batchWithProducts.batch?.id ?? 0,
          currentProduct.idMove ?? 0));
      batchBloc.oldLocation = currentProduct.locationId.toString();
      context.read<BatchBloc>().add(ClearScannedValueEvent('location'));
    } else {
      batchBloc.add(ValidateFieldsEvent(field: "location", isOk: false));
      context.read<BatchBloc>().add(ClearScannedValueEvent('location'));
    }
  }

  void validateProduct(String value) {
    final batchBloc = context.read<BatchBloc>();

    String scan = batchBloc.scannedValue2.toLowerCase() == ""
        ? value.toLowerCase()
        : batchBloc.scannedValue2.toLowerCase();


    print('scan product: $scan');
    _controllerProduct.text = "";
    final currentProduct = batchBloc.currentProduct;
    if (scan == currentProduct.barcode?.toLowerCase()) {
      batchBloc.add(ValidateFieldsEvent(field: "product", isOk: true));
      batchBloc.add(ChangeProductIsOkEvent(
          true,
          currentProduct.idProduct ?? 0,
          batchBloc.batchWithProducts.batch?.id ?? 0,
          0,
          currentProduct.idMove ?? 0));
      context.read<BatchBloc>().add(ClearScannedValueEvent('product'));
    } else {
      final isok = validateScannedBarcode(
          scan, batchBloc.currentProduct, batchBloc, true);

      if (!isok) {
        batchBloc.add(ValidateFieldsEvent(field: "product", isOk: false));
        context.read<BatchBloc>().add(ClearScannedValueEvent('product'));
      }
    }
  }

  void validateQuantity(String value) {
    final batchBloc = context.read<BatchBloc>();

    String scan = batchBloc.scannedValue3.toLowerCase() == ""
        ? value.toLowerCase()
        : batchBloc.scannedValue3.toLowerCase();

    _controllerQuantity.text = "";
    final currentProduct = batchBloc.currentProduct;
    //validamos que no aumente en cantidad si llego al maximo
    if (batchBloc.quantitySelected == currentProduct.quantity.toInt()) {
      return;
    }
    if (scan == currentProduct.barcode?.toLowerCase()) {
      batchBloc.add(AddQuantitySeparate(
          currentProduct.idProduct ?? 0, currentProduct.idMove ?? 0, 1, false));
      context.read<BatchBloc>().add(ClearScannedValueEvent('quantity'));
    } else {
      validateScannedBarcode(scan, batchBloc.currentProduct, batchBloc, false);

      context.read<BatchBloc>().add(ClearScannedValueEvent('quantity'));
    }
  }

  void validateMuelle(String value) {


    final batchBloc = context.read<BatchBloc>();
    String scan = batchBloc.scannedValue4.toLowerCase() == ""
        ? value.toLowerCase()
        : batchBloc.scannedValue4.toLowerCase();

    _controllerMuelle.text = "";
    final currentProduct = batchBloc.currentProduct;
    if (scan ==
        (batchBloc.configurations.result?.result?.muelleOption == "multiple"
            ? currentProduct.barcodeLocationDest?.toLowerCase()
            : batchBloc.batchWithProducts.batch?.barcodeMuelle
                ?.toLowerCase())) {
      validatePicking(batchBloc, context, currentProduct);
      context.read<BatchBloc>().add(ClearScannedValueEvent('muelle'));
    } else {
      batchBloc.add(ValidateFieldsEvent(field: "locationDest", isOk: false));
      context.read<BatchBloc>().add(ClearScannedValueEvent('muelle'));
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
        final batchBloc = context.read<BatchBloc>();

        int totalTasks = context.read<BatchBloc>().filteredProducts.length;

        double progress = totalTasks > 0
            ? context.read<BatchBloc>().filteredProducts.where((e) {
                  return e.isSeparate == 1;
                }).length /
                totalTasks
            : 0.0;

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
                      listenWhen: (previous, current) {
                    if (current is LoadingFetchBatch) {
                      print("------------entramos------------");
                      return true;
                    }
                    return true;
                  }, listener: (context, state) {
                    print("❤️‍🔥 state : $state");

                    // * validamos en todo cambio de estado de cantidad separada
                    if (state is ChangeQuantitySeparateStateSuccess) {
                      if (state.quantity == currentProduct.quantity.toInt()) {
                        _nextProduct(currentProduct, batchBloc);
                      }
                    }

                    if (state is CurrentProductChangedStateLoading) {
                      showDialog(
                        context: context,
                        barrierDismissible:
                            false, // No permitir que el usuario cierre el diálogo manualmente
                        builder: (context) => const DialogLoading(
                          message: 'Cargando producto...',
                        ),
                      );
                    }

                    if (state is CurrentProductChangedState) {
                      Future.delayed(const Duration(seconds: 1), () {
                        // _handleDependencies();
                        Navigator.pop(context);
                      });
                    }

                    if (state is ChangeQuantitySeparateStateError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content: Text(state.msg),
                        backgroundColor: Colors.red[200],
                      ));
                    }

                    if (state is CurrentProductChangedStateError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content: Text(state.msg),
                        backgroundColor: Colors.red[200],
                      ));
                    }

                    if (state is ValidateFieldsStateError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content: Text(state.msg),
                        backgroundColor: Colors.red[200],
                      ));
                    }

                    if (state is SelectNovedadStateError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content: Text(state.msg),
                        backgroundColor: Colors.red[200],
                      ));
                    }

                    if (state is LoadDataInfoError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content: Text(state.msg),
                        backgroundColor: Colors.red[200],
                      ));
                    }

                    //*estado cando la ubicacion de origen es cambiada
                    if (state is ChangeLocationIsOkState) {
                      //cambiamos el foco
                      Future.delayed(const Duration(seconds: 1), () {
                        FocusScope.of(context).requestFocus(focusNode2);
                      });
                      _handleDependencies();
                    }

                    //*estado cuando el producto es leido ok
                    if (state is ChangeProductIsOkState) {
                      //cambiamos el foco a cantidad
                      Future.delayed(const Duration(seconds: 1), () {
                        FocusScope.of(context).requestFocus(focusNode3);
                      });
                      _handleDependencies();
                    }
                    //*estado cuando el muelle fue editado
                    if (state is SubMuelleEditSusses) {
                      //mostramos alerta
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content: Text(state.message),
                        backgroundColor: Colors.green[200],
                      ));
                    }

                    if (state is SubMuelleEditFail) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content: Text(state.message),
                        backgroundColor: Colors.red[200],
                      ));
                    }
                  }, builder: (context, status) {
                    return Column(
                      children: [
                        const WarningWidgetCubit(),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  cantidadController.clear();

                                  batchBloc.add(ResetValuesEvent());
                                  context
                                      .read<WMSPickingBloc>()
                                      .add(FilterBatchesBStatusEvent(
                                        '',
                                      ));

                                  Navigator.pushReplacementNamed(
                                      context, 'wms-picking',
                                      arguments: 0);
                                },
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white, size: 20),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  batchBloc.batchWithProducts.batch?.name ?? '',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
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
                              horizontal: 10, vertical: 0),
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
                                // color: Colors.amber,
                                width: size.width * 0.85,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
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
                                              autofocus: true,
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
                                              validateLocation(
                                                  //validamos la ubicacion
                                                  context
                                                      .read<BatchBloc>()
                                                      .scannedValue1);

                                              return KeyEventResult.handled;
                                            } else {
                                              context.read<BatchBloc>().add(
                                                  UpdateScannedValueEvent(
                                                      event.data.keyLabel,
                                                      'location'));

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
                                    horizontal: 10, vertical: 2),
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
                                          TextFormField(
                                            showCursor: false,
                                            enabled:
                                                batchBloc.locationIsOk && //true
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
                                              hintText:
                                                  "${batchBloc.currentProduct.productId}",
                                              // .toString(),
                                              hintMaxLines: 2,
                                              disabledBorder: InputBorder.none,
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
                                                  currentProduct.barcode ==
                                                              false ||
                                                          currentProduct
                                                                  .barcode ==
                                                              null ||
                                                          currentProduct
                                                                  .barcode ==
                                                              ""
                                                      ? "Sin codigo de barras"
                                                      : currentProduct.barcode,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: currentProduct.barcode ==
                                                                  false ||
                                                              currentProduct
                                                                      .barcode ==
                                                                  null ||
                                                              currentProduct
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
                                                  expireDate: currentProduct
                                                                  .expireDate ==
                                                              "" ||
                                                          currentProduct
                                                                  .expireDate ==
                                                              null
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
                                              if (currentProduct.loteId != null)
                                                Row(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'Lote/serie:',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                primaryColorApp),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        currentProduct.lotId ??
                                                            '',
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: black),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return DialogBarcodes(
                                                                  listOfBarcodes:
                                                                      batchBloc
                                                                          .listOfBarcodes);
                                                            });
                                                      },
                                                      child: Visibility(
                                                        visible: batchBloc
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
                                                LogicalKeyboardKey.enter) {
                                              validateProduct(context
                                                  .read<BatchBloc>()
                                                  .scannedValue2);
                                              return KeyEventResult.handled;
                                            } else {
                                              context.read<BatchBloc>().add(
                                                  UpdateScannedValueEvent(
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
                                                      "${currentProduct.productId}",
                                                      maxLines: 3,
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: black),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
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
                                                            currentProduct.barcode ==
                                                                        false ||
                                                                    currentProduct
                                                                            .barcode ==
                                                                        null ||
                                                                    currentProduct
                                                                            .barcode ==
                                                                        ""
                                                                ? "Sin codigo de barras"
                                                                : currentProduct
                                                                    .barcode,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: currentProduct.barcode == false ||
                                                                        currentProduct.barcode ==
                                                                            null ||
                                                                        currentProduct.barcode ==
                                                                            ""
                                                                    ? red
                                                                    : black),
                                                          ),
                                                        ],
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
                                                    Row(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            'Lote/serie:',
                                                            style: TextStyle(
                                                                fontSize: 13,
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
                                                            currentProduct
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
                                                                          batchBloc
                                                                              .listOfBarcodes);
                                                                });
                                                          },
                                                          child: Visibility(
                                                            visible: batchBloc
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
                                              ExpiryDateWidget(
                                                  expireDate: currentProduct
                                                                  .expireDate ==
                                                              "" ||
                                                          currentProduct
                                                                  .expireDate ==
                                                              null
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
                                (batchBloc.filteredProducts.length) - 1 ||
                            batchBloc.filteredProducts.length == 1)
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
                                              enabled: batchBloc.locationIsOk &&
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
                                                hintText: 
                                                
                                                batchBloc
                                                            .configurations
                                                            .result
                                                            ?.result
                                                            ?.muelleOption ==
                                                        "multiple"


                                                    ? batchBloc.currentProduct
                                                        .locationDestId
                                                        .toString()
                                                    : batchBloc
                                                        .batchWithProducts
                                                        .batch
                                                        ?.muelle,
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
                                        focusNode: focusNode5,
                                        onKey: (FocusNode node,
                                            RawKeyEvent event) {
                                          if (event is RawKeyDownEvent) {
                                            if (event.logicalKey ==
                                                LogicalKeyboardKey.enter) {
                                              validateMuelle(context
                                                  .read<BatchBloc>()
                                                  .scannedValue4);
                                              return KeyEventResult.handled;
                                            } else {
                                              context.read<BatchBloc>().add(
                                                  UpdateScannedValueEvent(
                                                      event.data.keyLabel,
                                                      'muelle'));
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
                                                                    subtitle: muelle.barcode ==
                                                                                null ||
                                                                            muelle.barcode ==
                                                                                ""
                                                                        ? Text(
                                                                            "Sin codigo de barras",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: isSelected ? Colors.white : red,
                                                                            ),
                                                                          )
                                                                        : null,
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
                                                                    batchBloc
                                                                            .subMuelleSelected =
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
                                                                              .subMuelleSelected
                                                                              .completeName ==
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
                                                                            ));

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
                height: batchBloc.viewQuantity == true &&
                        context.read<UserBloc>().fabricante.contains("Zebra")
                    ? 300
                    : !batchBloc.viewQuantity
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
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                const Text('Cant:',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 13)),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    currentProduct.quantity?.toString() ?? "",
                                    style: TextStyle(
                                        color: primaryColorApp, fontSize: 13),
                                  ),
                                ),
                                Visibility(
                                  visible: (currentProduct.quantity ?? 0) -
                                          batchBloc.quantitySelected !=
                                      0,
                                  child: const Text('Pdte:',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 13)),
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: (currentProduct.quantity ?? 0) -
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
                                              fontSize: 13,
                                            ),
                                          )),
                                Text(currentProduct.unidades ?? "",
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 13)),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    height: 30,
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Container(
                                          alignment: Alignment.center,
                                          child: batchBloc.isPdaZebra
                                              ? Center(
                                                  child: TextFormField(
                                                    showCursor: false,
                                                    textAlign: TextAlign.center,
                                                    enabled: batchBloc
                                                            .locationIsOk && //true
                                                        batchBloc
                                                            .productIsOk && //true
                                                        batchBloc
                                                            .quantityIsOk && //true

                                                        !batchBloc
                                                            .locationDestIsOk,
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
                                                      hintStyle:
                                                          const TextStyle(
                                                              fontSize: 13,
                                                              color: black),
                                                      border: InputBorder.none,
                                                    ),
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
                                                        validateQuantity(context
                                                            .read<BatchBloc>()
                                                            .scannedValue3);
                                                        return KeyEventResult
                                                            .handled;
                                                      } else {
                                                        context
                                                            .read<BatchBloc>()
                                                            .add(UpdateScannedValueEvent(
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
                                ),
                                IconButton(
                                    onPressed: batchBloc.configurations.result
                                                ?.result?.manualQuantity ==
                                            false
                                        ? null
                                        : batchBloc.quantityIsOk &&
                                                batchBloc.quantitySelected >= 0
                                            ? () {
                                                batchBloc.add(ShowQuantityEvent(
                                                    !batchBloc.viewQuantity));
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 100), () {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusNode4);
                                                });
                                              }
                                            : null,
                                    icon: Icon(Icons.edit_note_rounded,
                                        color: primaryColorApp, size: 25)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: batchBloc.viewQuantity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        child: SizedBox(
                          height: 35,
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
                                  batchBloc.add(ShowQuantityEvent(
                                      !batchBloc.viewQuantity));
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
                                    content: const Text('Cantidad incorrecta'),
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
                                                // batchBloc.add(
                                                //     IsShouldRunDependencies(
                                                //         true));

                                                batchBloc.add(
                                                    ChangeQuantitySeparate(
                                                        int.parse(value),
                                                        currentProduct
                                                                .idProduct ??
                                                            0,
                                                        currentProduct.idMove ??
                                                            0));
                                                _nextProduct(
                                                    currentProduct, batchBloc);
                                              });
                                        });
                                  }
                                }
                              }
                              batchBloc.add(ShowQuantityEvent(false));
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
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
                            minimumSize: Size(size.width * 0.93, 30),
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
                      visible: batchBloc.viewQuantity &&
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
        cantidad,
        currentProduct.idProduct ?? 0,
        currentProduct.idMove ?? 0,
      ));
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
    // Si el proceso ya está en ejecución, no hacemos nada
    if (batchBloc.isProcessing) return;

    // Establecemos la bandera para indicar que el proceso está en ejecución
    batchBloc.add(SetIsProcessingEvent(true));

    try {
      DataBaseSqlite db = DataBaseSqlite();
      final batch = batchBloc.batchWithProducts.batch;

      // Si no hay batch, termina la ejecución
      if (batch == null) return;

      print("currentProduct ${currentProduct.productId}");

      // Función para actualizar la base de datos en varios campos a la vez
      Future<void> _updateDatabaseFields() async {
        await db.setFieldTableBatchProducts(
          batch.id ?? 0,
          currentProduct.idProduct ?? 0,
          'is_separate',
          1,
          currentProduct.idMove ?? 0,
        );

        await db.incrementProductSeparateQty(batch.id ?? 0);
      }

      // Función para gestionar la transición al siguiente producto
      Future<void> _moveToNextProduct() async {
        // Si estamos en la última posición
        if (batchBloc.index + 1 == batchBloc.filteredProducts.length) {
          // Cambiar el producto actual
          context.read<BatchBloc>().add(ChangeCurrentProduct(
              currentProduct: currentProduct, ));

          // Cambiar el estado de cantidad
          batchBloc.add(ChangeIsOkQuantity(
            false,
            currentProduct.idProduct ?? 0,
            batch.id ?? 0,
            currentProduct.idMove ?? 0,
          ));

          // Marcar como "no correcto" la cantidad
          await db.setFieldTableBatchProducts(
            batch.id ?? 0,
            currentProduct.idProduct ?? 0,
            'is_quantity_is_ok',
            0,
            currentProduct.idMove ?? 0,
          );

          // Recargar productos
          context
              .read<BatchBloc>()
              .add(FetchBatchWithProductsEvent(batch.id ?? 0));

          // Esperar 1 segundo y mover el foco
          await Future.delayed(const Duration(seconds: 1));
          FocusScope.of(context).requestFocus(focusNode5);
        } else {
          // Si no estamos en la última posición, cambiamos el producto actual
          context.read<BatchBloc>().add(ChangeCurrentProduct(
              currentProduct: currentProduct, ));

          // Validamos el campo "quantity"
          batchBloc.add(ValidateFieldsEvent(field: "quantity", isOk: true));

          // Limpiamos el controlador de cantidad
          batchBloc.quantitySelected = 0;
          cantidadController.clear();

          // Esperar 1 segundo y llamar los códigos de barras del producto
          await Future.delayed(const Duration(seconds: 1));
          batchBloc.add(FetchBarcodesProductEvent());
        }
      }

      // Ejecutar las operaciones en bloque
      await _updateDatabaseFields();
      batchBloc.add(ShowQuantityEvent(false));
      batchBloc.sortProductsByLocationId();
      await _moveToNextProduct();
    } catch (e, s) {
      print("❌ Error en _nextProduct: $e -> $s");
      // Manejo de errores
    } finally {
      batchBloc.add(SetIsProcessingEvent(false));
    }
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
    if (matchedBarcode.barcode != null) {
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
          return false;
        }

        batchBloc.add(AddQuantitySeparate(
            currentProduct.idProduct ?? 0,
            currentProduct.idMove ?? 0,
            matchedBarcode.cantidad.toInt(),
            false));
      }
      return false;
    }
    return false;
  }

  void validatePicking(
      BatchBloc batchBloc, BuildContext context, ProductsBatch currentProduct) {
    batchBloc.add(FetchBatchWithProductsEvent(
        batchBloc.batchWithProducts.batch?.id ?? 0));

    //validamos que la cantidad de productos separados sea igual a la cantidad de productos pedidos
//validamos el 100 de las unidades separadas
    final double unidadesSeparadas =
        double.parse(batchBloc.calcularUnidadesSeparadas());

    if (unidadesSeparadas == "100.0" || unidadesSeparadas >= 100.0) {
      var productsToSend = batchBloc.filteredProducts
          .where((element) => element.isSendOdoo == 0)
          .toList();

      // Si hay productos pendientes de enviar a Odoo, mostramos un modal
      if (productsToSend.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Center(
              child: Text("360 Software Informa",
                  style: TextStyle(color: yellow, fontSize: 16)),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "Tienes productos que no han sido enviados al WMS. revisa la lista de productos y envíalos antes de continuar.",
                    style: TextStyle(color: black, fontSize: 14)),
                const SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {
                      // Navigator.pop(context);
                      if (batchBloc.configurations.result?.result
                              ?.showDetallesPicking ==
                          true) {
                        //cerramos el focus
                        batchBloc.isSearch = false;
                        batchBloc.add(LoadProductEditEvent());
                        // batchBloc.add(IsShouldRunDependencies(false));
                        Navigator.pushReplacementNamed(
                          context,
                          'batch-detail',
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 1000),
                            content:
                                Text('No tienes permisos para ver detalles'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: Text('Ver productos',
                        style: TextStyle(color: primaryColorApp, fontSize: 12)))
              ],
            ),
          ),
        );
      } else {
        batchBloc.add(ValidateFieldsEvent(field: "locationDest", isOk: true));
        batchBloc.add(ChangeLocationDestIsOkEvent(
            true,
            currentProduct.idProduct ?? 0,
            batchBloc.batchWithProducts.batch?.id ?? 0,
            currentProduct.idMove ?? 0));

        batchBloc.add(EndTimePick(
            batchBloc.batchWithProducts.batch?.id ?? 0, DateTime.now()));

        batchBloc.add(PickingOkEvent(batchBloc.batchWithProducts.batch?.id ?? 0,
            currentProduct.idProduct ?? 0));
        context.read<WMSPickingBloc>().add(FilterBatchesBStatusEvent(
              '',
            ));
        batchBloc.index = 0;
        batchBloc.isSearch = true;
        Navigator.pushReplacementNamed(context, 'wms-picking', arguments: 0);
      }
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return DialogPickingIncompleted(
                currentProduct: batchBloc.currentProduct,
                cantidad: unidadesSeparadas,
                batchBloc: batchBloc,
                onAccepted: () {
                  if (batchBloc
                          .configurations.result?.result?.showDetallesPicking ==
                      true) {
                    //cerramos el focus
                    batchBloc.isSearch = false;
                    batchBloc.add(LoadProductEditEvent());
                    Navigator.pushReplacementNamed(
                      context,
                      'batch-detail',
                    ).then((_) {
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(milliseconds: 1000),
                        content: Text('No tienes permisos para ver detalles'),
                      ),
                    );
                  }
                });
          });
    }
  }
}
