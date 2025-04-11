// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get/get.dart';
// import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
// import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
// import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
// import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
// import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
// import 'package:wms_app/src/presentation/views/transferencias/transfer-externa/bloc/transfer_externa_bloc.dart';
// import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
// import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
// import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/expiredate_widget.dart';
// import 'package:wms_app/src/utils/constans/colors.dart';

// class TransferExternaScreen extends StatefulWidget {
//   const TransferExternaScreen({super.key});

//   @override
//   State<TransferExternaScreen> createState() => _TransferExternaScreenState();
// }

// class _TransferExternaScreenState extends State<TransferExternaScreen>
//     with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     // Añadimos el observer para escuchar el ciclo de vida de la app.
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     if (state == AppLifecycleState.resumed) {
//       if (mounted) {
//         // Aquí se ejecutan las acciones solo si la pantalla aún está montada
//         showDialog(
//           context: context,
//           builder: (context) {
//             return const DialogLoading(
//               message: "Espere un momento...",
//             );
//           },
//         );
//         Future.delayed(const Duration(seconds: 1), () {
//           Navigator.pop(context);
//         });
//       }
//     }
//   }

// //focus para escanear

//   FocusNode focusNode1 = FocusNode(); // location
//   FocusNode focusNode2 = FocusNode(); // producto
//   FocusNode focusNode3 = FocusNode(); // cantidad por pda
//   FocusNode focusNode4 = FocusNode(); //cantidad textformfieldƒ
//   FocusNode focusNode5 = FocusNode(); //location dest

//   String? selectedLocation;
//   String? selectedMuelle;

//   //controller
//   final TextEditingController _controllerLocation = TextEditingController();
//   final TextEditingController _controllerLocationDest = TextEditingController();
//   final TextEditingController _controllerProduct = TextEditingController();
//   final TextEditingController _controllerQuantity = TextEditingController();
//   final TextEditingController _cantidadController = TextEditingController();

//   @override
//   void dispose() {
//     focusNode1.dispose(); //product
//     focusNode2.dispose(); //product
//     focusNode3.dispose(); //quantity
//     focusNode4.dispose(); //quantity
//     focusNode5.dispose(); //quantity
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _handleDependencies();
//   }

//   void _handleDependencies() {
//     final batchBloc = context.read<TransferExternaBloc>();

//     if (!batchBloc.locationIsOk && //false
//             !batchBloc.productIsOk && //false
//             !batchBloc.quantityIsOk //false
//         ) {
//       print("🚼 location");
//       FocusScope.of(context).requestFocus(focusNode1);
//       //cerramos los demas focos
//       focusNode2.unfocus();
//       focusNode3.unfocus();
//       focusNode4.unfocus();
//     }
//     if (batchBloc.locationIsOk && //true
//         !batchBloc.productIsOk && //false
//         !batchBloc.quantityIsOk) //false
//     {
//       print("🚼 product");
//       FocusScope.of(context).requestFocus(focusNode2);
//       //cerramos los demas focos
//       focusNode1.unfocus();
//       focusNode3.unfocus();
//       focusNode4.unfocus();
//     }
//     if (batchBloc.locationIsOk && //true
//         batchBloc.productIsOk && //true
//         batchBloc.quantityIsOk && //true
//         !batchBloc.viewQuantity) //false
//     {
//       print("🚼 quantity");
//       FocusScope.of(context).requestFocus(focusNode3);
//       //cerramos los demas focos
//       focusNode1.unfocus();
//       focusNode2.unfocus();
//       focusNode4.unfocus();
//     }
//   }

//   void validateLocation(String value) {
//     final bloc = context.read<TransferExternaBloc>();

//     String scan = bloc.scannedValue1.toLowerCase() == ""
//         ? value.toLowerCase()
//         : bloc.scannedValue1.toLowerCase();

//     _controllerLocation.text = "";

//     ResultUbicaciones? matchedUbicacion = bloc.ubicaciones.firstWhere(
//         (ubicacion) => ubicacion.barcode?.toLowerCase() == scan,
//         orElse: () =>
//             ResultUbicaciones() // Si no se encuentra ningún match, devuelve null
//         );

//     if (matchedUbicacion.barcode != null) {
//       print('Ubicacion encontrada: ${matchedUbicacion.name}');
//       bloc.add(ValidateFieldsEvent(field: "location", isOk: true));
//       bloc.add(ChangeLocationIsOkEvent(matchedUbicacion));
//       bloc.add(ClearScannedValueEvent('location'));
//     } else {
//       print('Ubicacion no encontrada');
//       bloc.add(ValidateFieldsEvent(field: "location", isOk: false));
//       bloc.add(ClearScannedValueEvent('location'));
//     }
//   }

//   void validateProduct(String value) {
//     final bloc = context.read<TransferExternaBloc>();

//     // String scan = bloc.scannedValue2.toLowerCase() == ""
//     //     ? value.toLowerCase()
//     //     : bloc.scannedValue2.toLowerCase();

//     // _controllerProduct.text = "";

//     // Product? matchedProductUbicacion = bloc.productosUbicacion.firstWhere(
//     //     (productoUbi) => productoUbi.barcode?.toLowerCase() == scan,
//     //     orElse: () =>
//     //         Product() // Si no se encuentra ningún match, devuelve null
//     //     );

//     // if (matchedProductUbicacion.barcode != null) {
//     //   print('producto encontrado: ${matchedProductUbicacion.productName}');
//     //   bloc.add(ValidateFieldsEvent(field: "product", isOk: true));
//     //   bloc.add(ChangeProductIsOkEvent(matchedProductUbicacion));
//     //   bloc.add(ChangeIsOkQuantity(true));
//     //   bloc.add(ClearScannedValueEvent('product'));
//     // } else {
//     //   print('producto no econtrado en la ubicacion');

//     //   Product? matchedProducts = bloc.productos.firstWhere(
//     //     (producto) {
//     //       // Verifica si barcode no es nulo y es un String
//     //       if (producto.barcode is String) {
//     //         return producto.barcode!.toLowerCase() == scan.toLowerCase();
//     //       }
//     //       return false; // Si no es un String, no hacer el match
//     //     },
//     //     orElse: () =>
//     //         Product(), // Si no se encuentra ningún match, devuelve un Product vacío
//     //   );

//     //   if (matchedProducts.barcode != null) {
//     //     bloc.add(ClearScannedValueEvent('product'));

//     //     Get.defaultDialog(
//     //       title: '360 Software Informa',
//     //       titleStyle: TextStyle(color: Colors.amber, fontSize: 16),
//     //       // middleText:
//     //       //     'El producto  ${matchedProducts.productName} registra existencias en la ubicacion ${matchedProducts.locationName}',
//     //       // middleTextStyle: TextStyle(color: black, fontSize: 14),
//     //       content: Padding(
//     //         padding: const EdgeInsets.all(8.0),
//     //         child: Column(
//     //           children: [
//     //             RichText(
//     //                 text: TextSpan(
//     //               text: 'El producto  ',
//     //               style: TextStyle(color: black, fontSize: 14),
//     //               children: <TextSpan>[
//     //                 TextSpan(
//     //                   text: '${matchedProducts.productName} ',
//     //                   style: TextStyle(
//     //                     color: primaryColorApp,
//     //                     fontSize: 14,
//     //                   ),
//     //                 ),
//     //                 TextSpan(
//     //                   text: 'registra existencias en la ubicacion ',
//     //                   style: TextStyle(color: black, fontSize: 14),
//     //                 ),
//     //                 TextSpan(
//     //                   text: '${matchedProducts.locationName}',
//     //                   style: TextStyle(color: primaryColorApp, fontSize: 14),
//     //                 ),
//     //               ],
//     //             )),
//     //             const SizedBox(
//     //               height: 20,
//     //             ),
//     //             RichText(
//     //                 text: TextSpan(
//     //               text: 'Desea registrarlo en la ubicacion ',
//     //               style: TextStyle(color: black, fontSize: 14),
//     //               children: <TextSpan>[
//     //                 TextSpan(
//     //                   text: '${bloc.currentUbication?.name} ',
//     //                   style: TextStyle(
//     //                     color: primaryColorApp,
//     //                     fontSize: 14,
//     //                   ),
//     //                 ),
//     //                 TextSpan(
//     //                   text: '?',
//     //                   style: TextStyle(color: black, fontSize: 14),
//     //                 ),
//     //               ],
//     //             )),
//     //           ],
//     //         ),
//     //       ),
//     //       backgroundColor: Colors.white,
//     //       radius: 10,
//     //       actions: [
//     //         ElevatedButton(
//     //           onPressed: () {
//     //             bloc.add(ClearScannedValueEvent('product'));
//     //             Get.back();
//     //           },
//     //           style: ElevatedButton.styleFrom(
//     //             backgroundColor: grey,
//     //             shape: RoundedRectangleBorder(
//     //               borderRadius: BorderRadius.circular(10),
//     //             ),
//     //           ),
//     //           child: Text('Cancelar', style: TextStyle(color: white)),
//     //         ),
//     //         ElevatedButton(
//     //           onPressed: () {
//     //             bloc.add(ValidateFieldsEvent(field: "product", isOk: true));
//     //             bloc.add(ChangeProductIsOkEvent(matchedProducts));
//     //             bloc.add(ChangeIsOkQuantity(true));
//     //             bloc.add(ClearScannedValueEvent('product'));
//     //             Get.back();
//     //           },
//     //           style: ElevatedButton.styleFrom(
//     //             backgroundColor: primaryColorApp,
//     //             shape: RoundedRectangleBorder(
//     //               borderRadius: BorderRadius.circular(10),
//     //             ),
//     //           ),
//     //           child: Text('Aceptar', style: TextStyle(color: white)),
//     //         ),
//     //       ],
//     //     );
//     //   } else {
//     //     print('producto encontrado: ${matchedProducts.productName}');
//     //     bloc.add(ValidateFieldsEvent(field: "product", isOk: false));
//     //     bloc.add(ClearScannedValueEvent('product'));
//     //   }
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.sizeOf(context);

//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: BlocConsumer<TransferExternaBloc, TransferExternaState>(
//         listener: (context, state) {},
//         builder: (context, state) {
//           final bloc = context.read<TransferExternaBloc>();
//           return Scaffold(
//             backgroundColor: white,
//             body: SizedBox(
//                 width: size.width * 1,
//                 height: size.height * 1,
//                 child: Column(children: [
//                   //apbar

//                   Container(
//                     padding: const EdgeInsets.only(top: 20),
//                     decoration: BoxDecoration(
//                       color: primaryColorApp,
//                       borderRadius: const BorderRadius.only(
//                         bottomLeft: Radius.circular(20),
//                         bottomRight: Radius.circular(20),
//                       ),
//                     ),
//                     width: double.infinity,
//                     child: BlocProvider(
//                       create: (context) => ConnectionStatusCubit(),
//                       child: BlocConsumer<TransferExternaBloc,
//                               TransferExternaState>(
//                           listener: (context, state) {},
//                           builder: (context, status) {
//                             return Column(
//                               children: [
//                                 const WarningWidgetCubit(),
//                                 Padding(
//                                   padding: EdgeInsets.only(
//                                       // bottom: 5,
//                                       top: status != ConnectionStatus.online
//                                           ? 0
//                                           : 35),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       IconButton(
//                                         icon: const Icon(Icons.arrow_back,
//                                             color: white),
//                                         onPressed: () {
//                                           Navigator.pushReplacementNamed(
//                                             context,
//                                             'transferencias',
//                                           );
//                                         },
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             left: size.width * 0.07),
//                                         child: Text('TRANSFERENCIA EXTERNA',
//                                             style: TextStyle(
//                                                 color: white, fontSize: 18)),
//                                       ),
//                                       const Spacer(),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             );
//                           }),
//                     ),
//                   ),

