// ignore_for_file: unrelated_type_equality_checks, avoid_print, use_build_context_synchronously

import 'dart:ui';

import 'package:get/get.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/widgets/dialog_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
// import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_edit_product_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/expiredate_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/bloc/picking_pick_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/widgets/others/dialog_edit_product_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';

class PickDetailScreen extends StatelessWidget {
  const PickDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<PickingPickBloc, PickingPickState>(
      listener: (context, state) {
        if (state is ProductEditOk) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Producto ajustado correctamente"),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (state is SendProductPickOdooLoading) {
          showDialog(
              context: context,
              builder: (context) {
                return const DialogLoading(message: "Enviando producto...");
              });
        }

        if (state is SendProductPickOdooError) {
          Navigator.pop(context);
          // ErrorDialog.show(
          //   error: state.error,
          //   request: state.transferRequest.toMap(),
          // );
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

        if (state is SendProductPickOdooSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Producto enviado correctamente"),
              backgroundColor: Colors.green[200],
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<PickingPickBloc>();
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
              backgroundColor: Colors.white,
              body: SizedBox(
                width: size.width,
                height: size.height * 1,
                child: Column(
                  ///apbar

                  children: [
                    //*appbar
                    Container(
                      decoration: BoxDecoration(
                        color: bloc.pickWithProducts.pick?.isSeparate == 1
                            ? green
                            : primaryColorApp,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      width: double.infinity,
                      child:
                          BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                              builder: (context, status) {
                        return Column(
                          children: [
                            const WarningWidgetCubit(),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 5,
                                  top: status != ConnectionStatus.online
                                      ? 20
                                      : 30),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: white),
                                    onPressed: () {
                                      bloc.add(ClearSearchProudctsPickEvent());
                                      // bloc.add(FetchPickWithProductsEvent(
                                      //     bloc.pickWithProducts.pick?.id ?? 0));
                                      Navigator.pushReplacementNamed(
                                          context, 'scan-product-pick');
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * 0.25),
                                    child: Text(
                                        "${bloc.pickWithProducts.pick?.name}",
                                        style: const TextStyle(
                                            color: white, fontSize: 12)),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 5),
                    SizedBox(
                      width: size.width,
                      height: bloc.pickWithProducts.pick?.isSeparate == 1
                          ? 140
                          : bloc.isSearch == false
                              ? 70
                              : 100,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  color: white,
                                  elevation: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: size.width * 0.6,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              Text(
                                                "Unidades separadas: ${bloc.calcularUnidadesSeparadas()}%",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: getColorForPercentage(bloc
                                                      .calcularUnidadesSeparadas()), // Convertir a double
                                                ),
                                              ),
                                              const Spacer(),
                                              //icono de ayuda
                                              GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return BackdropFilter(
                                                          filter:
                                                              ImageFilter.blur(
                                                                  sigmaX: 5,
                                                                  sigmaY: 5),
                                                          child: AlertDialog(
                                                            actionsAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            title: Center(
                                                              child: Text(
                                                                  "Información",
                                                                  style: TextStyle(
                                                                      color:
                                                                          primaryColorApp,
                                                                      fontSize:
                                                                          20)),
                                                            ),
                                                            content:
                                                                const Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                    "El porcentaje de unidades separadas se calcula de la siguiente manera:"),
                                                                SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                    "Porcentaje de unidades separadas = (Unidades separadas / Unidades totales) * 100"),
                                                              ],
                                                            ),
                                                            actions: [
                                                              ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        grey,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: const Text(
                                                                      "Cerrar",
                                                                      style: TextStyle(
                                                                          color:
                                                                              white))),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Icon(Icons.help,
                                                      color: primaryColorApp,
                                                      size: 15)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),

                            // //*widget de busqueda

                            Visibility(
                              visible: bloc.isSearch,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 2,
                                  child: TextFormField(
                                    showCursor: true,
                                    readOnly: context
                                            .read<UserBloc>()
                                            .fabricante
                                            .contains("Zebra")
                                        ? true
                                        : false,
                                    focusNode: FocusNode(),
                                    textAlignVertical: TextAlignVertical.center,
                                    onChanged: (value) {
                                      bloc.add(SearchProductsPickEvent(value));
                                    },
                                    onTap: !context
                                            .read<UserBloc>()
                                            .fabricante
                                            .contains("Zebra")
                                        ? null
                                        : () {
                                            bloc.add(ShowKeyboard(true));
                                          },
                                    controller: bloc.searchController,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.search, color: grey),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            bloc.add(
                                                ClearSearchProudctsPickEvent());
                                            //cerramo el teclado
                                            FocusScope.of(context).unfocus();
                                            bloc.add(ShowKeyboard(false));
                                          },
                                          icon: const Icon(Icons.close,
                                              color: grey)),
                                      disabledBorder:
                                          const OutlineInputBorder(),
                                      hintText: "Buscar productos",
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // *Lista de productos
                    Expanded(
                      // height: size.height * 0.75,
                      child: bloc.filteredProducts.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: bloc.filteredProducts.length,
                              itemBuilder: (context, index) {
                                final productsBatch =
                                    bloc.filteredProducts[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      print("----------------");
                                      print(
                                          "product detail info: ${productsBatch.toMap()}");
                                      print("----------------");
                                    },
                                    child: Card(
                                        elevation: 4,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: productsBatch.quantity ==
                                                    productsBatch
                                                        .quantitySeparate
                                                ? Colors.green[100]
                                                : productsBatch.isSelected == 1
                                                    ? primaryColorApp
                                                        .withOpacity(0.3)
                                                    : productsBatch
                                                                .isSeparate ==
                                                            1
                                                        ? Colors.green[100]
                                                        : Colors.white,
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        productsBatch
                                                                .productId ??
                                                            '',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    if (!bloc.isSearch &&
                                                        (productsBatch
                                                                .quantity !=
                                                            productsBatch
                                                                .quantitySeparate))
                                                      SizedBox(
                                                        width: 50,
                                                        height: 50,
                                                        child: Card(
                                                          elevation: 2,
                                                          color: white,
                                                          child: IconButton(
                                                              onPressed: () {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      bloc.editProductController
                                                                          .text = '';
                                                                      return DialogEditProductPickWidget(
                                                                        productsBatch:
                                                                            productsBatch,
                                                                      );
                                                                    });
                                                              },
                                                              icon: Icon(
                                                                  Icons.edit,
                                                                  size: 20,
                                                                  color:
                                                                      primaryColorApp)),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Image.asset(
                                                      "assets/icons/barcode.png",
                                                      color: primaryColorApp,
                                                      width: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(productsBatch.barcode,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: black,
                                                        )),
                                                    if (productsBatch
                                                                .isSendOdoo !=
                                                            1 &&
                                                        productsBatch
                                                                .isSeparate !=
                                                            1) ...[
                                                      const Spacer(),
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return DialogoConfirmateProductLoad(
                                                                    productsBatch:
                                                                        productsBatch);
                                                              });
                                                        },
                                                        child: Icon(
                                                          Icons.play_circle,
                                                          color: green,
                                                          size: 25,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: bloc
                                                        .configurations
                                                        .result
                                                        ?.result
                                                        ?.showNextLocationsInDetails ==
                                                    true,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        color: primaryColorApp,
                                                        size: 15,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      const Text("Desde: ",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: black)),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.57,
                                                        child: Text(
                                                            productsBatch
                                                                    .locationId
                                                                    ?.toString() ??
                                                                '',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    primaryColorApp)),
                                                      ),
                                                      if (productsBatch
                                                              .isPending ==
                                                          1)
                                                        Container(
                                                          width: 30,
                                                          height: 30,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors
                                                                .amber[100],
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(3),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return const DialogInfo(
                                                                      title:
                                                                          "Producto pendiente",
                                                                      body:
                                                                          "Este producto fue enviado al final de la lista de picking. ",
                                                                    );
                                                                  });
                                                            },
                                                            child: Image.asset(
                                                              'assets/icons/list_final.png',
                                                              height: 20,
                                                              color:
                                                                  primaryColorApp,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.arrow_forward,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text("A:",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: black)),
                                                    const SizedBox(width: 5),
                                                    SizedBox(
                                                      width: size.width * 0.7,
                                                      child: Text(
                                                          productsBatch
                                                              .locationDestId
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  primaryColorApp)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: productsBatch.origin !=
                                                        "" &&
                                                    productsBatch.origin !=
                                                        null,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.file_open_sharp,
                                                        color: primaryColorApp,
                                                        size: 15,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                            "Doc. origen: ",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: grey)),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                            productsBatch
                                                                    .origin ??
                                                                "",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    primaryColorApp)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.priority_high,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text("Priority:",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: black)),
                                                    const SizedBox(width: 5),
                                                    SizedBox(
                                                      width: size.width * 0.5,
                                                      child: Text(
                                                          productsBatch
                                                              .rimovalPriority
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  primaryColorApp)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ExpiryDateWidget(
                                                  expireDate: productsBatch
                                                              .expireDate ==
                                                          ""
                                                      ? DateTime.now()
                                                      : DateTime.parse(
                                                          productsBatch
                                                              .expireDate),
                                                  size: size,
                                                  isDetaild: true,
                                                  isNoExpireDate: productsBatch
                                                              .expireDate ==
                                                          ""
                                                      ? true
                                                      : false),
                                              if (productsBatch.lote != "" &&
                                                  productsBatch.lote != null)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.bookmarks_sharp,
                                                        color: primaryColorApp,
                                                        size: 15,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      const Text("Lote:",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: black)),
                                                      const SizedBox(width: 5),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.55,
                                                        child: Text(
                                                            productsBatch.loteId ==
                                                                        "" ||
                                                                    productsBatch
                                                                            .loteId ==
                                                                        null
                                                                ? 'Sin manejo por lote'
                                                                : productsBatch
                                                                    .lote
                                                                    .toString(),
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    primaryColorApp)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              Card(
                                                elevation: 0,
                                                color: white,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 3),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .send_to_mobile_outlined,
                                                        color: primaryColorApp,
                                                        size: 15,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      const Text(
                                                          "Subido a WMS:",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: black)),
                                                      const SizedBox(width: 5),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.25,
                                                        child: Text(
                                                            productsBatch
                                                                        .isSendOdoo ==
                                                                    null
                                                                ? 'Sin enviar'
                                                                : productsBatch
                                                                            .isSendOdoo ==
                                                                        1
                                                                    ? 'Enviado'
                                                                    : 'No enviado',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: productsBatch
                                                                            .isSendOdoo ==
                                                                        null
                                                                    ? primaryColorApp
                                                                    : productsBatch.isSendOdoo ==
                                                                            1
                                                                        ? green
                                                                        : red)),
                                                      ),
                                                      if (productsBatch
                                                              .isSendOdoo ==
                                                          0)
                                                        ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              bloc.add(SendProductOdooPickEvent(
                                                                  productsBatch,
                                                                  (!bloc.isSearch &&
                                                                      (productsBatch
                                                                              .quantity !=
                                                                          productsBatch
                                                                              .quantitySeparate))));
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  primaryColorApp,
                                                              maximumSize:
                                                                  const Size(
                                                                      80, 20),
                                                              minimumSize:
                                                                  const Size(
                                                                      80, 20),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              elevation: 3,
                                                            ),
                                                            child: const Text(
                                                              'Enviar',
                                                              style: TextStyle(
                                                                  color: white,
                                                                  fontSize: 10),
                                                            ))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (productsBatch.isSeparate == 1)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.timer,
                                                          color:
                                                              primaryColorApp,
                                                          size: 15),
                                                      const SizedBox(width: 5),
                                                      RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            const TextSpan(
                                                              text:
                                                                  "Tiempo total: ",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    black, // color del texto antes de tiempoTotal
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: bloc.formatSecondsToHHMMSS(
                                                                  (productsBatch.timeSeparate ??
                                                                              0)
                                                                          .toDouble() ??
                                                                      0.0),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    primaryColorApp, // color rojo para tiempoTotal
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              const SizedBox(height: 5),
                                              Card(
                                                color: productsBatch.quantity ==
                                                        productsBatch
                                                            .quantitySeparate
                                                    ? Colors.green[100]
                                                    : productsBatch
                                                                .quantitySeparate ==
                                                            null
                                                        ? Colors.red[100]
                                                        : Colors.amber[100],
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            color:
                                                                primaryColorApp,
                                                            size: 15,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          const Text(
                                                              "Unidades:",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                              productsBatch
                                                                  .quantity
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      primaryColorApp)),
                                                          const Spacer(),
                                                          Icon(
                                                            Icons.check,
                                                            color:
                                                                primaryColorApp,
                                                            size: 15,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          const Text(
                                                              "Separadas:",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                              productsBatch
                                                                          .quantitySeparate ==
                                                                      null
                                                                  ? "0"
                                                                  : productsBatch
                                                                      .quantitySeparate
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      primaryColorApp)),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .assessment_outlined,
                                                            color:
                                                                primaryColorApp,
                                                            size: 15,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                              "Unidad de medida: ${productsBatch.unidades ?? ''}",
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          black)),
                                                        ],
                                                      ),
                                                      if (productsBatch
                                                              .quantity !=
                                                          productsBatch
                                                              .quantitySeparate)
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .assignment_late,
                                                                color:
                                                                    primaryColorApp,
                                                                size: 15,
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                              Text(
                                                                  "Novedad: ${productsBatch.observation ?? ''}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          black)),
                                                            ],
                                                          ),
                                                        ),
                                                      const SizedBox(height: 5),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      context
                                              .read<UserBloc>()
                                              .fabricante
                                              .contains("Zebra")
                                          ? 'No se encontraron resultados'
                                          : 'No hay productos en la lista',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: primaryColorApp)),
                                  Text(
                                      bloc.isSearch
                                          ? 'Intenta con otra búsqueda'
                                          : 'Todos los productos han sido completados',
                                      style: const TextStyle(
                                          fontSize: 12, color: grey)),
                                ],
                              ),
                            ),
                    ),

                    Visibility(
                      visible: bloc.isKeyboardVisible &&
                          context.read<UserBloc>().fabricante.contains("Zebra"),
                      child: CustomKeyboard(
                        isLogin: false,
                        controller: bloc.searchController,
                        onchanged: () {
                          bloc.add(SearchProductsPickEvent(
                              bloc.searchController.text));
                        },
                      ),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }

  Color getColorForPercentage(dynamic percentage) {
    //convertir el string en un double
    double parsedPercentage = double.tryParse(percentage.toString()) ?? 0.0;
    if (parsedPercentage >= 100) {
      return Colors.green; // Verde para 100%
    } else if (parsedPercentage < 20) {
      return Colors.red; // Rojo para menos del 20%
    } else if (parsedPercentage < 50) {
      return Colors.orange; // Naranja para menos del 50%
    } else {
      return const Color.fromARGB(
          255, 211, 190, 1); // Amarillo para entre 50% y 100%
    }
  }
}

class DialogoConfirmateProductLoad extends StatelessWidget {
  const DialogoConfirmateProductLoad({
    super.key,
    required this.productsBatch,
  });

  final ProductsBatch productsBatch;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        title: Center(
          child: Text("Confirmación",
              style: TextStyle(color: primaryColorApp, fontSize: 20)),
        ),
        content: Text.rich(
          TextSpan(
            text: "¿Está seguro que desea comenzar a separar ",
            style: const TextStyle(color: Colors.black), // estilo base
            children: [
              TextSpan(
                text: productsBatch.productId,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: primaryColorApp),
              ),
              if (productsBatch.lote != null && productsBatch.lote != "") ...[
                TextSpan(
                  text: " con lote: ",
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: productsBatch.lote ?? "",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColorApp),
                ),
              ],
              TextSpan(
                text: "?",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: primaryColorApp),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar", style: TextStyle(color: white))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColorApp,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<PickingPickBloc>()
                    .add(LoadSelectedProductEvent(productsBatch));
                Navigator.pushReplacementNamed(context, 'scan-product-pick');
              },
              child: const Text("Aceptar", style: TextStyle(color: white))),
        ],
      ),
    );
  }
}
