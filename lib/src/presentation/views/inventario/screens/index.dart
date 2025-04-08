// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/bloc/inventario_bloc.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/widgets/dialog_barcodes_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/expiredate_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen>
    with WidgetsBindingObserver {
  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfield

  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

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

    final batchBloc = context.read<InventarioBloc>();

    if (!batchBloc.locationIsOk && //false
            !batchBloc.productIsOk && //false
            !batchBloc.quantityIsOk //false
        ) {
      print("🚼 location");
      FocusScope.of(context).requestFocus(focusNode1);
      //cerramos los demas focos
      focusNode2.unfocus();
      focusNode3.unfocus();
      focusNode4.unfocus();
    }
    if (batchBloc.locationIsOk && //true
        !batchBloc.productIsOk && //false
        !batchBloc.quantityIsOk) //false
    {
      print("🚼 product");
      FocusScope.of(context).requestFocus(focusNode2);
      //cerramos los demas focos
      focusNode1.unfocus();
      focusNode3.unfocus();
      focusNode4.unfocus();
    }
    if (batchBloc.locationIsOk && //true
        batchBloc.productIsOk && //true
        batchBloc.quantityIsOk && //true
        !batchBloc.viewQuantity) //false
    {
      print("🚼 quantity");
      FocusScope.of(context).requestFocus(focusNode3);
      //cerramos los demas focos
      focusNode1.unfocus();
      focusNode2.unfocus();
      focusNode4.unfocus();
    }

    setState(() {});
  }

  void validateLocation(String value) {
    final bloc = context.read<InventarioBloc>();

    String scan = bloc.scannedValue1.toLowerCase() == ""
        ? value.toLowerCase()
        : bloc.scannedValue1.toLowerCase();

    _controllerLocation.text = "";

    ResultUbicaciones? matchedUbicacion = bloc.ubicaciones.firstWhere(
        (ubicacion) => ubicacion.barcode?.toLowerCase() == scan,
        orElse: () =>
            ResultUbicaciones() // Si no se encuentra ningún match, devuelve null
        );

    if (matchedUbicacion.barcode != null) {
      print('Ubicacion encontrada: ${matchedUbicacion.name}');
      bloc.add(ValidateFieldsEvent(field: "location", isOk: true));
      bloc.add(ChangeLocationIsOkEvent(matchedUbicacion));
      bloc.add(ClearScannedValueEvent('location'));
    } else {
      print('Ubicacion no encontrada');
      bloc.add(ValidateFieldsEvent(field: "location", isOk: false));
      bloc.add(ClearScannedValueEvent('location'));
    }
  }

  void validateProduct(String value) {
    final bloc = context.read<InventarioBloc>();

    String scan = bloc.scannedValue2.toLowerCase() == ""
        ? value.toLowerCase()
        : bloc.scannedValue2.toLowerCase();

    _controllerProduct.text = "";

    Product? matchedProductUbicacion = bloc.productosUbicacion.firstWhere(
        (productoUbi) => productoUbi.barcode?.toLowerCase() == scan,
        orElse: () =>
            Product() // Si no se encuentra ningún match, devuelve null
        );

    if (matchedProductUbicacion.barcode != null) {
      print('producto encontrado: ${matchedProductUbicacion.productName}');
      bloc.add(ValidateFieldsEvent(field: "product", isOk: true));
      bloc.add(ChangeProductIsOkEvent(matchedProductUbicacion));
      bloc.add(ChangeIsOkQuantity(true));
      bloc.add(ClearScannedValueEvent('product'));
    } else {
      print('producto no econtrado en la ubicacion');

      Product? matchedProducts = bloc.productos.firstWhere(
        (producto) {
          // Verifica si barcode no es nulo y es un String
          if (producto.barcode is String) {
            return producto.barcode!.toLowerCase() == scan.toLowerCase();
          }
          return false; // Si no es un String, no hacer el match
        },
        orElse: () =>
            Product(), // Si no se encuentra ningún match, devuelve un Product vacío
      );

      if (matchedProducts.barcode != null) {
        bloc.add(ClearScannedValueEvent('product'));

        Get.defaultDialog(
          title: '360 Software Informa',
          titleStyle: TextStyle(color: Colors.amber, fontSize: 16),
          // middleText:
          //     'El producto  ${matchedProducts.productName} registra existencias en la ubicacion ${matchedProducts.locationName}',
          // middleTextStyle: TextStyle(color: black, fontSize: 14),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                RichText(
                    text: TextSpan(
                  text: 'El producto  ',
                  style: TextStyle(color: black, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${matchedProducts.productName} ',
                      style: TextStyle(
                        color: primaryColorApp,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: 'registra existencias en la ubicacion ',
                      style: TextStyle(color: black, fontSize: 14),
                    ),
                    TextSpan(
                      text: '${matchedProducts.locationName}',
                      style: TextStyle(color: primaryColorApp, fontSize: 14),
                    ),
                  ],
                )),
                const SizedBox(
                  height: 20,
                ),
                RichText(
                    text: TextSpan(
                  text: 'Desea registrarlo en la ubicacion ',
                  style: TextStyle(color: black, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${bloc.currentUbication?.name} ',
                      style: TextStyle(
                        color: primaryColorApp,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: '?',
                      style: TextStyle(color: black, fontSize: 14),
                    ),
                  ],
                )),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          radius: 10,
          actions: [
            ElevatedButton(
              onPressed: () {
                bloc.add(ClearScannedValueEvent('product'));
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Cancelar', style: TextStyle(color: white)),
            ),
            ElevatedButton(
              onPressed: () {
                bloc.add(ValidateFieldsEvent(field: "product", isOk: true));
                bloc.add(ChangeProductIsOkEvent(matchedProducts));
                bloc.add(ChangeIsOkQuantity(true));
                bloc.add(ClearScannedValueEvent('product'));
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColorApp,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Aceptar', style: TextStyle(color: white)),
            ),
          ],
        );
      } else {
        print('producto encontrado: ${matchedProducts.productName}');
        bloc.add(ValidateFieldsEvent(field: "product", isOk: false));
        bloc.add(ClearScannedValueEvent('product'));
      }
    }
  }

  void validateQuantity(String value) {
    final bloc = context.read<InventarioBloc>();

    String scan = bloc.scannedValue3.toLowerCase() == ""
        ? value.toLowerCase()
        : bloc.scannedValue3.toLowerCase();

    _controllerQuantity.text = "";
    final currentProduct = bloc.currentProduct;
    //validamos que no aumente en cantidad si llego al maximo
    if (bloc.quantitySelected == currentProduct?.quantity.toInt()) {
      return;
    }
    if (scan == currentProduct?.barcode?.toLowerCase()) {
      bloc.add(AddQuantitySeparate(1, false));
      bloc.add(ClearScannedValueEvent('quantity'));
    } else {
      validateScannedBarcode(scan, currentProduct ?? Product(), bloc, false);

      bloc.add(ClearScannedValueEvent('quantity'));
    }
  }

  bool validateScannedBarcode(String scannedBarcode, Product currentProduct,
      InventarioBloc bloc, bool isProduct) {
    // Buscar el barcode que coincida con el valor escaneado
    BarcodeInventario? matchedBarcode = bloc.barcodeInventario.firstWhere(
        (barcode) => barcode.barcode?.toLowerCase() == scannedBarcode,
        orElse: () =>
            BarcodeInventario() // Si no se encuentra ningún match, devuelve null
        );
    if (matchedBarcode.barcode != null) {
      bloc.add(AddQuantitySeparate(matchedBarcode.cantidad!.toInt(), false));
      return false;
    }
    return false;
  }

  void _validatebuttonquantity() {
    final bloc = context.read<InventarioBloc>();
    int cantidad = int.parse(_cantidadController.text.isEmpty
        ? bloc.quantitySelected.toString()
        : _cantidadController.text);

    bloc.add(SendProductInventarioEnvet(cantidad));
  }

  @override
  void dispose() {
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<InventarioBloc, InventarioState>(
      listener: (context, state) {
        print("state ❤️‍🔥:: $state");

        //*estado cando la ubicacion de origen es cambiada
        if (state is ChangeLocationIsOkState) {
          //cambiamos el foco
          Future.delayed(const Duration(seconds: 1), () {
            FocusScope.of(context).requestFocus(focusNode2);
          });
          _handleDependencies();
        }

        if (state is CleanFieldsState) {
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

        if (state is SendProductLoading) {
          showDialog(
            context: context,
            builder: (context) {
              return const DialogLoading(
                message: "Validando informacion...",
              );
            },
          );
        }
        if (state is SendProductSuccess) {
          Navigator.pop(context);
          context.read<InventarioBloc>().add(CleanFieldsEent());
          Get.snackbar(
            '360 Software Informa',
            "Se ha registrado el producto correctamente",
            backgroundColor: white,
            colorText: primaryColorApp,
            icon: Icon(Icons.error, color: Colors.green),
          );
        }

        if (state is SendProductFailure) {
          Navigator.pop(context);
          Get.defaultDialog(
            title: '360 Software Informa',
            titleStyle: TextStyle(color: Colors.red, fontSize: 18),
            middleText: state.error,
            middleTextStyle: TextStyle(color: black, fontSize: 14),
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
                child: Text('Aceptar', style: TextStyle(color: white)),
              ),
            ],
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<InventarioBloc>();
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            backgroundColor: white,
            // floatingActionButton: FloatingActionButton(
            //   backgroundColor: primaryColorApp,
            //   onPressed: () {
            //     print("ubicaciones: ${bloc.ubicaciones.length}");
            //     print("productos toal: ${bloc.productos.length}");
            //     print(
            //         "productos de ubicacion: ${bloc.productosUbicacion.length}");
            //     print(
            //         "-----------------------------------------------------------------------------");
            //     print("productos actual: ${bloc.currentProduct?.toMap()}");
            //     print(
            //         'codigo por paquete del product: ${bloc.barcodeInventario.length}');
            //     print("ubicaicon actual: ${bloc.currentUbication?.toMap()}");
            //     print(
            //         "-----------------------------------------------------------------------------");
            //     print("lotes del producto: ${bloc.listLotesProduct.length}");
            //     print("lote actual: ${bloc.currentProductLote?.toMap()}");
            //   },
            //   child: const Icon(Icons.add),
            // ),
            body: Column(
              children: [
                //appbar
                Container(
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
                                bottom: 0,
                                top:
                                    status != ConnectionStatus.online ? 0 : 35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      size: 20, color: white),
                                  onPressed: () {
                                    bloc.add(CleanFieldsEent());
                                    Navigator.pushReplacementNamed(
                                      context,
                                      'home',
                                    );
                                  },
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: size.width * 0.2),
                                  child: const Text("INVENTARIO RÁPIDO",
                                      style: TextStyle(
                                          color: white, fontSize: 14)),
                                ),
                                const Spacer(),
                                IconButton(
                                    onPressed: () {
                                      bloc.add(CleanFieldsEent());
                                    },
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: white)),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),

                Expanded(
                  child: SizedBox(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        //todo : ubicacion de origen
                        const SizedBox(height: 10),
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
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: !bloc
                                                          .locationIsOk && //false
                                                      !bloc
                                                          .productIsOk && //false
                                                      !bloc.quantityIsOk
                                                  ? () {
                                                      Navigator
                                                          .pushReplacementNamed(
                                                        context,
                                                        'search-location',
                                                      );
                                                    }
                                                  : null,
                                              child: Row(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Ubicación de existencias',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: primaryColorApp,
                                                      ),
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
                                            ),
                                            Container(
                                              height: 15,
                                              margin: const EdgeInsets.only(
                                                  bottom: 5, top: 5),
                                              child: TextFormField(
                                                autofocus: true,
                                                showCursor: false,
                                                controller:
                                                    _controllerLocation, // Asignamos el controlador
                                                enabled: !bloc
                                                        .locationIsOk && // false
                                                    !bloc
                                                        .productIsOk && // false
                                                    !bloc.quantityIsOk,

                                                focusNode: focusNode1,
                                                onChanged: (value) {
                                                  // Llamamos a la validación al cambiar el texto
                                                  validateLocation(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: bloc.currentUbication
                                                                  ?.name ==
                                                              "" ||
                                                          bloc.currentUbication
                                                                  ?.name ==
                                                              null
                                                      ? 'Esperando escaneo'
                                                      : bloc.currentUbication
                                                          ?.name,
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
                                        ),
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
                                              bloc.add(UpdateScannedValueEvent(
                                                  event.data.keyLabel,
                                                  'location'));

                                              return KeyEventResult.handled;
                                            }
                                          }
                                          return KeyEventResult.ignored;
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: !bloc
                                                            .locationIsOk && //false
                                                        !bloc
                                                            .productIsOk && //false
                                                        !bloc.quantityIsOk
                                                    ? () {
                                                        Navigator
                                                            .pushReplacementNamed(
                                                          context,
                                                          'search-location',
                                                        );
                                                      }
                                                    : null,
                                                child: Row(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'Ubicación de existencias',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color:
                                                              primaryColorApp,
                                                        ),
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
                                              ),
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    bloc.currentUbication
                                                                    ?.name ==
                                                                "" ||
                                                            bloc.currentUbication
                                                                    ?.name ==
                                                                null
                                                        ? 'Esperando escaneo'
                                                        : bloc.currentUbication
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

                        //todo : producto
                        const SizedBox(height: 5),
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
                                // color: Colors.amber,
                                width: size.width * 0.85,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                child: context
                                        .read<UserBloc>()
                                        .fabricante
                                        .contains("Zebra")
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: bloc.locationIsOk && //true
                                                      !bloc
                                                          .productIsOk && //false
                                                      !bloc.quantityIsOk
                                                  ? () {
                                                      Navigator
                                                          .pushReplacementNamed(
                                                        context,
                                                        'search-product',
                                                      );
                                                    }
                                                  : null,
                                              child: Row(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Producto',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              primaryColorApp),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Image.asset(
                                                    "assets/icons/producto.png",
                                                    color: primaryColorApp,
                                                    width: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 15,
                                              margin: const EdgeInsets.only(
                                                  bottom: 5, top: 5),
                                              child: TextFormField(
                                                autofocus: true,
                                                showCursor: false,
                                                controller:
                                                    _controllerProduct, // Asignamos el controlador
                                                enabled: bloc
                                                        .locationIsOk && // false
                                                    !bloc
                                                        .productIsOk && // false
                                                    !bloc.quantityIsOk,

                                                focusNode: focusNode2,
                                                onChanged: (value) {
                                                  // Llamamos a la validación al cambiar el texto
                                                  validateProduct(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: bloc.currentProduct
                                                                  ?.productName ==
                                                              "" ||
                                                          bloc.currentProduct
                                                                  ?.productName ==
                                                              null
                                                      ? 'Esperando escaneo'
                                                      : bloc.currentProduct
                                                              ?.productName ??
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
                                                                    ?.barcode ==
                                                                false ||
                                                            bloc.currentProduct
                                                                    ?.barcode ==
                                                                null ||
                                                            bloc.currentProduct
                                                                    ?.barcode ==
                                                                ""
                                                        ? "Sin codigo de barras"
                                                        : bloc.currentProduct
                                                            ?.barcode,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: bloc.currentProduct?.barcode ==
                                                                    false ||
                                                                bloc.currentProduct
                                                                        ?.barcode ==
                                                                    null ||
                                                                bloc.currentProduct
                                                                        ?.barcode ==
                                                                    ""
                                                            ? red
                                                            : black),
                                                  ),
                                                  Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return DialogBarcodesInventario(
                                                                listOfBarcodes:
                                                                    bloc.barcodeInventario);
                                                          });
                                                    },
                                                    child: Visibility(
                                                      visible: bloc
                                                          .barcodeInventario
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
                                            // Visibility(
                                            //   visible: bloc.currentProduct
                                            //           ?.productTracking ==
                                            //       "lot",
                                            //   child: ExpiryDateWidget(
                                            //       expireDate: bloc.currentProduct
                                            //                       ?.expirationDate ==
                                            //                   "" ||
                                            //               bloc.currentProduct
                                            //                       ?.expirationDate ==
                                            //                   null
                                            //           ? DateTime.now()
                                            //           : DateTime.parse(bloc
                                            //               .currentProduct
                                            //               ?.expirationDate),
                                            //       size: size,
                                            //       isDetaild: false,
                                            //       isNoExpireDate: bloc
                                            //                   .currentProduct
                                            //                   ?.expirationDate ==
                                            //               ""
                                            //           ? true
                                            //           : false),
                                            // ),
                                          ],
                                        ),
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
                                              bloc.add(UpdateScannedValueEvent(
                                                  event.data.keyLabel,
                                                  'product'));

                                              return KeyEventResult.handled;
                                            }
                                          }
                                          return KeyEventResult.ignored;
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: bloc.locationIsOk && //true
                                                        !bloc.productIsOk && //false
                                                        !bloc.quantityIsOk
                                                    ? () {
                                                        Navigator
                                                            .pushReplacementNamed(
                                                          context,
                                                          'search-product',
                                                        );
                                                      }
                                                    : null,
                                                child: Row(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'Producto',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                primaryColorApp),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Image.asset(
                                                      "assets/icons/producto.png",
                                                      color: primaryColorApp,
                                                      width: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  bloc.currentProduct
                                                                  ?.productName ==
                                                              "" ||
                                                          bloc.currentProduct
                                                                  ?.productName ==
                                                              null
                                                      ? 'Esperando escaneo'
                                                      : bloc.currentProduct
                                                              ?.productName ??
                                                          "",
                                                  style: TextStyle(
                                                      color: black,
                                                      fontSize: 14),
                                                ),
                                              ),
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
                                                                      ?.barcode ==
                                                                  false ||
                                                              bloc.currentProduct
                                                                      ?.barcode ==
                                                                  null ||
                                                              bloc.currentProduct
                                                                      ?.barcode ==
                                                                  ""
                                                          ? "Sin codigo de barras"
                                                          : bloc.currentProduct
                                                              ?.barcode,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: bloc.currentProduct
                                                                          ?.barcode ==
                                                                      false ||
                                                                  bloc.currentProduct
                                                                          ?.barcode ==
                                                                      null ||
                                                                  bloc.currentProduct
                                                                          ?.barcode ==
                                                                      ""
                                                              ? red
                                                              : black),
                                                    ),
                                                    Spacer(),
                                                    GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return DialogBarcodesInventario(
                                                                  listOfBarcodes:
                                                                      bloc.barcodeInventario);
                                                            });
                                                      },
                                                      child: Visibility(
                                                        visible: bloc
                                                            .barcodeInventario
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
                                              Visibility(
                                                visible: bloc.currentProduct
                                                        ?.productTracking ==
                                                    "lot",
                                                child: ExpiryDateWidget(
                                                    expireDate: bloc.currentProduct
                                                                    ?.expirationDate ==
                                                                "" ||
                                                            bloc.currentProduct
                                                                    ?.expirationDate ==
                                                                null
                                                        ? DateTime.now()
                                                        : DateTime.parse(bloc
                                                            .currentProduct
                                                            ?.expirationDate),
                                                    size: size,
                                                    isDetaild: false,
                                                    isNoExpireDate: bloc
                                                                .currentProduct
                                                                ?.expirationDate ==
                                                            ""
                                                        ? true
                                                        : false),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        //todo: lotes

                        Visibility(
                          visible:
                              bloc.currentProduct?.productTracking == "lot",
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: bloc.loteIsOk ? green : yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Card(
                                color: bloc.isLoteOk
                                    ? bloc.loteIsOk
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
                                                    'new-lote-inventario',
                                                    arguments: [
                                                      bloc.currentProduct
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
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Lote: ',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: black),
                                                  ),
                                                  Text(
                                                    bloc.currentProductLote
                                                            ?.name ??
                                                        "",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColorApp),
                                                  ),
                                                ],
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
                                                    bloc.currentProductLote
                                                            ?.expirationDate
                                                            .toString() ??
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
                      ],
                    ),
                  )),
                ),

                //todo: cantidad
                SizedBox(
                  // color: Colors.amber,
                  width: size.width,
                  height: bloc.viewQuantity == true &&
                          context.read<UserBloc>().fabricante.contains("Zebra")
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
                                    visible: bloc.configurations.result?.result
                                            ?.countQuantityInventory ==
                                        true,
                                    child: Row(
                                      children: [
                                        const Text('Contar:',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14)),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              bloc.currentProduct?.quantity
                                                      ?.toString() ??
                                                  "",
                                              style: TextStyle(
                                                color: primaryColorApp,
                                                fontSize: 14,
                                              ),
                                            )),
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
                                                enabled:
                                                    bloc.productIsOk && //true
                                                        bloc.quantityIsOk //true
                                                ,
                                                // showCursor: false,
                                                controller:
                                                    _controllerQuantity, // Controlador que maneja el texto
                                                focusNode: focusNode3,
                                                onChanged: (value) {
                                                  validateQuantity(value);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: bloc
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
                                                          bloc.scannedValue3);

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
                                                  return KeyEventResult.ignored;
                                                },
                                                child: Text(
                                                    bloc.quantitySelected
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14)),
                                              )),
                                  ),
                                  IconButton(
                                      onPressed: bloc.quantityIsOk &&
                                              bloc.quantitySelected >= 0
                                          ? () {
                                              bloc.add(ShowQuantityEvent(
                                                  !bloc.viewQuantity));
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
                        visible: bloc.viewQuantity,
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
                                    bloc.add(
                                        ShowQuantityEvent(!bloc.viewQuantity));
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
                            onPressed:
                                bloc.quantityIsOk && bloc.quantitySelected >= 0
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
                        visible: bloc.viewQuantity &&
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
    );
  }
}
