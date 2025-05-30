// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';

import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/screens/widgets/location/location_card_widget.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/screens/widgets/others/dropdowbutton_widget.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/screens/widgets/product/product_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_barcodes_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/expiredate_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

import '../../../../providers/network/cubit/connection_status_cubit.dart';

class ScanProductTrasnferScreen extends StatefulWidget {
  final LineasTransferenciaTrans? currentProduct;

  const ScanProductTrasnferScreen({super.key, required this.currentProduct});

  @override
  State<ScanProductTrasnferScreen> createState() =>
      _ScanProductTrasnferScreenState();
}

class _ScanProductTrasnferScreenState extends State<ScanProductTrasnferScreen>
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

  FocusNode focusNode1 = FocusNode(); // location
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfieldƒ
  FocusNode focusNode5 = FocusNode(); //location dest

  String? selectedLocation;
  String? selectedMuelle;

  //controller
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerLocationDest = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  @override
  void dispose() {
    focusNode1.dispose(); //product
    focusNode2.dispose(); //product
    focusNode3.dispose(); //quantity
    focusNode4.dispose(); //quantity
    focusNode5.dispose(); //quantity
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleDependencies();
  }

  void _handleDependencies() {
    //mostremos que focus estan activos

    final bloc = context.read<TransferenciaBloc>();

    if (!bloc.locationIsOk && //false
        !bloc.productIsOk && //false
        !bloc.quantityIsOk && //false
        !bloc.locationDestIsOk) //false
    {
      print("🚼 location");
      FocusScope.of(context).requestFocus(focusNode1);
      //cerramos los demas focos
      focusNode2.unfocus();
      focusNode3.unfocus();
      focusNode4.unfocus();
      focusNode5.unfocus();
    }
    if (bloc.locationIsOk && //true
        !bloc.productIsOk && //false
        !bloc.quantityIsOk && //false
        !bloc.locationDestIsOk) //false
    {
      print("🚼 product");
      FocusScope.of(context).requestFocus(focusNode2);
      //cerramos los demas focos
      focusNode1.unfocus();
      focusNode3.unfocus();
      focusNode4.unfocus();
      focusNode5.unfocus();
    }

    if (bloc.locationIsOk && //true
        bloc.productIsOk && //true
        bloc.quantityIsOk && //true
        !bloc.locationDestIsOk && //false
        !bloc.viewQuantity) //false
    {
      print("🚼 quantity");
      FocusScope.of(context).requestFocus(focusNode3);
      //cerramos los demas focos
      focusNode1.unfocus();
      focusNode2.unfocus();
      focusNode4.unfocus();
      focusNode5.unfocus();
    }
    if (bloc.locationIsOk &&
        bloc.productIsOk &&
        !bloc.quantityIsOk &&
        !bloc.locationDestIsOk) {
      print("🚼 muelle");
      FocusScope.of(context).requestFocus(focusNode5);
      //cerramos los demas focos
      focusNode1.unfocus();
      focusNode2.unfocus();
      focusNode3.unfocus();
      focusNode4.unfocus();
    }

    print('locationDestIsOk: ${bloc.locationDestIsOk}');
    print('isLocationDestOk: ${bloc.isLocationDestOk}');

    setState(() {});
  }

  void validateLocation(String value) {
    final bloc = context.read<TransferenciaBloc>();

    String scan = bloc.scannedValue1.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue1.trim().toLowerCase();

    _controllerLocation.text = "";
    final currentProduct = bloc.currentProduct;
    if (scan == currentProduct.locationBarcode.toString().toLowerCase()) {
      bloc.add(ValidateFieldsEvent(field: "location", isOk: true));
      bloc.add(ChangeLocationIsOkEvent(
          int.parse(currentProduct.productId),
          bloc.currentProduct.idTransferencia ?? 0,
          currentProduct.idMove ?? 0));

      bloc.oldLocation = currentProduct.locationId.toString();
      bloc.add(ClearScannedValueEvent('location'));
    } else {
      bloc.add(ValidateFieldsEvent(field: "location", isOk: false));
      bloc.add(ClearScannedValueEvent('location'));
    }
  }

  void validateProduct(String value) {
    final bloc = context.read<TransferenciaBloc>();

    String scan = bloc.scannedValue2.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue2.trim().toLowerCase();

    print('scan product: $scan');
    _controllerProduct.text = "";
    final currentProduct = bloc.currentProduct;
    if (scan == currentProduct.productBarcode?.toLowerCase()) {
      bloc.add(ValidateFieldsEvent(field: "product", isOk: true));
      bloc.add(ChangeProductIsOkEvent(true, int.parse(currentProduct.productId),
          currentProduct.idTransferencia ?? 0, 0, currentProduct.idMove ?? 0));
      bloc.add(ClearScannedValueEvent('product'));
    } else {
      final isok =
          validateScannedBarcode(scan, bloc.currentProduct, bloc, true);

      if (!isok) {
        bloc.add(ValidateFieldsEvent(field: "product", isOk: false));
        bloc.add(ClearScannedValueEvent('product'));
      }
    }
  }

  void validateQuantity(String value) {
    final bloc = context.read<TransferenciaBloc>();

    String scan = bloc.scannedValue3.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue3.trim().toLowerCase();

    _controllerQuantity.text = "";
    final currentProduct = bloc.currentProduct;
    //validamos que no aumente en cantidad si llego al maximo
    if (bloc.quantitySelected == bloc.currentProduct.cantidadFaltante) {
      return;
    }

    if (scan == currentProduct.productBarcode?.toLowerCase()) {
      bloc.add(AddQuantitySeparate(
          int.parse(currentProduct.productId),
          currentProduct.idMove ?? 0,
          1,
          false,
          currentProduct.idTransferencia ?? 0));
      bloc.add(ClearScannedValueEvent('quantity'));
    } else {
      validateScannedBarcode(scan, bloc.currentProduct, bloc, false);

      bloc.add(ClearScannedValueEvent('quantity'));
    }
  }

  void _validatebuttonquantity2() {
    final bloc = context.read<TransferenciaBloc>();
    //desactivamos volver a ingresar la cantidad

    String input = _cantidadController.text.trim();

    // Si está vacío, usar la cantidad seleccionada del bloc
    if (input.isEmpty) {
      input = bloc.quantitySelected.toString();
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

    if (cantidad > (bloc.currentProduct.cantidadFaltante)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1000),
        content: const Text('Cantidad erronea'),
        backgroundColor: Colors.red[200],
      ));
    } else {
      bloc.add(ChangeQuantitySeparate(
        cantidad,
        int.parse(bloc.currentProduct.productId),
        bloc.currentProduct.idMove ?? 0,
        bloc.currentProduct.idTransferencia ?? 0,
      ));
      //desactivamos volver a ingresar la cantidad
      bloc.add(ChangeIsOkQuantity(
          false,
          int.parse(bloc.currentProduct.productId),
          bloc.currentProduct.idTransferencia ?? 0,
          bloc.currentProduct.idMove ?? 0));
      // //escondemos el teclado
      if (bloc.viewQuantity == true) {
        bloc.add(ShowQuantityEvent(!bloc.viewQuantity));
      }
      //pasamso el foco a ubicacion destino
      Future.delayed(const Duration(seconds: 1), () {
        FocusScope.of(context).requestFocus(focusNode5);
      });
      _handleDependencies();
    }
  }

  void _validatebuttonquantity() {
    final bloc = context.read<TransferenciaBloc>();
    bloc.add(ChangeIsOkQuantity(
        false,
        int.parse(bloc.currentProduct.productId),
        bloc.currentProduct.idTransferencia ?? 0,
        bloc.currentProduct.idMove ?? 0));
  }

  void validateMuelle(String value) {
    final bloc = context.read<TransferenciaBloc>();

    String scan = bloc.scannedValue4.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue4.trim().toLowerCase();

    _controllerLocationDest.text = "";
    final currentProduct = bloc.currentProduct;

    if (scan == currentProduct.locationDestBarcode.toString().toLowerCase()) {
      bloc.add(ValidateFieldsEvent(field: "locationDest", isOk: true));
      bloc.add(ChangeLocationDestIsOkEvent(
          true,
          int.parse(currentProduct.productId),
          currentProduct.idTransferencia ?? 0,
          currentProduct.idMove ?? 0,
          ResultUbicaciones(
            id: currentProduct.locationDestId,
            name: currentProduct.locationDestName,
            barcode: currentProduct.locationDestBarcode,
            locationId: 0,
            locationName: "",
          )));

      bloc.add(ClearScannedValueEvent('muelle'));
    } else {
      // Buscar el barcode que coincida con el valor escaneado
      ResultUbicaciones? matchedUbicacion = bloc.ubicaciones.firstWhere(
          (ubicacion) => ubicacion.barcode?.toLowerCase() == scan.trim(),
          orElse: () =>
              ResultUbicaciones() // Si no se encuentra ningún match, devuelve null
          );

      if (matchedUbicacion.barcode != null) {
        print('Ubicacion encontrada: ${matchedUbicacion.name}');
        bloc.add(ValidateFieldsEvent(field: "locationDest", isOk: true));
        bloc.add(ChangeLocationDestIsOkEvent(
          true,
          int.parse(currentProduct.productId),
          currentProduct.idTransferencia ?? 0,
          currentProduct.idMove ?? 0,
          matchedUbicacion,
        ));

        bloc.add(ClearScannedValueEvent('muelle'));
      } else {
        print('Ubicacion no encontrada');
        bloc.add(ValidateFieldsEvent(field: "locationDest", isOk: false));
        bloc.add(ClearScannedValueEvent('muelle'));
      }
    }
  }

  void _validateQuantityFinish() {
    final batchBloc = context.read<TransferenciaBloc>();
    final currentProduct = batchBloc.currentProduct;

    double cantidad = double.parse(_cantidadController.text.isEmpty
        ? batchBloc.quantitySelected.toString()
        : _cantidadController.text);

    double truncado = double.parse(
        (batchBloc.currentProduct.cantidadFaltante).toStringAsFixed(2));

    if (cantidad == truncado) {
      _finishSeprateProductOrder(context, cantidad);
      Navigator.pushReplacementNamed(context, 'transferencia-detail',
          arguments: [batchBloc.currentTransferencia, 1]);
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return DialogTransferAdvetenciaCantidadScreen(
                currentProduct: currentProduct,
                cantidad: cantidad,
                onAccepted: () async {
                  _finishSeprateProductOrder(context, cantidad);

                  Navigator.pushReplacementNamed(
                      context, 'transferencia-detail',
                      arguments: [batchBloc.currentTransferencia, 1]);
                },
                onSplit: () {
                  _finishSeprateProductOrderSplit(context, cantidad);
                  Navigator.pushReplacementNamed(
                      context, 'transferencia-detail',
                      arguments: [batchBloc.currentTransferencia, 1]);
                });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocBuilder<TransferenciaBloc, TransferenciaState>(
        builder: (context, state) {
          final bloc = context.read<TransferenciaBloc>();
          return Scaffold(
            backgroundColor: white,
            body: SizedBox(
              width: size.width * 1,
              height: size.height * 1,
              child: Column(
                children: [
                  BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                    builder: (context, status) {
                      return Container(
                        padding: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: primaryColorApp,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        width: double.infinity,
                        child:
                            BlocConsumer<TransferenciaBloc, TransferenciaState>(
                                listener: (context, state) {
                          print('STATE ❤️‍🔥 $state');

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

                          //*estado cuando la cantidad fue cambiada
                          if (state is ChangeQuantitySeparateStateSuccess) {
                            if (state.quantity ==
                                (bloc.currentProduct.cantidadFaltante)) {
                              Future.delayed(const Duration(seconds: 1), () {
                                FocusScope.of(context).requestFocus(focusNode5);
                              });
                              _handleDependencies();
                              //validacion automatica donde la cantidad a mover sea igual a la cantidad pedida
                              _validatebuttonquantity();
                            }
                          }

                          //*estado cuando la ubicacion de destino es validada
                          if (state is ChangeLocationDestIsOkState) {
                            _validateQuantityFinish();
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

                                        bloc.add(CleanFieldsEvent());
                                        Navigator.pushReplacementNamed(
                                            context, 'transferencia-detail',
                                            arguments: [
                                              bloc.currentTransferencia,
                                              1
                                            ]);
                                      },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: size.width * 0.2),
                                      child: Text(
                                          bloc.currentTransferencia.name ?? '',
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
                      );
                    },
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: bloc.locationIsOk ? green : yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Card(
                                color: bloc.isLocationOk
                                    ? bloc.locationIsOk
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
                                            LocationDropdownTransferWidget(
                                              isPDA: false,
                                              selectedLocation:
                                                  selectedLocation,
                                              positionsOrigen:
                                                  bloc.positionsOrigen,
                                              currentLocationId: bloc
                                                      .currentProduct
                                                      .locationName ??
                                                  "",
                                              batchBloc: bloc,
                                              currentProduct:
                                                  bloc.currentProduct,
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
                                                enabled: !bloc
                                                        .locationIsOk && // false
                                                    !bloc
                                                        .productIsOk && // false
                                                    !bloc
                                                        .quantityIsOk && // false
                                                    !bloc.locationDestIsOk,

                                                focusNode: focusNode1,
                                                onChanged: (value) {
                                                  // Llamamos a la validación al cambiar el texto
                                                  validateLocation(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: bloc.currentProduct
                                                      .locationName
                                                      .toString(),
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
                                                validateLocation(
                                                    //validamos la ubicacion
                                                    bloc.scannedValue1);

                                                return KeyEventResult.handled;
                                              } else {
                                                bloc.add(
                                                    UpdateScannedValueEvent(
                                                        event.data.keyLabel,
                                                        'location'));

                                                return KeyEventResult.handled;
                                              }
                                            }
                                            return KeyEventResult.ignored;
                                          },
                                          child: LocationDropdownTransferWidget(
                                            isPDA: true,
                                            selectedLocation: selectedLocation,
                                            positionsOrigen:
                                                bloc.positionsOrigen,
                                            currentLocationId: bloc
                                                .currentProduct.locationName
                                                .toString(),
                                            batchBloc: bloc,
                                            currentProduct: bloc.currentProduct,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          //todo: producto
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: bloc.productIsOk ? green : yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Card(
                                color: bloc.isProductOk
                                    ? bloc.productIsOk
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
                                            ProductDropdownTransferWidget(
                                              selectedProduct: selectedLocation,
                                              listOfProductsName:
                                                  bloc.listOfProductsName,
                                              currentProductId: bloc
                                                  .currentProduct.productName
                                                  .toString(),
                                              batchBloc: bloc,
                                              currentProduct:
                                                  bloc.currentProduct,
                                              isPDA: false,
                                            ),
                                            TextFormField(
                                              showCursor: false,
                                              enabled: bloc
                                                      .locationIsOk && //true
                                                  !bloc.productIsOk && //false
                                                  !bloc.quantityIsOk && //false
                                                  !bloc.locationDestIsOk,

                                              controller:
                                                  _controllerProduct, // Controlador que maneja el texto
                                              focusNode: focusNode2,
                                              onChanged: (value) {
                                                validateProduct(value);
                                              },
                                              decoration: InputDecoration(
                                                hintText:
                                                    "${bloc.currentProduct.productName}",
                                                // .toString(),
                                                hintMaxLines: 2,
                                                disabledBorder:
                                                    InputBorder.none,
                                                hintStyle: const TextStyle(
                                                    fontSize: 12, color: black),
                                                border: InputBorder.none,
                                              ),
                                            ),

                                            Row(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'N° ',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: primaryColorApp),
                                                  ),
                                                ),
                                                Text(
                                                  bloc.currentProduct
                                                          .productCode
                                                          .toString() ??
                                                      'Sin codigo',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: black),
                                                ),
                                              ],
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
                                                    bloc.currentProduct
                                                                    .productBarcode ==
                                                                false ||
                                                            bloc.currentProduct
                                                                    .productBarcode ==
                                                                null ||
                                                            bloc.currentProduct
                                                                    .productBarcode ==
                                                                ""
                                                        ? "Sin codigo de barras"
                                                        : bloc.currentProduct
                                                                .productBarcode ??
                                                            "",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: bloc.currentProduct.productBarcode ==
                                                                    false ||
                                                                bloc.currentProduct
                                                                        .productBarcode ==
                                                                    null ||
                                                                bloc.currentProduct
                                                                        .productBarcode ==
                                                                    ""
                                                            ? red
                                                            : black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                if (bloc.currentProduct
                                                        .productTracking ==
                                                    'lot')
                                                  ExpiryDateWidget(
                                                      expireDate: bloc.currentProduct
                                                                      .fechaVencimiento ==
                                                                  "" ||
                                                              bloc.currentProduct
                                                                      .fechaVencimiento ==
                                                                  null
                                                          ? DateTime.now()
                                                          : DateTime.parse(bloc
                                                                  .currentProduct
                                                                  .fechaVencimiento ??
                                                              ''),
                                                      size: size,
                                                      isDetaild: false,
                                                      isNoExpireDate: bloc
                                                                  .currentProduct
                                                                  .fechaVencimiento ==
                                                              ""
                                                          ? true
                                                          : false),
                                                if (bloc.currentProduct
                                                        .productTracking ==
                                                    'lot')
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
                                                      const SizedBox(width: 5),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          bloc.currentProduct
                                                                  .lotName ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13,
                                                                  color: black),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return DialogBarcodes(
                                                                    listOfBarcodes:
                                                                        bloc.listOfBarcodes);
                                                              });
                                                        },
                                                        child: Visibility(
                                                          visible: bloc
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
                                                validateProduct(
                                                    bloc.scannedValue2);
                                                return KeyEventResult.handled;
                                              } else {
                                                bloc.add(
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
                                                ProductDropdownTransferWidget(
                                                  selectedProduct:
                                                      selectedLocation,
                                                  listOfProductsName:
                                                      bloc.listOfProductsName,
                                                  currentProductId: bloc
                                                      .currentProduct
                                                      .productName
                                                      .toString(),
                                                  batchBloc: bloc,
                                                  currentProduct:
                                                      bloc.currentProduct,
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
                                                        "${bloc.currentProduct.productName}",
                                                        maxLines: 3,
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: black),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Codigo: ',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color:
                                                                      primaryColorApp),
                                                            ),
                                                          ),
                                                          Text(
                                                            bloc.currentProduct
                                                                    .productCode
                                                                    .toString() ??
                                                                'Sin codigo',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: black),
                                                          ),
                                                        ],
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
                                                              bloc.currentProduct.productBarcode == false ||
                                                                      bloc.currentProduct
                                                                              .productBarcode ==
                                                                          null ||
                                                                      bloc.currentProduct
                                                                              .productBarcode ==
                                                                          ""
                                                                  ? "Sin codigo de barras"
                                                                  : bloc.currentProduct
                                                                          .productBarcode ??
                                                                      "",
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: bloc.currentProduct.productBarcode == false ||
                                                                          bloc.currentProduct.productBarcode ==
                                                                              null ||
                                                                          bloc.currentProduct.productBarcode ==
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
                                                if (bloc.currentProduct
                                                        .productTracking ==
                                                    'lot')
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
                                                              bloc.currentProduct
                                                                      .lotName ??
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
                                                                            bloc.listOfBarcodes);
                                                                  });
                                                            },
                                                            child: Visibility(
                                                              visible: bloc
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
                                                if (bloc.currentProduct
                                                        .productTracking ==
                                                    'lot')
                                                  ExpiryDateWidget(
                                                      expireDate: bloc.currentProduct
                                                                      .fechaVencimiento ==
                                                                  "" ||
                                                              bloc.currentProduct
                                                                      .fechaVencimiento ==
                                                                  null
                                                          ? DateTime.now()
                                                          : DateTime.parse(bloc
                                                                  .currentProduct
                                                                  .fechaVencimiento ??
                                                              ""),
                                                      size: size,
                                                      isDetaild: false,
                                                      isNoExpireDate: bloc
                                                                  .currentProduct
                                                                  .fechaVencimiento ==
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

                          //todo: muelle
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
                                        bloc.locationDestIsOk ? green : yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Card(
                                color: bloc.isLocationDestOk
                                    ? bloc.locationDestIsOk
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
                                            GestureDetector(
                                              onTap: bloc.locationIsOk &&
                                                      bloc.productIsOk &&
                                                      !bloc.quantityIsOk &&
                                                      !bloc.locationDestIsOk
                                                  ? () {
                                                      Navigator
                                                          .pushReplacementNamed(
                                                              context,
                                                              'seacrh-locationsDest-trans',
                                                              arguments: [
                                                            bloc.currentProduct
                                                          ]);
                                                    }
                                                  : null,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Ubicación de destino',
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
                                            ),
                                            Container(
                                              height: 15,
                                              margin: const EdgeInsets.only(
                                                  bottom: 5, top: 10),
                                              child: TextFormField(
                                                showCursor: false,
                                                enabled: bloc.locationIsOk &&
                                                    bloc.productIsOk &&
                                                    !bloc.quantityIsOk &&
                                                    !bloc.locationDestIsOk,
                                                controller:
                                                    _controllerLocationDest, // Controlador que maneja el texto
                                                focusNode: focusNode5,
                                                onChanged: (value) {
                                                  validateMuelle(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText:
                                                      bloc.selectedLocation,
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
                                                validateMuelle(
                                                    bloc.scannedValue4);
                                                return KeyEventResult.handled;
                                              } else {
                                                bloc.add(
                                                    UpdateScannedValueEvent(
                                                        event.data.keyLabel,
                                                        'muelle'));
                                                return KeyEventResult.handled;
                                              }
                                            }
                                            return KeyEventResult.ignored;
                                          },
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: bloc.locationIsOk &&
                                                        bloc.productIsOk &&
                                                        !bloc.quantityIsOk &&
                                                        !bloc.locationDestIsOk
                                                    ? () {
                                                        Navigator
                                                            .pushReplacementNamed(
                                                                context,
                                                                'seacrh-locationsDest-trans',
                                                                arguments: [
                                                              bloc.currentProduct
                                                            ]);
                                                      }
                                                    : null,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Ubicación de destino',
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
                                              ),
                                              const SizedBox(height: 10),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  bloc.selectedLocation,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black),
                                                ),
                                              ),
                                            ],
                                          )),
                                ),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                  ),

                  //todo: cantidad

                  SizedBox(
                    width: size.width,
                    height: bloc.viewQuantity == true &&
                            context
                                .read<UserBloc>()
                                .fabricante
                                .contains("Zebra")
                        ? 300
                        : !bloc.viewQuantity
                            ? 110
                            : 150,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Card(
                            color: bloc.isQuantityOk
                                ? bloc.quantityIsOk
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text(
                                        (bloc.currentProduct.cantidadFaltante)
                                            .toStringAsFixed(2),
                                        style: TextStyle(
                                            color: primaryColorApp,
                                            fontSize: 13),
                                      ),
                                    ),
                                    Visibility(
                                      visible: (bloc.currentProduct
                                                  .cantidadFaltante) -
                                              bloc.quantitySelected !=
                                          0,
                                      child: const Text('Pdte:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13)),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: (bloc.currentProduct
                                                        .cantidadFaltante) -
                                                    bloc.quantitySelected ==
                                                0
                                            ? Container() // Ocultamos el widget si la diferencia es 0

                                            : Text(
                                                (bloc.quantitySelected <=
                                                        (bloc.currentProduct
                                                            .cantidadFaltante)
                                                    ? ((bloc.currentProduct
                                                                .cantidadFaltante) -
                                                            bloc.quantitySelected)
                                                        .toStringAsFixed(2)
                                                    : '0'), // Aquí puedes definir qué mostrar si la condición no se cumple
                                                style: TextStyle(
                                                  color: _getColorForDifference(
                                                    bloc.quantitySelected <=
                                                            (bloc.currentProduct
                                                                .cantidadFaltante)
                                                        ? ((bloc.currentProduct
                                                                .cantidadFaltante) -
                                                            bloc.quantitySelected)
                                                        : 0, // Si no cumple, el color será para diferencia 0
                                                  ),
                                                  fontSize: 13,
                                                ),
                                              )),
                                    Text(bloc.currentProduct.uom ?? "",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 13)),
                                    Expanded(
                                      child: Container(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        height: 30,
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Container(
                                              alignment: Alignment.center,
                                              child: context
                                                      .read<UserBloc>()
                                                      .fabricante
                                                      .contains("Zebra")
                                                  ? Center(
                                                      child: TextFormField(
                                                        showCursor: false,
                                                        textAlign:
                                                            TextAlign.center,
                                                        enabled: bloc
                                                                .locationIsOk && //true
                                                            bloc
                                                                .productIsOk && //true
                                                            bloc
                                                                .quantityIsOk && //true

                                                            !bloc
                                                                .locationDestIsOk,
                                                        // showCursor: false,
                                                        controller:
                                                            _controllerQuantity, // Controlador que maneja el texto
                                                        focusNode: focusNode3,
                                                        onChanged: (value) {
                                                          validateQuantity(
                                                              value);
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: bloc
                                                              .quantitySelected
                                                              .toString(),
                                                          disabledBorder:
                                                              InputBorder.none,
                                                          hintStyle:
                                                              const TextStyle(
                                                                  fontSize: 13,
                                                                  color: black),
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    )
                                                  : Focus(
                                                      focusNode: focusNode3,
                                                      onKey: (FocusNode node,
                                                          RawKeyEvent event) {
                                                        if (event
                                                            is RawKeyDownEvent) {
                                                          if (event
                                                                  .logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .enter) {
                                                            validateQuantity(bloc
                                                                .scannedValue3);
                                                            return KeyEventResult
                                                                .handled;
                                                          } else {
                                                            bloc.add(
                                                                UpdateScannedValueEvent(
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
                                                          bloc.quantitySelected
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          )),
                                                    )),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: bloc
                                                    .configurations
                                                    .result
                                                    ?.result
                                                    ?.manualQuantityTransfer ==
                                                false
                                            ? null
                                            : bloc.quantityEdit &&
                                                    bloc.quantitySelected >= 0
                                                ? () {
                                                    bloc.add(ShowQuantityEvent(
                                                        !bloc.viewQuantity));
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
                                            color: primaryColorApp, size: 25)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: bloc.viewQuantity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            child: SizedBox(
                              height: 35,
                              child: TextFormField(
                                //tmano del campo

                                focusNode: focusNode4,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]')),
                                ],
                                onChanged: (value) {
                                  // Verifica si el valor no está vacío y si es un número válido
                                  if (value.isNotEmpty) {
                                    try {
                                      bloc.quantitySelected = int.parse(value);
                                    } catch (e) {
                                      // Manejo de errores si la conversión falla
                                      print('Error al convertir a entero: $e');
                                      // Aquí puedes mostrar un mensaje al usuario o manejar el error de otra forma
                                    }
                                  } else {
                                    // Si el valor está vacío, puedes establecer un valor por defecto
                                    bloc.quantitySelected =
                                        0; // O cualquier valor que consideres adecuado
                                  }
                                },
                                controller: _cantidadController,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                decoration:
                                    InputDecorations.authInputDecoration(
                                  hintText: 'Cantidad',
                                  labelText: 'Cantidad',
                                  suffixIconButton: IconButton(
                                    onPressed: () {
                                      bloc.add(ShowQuantityEvent(
                                          !bloc.viewQuantity));
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
                                horizontal: 10, vertical: 0),
                            child: ElevatedButton(
                              onPressed: bloc.quantityEdit &&
                                      bloc.quantitySelected >= 0 &&
                                      !bloc.locationDestIsOk
                                  ? () {
                                      //cerramos el teclado
                                      FocusScope.of(context).unfocus();
                                      _validatebuttonquantity2();
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            )),
                        //teclado de la app
                        Visibility(
                          visible: bloc.viewQuantity &&
                              context
                                  .read<UserBloc>()
                                  .fabricante
                                  .contains("Zebra"),
                          child: CustomKeyboardNumber(
                            controller: _cantidadController,
                            onchanged: () {
                              _validatebuttonquantity2();
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

  void _finishSeprateProductOrder(BuildContext context, dynamic cantidad) {
    context.read<TransferenciaBloc>().add(FinalizarTransferProducto());
    context
        .read<TransferenciaBloc>()
        .add(SendProductToTransfer(false, cantidad));
    termiateProcess();
  }

  void _finishSeprateProductOrderSplit(
    BuildContext context,
    dynamic cantidad,
  ) {
    context
        .read<TransferenciaBloc>()
        .add(FinalizarTransferProductoSplit(cantidad));
    context
        .read<TransferenciaBloc>()
        .add(SendProductToTransfer(true, cantidad));
    termiateProcess();
  }

  void termiateProcess() {
    FocusScope.of(context).unfocus();

    context.read<TransferenciaBloc>().add(GetPorductsToTransfer(
        context.read<TransferenciaBloc>().currentTransferencia.id ?? 0));
  }

  // Función que devuelve el color basado en la diferencia
  Color _getColorForDifference(dynamic difference) {
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

  bool validateScannedBarcode(
      String scannedBarcode,
      LineasTransferenciaTrans currentProduct,
      TransferenciaBloc bloc,
      bool isProduct) {
    // Buscar el barcode que coincida con el valor escaneado
    Barcodes? matchedBarcode = bloc.listOfBarcodes.firstWhere(
        (barcode) => barcode.barcode?.toLowerCase() == scannedBarcode,
        orElse: () =>
            Barcodes() // Si no se encuentra ningún match, devuelve null
        );
    if (matchedBarcode.barcode != null) {
      if (isProduct) {
        bloc.add(ValidateFieldsEvent(field: "product", isOk: true));

        bloc.add(ChangeQuantitySeparate(0, int.parse(currentProduct.productId),
            currentProduct.idMove ?? 0, currentProduct.idTransferencia ?? 0));

        bloc.add(ChangeProductIsOkEvent(
            true,
            int.parse(currentProduct.productId),
            currentProduct.idTransferencia ?? 0,
            0,
            currentProduct.idMove ?? 0));

        bloc.add(ChangeIsOkQuantity(true, int.parse(currentProduct.productId),
            currentProduct.idTransferencia ?? 0, currentProduct.idMove ?? 0));

        return true;
      } else {
        //valisamos si la suma de la cantidad del paquete es correcta con lo que se pide
        if (matchedBarcode.cantidad + bloc.quantitySelected >
            (currentProduct.cantidadFaltante)) {
          return false;
        }

        bloc.add(AddQuantitySeparate(
          int.parse(currentProduct.productId),
          currentProduct.idMove ?? 0,
          matchedBarcode.cantidad,
          false,
          currentProduct.idTransferencia ?? 0,
        ));
      }
      return false;
    }
    return false;
  }
}
