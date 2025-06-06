// ignore_for_file: unrelated_type_equality_checks, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/individual/screens/widgets/others/dialog_view_img_temp_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab4Screen extends StatelessWidget {
  const Tab4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<WmsPackingBloc, WmsPackingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 10),
                  // width: double.infinity,
                  // height: size.height * 0.7,
                  child: (context
                          .read<WmsPackingBloc>()
                          .productsDonePacking
                          .isEmpty)
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('No hay productos listos',
                                  style: TextStyle(fontSize: 14, color: grey)),
                              Text('Intente con otro pedido o batch',
                                  style: TextStyle(fontSize: 12, color: grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: context
                              .read<WmsPackingBloc>()
                              .productsDonePacking
                              .length,
                          itemBuilder: (context, index) {
                            final product = context
                                .read<WmsPackingBloc>()
                                .productsDonePacking[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: GestureDetector(
                                onTap: () {
                                  print("Producto: ${product.toJson()}");
                                },
                                child: Card(
                                    color: product.isSeparate == 1
                                        ? Colors.green[100]
                                        : Colors.white,
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Producto:",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: primaryColorApp,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.65,
                                                  child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          " ${product.productId}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black))),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Card(
                                            elevation: 3,
                                            color: white,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Certificado: ",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              primaryColorApp,
                                                        ),
                                                      ),
                                                      Text(
                                                          product.isCertificate ==
                                                                  0
                                                              ? "No"
                                                              : "Si",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)),
                                                      const Spacer(),
                                                      Text(
                                                        "Unidades: ",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              primaryColorApp,
                                                        ),
                                                      ),
                                                      Text(
                                                          "${product.unidades}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)),
                                                    ],
                                                  ),
                                                  Visibility(
                                                    visible: product
                                                            .manejaTemperatura ==
                                                        1,
                                                    child: Row(
                                                      children: [
                                                       
                                                        Text(
                                                          "Temperatura: ",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                primaryColorApp,
                                                          ),
                                                        ),
                                                        Text(
                                                            "${product.temperatura}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                        const Spacer(),
                                                        Visibility(
                                                          visible:
                                                              product.image !=
                                                                  "",
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              showImageDialog(
                                                                context,
                                                                product.image ??
                                                                    '', // URL o path de la imagen
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.image,
                                                              color:
                                                                  primaryColorApp,
                                                              size: 23,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Cantidad empacada: ",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              primaryColorApp,
                                                        ),
                                                      ),
                                                      Text(
                                                          product.isCertificate ==
                                                                  0
                                                              ? "${product.quantity}"
                                                              : "${product.quantitySeparate}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Paquete: ",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              primaryColorApp,
                                                        ),
                                                      ),
                                                      Text(
                                                          "${product.packageName}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)),
                                                    ],
                                                  ),
                                                  if (product.observation !=
                                                      null)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Novedad: ",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                primaryColorApp,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              size.width * 0.55,
                                                          child: Text(
                                                              "${product.observation}",
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          black)),
                                                        ),
                                                        const Spacer(),
                                                        Visibility(
                                                          visible: product
                                                                  .imageNovedad !=
                                                              "",
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              showImageDialog(
                                                                context,
                                                                product.imageNovedad ??
                                                                    '', // URL o path de la imagen
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.image,
                                                              color:
                                                                  primaryColorApp,
                                                              size: 23,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  if (product.isProductSplit ==
                                                      1)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Novedad: ",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                primaryColorApp,
                                                          ),
                                                        ),
                                                        const Text(
                                                          "Producto en diferentes paquetes",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (product.tracking == 'lot')
                                            Row(
                                              children: [
                                                Text(
                                                  "Numero de serie/lote: ",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: primaryColorApp,
                                                  ),
                                                ),
                                                Text(" ${product.lotId}",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: black)),
                                              ],
                                            ),
                                          Row(
                                            children: [
                                              Text(
                                                "Peso: ",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              Text("${product.weight}",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: black)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                            );
                          }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
