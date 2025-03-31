// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/bloc/inventario_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

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
      bloc.add(ClearScannedValueEvent('product'));
    } else {
      print('producto no econtrado en la ubicacion');

      // Product? matchedProducts = bloc.productos.firstWhere(
      // (producto) => producto.barcode?.toLowerCase() == scan,
      // orElse: () =>
      //     Product() // Si no se encuentra ningún match, devuelve null
      // );

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

        //*estado cuando el producto es leido ok
        if (state is ChangeProductIsOkState) {
          //cambiamos el foco a cantidad
          Future.delayed(const Duration(seconds: 1), () {
            FocusScope.of(context).requestFocus(focusNode3);
          });
          _handleDependencies();
        }
      },
      builder: (context, state) {
        final bloc = context.read<InventarioBloc>();
        return Scaffold(
          backgroundColor: white,
          body: SizedBox(
              width: size.width * 1,
              height: size.height * 1,
              child: SingleChildScrollView(
                child: Column(
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
                        child: BlocBuilder<ConnectionStatusCubit,
                            ConnectionStatus>(builder: (context, status) {
                          return Column(
                            children: [
                              const WarningWidgetCubit(),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: 0,
                                    top: status != ConnectionStatus.online
                                        ? 0
                                        : 35),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back,
                                          size: 20, color: white),
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          'home',
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: size.width * 0.2),
                                      child: const Text("INVENTARIO RÁPIDO",
                                          style: TextStyle(
                                              color: white, fontSize: 14)),
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

                    //todo : ubicacion de origen
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                        Row(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
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
                                                !bloc.productIsOk && // false
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
                                                  : bloc.currentUbication?.name,
                                              disabledBorder: InputBorder.none,
                                              hintStyle: const TextStyle(
                                                  fontSize: 14, color: black),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Focus(
                                    focusNode: focusNode1,
                                    onKey: (FocusNode node, RawKeyEvent event) {
                                      if (event is RawKeyDownEvent) {
                                        if (event.logicalKey ==
                                            LogicalKeyboardKey.enter) {
                                          validateLocation(
                                              //validamos la ubicacion
                                              bloc.scannedValue1);

                                          return KeyEventResult.handled;
                                        } else {
                                          bloc.add(UpdateScannedValueEvent(
                                              event.data.keyLabel, 'location'));

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
                                            onTap: () {
                                              Navigator.pushReplacementNamed(
                                                context,
                                                'search-location',
                                              );
                                            },
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
                                          Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                bloc.currentUbication?.name ==
                                                            "" ||
                                                        bloc.currentUbication
                                                                ?.name ==
                                                            null
                                                    ? 'Esperando escaneo'
                                                    : bloc.currentUbication
                                                            ?.name ??
                                                        "",
                                                style: TextStyle(
                                                    color: black, fontSize: 14),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                          onTap: () {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              'search-product',
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Producto',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: primaryColorApp),
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
                                            enabled: !bloc
                                                    .locationIsOk && // false
                                                !bloc.productIsOk && // false
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
                                              disabledBorder: InputBorder.none,
                                              hintStyle: const TextStyle(
                                                  fontSize: 14, color: black),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Focus(
                                    focusNode: focusNode2,
                                    onKey: (FocusNode node, RawKeyEvent event) {
                                      if (event is RawKeyDownEvent) {
                                        if (event.logicalKey ==
                                            LogicalKeyboardKey.enter) {
                                          validateProduct(bloc.scannedValue2);

                                          return KeyEventResult.handled;
                                        } else {
                                          bloc.add(UpdateScannedValueEvent(
                                              event.data.keyLabel, 'product'));

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
                                            onTap: () {
                                              Navigator.pushReplacementNamed(
                                                context,
                                                'search-product',
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Producto',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColorApp),
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
                                                  color: black, fontSize: 14),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    // Expanded(child: Container()),

                    //todo: cantidad

                    // SizedBox(
                    //   width: size.width,
                    //   height: bloc.viewQuantity == true &&
                    //           context
                    //               .read<UserBloc>()
                    //               .fabricante
                    //               .contains("Zebra")
                    //       ? 300
                    //       : !bloc.viewQuantity
                    //           ? 110
                    //           : 150,
                    //   child: Column(
                    //     children: [
                    //       Padding(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 10,
                    //         ),
                    //         child: Card(
                    //           color: bloc.isQuantityOk
                    //               ? bloc.quantityIsOk
                    //                   ? white
                    //                   : Colors.grey[300]
                    //               : Colors.red[200],
                    //           elevation: 1,
                    //           child: Padding(
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: 10,
                    //             ),
                    //             child: Center(
                    //               child: Row(
                    //                 children: [
                    //                   const Text('Cant:',
                    //                       style: TextStyle(
                    //                           color: Colors.black,
                    //                           fontSize: 13)),
                    //                   Padding(
                    //                     padding: const EdgeInsets.symmetric(
                    //                         horizontal: 5),
                    //                     child: Text(
                    //                       "10",
                    //                       style: TextStyle(
                    //                           color: primaryColorApp,
                    //                           fontSize: 13),
                    //                     ),
                    //                   ),
                    //                   Expanded(
                    //                     child: Container(
                    //                       padding: const EdgeInsets.only(
                    //                           bottom: 5),
                    //                       height: 30,
                    //                       alignment: Alignment.center,
                    //                       child: Padding(
                    //                         padding:
                    //                             const EdgeInsets.symmetric(
                    //                                 horizontal: 10),
                    //                         child: Container(
                    //                             alignment: Alignment.center,
                    //                             child: context
                    //                                     .read<UserBloc>()
                    //                                     .fabricante
                    //                                     .contains("Zebra")
                    //                                 ? Center(
                    //                                     child: TextFormField(
                    //                                       showCursor: false,
                    //                                       textAlign: TextAlign
                    //                                           .center,
                    //                                       enabled: bloc
                    //                                               .locationIsOk && //true
                    //                                           bloc.productIsOk && //true
                    //                                           bloc.quantityIsOk,
                    //                                       // showCursor: false,
                    //                                       controller:
                    //                                           _controllerQuantity, // Controlador que maneja el texto
                    //                                       focusNode:
                    //                                           focusNode3,
                    //                                       onChanged: (value) {
                    //                                         // validateQuantity(
                    //                                         //     value);
                    //                                       },
                    //                                       decoration:
                    //                                           InputDecoration(
                    //                                         // hintText: batchBloc
                    //                                         //     .quantitySelected
                    //                                         //     .toString(),
                    //                                         disabledBorder:
                    //                                             InputBorder
                    //                                                 .none,
                    //                                         hintStyle:
                    //                                             const TextStyle(
                    //                                                 fontSize:
                    //                                                     13,
                    //                                                 color:
                    //                                                     black),
                    //                                         border:
                    //                                             InputBorder
                    //                                                 .none,
                    //                                       ),
                    //                                     ),
                    //                                   )
                    //                                 : Focus(
                    //                                     focusNode: focusNode3,
                    //                                     onKey:
                    //                                         (FocusNode node,
                    //                                             RawKeyEvent
                    //                                                 event) {
                    //                                       if (event
                    //                                           is RawKeyDownEvent) {
                    //                                         if (event
                    //                                                 .logicalKey ==
                    //                                             LogicalKeyboardKey
                    //                                                 .enter) {
                    //                                           // validateQuantity(context
                    //                                           //     .read<
                    //                                           //         BatchBloc>()
                    //                                           //     .scannedValue3);
                    //                                           return KeyEventResult
                    //                                               .handled;
                    //                                         } else {
                    //                                           // context
                    //                                           //     .read<
                    //                                           //         BatchBloc>()
                    //                                           //     .add(UpdateScannedValueEvent(
                    //                                           //         event
                    //                                           //             .data
                    //                                           //             .keyLabel,
                    //                                           //         'quantity'));

                    //                                           return KeyEventResult
                    //                                               .handled;
                    //                                         }
                    //                                       }
                    //                                       return KeyEventResult
                    //                                           .ignored;
                    //                                     },
                    //                                     child: Text(
                    //                                         bloc.quantitySelected
                    //                                             .toString(),
                    //                                         maxLines: 1,
                    //                                         overflow:
                    //                                             TextOverflow
                    //                                                 .ellipsis,
                    //                                         style:
                    //                                             const TextStyle(
                    //                                           color: Colors
                    //                                               .black,
                    //                                           fontSize: 14,
                    //                                         )),
                    //                                   )),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),

                    //       //teclado de la app
                    //       // Visibility(
                    //       //   // visible: bloc.viewQuantity &&
                    //       //   //     context
                    //       //   //         .read<UserBloc>()
                    //       //   //         .fabricante
                    //       //   //         .contains("Zebra"),
                    //       //   child: CustomKeyboardNumber(
                    //       //     controller: cantidadController,
                    //       //     onchanged: () {
                    //       //       // _validatebuttonquantity();
                    //       //     },
                    //       //   ),
                    //       // ),
                    //       Padding(
                    //           padding: const EdgeInsets.symmetric(
                    //               horizontal: 10, vertical: 0),
                    //           child: ElevatedButton(
                    //             onPressed: bloc.quantityIsOk &&
                    //                     bloc.quantitySelected >= 0
                    //                 ? () {
                    //                     //cerramos el teclado
                    //                     // FocusScope.of(context).unfocus();
                    //                     // _validatebuttonquantity();
                    //                   }
                    //                 : null,
                    //             style: ElevatedButton.styleFrom(
                    //               backgroundColor: primaryColorApp,
                    //               minimumSize: Size(size.width * 0.93, 30),
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //               ),
                    //             ),
                    //             child: const Text(
                    //               'ACTUALIZAR INVENTARIO',
                    //               style: TextStyle(
                    //                   color: Colors.white, fontSize: 14),
                    //             ),
                    //           )),

                    //     ],
                    //   ),

                    // ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