//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.only(top: 2),
//                       child: SingleChildScrollView(
//                         child: Column(children: [
//                           const SizedBox(height: 10),
//                           //todo : ubicacion de origen
//                           Row(
//                             children: [
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 10),
//                                 child: Container(
//                                   width: 10,
//                                   height: 10,
//                                   decoration: BoxDecoration(
//                                     color: bloc.locationIsOk ? green : yellow,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                               ),
//                               Card(
//                                 color: bloc.isLocationOk
//                                     ? bloc.locationIsOk
//                                         ? Colors.green[100]
//                                         : Colors.grey[300]
//                                     : Colors.red[200],
//                                 elevation: 5,
//                                 child: Container(
//                                   // color: Colors.amber,
//                                   width: size.width * 0.85,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 2),
//                                   child: context
//                                           .read<UserBloc>()
//                                           .fabricante
//                                           .contains("Zebra")
//                                       ? Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Column(
//                                             children: [
//                                               GestureDetector(
//                                                 onTap: !bloc
//                                                             .locationIsOk && //false
//                                                         !bloc
//                                                             .productIsOk && //false
//                                                         !bloc.quantityIsOk
//                                                     ? () {
//                                                         Navigator
//                                                             .pushReplacementNamed(
//                                                           context,
//                                                           'search-location',
//                                                         );
//                                                       }
//                                                     : null,
//                                                 child: Row(
//                                                   children: [
//                                                     Align(
//                                                       alignment:
//                                                           Alignment.centerLeft,
//                                                       child: Text(
//                                                         'Ubicación de existencias',
//                                                         style: TextStyle(
//                                                           fontSize: 15,
//                                                           color:
//                                                               primaryColorApp,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     Spacer(),
//                                                     Image.asset(
//                                                       "assets/icons/ubicacion.png",
//                                                       color: primaryColorApp,
//                                                       width: 20,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               Container(
//                                                 height: 15,
//                                                 margin: const EdgeInsets.only(
//                                                     bottom: 5, top: 5),
//                                                 child: TextFormField(
//                                                   autofocus: true,
//                                                   showCursor: false,
//                                                   controller:
//                                                       _controllerLocation, // Asignamos el controlador
//                                                   enabled: !bloc
//                                                           .locationIsOk && // false
//                                                       !bloc
//                                                           .productIsOk && // false
//                                                       !bloc.quantityIsOk,

