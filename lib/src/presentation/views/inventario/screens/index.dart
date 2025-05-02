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

  @override
  void initState() {
    super.initState();

    // Añadimos el observer para escuchar el ciclo de vida de la app.
    WidgetsBinding.instance.addObserver(this);
  }

  //metodo para cuando el build este listo

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
    final batchBloc = context.read<InventarioBloc>();

    //validamos que tengamos productos ya descargados

    //mostremos que focus estan activos
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
    String scan = bloc.scannedValue1.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue1.trim().toLowerCase();

    print('scan location: $scan');

    bloc.controllerLocation.clear();

    ResultUbicaciones? matchedUbicacion = bloc.ubicaciones.firstWhere(
        (ubicacion) => ubicacion.barcode?.toLowerCase() == scan.trim(),
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

    String scan = bloc.scannedValue2.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue2.trim().toLowerCase();

    print('scan product: $scan');

    bloc.controllerProduct.clear();

    Product? matchedProducts = bloc.productos.firstWhere(
        (productoUbi) => productoUbi.barcode?.toLowerCase() == scan.trim(),
        orElse: () =>
            Product() // Si no se encuentra ningún match, devuelve null
        );

    if (matchedProducts.barcode != null) {
      print('producto encontrado: ${matchedProducts.name}');
      bloc.add(ValidateFieldsEvent(field: "product", isOk: true));
      bloc.add(ChangeProductIsOkEvent(matchedProducts));
      bloc.add(ChangeIsOkQuantity(true));
      bloc.add(ClearScannedValueEvent('product'));
    } else {
      print('producto encontrado: ${matchedProducts.name}');
      bloc.add(ValidateFieldsEvent(field: "product", isOk: false));
      bloc.add(ClearScannedValueEvent('product'));
    }
  }

  void validateQuantity(String value) {
    final bloc = context.read<InventarioBloc>();

    String scan = bloc.scannedValue3.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue3.trim().toLowerCase();
    print('scan quantity: $scan');
    bloc.controllerQuantity.clear();
    final currentProduct = bloc.currentProduct;

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
    print('entrando a validar barcode');
    // Buscar el barcode que coincida con el valor escaneado
    BarcodeInventario? matchedBarcode = bloc.barcodeInventario.firstWhere(
        (barcode) => barcode.barcode?.toLowerCase() == scannedBarcode.trim(),
        orElse: () =>
            BarcodeInventario() // Si no se encuentra ningún match, devuelve null
        );
    if (matchedBarcode.barcode != null) {
      bloc.add(AddQuantitySeparate(matchedBarcode.cantidad, false));
      return false;
    }
    return false;
  }

  void _validatebuttonquantity() {
    final bloc = context.read<InventarioBloc>();



    String input = bloc.cantidadController.text.trim();
    //validamos quantity
     


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

    if (bloc.currentUbication?.id == null) {
      Get.snackbar(
        '360 Software Informa',
        "No se ha selecionado la ubicacion",
        backgroundColor: white,
        colorText: primaryColorApp,
        icon: Icon(Icons.error, color: Colors.amber),
      );
      return;
    }

    if (bloc.currentProduct?.tracking == 'lot') {
      if (bloc.currentProductLote?.id == null) {
        Get.snackbar(
          '360 Software Informa',
          "No se ha selecionado el lote",
          backgroundColor: white,
          colorText: primaryColorApp,
          icon: Icon(Icons.error, color: Colors.amber),
        );
        return;
      } else {
        double cantidad = double.parse(bloc.cantidadController.text.isEmpty
            ? bloc.quantitySelected.toString()
            : bloc.cantidadController.text);
        bloc.add(SendProductInventarioEnvet(cantidad));
      }
    } else {
      double cantidad = double.parse(bloc.cantidadController.text.isEmpty
          ? bloc.quantitySelected.toString()
          : bloc.cantidadController.text);
      bloc.add(SendProductInventarioEnvet(cantidad));
    }
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
// Mostrar el diálogo solo una vez cuando la vista se crea

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
          showDialog(
            context: context,
            builder: (context) {
              return const DialogLoading(
                message: "Validando informacion...",
              );
            },
          );
          _handleDependencies();
          //esperamos 1 segundo para que se vea el dialogo
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
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
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
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
                                    horizontal: 0, vertical: 5),
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
                                                      if (bloc
                                                          .ubicacionesFilters
                                                          .isEmpty) {
                                                        Get.defaultDialog(
                                                          title:
                                                              '360 Software Informa',
                                                          titleStyle: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 18),
                                                          middleText:
                                                              "No hay ubicaciones cargadas, por favor cargues las ubicaciones",
                                                          middleTextStyle:
                                                              TextStyle(
                                                                  color: black,
                                                                  fontSize: 14),
                                                          backgroundColor:
                                                              Colors.white,
                                                          radius: 10,
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                context
                                                                    .read<
                                                                        InventarioBloc>()
                                                                    .add(
                                                                        GetLocationsEvent());
                                                                //esperamos 1 segundo para que se vea el dialogo

                                                                Get.back();
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    primaryColorApp,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                  'Cargar ubicaciones',
                                                                  style: TextStyle(
                                                                      color:
                                                                          white)),
                                                            ),
                                                          ],
                                                        );
                                                      } else {
                                                        Navigator
                                                            .pushReplacementNamed(
                                                          context,
                                                          'search-location',
                                                        );
                                                      }
                                                    }
                                                  : null,
                                              child: Card(
                                                color: white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Row(
                                                    children: [
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
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
                                              ),
                                            ),
                                            Container(
                                              height: 20,
                                              margin: const EdgeInsets.only(
                                                  bottom: 5, top: 5),
                                              child: TextFormField(
                                                autofocus: true,
                                                showCursor: false,
                                                controller: bloc
                                                    .controllerLocation, // Asignamos el controlador
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
                                                      fontSize: 12,
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
                                                        if (bloc
                                                            .ubicacionesFilters
                                                            .isEmpty) {
                                                          Get.defaultDialog(
                                                            title:
                                                                '360 Software Informa',
                                                            titleStyle:
                                                                TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        18),
                                                            middleText:
                                                                "No hay ubicaciones cargadas, por favor cargues las ubicaciones",
                                                            middleTextStyle:
                                                                TextStyle(
                                                                    color:
                                                                        black,
                                                                    fontSize:
                                                                        14),
                                                            backgroundColor:
                                                                Colors.white,
                                                            radius: 10,
                                                            actions: [
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  context
                                                                      .read<
                                                                          InventarioBloc>()
                                                                      .add(
                                                                          GetLocationsEvent());
                                                                  //esperamos 1 segundo para que se vea el dialogo

                                                                  Get.back();
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
                                                                child: Text(
                                                                    'Cargar ubicaciones',
                                                                    style: TextStyle(
                                                                        color:
                                                                            white)),
                                                              ),
                                                            ],
                                                          );
                                                        } else {
                                                          Navigator
                                                              .pushReplacementNamed(
                                                            context,
                                                            'search-location',
                                                          );
                                                        }
                                                      }
                                                    : null,
                                                child: Card(
                                                  color:white,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(6.0),
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 5),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: (bloc
                                                          .locationIsOk && //true
                                                      !bloc
                                                          .productIsOk && //false
                                                      !bloc
                                                          .quantityIsOk) //false

                                                  ? () {
                                                      if (bloc
                                                          .productos.isEmpty) {
                                                        Get.defaultDialog(
                                                          title:
                                                              '360 Software Informa',
                                                          titleStyle: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 18),
                                                          middleText:
                                                              "No hay productos cargadoss, por favor cargues las productos",
                                                          middleTextStyle:
                                                              TextStyle(
                                                                  color: black,
                                                                  fontSize: 14),
                                                          backgroundColor:
                                                              Colors.white,
                                                          radius: 10,
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                context
                                                                    .read<
                                                                        InventarioBloc>()
                                                                    .add(
                                                                        GetProductsEvent());
                                                                //esperamos 1 segundo para que se vea el dialogo
                                                                Get.back();
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    primaryColorApp,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                  'Cargar productos',
                                                                  style: TextStyle(
                                                                      color:
                                                                          white)),
                                                            ),
                                                          ],
                                                        );
                                                      } else {
                                                        Navigator
                                                            .pushReplacementNamed(
                                                          context,
                                                          'search-product',
                                                        );
                                                      }
                                                    }
                                                  : null,
                                              child: Card(
                                                color: white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Row(
                                                    children: [
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
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
                                              ),
                                            ),

                                            Container(
                                              height: 20,
                                              margin: const EdgeInsets.only(
                                                  bottom: 5, top: 5),
                                              child: TextFormField(
                                                autofocus: true,
                                                showCursor: false,
                                                controller: bloc
                                                    .controllerProduct, // Asignamos el controlador
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
                                                                  ?.name ==
                                                              "" ||
                                                          bloc.currentProduct
                                                                  ?.name ==
                                                              null
                                                      ? 'Esperando escaneo'
                                                      : bloc.currentProduct
                                                              ?.name ??
                                                          "",
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  hintStyle: const TextStyle(
                                                      fontSize: 12,
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
                                                                ?.barcode ??
                                                            "",
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
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  Text('codigo: ',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: black)),
                                                  Text(
                                                    bloc.currentProduct?.code ==
                                                                false ||
                                                            bloc.currentProduct
                                                                    ?.code ==
                                                                null ||
                                                            bloc.currentProduct
                                                                    ?.code ==
                                                                ""
                                                        ? "Sin codigo "
                                                        : bloc.currentProduct
                                                                ?.code ??
                                                            "",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: bloc.currentProduct?.code ==
                                                                    false ||
                                                                bloc.currentProduct
                                                                        ?.code ==
                                                                    null ||
                                                                bloc.currentProduct
                                                                        ?.code ==
                                                                    ""
                                                            ? red
                                                            : primaryColorApp),
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 5),
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: bloc.locationIsOk && //true
                                                        !bloc.productIsOk && //false
                                                        !bloc.quantityIsOk
                                                    ? () {
                                                        if (bloc.productos
                                                            .isEmpty) {
                                                          Get.defaultDialog(
                                                            title:
                                                                '360 Software Informa',
                                                            titleStyle:
                                                                TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        18),
                                                            middleText:
                                                                "No hay productos cargadoss, por favor cargues las productos",
                                                            middleTextStyle:
                                                                TextStyle(
                                                                    color:
                                                                        black,
                                                                    fontSize:
                                                                        14),
                                                            backgroundColor:
                                                                Colors.white,
                                                            radius: 10,
                                                            actions: [
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  context
                                                                      .read<
                                                                          InventarioBloc>()
                                                                      .add(
                                                                          GetProductsEvent());
                                                                  //esperamos 1 segundo para que se vea el dialogo

                                                                  Get.back();
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
                                                                child: Text(
                                                                    'Cargar productos',
                                                                    style: TextStyle(
                                                                        color:
                                                                            white)),
                                                              ),
                                                            ],
                                                          );
                                                        } else {
                                                          Navigator
                                                              .pushReplacementNamed(
                                                            context,
                                                            'search-product',
                                                          );
                                                        }
                                                      }
                                                    : null,
                                                child: Card(
                                                  color: //transparente
                                                      white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Row(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
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
                                                          color:
                                                              primaryColorApp,
                                                          width: 20,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  bloc.currentProduct?.name ==
                                                              "" ||
                                                          bloc.currentProduct
                                                                  ?.name ==
                                                              null
                                                      ? 'Esperando escaneo'
                                                      : bloc.currentProduct
                                                              ?.name ??
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
                                                                  ?.barcode ??
                                                              "",
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
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Text('codigo: ',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: black)),
                                                    Text(
                                                      bloc.currentProduct
                                                                      ?.code ==
                                                                  false ||
                                                              bloc.currentProduct
                                                                      ?.code ==
                                                                  null ||
                                                              bloc.currentProduct
                                                                      ?.code ==
                                                                  ""
                                                          ? "Sin codigo "
                                                          : bloc.currentProduct
                                                                  ?.code ??
                                                              "",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: bloc.currentProduct
                                                                          ?.code ==
                                                                      false ||
                                                                  bloc.currentProduct
                                                                          ?.code ==
                                                                      null ||
                                                                  bloc.currentProduct
                                                                          ?.code ==
                                                                      ""
                                                              ? red
                                                              : primaryColorApp),
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
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        //todo: lotes

                        Visibility(
                          visible: bloc.currentProduct?.tracking == "lot",
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
                                  Text('UND: ',
                                      style: TextStyle(
                                          fontSize: 14, color: black)),
                                  Text(
                                      bloc.currentProduct?.uom == "" ||
                                              bloc.currentProduct?.uom == null
                                          ? "Sin unidad"
                                          : bloc.currentProduct?.uom ?? "",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: primaryColorApp)),
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
                                                controller: bloc
                                                    .controllerQuantity, // Controlador que maneja el texto
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
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
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
                              controller: bloc.cantidadController,
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
                                    bloc.cantidadController.clear();
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
                          controller: bloc.cantidadController,
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
