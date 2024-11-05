// ignore_for_file: unrelated_type_equality_checks

import 'dart:ui';

import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../utils/constans/colors.dart';

class BatchDetailScreen extends StatelessWidget {
  const BatchDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<BatchBloc, BatchState>(
      builder: (context, state) {
        return Scaffold(
            backgroundColor: Colors.white,
            // appBar: AppBarGlobal(
            //     tittle: 'Picking Detail', actions: const SizedBox()),
            body: SizedBox(
              width: size.width,
              height: size.height * 0.96,
              child: Column(
                ///apbar

                children: [
                  //*appbar
                  Container(
                    decoration: const BoxDecoration(
                      color: primaryColorApp,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    width: double.infinity,
                    child: BlocProvider(
                      create: (context) => ConnectionStatusCubit(),
                      child:
                          BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                              builder: (context, status) {
                        return Column(
                          children: [
                            const WarningWidgetCubit(),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 10,
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
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * 0.18),
                                    child: Text(
                                        "Detalles ${context.read<BatchBloc>().batchWithProducts.batch?.name}",
                                        style: const TextStyle(
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

                  //*widget de busqueda
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  //   child: Card(
                  //     color: Colors.white,
                  //     elevation: 2,
                  //     child: TextFormField(
                  //       textAlignVertical: TextAlignVertical.center,
                  //       controller: context.read<BatchBloc>().searchController,
                  //       decoration: InputDecoration(
                  //         prefixIcon: const Icon(Icons.search, color: grey),
                  //         suffixIcon: IconButton(
                  //             onPressed: () {
                  //               context
                  //                   .read<BatchBloc>()
                  //                   .add(ClearSearchProudctsBatchEvent());
                  //               FocusScope.of(context).unfocus();
                  //             },
                  //             icon: const Icon(Icons.close, color: grey)),
                  //         disabledBorder: const OutlineInputBorder(),
                  //         hintText: "Buscar productos",
                  //         hintStyle:
                  //             const TextStyle(color: Colors.grey, fontSize: 14),
                  //         border: InputBorder.none,
                  //       ),
                  //       onChanged: (value) {
                  //         context
                  //             .read<BatchBloc>()
                  //             .add(SearchProductsBatchEvent(value));
                  //       },
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: size.width,
                    height: context
                                .read<BatchBloc>()
                                .batchWithProducts
                                .batch
                                ?.isSeparate ==
                            1
                        ? 170
                        : 80,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                color: white,
                                elevation: 3,
                                child: SizedBox(
                                  height: 60,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Center(
                                          child: Text(
                                              "Items: ${context.read<BatchBloc>().batchWithProducts.products?.length ?? 0}",
                                              style: const TextStyle(
                                                  fontSize: 13, color: black)),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Center(
                                          child: Text(
                                              "Separados: ${context.read<BatchBloc>().batchWithProducts.batch?.productSeparateQty ?? 0}",
                                              style: const TextStyle(
                                                  fontSize: 13, color: black)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                color: white,
                                elevation: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: size.width * 0.6,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Text(
                                              "Ejecucion: ${context.read<BatchBloc>().calculateProgress()}%",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: getColorForPercentage(
                                                    double.parse(context
                                                        .read<BatchBloc>()
                                                        .calculateProgress())), // Convertir a double
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
                                                          title: const Center(
                                                            child: Text(
                                                                "Información",
                                                                style: TextStyle(
                                                                    color:
                                                                        primaryColorApp,
                                                                    fontSize:
                                                                        20)),
                                                          ),
                                                          content: const Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                  "El porcentaje de ejecución se calcula de la siguiente manera:"),
                                                              SizedBox(
                                                                  height: 5),
                                                              Text(
                                                                  "Porcentaje de ejecución = (Unidades separadas / Unidades totales) * 100"),
                                                              SizedBox(
                                                                  height: 5),
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
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                ),
                                                                onPressed: () {
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
                                                child: const Icon(Icons.help,
                                                    color: primaryColorApp,
                                                    size: 20)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.6,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Text(
                                              "Unidades separadas: ${context.read<BatchBloc>().calcularUnidadesSeparadas()}%",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: getColorForPercentage(
                                                    double.parse(context
                                                        .read<BatchBloc>()
                                                        .calcularUnidadesSeparadas())), // Convertir a double
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
                                                          title: const Center(
                                                            child: Text(
                                                                "Información",
                                                                style: TextStyle(
                                                                    color:
                                                                        primaryColorApp,
                                                                    fontSize:
                                                                        20)),
                                                          ),
                                                          content: const Column(
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
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                ),
                                                                onPressed: () {
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
                                                child: const Icon(Icons.help,
                                                    color: primaryColorApp,
                                                    size: 20)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          if (context
                                  .read<BatchBloc>()
                                  .batchWithProducts
                                  .batch
                                  ?.isSeparate ==
                              1)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 2),
                              child: Card(
                                color: primaryColorAppLigth,
                                elevation: 2,
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FutureBuilder<String>(
                                      future: context
                                          .read<BatchBloc>()
                                          .calcularTiempoTotalPicking(context
                                                  .read<BatchBloc>()
                                                  .batchWithProducts
                                                  .batch
                                                  ?.id ??
                                              0), // Asegúrate de pasar los IDs correctos
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          // Muestra un indicador de carga mientras esperas el resultado
                                          return const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.timer,
                                                  color: primaryColorApp,
                                                  size: 20),
                                              SizedBox(width: 10),
                                              CircularProgressIndicator(), // O cualquier otro widget de carga
                                            ],
                                          );
                                        } else {
                                          // Cuando se tiene el resultado
                                          String tiempoTotal = snapshot.data ??
                                              "00:00:00"; // Valor por defecto si es nulo
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.timer,
                                                  color: primaryColorApp,
                                                  size: 20),
                                              const SizedBox(width: 10),
                                              Text(
                                                  "Tiempo total del picking: $tiempoTotal",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: black)),
                                            ],
                                          );
                                        }
                                      },
                                    )),
                              ),
                            ),
                          if (context
                                  .read<BatchBloc>()
                                  .batchWithProducts
                                  .batch
                                  ?.isSeparate ==
                              1)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Card(
                                elevation: 2,
                                color: primaryColorAppLigth,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text("Picking finalizado",
                                            style: TextStyle(
                                                fontSize: 14, color: black)),
                                        const SizedBox(width: 10),
                                        //icono de check
                                        GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 5, sigmaY: 5),
                                                    child: AlertDialog(
                                                      actionsAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      title: const Center(
                                                        child: Text(
                                                            "Información",
                                                            style: TextStyle(
                                                                color:
                                                                    primaryColorApp,
                                                                fontSize: 20)),
                                                      ),
                                                      content: const Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                              "El picking se considera finalizado cuando se han separado todas las unidades de los productos."),
                                                          SizedBox(height: 5),
                                                          Text(
                                                              "Para finalizar el picking, asegúrese de haber separado todas las unidades de los productos y llevarlos al área de muelle indicado por el batch."),
                                                        ],
                                                      ),
                                                      actions: [
                                                        ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  grey,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                            ),
                                                            onPressed: () {
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
                                            child: const Icon(Icons.check,
                                                color: primaryColorApp,
                                                size: 20)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),

                  // *Lista de productos
                  Expanded(
                    // height: size.height * 0.75,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: context
                                  .read<BatchBloc>()
                                  .batchWithProducts
                                  .products
                                  ?.isNotEmpty ??
                              false
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: context
                                  .read<BatchBloc>()
                                  .batchWithProducts
                                  .products
                                  ?.length,
                              itemBuilder: (context, index) {
                                final productsBatch = context
                                    .read<BatchBloc>()
                                    .batchWithProducts
                                    .products?[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: GestureDetector(
                                    onTap: () async {
                                     
                                    },
                                    child: Card(
                                        elevation: 4,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: productsBatch?.quantity ==
                                                    productsBatch
                                                        ?.quantitySeparate
                                                ? Colors.green[100]
                                                : productsBatch?.isSelected == 1
                                                    ? primaryColorApp
                                                        .withOpacity(0.3)
                                                    : productsBatch
                                                                ?.isSeparate ==
                                                            1
                                                        ? Colors.green[100]
                                                        : Colors.white,
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Center(
                                                child: Text(
                                                  productsBatch?.productId ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      color: primaryColorApp,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text("Desde: ",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: black)),
                                                    SizedBox(
                                                      width: size.width * 0.6,
                                                      child: Text(
                                                          productsBatch
                                                                  ?.locationId
                                                                  ?.toString() ??
                                                              '',
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  primaryColorApp)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.arrow_forward,
                                                      color: primaryColorApp,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text("A:",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: black)),
                                                    const SizedBox(width: 5),
                                                    SizedBox(
                                                      width: size.width * 0.7,
                                                      child: Text(
                                                          productsBatch
                                                                  ?.locationDestId
                                                                  .toString() ??
                                                              '',
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  primaryColorApp)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.bookmarks_sharp,
                                                      color: primaryColorApp,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text("Lote:",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: black)),
                                                    const SizedBox(width: 5),
                                                    SizedBox(
                                                      width: size.width * 0.7,
                                                      child: Text(
                                                          productsBatch?.lotId
                                                                  .toString() ??
                                                              '',
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  primaryColorApp)),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              if (productsBatch?.isSeparate ==
                                                  1)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Row(
                                                    children: [
                                                      FutureBuilder<String>(
                                                        future: context
                                                            .read<BatchBloc>()
                                                            .calcularTiempoTotalProducto(
                                                              context
                                                                      .read<
                                                                          BatchBloc>()
                                                                      .batchWithProducts
                                                                      .batch
                                                                      ?.id ??
                                                                  0,
                                                              productsBatch
                                                                      ?.idProduct ??
                                                                  0,
                                                              productsBatch
                                                                      ?.idMove ??
                                                                  0,
                                                            ), // Asegúrate de pasar los IDs correctos
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    String>
                                                                snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            // Muestra un indicador de carga mientras esperas el resultado
                                                            return const Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                    Icons.timer,
                                                                    color:
                                                                        primaryColorApp,
                                                                    size: 20),
                                                                SizedBox(
                                                                    width: 10),
                                                                CircularProgressIndicator(), // O cualquier otro widget de carga
                                                              ],
                                                            );
                                                          } else {
                                                            // Cuando se tiene el resultado
                                                            String tiempoTotal =
                                                                snapshot.data ??
                                                                    "00:00:00"; // Valor por defecto si es nulo
                                                            return Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Icon(
                                                                    Icons.timer,
                                                                    color:
                                                                        primaryColorApp,
                                                                    size: 20),
                                                                const SizedBox(
                                                                    width: 5),
                                                                RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      const TextSpan(
                                                                        text:
                                                                            "Tiempo total: ",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              black, // color del texto antes de tiempoTotal
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            tiempoTotal,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              primaryColorApp, // color rojo para tiempoTotal
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                              // Padding(
                                              //   padding:
                                              //       const EdgeInsets.symmetric(
                                              //           horizontal: 8),
                                              //   child: Row(
                                              //     children: [
                                              //       const Icon(
                                              //         Icons.timer_rounded,
                                              //         color: primaryColorApp,
                                              //         size: 20,
                                              //       ),
                                              //       const SizedBox(width: 5),
                                              //       const Text("Termino:",
                                              //           style: TextStyle(
                                              //               fontSize: 14,
                                              //               color: black)),
                                              //       const SizedBox(width: 5),
                                              //       SizedBox(
                                              //         width: size.width * 0.6,
                                              //         child: Text(
                                              //             productsBatch?.timeSeparateEnd
                                              //                     .toString() ??
                                              //                 '',
                                              //             style: const TextStyle(
                                              //                 fontSize: 14,
                                              //                 color:
                                              //                     primaryColorApp)),
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),

                                              const SizedBox(height: 5),
                                              Card(
                                                color: productsBatch
                                                            ?.quantity ==
                                                        productsBatch
                                                            ?.quantitySeparate
                                                    ? Colors.green[100]
                                                    : productsBatch
                                                                ?.quantitySeparate ==
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
                                                          const Icon(
                                                            Icons.add,
                                                            color:
                                                                primaryColorApp,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          const Text(
                                                              "Unidades:",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color:
                                                                      black)),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                              productsBatch
                                                                      ?.quantity
                                                                      .toString() ??
                                                                  "",
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  color:
                                                                      primaryColorApp)),
                                                          const Spacer(),
                                                          const Icon(
                                                            Icons.check,
                                                            color:
                                                                primaryColorApp,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          const Text(
                                                              "Separadas:",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color:
                                                                      black)),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                              productsBatch
                                                                          ?.quantitySeparate ==
                                                                      null
                                                                  ? "0"
                                                                  : productsBatch
                                                                          ?.quantitySeparate
                                                                          .toString() ??
                                                                      "",
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  color:
                                                                      primaryColorApp)),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .assessment_outlined,
                                                            color:
                                                                primaryColorApp,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                              "Unidades: ${productsBatch?.unidades ?? ''}",
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color:
                                                                          black)),
                                                        ],
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .assignment_late,
                                                              color:
                                                                  primaryColorApp,
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Text(
                                                                "Novedad: ${productsBatch?.observation ?? ''}",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
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
                                  Image.asset('assets/images/empty.png',
                                      height:
                                          200), // Ajusta la altura según necesites
                                  const SizedBox(height: 10),
                                  const Text('No se encontraron resultados',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: primaryColorApp)),
                                  const Text('Intenta con otra búsqueda',
                                      style:
                                          TextStyle(fontSize: 14, color: grey)),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  Color getColorForPercentage(double percentage) {
    if (percentage >= 100) {
      return Colors.green; // Verde para 100%
    } else if (percentage < 20) {
      return Colors.red; // Rojo para menos del 20%
    } else if (percentage < 50) {
      return Colors.orange; // Naranja para menos del 50%
    } else {
      return const Color.fromARGB(
          255, 211, 190, 1); // Amarillo para entre 50% y 100%
    }
  }
}