//                                                   focusNode: focusNode1,
//                                                   onChanged: (value) {
//                                                     // Llamamos a la validación al cambiar el texto
//                                                     validateLocation(value);
//                                                   },
//                                                   decoration: InputDecoration(
//                                                     hintText: bloc.currentUbication
//                                                                     ?.name ==
//                                                                 "" ||
//                                                             bloc.currentUbication
//                                                                     ?.name ==
//                                                                 null
//                                                         ? 'Esperando escaneo'
//                                                         : bloc.currentUbication
//                                                             ?.name,
//                                                     disabledBorder:
//                                                         InputBorder.none,
//                                                     hintStyle: const TextStyle(
//                                                         fontSize: 14,
//                                                         color: black),
//                                                     border: InputBorder.none,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         )
//                                       : Focus(
//                                           focusNode: focusNode1,
//                                           onKey: (FocusNode node,
//                                               RawKeyEvent event) {
//                                             if (event is RawKeyDownEvent) {
//                                               if (event.logicalKey ==
//                                                   LogicalKeyboardKey.enter) {
//                                                 validateLocation(
//                                                     //validamos la ubicacion
//                                                     bloc.scannedValue1);

//                                                 return KeyEventResult.handled;
//                                               } else {
//                                                 bloc.add(
//                                                     UpdateScannedValueEvent(
//                                                         event.data.keyLabel,
//                                                         'location'));

