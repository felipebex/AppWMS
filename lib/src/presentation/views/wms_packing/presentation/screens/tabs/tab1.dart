// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/widgets/dialog_unPacking.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab1Screen extends StatelessWidget {
  const Tab1Screen({
    super.key,
    required this.size,
    required this.packingModel,
    this.batchModel,
  });

  final Size size;
  final PedidoPacking? packingModel;
  final BatchPackingModel? batchModel;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: BlocBuilder<WmsPackingBloc, WmsPackingState>(
        builder: (context, state) {
          return BlocListener<WmsPackingBloc, WmsPackingState>(
            listener: (context, state) {
              if (state is UnPackignSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(milliseconds: 1000),
                  content: Text(state.message),
                  backgroundColor: Colors.green[200],
                ));
              }
            },
            child: Scaffold(
              backgroundColor: white,
              floatingActionButton: packingModel?.isTerminate == 1
                  ? null
                  : FloatingActionButton(
                      onPressed: () {
                        if (context.read<WmsPackingBloc>().packages.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'No se puede confirmar un pedido sin empaques',
                                style: TextStyle(color: white),
                              ),
                              backgroundColor: Colors.red[200],
                            ),
                          );
                          return;
                        } else if (context
                                .read<WmsPackingBloc>()
                                .productsDone
                                .isNotEmpty &&
                            context
                                .read<WmsPackingBloc>()
                                .listOfProductosProgress
                                .isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'No se puede confirmar un pedido con productos en proceso o listos para empaquetar',
                                style: TextStyle(color: white),
                              ),
                              backgroundColor: Colors.red[200],
                            ),
                          );
                          return;
                        }

                        showDialog(
                            context: context,
                            builder: (context) {
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: AlertDialog(
                                  backgroundColor: Colors.white,
                                  actionsAlignment: MainAxisAlignment.center,
                                  title: Text(
                                    'Confirmar pedido',
                                    style: TextStyle(
                                        color: primaryColorApp, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        width: 200,
                                        child: Image.asset(
                                          "assets/images/icono.jpeg",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          '¿Estás seguro de confirmar el pedido y dejarlo listo para ser enviado?',
                                          style: TextStyle(
                                              color: black, fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await DataBaseSqlite()
                                            .setFieldTablePedidosPacking(
                                          packingModel?.batchId ?? 0,
                                          packingModel?.id ?? 0,
                                          "is_terminate",
                                          "true",
                                        );

                                        context
                                            .read<WmsPackingBloc>()
                                            .add(LoadAllPedidosFromBatchEvent(
                                              packingModel?.batchId ?? 0,
                                            ));

                                        Navigator.of(context).pop();
                                        Navigator.pushReplacementNamed(
                                            context, 'packing-list',
                                            arguments: [batchModel]);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColorApp,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'Aceptar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      backgroundColor: primaryColorApp,
                      child: const Icon(Icons.check, color: white),
                    ),
              body: Column(
                children: [
                  const WarningWidgetCubit(),

                  //detalles del batch
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  packingModel?.name ?? '',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColorApp,
                                      fontWeight: FontWeight.bold),
                                )),
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Contacto: ',
                                  style: TextStyle(fontSize: 14, color: black),
                                )),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  packingModel?.contactoName ?? '',
                                  style: TextStyle(
                                      fontSize: 14, color: primaryColorApp),
                                )),
                            Row(
                              children: [
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Total productos del pedido: ',
                                      style:
                                          TextStyle(fontSize: 14, color: black),
                                    )),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      packingModel?.cantidadProductos
                                              .toString() ??
                                          "",
                                      style: TextStyle(
                                          fontSize: 14, color: primaryColorApp),
                                    )),
                              ],
                            ),
                            Row(
                              children: [
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Total productos empacados: ',
                                      style:
                                          TextStyle(fontSize: 14, color: black),
                                    )),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      context
                                          .read<WmsPackingBloc>()
                                          .listOfProductos
                                          .where((element) =>
                                              element.isPackage == 1)
                                          .length
                                          .toString(), // Convierte el número en un String
                                      style: TextStyle(
                                          fontSize: 14, color: primaryColorApp),
                                    )),
                              ],
                            ),
                            Row(
                              children: [
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Operacion: ',
                                      style:
                                          TextStyle(fontSize: 14, color: black),
                                    )),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      packingModel?.tipoOperacion ?? "",
                                      style: TextStyle(
                                          fontSize: 14, color: primaryColorApp),
                                    )),
                              ],
                            ),
                            Row(
                              children: [
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Numero de paquetes: ',
                                      style:
                                          TextStyle(fontSize: 14, color: black),
                                    )),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      context
                                          .read<WmsPackingBloc>()
                                          .packages
                                          .length
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 14, color: primaryColorApp),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text("Listado de empaques",
                      style: TextStyle(
                          fontSize: 16,
                          color: primaryColorApp,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 2, bottom: 10, top: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: (context.read<WmsPackingBloc>().packages.isEmpty)
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('No hay empaques',
                                      style:
                                          TextStyle(fontSize: 14, color: grey)),
                                  Text('Realiza el proceso de empaque',
                                      style:
                                          TextStyle(fontSize: 12, color: grey)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 55),
                              itemCount: context
                                  .read<WmsPackingBloc>()
                                  .packages
                                  .length,
                              itemBuilder: (BuildContext context, int index) {
                                final package = context
                                    .read<WmsPackingBloc>()
                                    .packages[index];

                                // Filtrar los productos de acuerdo al id_package del paquete actual
                                final filteredProducts = context
                                    .read<WmsPackingBloc>()
                                    .listOfProductos
                                    .where((product) =>
                                        product.idPackage == package.id)
                                    .toList();

                                return Card(
                                  color: Colors.white,
                                  child: ExpansionTile(
                                    childrenPadding: const EdgeInsets.all(5),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${package.name}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: primaryColorApp),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Cantidad de productos: ${package.cantidadProductos}",
                                              style: const TextStyle(
                                                  fontSize: 14, color: black),
                                            ),
                                            const Spacer(),
                                            if (package.isSticker == true)
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons.print,
                                                    color: primaryColorApp,
                                                    size: 20,
                                                  ))
                                          ],
                                        ),
                                      ],
                                    ),
                                    children: [
                                      // Aquí generamos la lista de productos filtrados
                                      SizedBox(
                                        width: double.infinity,
                                        height: 150,
                                        child: ListView.builder(
                                          itemCount: filteredProducts
                                              .length, // La cantidad de productos filtrados
                                          itemBuilder: (context, index) {
                                            final product =
                                                filteredProducts[index];
                                            return GestureDetector(
                                              onTap: () {
                                                print(
                                                    "info paquete: ${package.toMap()}");
                                                print("--------------------");
                                                print(
                                                    "Producto seleccionado: ${product.toMap()}");
                                              },
                                              child: Card(
                                                color: white,
                                                elevation: 2,
                                                child: ListTile(
                                                  title: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                            product.productId ??
                                                                "",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          //mensaje de confirmacion de desempacar el producto
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return DialogUnPacking(
                                                                  product:
                                                                      product,
                                                                  package:
                                                                      package,
                                                                );
                                                              });
                                                        },
                                                        child: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ), // Muestra el nombre del producto
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          if (product
                                                                  .isCertificate !=
                                                              0)
                                                            RichText(
                                                              text: TextSpan(
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      14, // Tamaño del texto
                                                                  color: Colors
                                                                      .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                                ),
                                                                children: <TextSpan>[
                                                                  const TextSpan(
                                                                      text:
                                                                          "Cantidad empacada: ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              black)), // Parte del texto en color negro (o el color que prefieras)
                                                                  TextSpan(
                                                                    text:
                                                                        "${product.quantitySeparate}", // La cantidad en color rojo
                                                                    style: TextStyle(
                                                                        color:
                                                                            primaryColorApp,
                                                                        fontSize:
                                                                            12), // Estilo solo para la cantidad
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          if (product
                                                                  .isCertificate ==
                                                              0)
                                                            RichText(
                                                              text:
                                                                  const TextSpan(
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14, // Tamaño del texto
                                                                  color: Colors
                                                                      .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                                ),
                                                                children: <TextSpan>[
                                                                  TextSpan(
                                                                      text:
                                                                          "Cantidad: ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              black)), // Parte del texto en color negro (o el color que prefieras)

                                                                  TextSpan(
                                                                    text:
                                                                        "No certificado", // La cantidad en color rojo
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            12), // Estilo solo para la cantidad
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          //icono de check

                                                          Visibility(
                                                            visible: product
                                                                    .isCertificate ==
                                                                0,
                                                            child: const Icon(
                                                                Icons.warning,
                                                                color: Colors
                                                                    .amber,
                                                                size: 15),
                                                          ),
                                                          //icono de check
                                                          Visibility(
                                                            visible: product
                                                                    .isCertificate ==
                                                                1,
                                                            child: const Icon(
                                                                Icons.check,
                                                                color: green,
                                                                size: 15),
                                                          ),
                                                          const Spacer(),
                                                          RichText(
                                                            text: TextSpan(
                                                              style:
                                                                  const TextStyle(
                                                                fontSize:
                                                                    14, // Tamaño del texto
                                                                color: Colors
                                                                    .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                              ),
                                                              children: <TextSpan>[
                                                                const TextSpan(
                                                                    text:
                                                                        "Unidades: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            black)), // Parte del texto en color negro (o el color que prefieras)
                                                                TextSpan(
                                                                  text:
                                                                      "${product.unidades}", // La cantidad en color rojo
                                                                  style: TextStyle(
                                                                      color:
                                                                          primaryColorApp,
                                                                      fontSize:
                                                                          12), // Estilo solo para la cantidad
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      // Row(
                                                      //   children: [
                                                      //     RichText(
                                                      //       text: TextSpan(
                                                      //         style: const TextStyle(
                                                      //           fontSize:
                                                      //               14, // Tamaño del texto
                                                      //           color: Colors
                                                      //               .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                      //         ),
                                                      //         children: <TextSpan>[
                                                      //           const TextSpan(
                                                      //               text:
                                                      //                   "Cantidad solicitada: ",
                                                      //               style: TextStyle(
                                                      //                   fontSize: 12,
                                                      //                   color:
                                                      //                       black)), // Parte del texto en color negro (o el color que prefieras)
                                                      //           TextSpan(
                                                      //             text:
                                                      //                 "${product.quantity}", // La cantidad en color rojo
                                                      //             style: TextStyle(
                                                      //                 color:
                                                      //                     primaryColorApp,
                                                      //                 fontSize:
                                                      //                     12), // Estilo solo para la cantidad
                                                      //           ),
                                                      //         ],
                                                      //       ),
                                                      //     ),
                                                      //     const Spacer(),
                                                      //     RichText(
                                                      //       text: TextSpan(
                                                      //         style: const TextStyle(
                                                      //           fontSize:
                                                      //               14, // Tamaño del texto
                                                      //           color: Colors
                                                      //               .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                      //         ),
                                                      //         children: <TextSpan>[
                                                      //           const TextSpan(
                                                      //               text: "Peso: ",
                                                      //               style: TextStyle(
                                                      //                   fontSize: 12,
                                                      //                   color:
                                                      //                       black)), // Parte del texto en color negro (o el color que prefieras)
                                                      //           TextSpan(
                                                      //             text:
                                                      //                 "${product.weight}", // La cantidad en color rojo
                                                      //             style: TextStyle(
                                                      //                 color:
                                                      //                     primaryColorApp,
                                                      //                 fontSize:
                                                      //                     12), // Estilo solo para la cantidad
                                                      //           ),
                                                      //         ],
                                                      //       ),
                                                      //     ),
                                                      //   ],
                                                      // ),

                                                      Visibility(
                                                        visible: product
                                                                .isCertificate ==
                                                            0,
                                                        child: Row(
                                                          children: [
                                                            RichText(
                                                              text: TextSpan(
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      14, // Tamaño del texto
                                                                  color: Colors
                                                                      .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                                ),
                                                                children: <TextSpan>[
                                                                  const TextSpan(
                                                                      text:
                                                                          "Cantidad empacada: ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              black)), // Parte del texto en color negro (o el color que prefieras)

                                                                  TextSpan(
                                                                    text:
                                                                        "${product.quantity}", // La cantidad en color rojo
                                                                    style: TextStyle(
                                                                        color:
                                                                            primaryColorApp,
                                                                        fontSize:
                                                                            12), // Estilo solo para la cantidad
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: product
                                                                .isCertificate ==
                                                            1,
                                                        child: Row(
                                                          children: [
                                                            RichText(
                                                              text: TextSpan(
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      14, // Tamaño del texto
                                                                  color: Colors
                                                                      .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                                ),
                                                                children: <TextSpan>[
                                                                  const TextSpan(
                                                                      text:
                                                                          "Novedad: ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              black)), // Parte del texto en color negro (o el color que prefieras)
                                                                  if (product
                                                                          .isProductSplit ==
                                                                      1)
                                                                    TextSpan(
                                                                      text:
                                                                          "Producto en diferentes paquetes", // La cantidad en color rojo
                                                                      style: TextStyle(
                                                                          color:
                                                                              primaryColorApp,
                                                                          fontSize:
                                                                              12), // Estilo solo para la cantidad
                                                                    ),
                                                                  if (product
                                                                          .isProductSplit ==
                                                                      null)
                                                                    TextSpan(
                                                                      text: product.observation ==
                                                                              null
                                                                          ? "Sin novedad"
                                                                          : "${product.observation}", // La cantidad en color rojo
                                                                      style: TextStyle(
                                                                          color:
                                                                              primaryColorApp,
                                                                          fontSize:
                                                                              12), // Estilo solo para la cantidad
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ), // Muestra la cantidad
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      if (package.isSticker == true)
                                        ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                minimumSize:
                                                    Size(size.width, 35),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.print),
                                                SizedBox(width: 10),
                                                Text(
                                                  "Imprimir sticker",
                                                  style:
                                                      TextStyle(color: black),
                                                )
                                              ],
                                            )),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
