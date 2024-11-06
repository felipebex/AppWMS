// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/progressIndicatos_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class PackingScreen extends StatefulWidget {
  const PackingScreen({super.key});

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();

  bool viewQuantity = false;

  String? selectedLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // if (!context.read<BatchBloc>().locationIsOk) {
    FocusScope.of(context).requestFocus(focusNode1);
    // } else {
    //   FocusScope.of(context).requestFocus(focusNode2);
    // }
  }

  @override
  void dispose() {
    focusNode4.dispose(); // Limpiar el FocusNode
    super.dispose();
  }

  TextEditingController cantidadController = TextEditingController();
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocConsumer<WmsPackingBloc, WmsPackingState>(
      listener: (context, state) {},
      builder: (context, state) {
        int completedTasks = context.read<WmsPackingBloc>().index;
        int totalTasks =
            // context.read<WmsPackingBloc>().listProductPacking.length ;
            10;
        double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

        final packinghBloc = context.read<WmsPackingBloc>();

        // final currentProduct =
        //     packinghBloc.listProductPacking[packinghBloc.index];

        return Scaffold(
            body: Column(
          children: [
            //*barra de informacion
            Container(
              padding: const EdgeInsets.only(top: 30),
              width: size.width,
              height: 120,
              color: primaryColorApp,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context
                              .read<WmsPackingBloc>()
                              .add(ChangeLocationIsOkEvent(false));
                          context
                              .read<WmsPackingBloc>()
                              .add(ChangeProductIsOkEvent(false));
                          context.read<WmsPackingBloc>().index = 0;
                          context.read<WmsPackingBloc>().oldLocation = '';
                          context
                              .read<WmsPackingBloc>()
                              .add(ChangeLocationDestIsOkEvent(false));
                          context
                              .read<WmsPackingBloc>()
                              .add(ChangeIsOkQuantity(false));
                          context.read<WmsPackingBloc>().completedProducts = 0;
                          quantity = 0;
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 30),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context
                                  .read<WmsPackingBloc>()
                                  .batchWithProducts
                                  .batch
                                  ?.name ??
                              '',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  ProgressIndicatorWidget(
                    progress: progress,
                    completed: completedTasks,
                    total: totalTasks,
                  ),
                ],
              ),
            ),
            //* todo ubicacion
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                              color: packinghBloc.locationIsOk
                                  ? Colors.green[100]
                                  : Colors.grey[300],
                              elevation: 5,
                              child: Container(
                                width: size.width * 0.85,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Focus(
                                  focusNode: focusNode1,
                                  onKey: (FocusNode node, RawKeyEvent event) {
                                    if (event is RawKeyDownEvent) {
                                      if (event.logicalKey ==
                                          LogicalKeyboardKey.enter) {
                                        if (scannedValue1.isNotEmpty) {
                                       
                                          // //todo? aca es donde validamos la entrada con la ubicacion del producto
                                          // if (scannedValue1.toLowerCase() ==
                                          //     currentProduct.locationDestId[1]
                                          //         .toLowerCase()) {
                                          //   packinghBloc.add(
                                          //       ChangeLocationIsOkEvent(true));
                                          //   packinghBloc.oldLocation =
                                          //       currentProduct.locationDestId[1];
                                          //   Future.delayed(
                                          //       const Duration(seconds: 1), () {
                                          //     FocusScope.of(context)
                                          //         .requestFocus(focusNode2);
                                          //   });
                                          // } else {
                                          //   setState(() {
                                          //     scannedValue1 =
                                          //         ""; //limpiamos el valor escaneado
                                          //   });
                                          //   ScaffoldMessenger.of(context)
                                          //       .showSnackBar(SnackBar(
                                          //     duration: const Duration(
                                          //         milliseconds: 1000),
                                          //     content:
                                          //         const Text('Codigo erroneo'),
                                          //     backgroundColor: Colors.red[200],
                                          //   ));
                                          // }
                                        }

                                        return KeyEventResult.handled;
                                      } else {
                                        setState(() {
                                          scannedValue1 += event.data.keyLabel;
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
                                        Center(
                                          child: DropdownButton<String>(
                                            underline: Container(
                                              height: 0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            focusColor: Colors.white,
                                            isExpanded: true,
                                            hint: const Text(
                                              'Ubicación de origen',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: primaryColorApp),
                                            ),
                                            icon: Image.asset(
                                              "assets/icons/ubicacion.png",
                                              color: primaryColorApp,
                                              width: 24,
                                            ),
                                            value: selectedLocation,
                                            items: packinghBloc.positions
                                                .map((String location) {
                                              return DropdownMenuItem<String>(
                                                value: location,
                                                child: Text(location),
                                              );
                                            }).toList(),
                                            onChanged: packinghBloc.locationIsOk
                                                ? null
                                                : (String? newValue) {
                                                    // if (newValue ==
                                                    //     currentProduct
                                                    //         .locationDestId[1]) {
                                                    //   packinghBloc.add(
                                                    //       ChangeLocationIsOkEvent(
                                                    //           true));
                                                    //   packinghBloc.oldLocation =
                                                    //       currentProduct
                                                    //           .locationDestId[1];
                                                    //   Future.delayed(
                                                    //       const Duration(
                                                    //           seconds: 1), () {
                                                    //     FocusScope.of(context)
                                                    //         .requestFocus(
                                                    //             focusNode2);
                                                    //   });

                                                      
                                                    // } else {
                                                    // }
                                                  },
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              Text(
                                                // currentProduct.locationDestId[1] ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 16, color: black),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                    ),
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
                                  color:
                                      packinghBloc.productIsOk ? green : yellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Card(
                              color: packinghBloc.productIsOk
                                  ? Colors.green[100]
                                  : Colors.grey[300],
                              elevation: 5,
                              child: Container(
                                width: size.width * 0.85,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Focus(
                                  focusNode: focusNode2,
                                  onKey: (FocusNode node, RawKeyEvent event) {
                                    if (event is RawKeyDownEvent) {
                                      if (event.logicalKey ==
                                          LogicalKeyboardKey.enter) {
                                        if (scannedValue2.isNotEmpty) {
                                          if (scannedValue2.isNotEmpty) {
                                            // if (scannedValue2.toLowerCase() ==
                                            //     packinghBloc.product.barcode
                                            //         ?.toLowerCase()) {
                                            //   quantity = quantity + 1;
                                            //   packinghBloc.add(
                                            //       ChangeProductIsOkEvent(true));
                                            //   packinghBloc.add(
                                            //       ChangeIsOkQuantity(true));
                                            //   Future.delayed(
                                            //       const Duration(
                                            //           milliseconds: 100), () {
                                            //     FocusScope.of(context)
                                            //         .requestFocus(focusNode3);
                                            //   });
                                            // } else {
                                            //   setState(() {
                                            //     scannedValue2 =
                                            //         ""; //limpiamos el valor escaneado
                                            //   });
                                            //   //mostramos alerta de error
                                            //   ScaffoldMessenger.of(context)
                                            //       .showSnackBar(SnackBar(
                                            //     duration: const Duration(
                                            //         milliseconds: 1000),
                                            //     content: const Text(
                                            //         'Codigo erroneo'),
                                            //     backgroundColor:
                                            //         Colors.red[200],
                                            //   ));
                                            // }
                                          }

                                          return KeyEventResult.handled;
                                        }

                                        return KeyEventResult.handled;
                                      } else {
                                        setState(() {
                                          scannedValue2 += event.data.keyLabel;
                                        });
                                        return KeyEventResult.handled;
                                      }
                                    }
                                    return KeyEventResult.ignored;
                                  },
                                  child: Center(
                                  //   child: Column(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.center,
                                  //     children: [
                                  //       Center(
                                  //         child: DropdownButton<String>(
                                  //           underline: Container(
                                  //             height: 0,
                                  //           ),
                                  //           borderRadius:
                                  //               BorderRadius.circular(10),
                                  //           focusColor: Colors.white,
                                  //           isExpanded: true,
                                  //           hint: const Text(
                                  //             'Producto',
                                  //             style: TextStyle(
                                  //                 fontSize: 16,
                                  //                 color: primaryColorApp),
                                  //           ),
                                  //           icon: Image.asset(
                                  //             "assets/icons/producto.png",
                                  //             color: primaryColorApp,
                                  //             width: 24,
                                  //           ),
                                  //           value: selectedLocation,
                                  //           // items: batchBloc.positions
                                  //           items: packinghBloc
                                  //               .batchWithProducts.products
                                  //               ?.map((ProductsBatch product) {
                                  //             return DropdownMenuItem<String>(
                                  //               value: product.productId
                                  //                   .toString(),
                                  //               child: Text(product.productId
                                  //                   .toString()),
                                  //             );
                                  //           }).toList(),

                                  //           onChanged: !packinghBloc
                                  //                   .locationIsOk
                                  //               ? null
                                  //               : (String? newValue) {
                                  //                   if (newValue ==
                                  //                       currentProduct
                                  //                           .productId) {
                                  //                     quantity = quantity + 1;
                                  //                     packinghBloc.add(
                                  //                         ChangeProductIsOkEvent(
                                  //                             true));
                                  //                     packinghBloc.add(
                                  //                         ChangeIsOkQuantity(
                                  //                             true));
                                  //                     Future.delayed(
                                  //                         const Duration(
                                  //                             milliseconds:
                                  //                                 100), () {
                                  //                       FocusScope.of(context)
                                  //                           .requestFocus(
                                  //                               focusNode3);
                                  //                     });
                                  //                   } else {}
                                  //                 },
                                  //         ),
                                  //       ),
                                  //       const SizedBox(height: 10),
                                  //       Align(
                                  //         alignment: Alignment.centerLeft,
                                  //         child: Text(
                                  //           currentProduct.productId
                                  //                   .toString() ,
                                  //           style: const TextStyle(
                                  //               fontSize: 16, color: black),
                                  //         ),
                                  //       ),

                                  //       const SizedBox(height: 10),
                                  //       // informacion del lote:
                                  //       // if (batchBloc.product.tracking ==
                                  //       //         'lot' ||
                                  //       //     batchBloc.product.tracking ==
                                  //       //         'serial')
                                  //       //   const Column(
                                  //       //     children: [
                                  //       //       Align(
                                  //       //         alignment: Alignment.centerLeft,
                                  //       //         child: Text(
                                  //       //           'Lote/Numero de serie ',
                                  //       //           style: TextStyle(
                                  //       //               fontSize: 16,
                                  //       //               color: primaryColorApp),
                                  //       //         ),
                                  //       //       ),
                                  //       //       Align(
                                  //       //         alignment: Alignment.centerLeft,
                                  //       //         child: Text(
                                  //       //           "",
                                  //       //           style: TextStyle(
                                  //       //               fontSize: 16,
                                  //       //               color: black),
                                  //       //         ),
                                  //       //       ),
                                  //       //     ],
                                  //       //   ),
                                  //     ],
                                  //   ),
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
          ],
        ));
      },
    );
  }
}