//                                                 return KeyEventResult.handled;
//                                               }
//                                             }
//                                             return KeyEventResult.ignored;
//                                           },
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Column(
//                                               children: [
//                                                 GestureDetector(
//                                                   onTap: !bloc
//                                                               .locationIsOk && //false
//                                                           !bloc
//                                                               .productIsOk && //false
//                                                           !bloc.quantityIsOk
//                                                       ? () {
//                                                           Navigator
//                                                               .pushReplacementNamed(
//                                                             context,
//                                                             'search-location',
//                                                           );
//                                                         }
//                                                       : null,
//                                                   child: Row(
//                                                     children: [
//                                                       Align(
//                                                         alignment: Alignment
//                                                             .centerLeft,
//                                                         child: Text(
//                                                           'Ubicación de existencias',
//                                                           style: TextStyle(
//                                                             fontSize: 15,
//                                                             color:
//                                                                 primaryColorApp,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Spacer(),
//                                                       Image.asset(
//                                                         "assets/icons/ubicacion.png",
//                                                         color: primaryColorApp,
//                                                         width: 20,
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 Align(
//                                                     alignment:
//                                                         Alignment.centerLeft,
//                                                     child: Text(
//                                                       bloc.currentUbication
//                                                                       ?.name ==
//                                                                   "" ||
//                                                               bloc.currentUbication
//                                                                       ?.name ==
//                                                                   null
//                                                           ? 'Esperando escaneo'
//                                                           : bloc.currentUbication
//                                                                   ?.name ??
//                                                               "",
//                                                       style: TextStyle(
//                                                           color: black,
//                                                           fontSize: 14),
//                                                     ))
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 5),
//                           Row(
//                             children: [
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 10),
//                                 child: Container(
//                                   width: 10,
//                                   height: 10,
//                                   decoration: BoxDecoration(
//                                     color: bloc.productIsOk ? green : yellow,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                               ),
//                               Card(
//                                 color: bloc.isProductOk
//                                     ? bloc.productIsOk
//                                         ? Colors.green[100]
//                                         : Colors.grey[300]
//                                     : Colors.red[200],
//                                 elevation: 5,
//                                 child: Container(
//                                   // color: Colors.amber,
//                                   width: size.width * 0.85,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 2),
//                                   child: context
//                                           .read<UserBloc>()
//                                           .fabricante
//                                           .contains("Zebra")
//                                       ? Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Column(
//                                             children: [
//                                               GestureDetector(
//                                                 onTap: bloc.locationIsOk && //true
//                                                         !bloc.productIsOk && //false
//                                                         !bloc.quantityIsOk
//                                                     ? () {
//                                                         Navigator
//                                                             .pushReplacementNamed(
//                                                           context,
//                                                           'search-product',
//                                                         );
//                                                       }
//                                                     : null,
//                                                 child: Row(
//                                                   children: [
//                                                     Align(
//                                                       alignment:
//                                                           Alignment.centerLeft,
//                                                       child: Text(
//                                                         'Producto',
//                                                         style: TextStyle(
//                                                             fontSize: 14,
//                                                             color:
//                                                                 primaryColorApp),
//                                                       ),
//                                                     ),
//                                                     Spacer(),
//                                                     Image.asset(
//                                                       "assets/icons/producto.png",
//                                                       color: primaryColorApp,
//                                                       width: 20,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               Container(
//                                                 height: 15,
//                                                 margin: const EdgeInsets.only(
//                                                     bottom: 5, top: 5),
//                                                 child: TextFormField(
//                                                   autofocus: true,
//                                                   showCursor: false,
//                                                   controller:
//                                                       _controllerProduct, // Asignamos el controlador
//                                                   enabled: bloc
//                                                           .locationIsOk && // false
//                                                       !bloc
//                                                           .productIsOk && // false
//                                                       !bloc.quantityIsOk,

