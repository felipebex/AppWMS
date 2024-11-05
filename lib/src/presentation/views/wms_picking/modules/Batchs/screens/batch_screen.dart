// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print, unused_element, sort_child_properties_last

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/dropdowbutton_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/progressIndicatos_widget.dart';
import 'package:wms_app/src/presentation/widgets/appbar.dart';
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

  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfield
  FocusNode focusNode5 = FocusNode(); //cantidad textformfield

  String? selectedLocation;
  String? selectedMuelle;

  bool viewQuantity = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!context.read<BatchBloc>().locationIsOk) {
      FocusScope.of(context).requestFocus(focusNode1);
    }
    if (!context.read<BatchBloc>().productIsOk) {
      FocusScope.of(context).requestFocus(focusNode2);
    }
    if (!context.read<BatchBloc>().quantityIsOk) {
      FocusScope.of(context).requestFocus(focusNode3);
    }
    if (!context.read<BatchBloc>().locationDestIsOk) {
      FocusScope.of(context).requestFocus(focusNode5);
    }
  }

  @override
  void dispose() {
    focusNode4.dispose(); // Limpiar el FocusNode
    super.dispose();
  }

  TextEditingController cantidadController = TextEditingController();
  // int quantity = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocBuilder<BatchBloc, BatchState>(builder: (context, state) {
        int totalTasks =
            context.read<BatchBloc>().batchWithProducts.products?.length ?? 0;

        double progress = totalTasks > 0
            ? context.read<BatchBloc>().completedProducts / totalTasks
            : 0.0;

        final batchBloc = context.read<BatchBloc>();

        if (state is EmptyroductsBatch) {
          return Scaffold(
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () {
            //     showDialog(
            //         context: context,
            //         builder: (context) {
            //           return DialogLoading();
            //         });
            //     Future.delayed(const Duration(seconds: 2), () {
            //       Navigator.pop(context);
            //     });
            //   },
            // ),
            appBar:
                AppBarGlobal(tittle: 'Detalle de Batch', actions: Container()),
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/empty.png',
                      height: 150), // Ajusta la altura según necesites
                  const SizedBox(height: 10),
                  const Text('No se encontraron resultados',
                      style: TextStyle(fontSize: 18, color: grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                          'El Batch  ${context.read<BatchBloc>().batchWithProducts.batch?.name} no tiene productos',
                          style: const TextStyle(
                              fontSize: 18, color: primaryColorApp),
                          textAlign: TextAlign.center),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        }

        // final currentProduct =
        //     batchBloc.batchWithProducts.products?[batchBloc.index];

        if (state is LoadProductsBatchSuccesStateBD ||
            state is ChangeIsOkState ||
            state is CurrentProductChangedState ||
            state is SelectNovedadState ||
            state is QuantityChangedState ||
            state is LoadDataInfoState ||
            state is ChangeQuantitySeparateState ||
            state is PickingOkState ||
            state is ValidateFieldsState) {
          final currentProduct = batchBloc.currentProduct;

          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                //todo: barra info
                Container(
                  // padding: const EdgeInsets.only(top: 30),
                  width: size.width,
                  // height: 120,
                  color: primaryColorApp,
                  child: BlocProvider(
                    create: (context) => ConnectionStatusCubit(),
                    child: BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                        builder: (context, status) {
                      return Column(
                        children: [
                          const WarningWidgetCubit(),
                          Padding(
                            padding: EdgeInsets.only(
                                top:
                                    status != ConnectionStatus.online ? 0 : 35),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.read<BatchBloc>().index = 0;
                                    context.read<BatchBloc>().quantitySelected =
                                        0;
                                    context
                                        .read<BatchBloc>()
                                        .completedProducts = 0;
                                    cantidadController.clear();
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
                                    context
                                            .read<BatchBloc>()
                                            .batchWithProducts
                                            .batch
                                            ?.name ??
                                        '',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                                const Spacer(),
                                PopupMenuButton<String>(
                                  shadowColor: Colors.white,
                                  color: Colors.white,
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.white, size: 30),
                                  onSelected: (String value) {
                                    // Manejar la selección de opciones aquí
                                    if (value == '1') {
                                      context.read<BatchBloc>().add(
                                          FetchBatchWithProductsEvent(batchBloc
                                                  .batchWithProducts
                                                  .batch
                                                  ?.id ??
                                              0));

                                      Navigator.pushNamed(
                                        context,
                                        'batch-detail',
                                      );
                                      // Acción para opción 1
                                    } else if (value == '2') {
                                      // Acción para opción 2
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 5, sigmaY: 5),
                                              child: AlertDialog(
                                                backgroundColor: Colors.white,
                                                actionsAlignment:
                                                    MainAxisAlignment.center,
                                                title: const Center(
                                                    child: Text(
                                                        'Dejar pendiente',
                                                        style: TextStyle(
                                                            color:
                                                                primaryColorApp))),
                                                content: const Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Center(
                                                      child: Text(
                                                          '¿Estás seguro de dejar pendiente este producto al final de la lista?'),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              elevation: 3),
                                                      child: const Text(
                                                          'Cancelar',
                                                          style: TextStyle(
                                                              color:
                                                                  primaryColorApp))),
                                                  ElevatedButton(
                                                      onPressed: () {},
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            primaryColorApp,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        elevation: 3,
                                                      ),
                                                      child: const Text(
                                                          'Aceptar',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ))),
                                                ],
                                              ),
                                            );
                                          });
                                    }
                                    // Agrega más opciones según sea necesario
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: '1',
                                        child: Row(
                                          children: [
                                            Icon(Icons.info,
                                                color: primaryColorApp,
                                                size: 20),
                                            SizedBox(width: 10),
                                            Text('Ver detalles'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: '2',
                                        child: Row(
                                          children: [
                                            Icon(Icons.timelapse_rounded,
                                                color: primaryColorApp,
                                                size: 20),
                                            SizedBox(width: 10),
                                            Text('Dejar pendiente'),
                                          ],
                                        ),
                                      ),
                                      // Agrega más PopupMenuItems aquí
                                    ];
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ProgressIndicatorWidget(
                              progress: progress,
                              completed: batchBloc.completedProducts,
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
                    child: Form(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
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
                                      color: batchBloc.locationIsOk
                                          ? green
                                          : yellow,
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
                                    child: Focus(
                                      focusNode: focusNode1,
                                      onKey:
                                          (FocusNode node, RawKeyEvent event) {
                                        if (event is RawKeyDownEvent) {
                                          if (event.logicalKey ==
                                              LogicalKeyboardKey.enter) {
                                            if (scannedValue1.isNotEmpty) {
                                              if (scannedValue1.toLowerCase() ==
                                                  currentProduct.locationId
                                                      .toString()
                                                      .toLowerCase()) {
                                                batchBloc.add(
                                                    ValidateFieldsEvent(
                                                        field: "location",
                                                        isOk: true));

                                                batchBloc.add(
                                                    ChangeLocationIsOkEvent(
                                                        true,
                                                        currentProduct.idProduct ??
                                                            0,
                                                        batchBloc
                                                                .batchWithProducts
                                                                .batch
                                                                ?.id ??
                                                            0,
                                                        currentProduct.idMove ??
                                                            0));

                                                batchBloc.oldLocation =
                                                    currentProduct.locationId
                                                        .toString();

                                                Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusNode2);
                                                });
                                              } else {
                                                batchBloc.add(
                                                    ValidateFieldsEvent(
                                                        field: "location",
                                                        isOk: false));
                                                setState(() {
                                                  scannedValue1 =
                                                      ""; //limpiamos el valor escaneado
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                  content: const Text(
                                                      'Ubicacion erronea'),
                                                  backgroundColor:
                                                      Colors.red[200],
                                                ));
                                              }
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
                                                items: batchBloc.positions
                                                    .map((String location) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: location,
                                                    child: Text(location),
                                                  );
                                                }).toList(),
                                                onChanged: batchBloc
                                                        .locationIsOk
                                                    ? null
                                                    : (String? newValue) {
                                                        if (newValue ==
                                                            currentProduct
                                                                .locationId
                                                                .toString()) {
                                                          batchBloc.add(
                                                              ValidateFieldsEvent(
                                                                  field:
                                                                      "location",
                                                                  isOk: true));
                                                          batchBloc.add(ChangeLocationIsOkEvent(
                                                              true,
                                                              currentProduct
                                                                      .idProduct ??
                                                                  0,
                                                              batchBloc
                                                                      .batchWithProducts
                                                                      .batch
                                                                      ?.id ??
                                                                  0,
                                                              currentProduct
                                                                      .idMove ??
                                                                  0));

                                                          batchBloc
                                                                  .oldLocation =
                                                              currentProduct
                                                                  .locationId
                                                                  .toString();
                                                          Future.delayed(
                                                              const Duration(
                                                                  seconds: 1),
                                                              () {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    focusNode2);
                                                          });
                                                        } else {
                                                          batchBloc.add(
                                                              ValidateFieldsEvent(
                                                                  field:
                                                                      "location",
                                                                  isOk: false));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        1000),
                                                            content: const Text(
                                                                'Ubicacion erronea'),
                                                            backgroundColor:
                                                                Colors.red[200],
                                                          ));
                                                        }
                                                      },
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    currentProduct.locationId,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: black),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: batchBloc.productIsOk
                                          ? green
                                          : yellow,
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
                                    child: Focus(
                                      focusNode: focusNode2,
                                      onKey:
                                          (FocusNode node, RawKeyEvent event) {
                                        if (event is RawKeyDownEvent) {
                                          if (event.logicalKey ==
                                              LogicalKeyboardKey.enter) {
                                            if (scannedValue2.isNotEmpty) {
                                              if (scannedValue2.toLowerCase() ==
                                                  batchBloc.product.barcode
                                                      ?.toLowerCase()) {
                                                batchBloc.add(
                                                    ValidateFieldsEvent(
                                                        field: "product",
                                                        isOk: true));

                                                batchBloc.add(
                                                    ChangeQuantitySeparate(
                                                        1,
                                                        currentProduct
                                                                .idProduct ??
                                                            0,
                                                        currentProduct.idMove ??
                                                            0));

                                                batchBloc.add(ChangeProductIsOkEvent(
                                                    true,
                                                    currentProduct.idProduct ??
                                                        0,
                                                    batchBloc.batchWithProducts
                                                            .batch?.id ??
                                                        0,
                                                    1,
                                                    currentProduct.idMove ??
                                                        0));

                                                batchBloc.add(ChangeIsOkQuantity(
                                                    true,
                                                    currentProduct.idProduct ??
                                                        0,
                                                    batchBloc.batchWithProducts
                                                            .batch?.id ??
                                                        0,
                                                    currentProduct.idMove ??
                                                        0));

                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 100), () {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusNode3);
                                                });
                                              } else {
                                                batchBloc.add(
                                                    ValidateFieldsEvent(
                                                        field: "product",
                                                        isOk: false));
                                                setState(() {
                                                  scannedValue2 =
                                                      ""; //limpiamos el valor escaneado
                                                });

                                                //mostramos alerta de error
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                  content: const Text(
                                                      'Producto erroneo'),
                                                  backgroundColor:
                                                      Colors.red[200],
                                                ));
                                              }
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
                                                  'Producto',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: primaryColorApp),
                                                ),
                                                icon: Image.asset(
                                                  "assets/icons/producto.png",
                                                  color: primaryColorApp,
                                                  width: 24,
                                                ),
                                                value: selectedLocation,
                                                // items: batchBloc.positions
                                                items: batchBloc
                                                    .batchWithProducts.products
                                                    ?.map((ProductsBatch
                                                        product) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: product.productId
                                                        .toString(),
                                                    child: Text(product
                                                        .productId
                                                        .toString()),
                                                  );
                                                }).toList(),

                                                onChanged: batchBloc
                                                            .locationIsOk &&
                                                        !batchBloc.productIsOk
                                                    ? (String? newValue) {
                                                        if (newValue ==
                                                            currentProduct
                                                                .productId
                                                                .toString()) {
                                                          batchBloc.add(
                                                              ValidateFieldsEvent(
                                                                  field:
                                                                      "product",
                                                                  isOk: true));

                                                          batchBloc.add(
                                                              ChangeQuantitySeparate(
                                                                  0,
                                                                  currentProduct
                                                                          .idProduct ??
                                                                      0,
                                                                  currentProduct
                                                                          .idMove ??
                                                                      0));

                                                          batchBloc.add(ChangeProductIsOkEvent(
                                                              true,
                                                              currentProduct
                                                                      .idProduct ??
                                                                  0,
                                                              batchBloc
                                                                      .batchWithProducts
                                                                      .batch
                                                                      ?.id ??
                                                                  0,
                                                              0,
                                                              currentProduct
                                                                      .idMove ??
                                                                  0));

                                                          batchBloc.add(ChangeIsOkQuantity(
                                                              true,
                                                              currentProduct
                                                                      .idProduct ??
                                                                  0,
                                                              batchBloc
                                                                      .batchWithProducts
                                                                      .batch
                                                                      ?.id ??
                                                                  0,
                                                              currentProduct
                                                                      .idMove ??
                                                                  0));

                                                          Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      100), () {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    focusNode3);
                                                          });
                                                        } else {
                                                          batchBloc.add(
                                                              ValidateFieldsEvent(
                                                                  field:
                                                                      "product",
                                                                  isOk: false));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        1000),
                                                            content: const Text(
                                                                'Producto erroneo'),
                                                            backgroundColor:
                                                                Colors.red[200],
                                                          ));
                                                        }
                                                      }
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                currentProduct.productId
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 16, color: black),
                                              ),
                                            ),

                                            const SizedBox(height: 10),
                                            //informacion del lote:
                                            if (batchBloc.product.tracking ==
                                                    'lot' ||
                                                batchBloc.product.tracking ==
                                                    'serial')
                                              const Column(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Lote/Numero de serie ',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              primaryColorApp),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: black),
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
                            ),

                            //Todo: MUELLE
                            //solo lo mostramos si es el ultimo producto
                            if (batchBloc.index + 1 ==
                                batchBloc.batchWithProducts.products?.length)
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
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
                                      child: Focus(
                                        focusNode: focusNode5,
                                        onKey: (FocusNode node,
                                            RawKeyEvent event) {
                                          if (event is RawKeyDownEvent) {
                                            if (event.logicalKey ==
                                                LogicalKeyboardKey.enter) {
                                              if (scannedValue4.isNotEmpty) {
                                                if (scannedValue4
                                                        .toLowerCase() ==
                                                    batchBloc.batchWithProducts
                                                        .batch?.muelle
                                                        ?.toLowerCase()) {
                                                  batchBloc.add(
                                                      ValidateFieldsEvent(
                                                          field: "locationDest",
                                                          isOk: true));

                                                  batchBloc.add(
                                                      ChangeLocationDestIsOkEvent(
                                                          true,
                                                          currentProduct
                                                                  .idProduct ??
                                                              0,
                                                          batchBloc
                                                                  .batchWithProducts
                                                                  .batch
                                                                  ?.id ??
                                                              0,
                                                          currentProduct
                                                                  .idMove ??
                                                              0));

                                                  batchBloc.add(PickingOkEvent(
                                                      batchBloc
                                                              .batchWithProducts
                                                              .batch
                                                              ?.id ??
                                                          0,
                                                      currentProduct
                                                              .idProduct ??
                                                          0));
                                                  context
                                                      .read<WMSPickingBloc>()
                                                      .add(
                                                          LoadBatchsFromDBEvent());
                                                  context
                                                      .read<BatchBloc>()
                                                      .index = 0;
                                                  context
                                                      .read<BatchBloc>()
                                                      .completedProducts = 0;

                                                  Navigator.pop(context);
                                                } else {
                                                  batchBloc.add(
                                                      ValidateFieldsEvent(
                                                          field: "locationDest",
                                                          isOk: false));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    duration: const Duration(
                                                        milliseconds: 1000),
                                                    content: const Text(
                                                        'Muelle erroneo'),
                                                    backgroundColor:
                                                        Colors.red[200],
                                                  ));
                                                }
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
                                                    'Muelle',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: primaryColorApp),
                                                  ),
                                                  icon: Image.asset(
                                                    "assets/icons/packing.png",
                                                    color: primaryColorApp,
                                                    width: 24,
                                                  ),
                                                  value: selectedMuelle,
                                                  // items: batchBloc.positions
                                                  items: batchBloc.muelles
                                                      .map((String location) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: location,
                                                      child: Text(location),
                                                    );
                                                  }).toList(),

                                                  onChanged: !batchBloc
                                                              .quantityIsOk &&
                                                          !batchBloc
                                                              .locationDestIsOk &&
                                                          batchBloc.productIsOk
                                                      ? (String? newValue) {
                                                          if (newValue ==
                                                              batchBloc
                                                                  .batchWithProducts
                                                                  .batch
                                                                  ?.muelle) {
                                                            batchBloc.add(
                                                                ValidateFieldsEvent(
                                                                    field:
                                                                        "locationDest",
                                                                    isOk:
                                                                        true));

                                                            batchBloc.add(ChangeLocationDestIsOkEvent(
                                                                true,
                                                                currentProduct
                                                                        .idProduct ??
                                                                    0,
                                                                batchBloc
                                                                        .batchWithProducts
                                                                        .batch
                                                                        ?.id ??
                                                                    0,
                                                                currentProduct
                                                                        .idMove ??
                                                                    0));

                                                            batchBloc.add(PickingOkEvent(
                                                                batchBloc
                                                                        .batchWithProducts
                                                                        .batch
                                                                        ?.id ??
                                                                    0,
                                                                currentProduct
                                                                        .idProduct ??
                                                                    0));
                                                            context
                                                                .read<
                                                                    WMSPickingBloc>()
                                                                .add(
                                                                    LoadBatchsFromDBEvent());
                                                            context
                                                                .read<
                                                                    BatchBloc>()
                                                                .index = 0;
                                                            context
                                                                .read<
                                                                    BatchBloc>()
                                                                .completedProducts = 0;

                                                            Navigator.pop(
                                                                context);
                                                          } else {
                                                            batchBloc.add(
                                                                ValidateFieldsEvent(
                                                                    field:
                                                                        "locationDest",
                                                                    isOk:
                                                                        false));
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000),
                                                              content: const Text(
                                                                  'Muelle erroneo'),
                                                              backgroundColor:
                                                                  Colors
                                                                      .red[200],
                                                            ));
                                                          }
                                                        }
                                                      : null,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  batchBloc.batchWithProducts
                                                          .batch?.muelle
                                                          .toString() ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: black),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                //todo: cantidad
                SizedBox(
                  width: size.width,
                  height: viewQuantity ? 150 : 110,
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
                                  const Text('Recoger:',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      currentProduct.quantity?.toString() ?? "",
                                      style: const TextStyle(
                                          color: primaryColorApp, fontSize: 18),
                                    ),
                                  ),
                                  Text(currentProduct.unidades ?? "",
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18)),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Expanded(
                                      child: Container(
                                          alignment: Alignment.center,
                                          child: Focus(
                                            focusNode: focusNode3,
                                            onKey: (FocusNode node,
                                                RawKeyEvent event) {
                                              if (event is RawKeyDownEvent) {
                                                if (event.logicalKey ==
                                                    LogicalKeyboardKey.enter) {
                                                  if (scannedValue3
                                                      .isNotEmpty) {
                                                    if (scannedValue3
                                                            .toLowerCase() ==
                                                        batchBloc
                                                            .product.barcode
                                                            ?.toLowerCase()) {
                                                      batchBloc.add(
                                                          ValidateFieldsEvent(
                                                              field: "quantity",
                                                              isOk: true));

                                                      batchBloc.add(
                                                          AddQuantitySeparate(
                                                              1,
                                                              currentProduct
                                                                      .idProduct ??
                                                                  0));

                                                      setState(() {
                                                        scannedValue3 =
                                                            ""; //limpiamos el valor escaneado
                                                      });

                                                      //*validamos que la cantidad sea igual a la cantidad del producto
                                                      if (batchBloc
                                                              .quantitySelected ==
                                                          currentProduct
                                                              .quantity) {
//*validamos que el prducto sea el ultimo de la lista

                                                        _nextProduct(
                                                            currentProduct,
                                                            batchBloc);
                                                      }
                                                    } else {
                                                      setState(() {
                                                        scannedValue3 =
                                                            ""; //limpiamos el valor escaneado
                                                      });
                                                    }
                                                  }

                                                  return KeyEventResult.handled;
                                                } else {
                                                  setState(() {
                                                    scannedValue3 +=
                                                        event.data.keyLabel;
                                                  });
                                                  return KeyEventResult.handled;
                                                }
                                              }
                                              return KeyEventResult.ignored;
                                            },
                                            child: Text(
                                                batchBloc.quantitySelected
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18)),
                                          )),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: batchBloc.quantityIsOk &&
                                              batchBloc.quantitySelected >= 0
                                          ? () {
                                              setState(() {
                                                viewQuantity = !viewQuantity;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.edit_note_rounded,
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
                                    batchBloc.quantitySelected =
                                        int.parse(value);
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
                              decoration: InputDecorations.authInputDecoration(
                                hintText: 'Cantidad',
                                labelText: 'Cantidad',
                              ),
                              //al dar enter
                              onFieldSubmitted: (value) {
                                setState(() {
                                  //validamos que el texto no este vacio
                                  if (value.isNotEmpty) {
                                    if (int.parse(value) >
                                        (currentProduct.quantity ?? 0)
                                            .toInt()) {
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

                                        _nextProduct(currentProduct, batchBloc);
                                      } else {
                                        //todo cantidad menor a la cantidad pedida
                                        //preguntar si estamos en la ultima posicion

                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return DialogAdvetenciaCantidadScreen(
                                                  currentProduct:
                                                      currentProduct,
                                                  cantidad: batchBloc
                                                      .quantitySelected,
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
                                    int cantidad = int.parse(cantidadController
                                            .text.isEmpty
                                        ? batchBloc.quantitySelected.toString()
                                        : cantidadController.text);

                                    if (cantidad == currentProduct.quantity) {
                                      batchBloc.add(ChangeQuantitySeparate(
                                          int.parse(cantidadController.text),
                                          currentProduct.idProduct ?? 0,
                                          currentProduct.idMove ?? 0));

                                      _nextProduct(currentProduct, batchBloc);
                                    } else {
                                      if (cantidad <
                                          (currentProduct.quantity ?? 0)
                                              .toInt()) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return DialogAdvetenciaCantidadScreen(
                                                  currentProduct:
                                                      currentProduct,
                                                  cantidad: cantidad,
                                                  batchId: batchBloc
                                                          .batchWithProducts
                                                          .batch
                                                          ?.id ??
                                                      0,
                                                  onAccepted: () async {
                                                    batchBloc.add(
                                                        ChangeQuantitySeparate(
                                                            cantidad,
                                                            currentProduct
                                                                    .idProduct ??
                                                                0,
                                                            currentProduct
                                                                    .idMove ??
                                                                0));

                                                    _nextProduct(currentProduct,
                                                        batchBloc);
                                                    cantidadController.clear();
                                                  });
                                            });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          content:
                                              const Text('Cantidad erronea'),
                                          backgroundColor: Colors.red[200],
                                        ));
                                      }
                                    }
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
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          )),
                    ],
                  ),
                ),
                // YourWidget(),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 200,
                  child: Image.asset(
                    "assets/images/icon.png",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Error al cargar los datos...",
                  style: TextStyle(fontSize: 18, color: black),
                ),
                const Text(
                  "Comprueba tu conexión a internet",
                  style: TextStyle(fontSize: 16, color: black),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(size.width * 0.6, 40),
                    ),
                    child: const Text(
                      "Atras",
                      style: TextStyle(color: white, fontSize: 16),
                    ))
              ],
            ),
          ),
        );
      }),
    );
  }

  void _nextProduct(ProductsBatch currentProduct, BatchBloc batchBloc) async {
    batchBloc.completedProducts = batchBloc.completedProducts + 1;
    DataBaseSqlite db = DataBaseSqlite();
    await db.separateProduct(batchBloc.batchWithProducts.batch?.id ?? 0,
        currentProduct.idProduct ?? 0, currentProduct.idMove ?? 0);
    await db.incrementProductSeparateQty(
        batchBloc.batchWithProducts.batch?.id ?? 0);

    viewQuantity = false;
    setState(() {});

    // await db.endStopwatchProduct(
    //     batchBloc.batchWithProducts.batch?.id ?? 0,
    //     DateTime.now().toString(),
    //     currentProduct.idProduct ?? 0,
    //     currentProduct.idMove ?? 0);

    //  String tiempoTotal =  await batchBloc.calcularTiempoTotalPickingProduct(
    //     batchBloc.batchWithProducts.batch?.id ?? 0,
    //     currentProduct.idProduct ?? 0,
    //     currentProduct.idMove ?? 0);

      // print("tiempoTotal: $tiempoTotal");

    ///cambiamos al siguiente producto

    if (batchBloc.index + 1 == batchBloc.batchWithProducts.products?.length) {
      context
          .read<BatchBloc>()
          .add(ChangeCurrentProduct(currentProduct: currentProduct));

      batchBloc.add(ChangeIsOkQuantity(
          false,
          currentProduct.idProduct ?? 0,
          batchBloc.batchWithProducts.batch?.id ?? 0,
          currentProduct.idMove ?? 0));
      await db.updateIsQuantityIsFalse(
          batchBloc.batchWithProducts.batch?.id ?? 0,
          currentProduct.idProduct ?? 0,
          currentProduct.idMove ?? 0);
      batchBloc.quantitySelected = 0;
      return;
    } else {
      context
          .read<BatchBloc>()
          .add(ChangeCurrentProduct(currentProduct: currentProduct));
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
}