//                                                   focusNode: focusNode2,
//                                                   onChanged: (value) {
//                                                     // Llamamos a la validación al cambiar el texto
//                                                     validateProduct(value);
//                                                   },
//                                                   decoration: InputDecoration(
//                                                     hintText: bloc.currentProduct
//                                                                     ?.productName ==
//                                                                 "" ||
//                                                             bloc.currentProduct
//                                                                     ?.productName ==
//                                                                 null
//                                                         ? 'Esperando escaneo'
//                                                         : bloc.currentProduct
//                                                                 ?.productName ??
//                                                             "",
//                                                     disabledBorder:
//                                                         InputBorder.none,
//                                                     hintStyle: const TextStyle(
//                                                         fontSize: 14,
//                                                         color: black),
//                                                     border: InputBorder.none,
//                                                   ),
//                                                 ),
//                                               ),
//                                               Align(
//                                                 alignment: Alignment.centerLeft,
//                                                 child: Row(
//                                                   children: [
//                                                     Image.asset(
//                                                       "assets/icons/barcode.png",
//                                                       color: primaryColorApp,
//                                                       width: 20,
//                                                     ),
//                                                     const SizedBox(width: 10),
//                                                     Text(
//                                                       bloc.currentProduct
//                                                                       ?.barcode ==
//                                                                   false ||
//                                                               bloc.currentProduct
//                                                                       ?.barcode ==
//                                                                   null ||
//                                                               bloc.currentProduct
//                                                                       ?.barcode ==
//                                                                   ""
//                                                           ? "Sin codigo de barras"
//                                                           : bloc.currentProduct
//                                                               ?.barcode,
//                                                       textAlign:
//                                                           TextAlign.start,
//                                                       style: TextStyle(
//                                                           fontSize: 12,
//                                                           color: bloc.currentProduct
//                                                                           ?.barcode ==
//                                                                       false ||
//                                                                   bloc.currentProduct
//                                                                           ?.barcode ==
//                                                                       null ||
//                                                                   bloc.currentProduct
//                                                                           ?.barcode ==
//                                                                       ""
//                                                               ? red
//                                                               : black),
//                                                     ),
//                                                     Spacer(),
//                                                     // GestureDetector(
//                                                     //   onTap: () {
//                                                     //     showDialog(
//                                                     //         context: context,
//                                                     //         builder:
//                                                     //             (context) {
//                                                     //           return DialogBarcodesInventario(
//                                                     //               listOfBarcodes:
//                                                     //                   bloc.barcodeInventario);
//                                                     //         });
//                                                     //   },
//                                                     //   child: Visibility(
//                                                     //     visible: bloc
//                                                     //         .barcodeInventario
//                                                     //         .isNotEmpty,
//                                                     //     child: Image.asset(
//                                                     //         "assets/icons/package_barcode.png",
//                                                     //         color:
//                                                     //             primaryColorApp,
//                                                     //         width: 20),
//                                                     //   ),
//                                                     // ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               Visibility(
//                                                 visible: bloc.currentProduct
//                                                         ?.productTracking ==
//                                                     "lot",
//                                                 child: ExpiryDateWidget(
//                                                     expireDate: bloc.currentProduct
//                                                                     ?.expirationDate ==
//                                                                 "" ||
//                                                             bloc.currentProduct
//                                                                     ?.expirationDate ==
//                                                                 null
//                                                         ? DateTime.now()
//                                                         : DateTime.parse(bloc
//                                                             .currentProduct
//                                                             ?.expirationDate),
//                                                     size: size,
//                                                     isDetaild: false,
//                                                     isNoExpireDate: bloc
//                                                                 .currentProduct
//                                                                 ?.expirationDate ==
//                                                             ""
//                                                         ? true
//                                                         : false),
//                                               ),
//                                             ],
//                                           ),
//                                         )
//                                       : Focus(
//                                           focusNode: focusNode2,
//                                           onKey: (FocusNode node,
//                                               RawKeyEvent event) {
//                                             if (event is RawKeyDownEvent) {
//                                               if (event.logicalKey ==
//                                                   LogicalKeyboardKey.enter) {
//                                                 validateProduct(
//                                                     bloc.scannedValue2);

//                                                 return KeyEventResult.handled;
//                                               } else {
//                                                 bloc.add(
//                                                     UpdateScannedValueEvent(
//                                                         event.data.keyLabel,
//                                                         'product'));

//                                                 return KeyEventResult.handled;
//                                               }
//                                             }
//                                             return KeyEventResult.ignored;
//                                           },
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Column(
//                                               children: [
//                                                 GestureDetector(
//                                                   onTap: bloc.locationIsOk && //true
//                                                           !bloc.productIsOk && //false
//                                                           !bloc.quantityIsOk
//                                                       ? () {
//                                                           Navigator
//                                                               .pushReplacementNamed(
//                                                             context,
//                                                             'search-product',
//                                                           );
//                                                         }
//                                                       : null,
//                                                   child: Row(
//                                                     children: [
//                                                       Align(
//                                                         alignment: Alignment
//                                                             .centerLeft,
//                                                         child: Text(
//                                                           'Producto',
//                                                           style: TextStyle(
//                                                               fontSize: 14,
//                                                               color:
//                                                                   primaryColorApp),
//                                                         ),
//                                                       ),
//                                                       Spacer(),
//                                                       Image.asset(
//                                                         "assets/icons/producto.png",
//                                                         color: primaryColorApp,
//                                                         width: 20,
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 Align(
//                                                   alignment:
//                                                       Alignment.centerLeft,
//                                                   child: Text(
//                                                     bloc.currentProduct
//                                                                     ?.productName ==
//                                                                 "" ||
//                                                             bloc.currentProduct
//                                                                     ?.productName ==
//                                                                 null
//                                                         ? 'Esperando escaneo'
//                                                         : bloc.currentProduct
//                                                                 ?.productName ??
//                                                             "",
//                                                     style: TextStyle(
//                                                         color: black,
//                                                         fontSize: 14),
//                                                   ),
//                                                 ),
//                                                 Align(
//                                                   alignment:
//                                                       Alignment.centerLeft,
//                                                   child: Row(
//                                                     children: [
//                                                       Image.asset(
//                                                         "assets/icons/barcode.png",
//                                                         color: primaryColorApp,
//                                                         width: 20,
//                                                       ),
//                                                       const SizedBox(width: 10),
//                                                       Text(
//                                                         bloc.currentProduct?.barcode ==
//                                                                     false ||
//                                                                 bloc.currentProduct
//                                                                         ?.barcode ==
//                                                                     null ||
//                                                                 bloc.currentProduct
//                                                                         ?.barcode ==
//                                                                     ""
//                                                             ? "Sin codigo de barras"
//                                                             : bloc
//                                                                 .currentProduct
//                                                                 ?.barcode,
//                                                         textAlign:
//                                                             TextAlign.start,
//                                                         style: TextStyle(
//                                                             fontSize: 12,
//                                                             color: bloc.currentProduct
//                                                                             ?.barcode ==
//                                                                         false ||
//                                                                     bloc.currentProduct
//                                                                             ?.barcode ==
//                                                                         null ||
//                                                                     bloc.currentProduct
//                                                                             ?.barcode ==
//                                                                         ""
//                                                                 ? red
//                                                                 : black),
//                                                       ),
//                                                       Spacer(),
//                                                       // GestureDetector(
//                                                       //   onTap: () {
//                                                       //     showDialog(
//                                                       //         context:
//                                                       //             context,
//                                                       //         builder:
//                                                       //             (context) {
//                                                       //           return DialogBarcodesInventario(
//                                                       //               listOfBarcodes:
//                                                       //                   bloc.barcodeInventario);
//                                                       //         });
//                                                       //   },
//                                                       //   child: Visibility(
//                                                       //     visible: bloc
//                                                       //         .barcodeInventario
//                                                       //         .isNotEmpty,
//                                                       //     child: Image.asset(
//                                                       //         "assets/icons/package_barcode.png",
//                                                       //         color:
//                                                       //             primaryColorApp,
//                                                       //         width: 20),
//                                                       //   ),
//                                                       // ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 Visibility(
//                                                   visible: bloc.currentProduct
//                                                           ?.productTracking ==
//                                                       "lot",
//                                                   child: ExpiryDateWidget(
//                                                       expireDate: bloc.currentProduct
//                                                                       ?.expirationDate ==
//                                                                   "" ||
//                                                               bloc.currentProduct
//                                                                       ?.expirationDate ==
//                                                                   null
//                                                           ? DateTime.now()
//                                                           : DateTime.parse(bloc
//                                                               .currentProduct
//                                                               ?.expirationDate),
//                                                       size: size,
//                                                       isDetaild: false,
//                                                       isNoExpireDate: bloc
//                                                                   .currentProduct
//                                                                   ?.expirationDate ==
//                                                               ""
//                                                           ? true
//                                                           : false),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ]),
//                       ),
//                     ),
//                   ),
//                 ])),
//           );
//         },
//       ),
//     );
//   }
// }
