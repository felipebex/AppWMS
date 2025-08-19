// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/un_packing_request.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/screens/widgets/dialog_unPacking.dart';

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

  void _showQRDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Center(
              child: Text(
            "Información del paquete",
            style: const TextStyle(
              color: primaryColorApp,
              fontSize: 16,
            ),
          )),
          content: SizedBox(
            height: 200, // Establecemos el tamaño del dialogo
            width: 200,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Esto hace que el contenido sea flexible
              children: [
                QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
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
              body: Column(
                children: [
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
                            // Header con título y botón
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  packingModel?.name ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primaryColorApp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    context.read<WmsPackingBloc>().viewDetail
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: primaryColorApp,
                                  ),
                                  onPressed: () {
                                    context.read<WmsPackingBloc>().add(
                                        ShowDetailvent(context
                                            .read<WmsPackingBloc>()
                                            .viewDetail));
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  iconSize: 24,
                                ),
                              ],
                            ),

                            // Contenido colapsable
                            AnimatedSize(
                              duration: Duration(milliseconds: 300),
                              child: context.read<WmsPackingBloc>().viewDetail
                                  ? Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Referencia: ',
                                              style: TextStyle(
                                                  fontSize: 12, color: black),
                                            ),
                                            Text(
                                              packingModel?.referencia ?? '',
                                              style: TextStyle(
                                                  fontSize: 12, color: black),
                                            ),
                                          ],
                                        ),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Contacto: ',
                                            style: TextStyle(
                                                fontSize: 12, color: black),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            packingModel?.contactoName ?? '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Total productos del pedido: ',
                                              style: TextStyle(
                                                  fontSize: 12, color: black),
                                            ),
                                            Text(
                                              packingModel?.cantidadProductos
                                                      .toStringAsFixed(2) ??
                                                  "",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              batchModel?.name ?? "",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Total productos empacados: ',
                                              style: TextStyle(
                                                  fontSize: 12, color: black),
                                            ),
                                            Text(
                                              context
                                                  .read<WmsPackingBloc>()
                                                  .listOfProductos
                                                  .where((element) =>
                                                      element.isPackage == 1)
                                                  .length
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Operacion: ',
                                              style: TextStyle(
                                                  fontSize: 12, color: black),
                                            ),
                                            Text(
                                              packingModel?.tipoOperacion ?? "",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Numero de paquetes: ',
                                              style: TextStyle(
                                                  fontSize: 12, color: black),
                                            ),
                                            Text(
                                              context
                                                  .read<WmsPackingBloc>()
                                                  .packages
                                                  .length
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp),
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                          visible:
                                              packingModel?.isTerminate != 1,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                if (context
                                                    .read<WmsPackingBloc>()
                                                    .packages
                                                    .isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                        'No se puede confirmar un pedido sin empaques',
                                                        style: TextStyle(
                                                            color: white),
                                                      ),
                                                      backgroundColor:
                                                          Colors.red[200],
                                                    ),
                                                  );
                                                  return;
                                                } else if (context
                                                        .read<WmsPackingBloc>()
                                                        .productsDone
                                                        .isNotEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                        'No se puede confirmar un pedido con productos en estado preparado',
                                                        style: TextStyle(
                                                            color: white),
                                                      ),
                                                      backgroundColor:
                                                          Colors.red[200],
                                                    ),
                                                  );
                                                  return;
                                                }

                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 5,
                                                                sigmaY: 5),
                                                        child: AlertDialog(
                                                          backgroundColor:
                                                              Colors.white,
                                                          actionsAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          title: Text(
                                                            'Confirmar pedido',
                                                            style: TextStyle(
                                                                color:
                                                                    primaryColorApp,
                                                                fontSize: 16),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SizedBox(
                                                                height: 100,
                                                                width: 200,
                                                                child:
                                                                    Image.asset(
                                                                  "assets/images/icono.jpeg",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              const Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  '¿Estás seguro de confirmar el pedido y dejarlo listo para ser enviado?',
                                                                  style: TextStyle(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          14),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    grey,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'Cancelar',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                await DataBaseSqlite()
                                                                    .pedidosPackingRepository
                                                                    .setFieldTablePedidosPacking(
                                                                      packingModel
                                                                              ?.batchId ??
                                                                          0,
                                                                      packingModel
                                                                              ?.id ??
                                                                          0,
                                                                      "is_terminate",
                                                                      1,
                                                                    );
                                                                context
                                                                    .read<
                                                                        WmsPackingBloc>()
                                                                    .add(
                                                                        LoadAllPedidosFromBatchEvent(
                                                                      packingModel
                                                                              ?.batchId ??
                                                                          0,
                                                                    ));

                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.pushReplacementNamed(
                                                                    context,
                                                                    'packing-list',
                                                                    arguments: [
                                                                      batchModel
                                                                    ]);
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
                                                              child: const Text(
                                                                'Aceptar',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(
                                                  size.width * 0.9,
                                                  30, // Alto
                                                ),
                                                backgroundColor:
                                                    primaryColorApp,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                'Confirmar pedido',
                                                style: TextStyle(
                                                    color: white, fontSize: 12),
                                              )),
                                        ),
                                      ],
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!context.read<WmsPackingBloc>().viewDetail) ...[
                    Text("Listado de empaques",
                        style: TextStyle(
                            fontSize: 14,
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
                                        style: TextStyle(
                                            fontSize: 14, color: grey)),
                                    Text('Realiza el proceso de empaque',
                                        style: TextStyle(
                                            fontSize: 12, color: grey)),
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
                                                fontSize: 12,
                                                color: primaryColorApp),
                                          ),
                                          Text(
                                            "${package.consecutivo}",
                                            style: TextStyle(
                                                fontSize: 10, color: black),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Cantidad de productos: ${package.cantidadProductos}",
                                                style: const TextStyle(
                                                    fontSize: 12, color: black),
                                              ),
                                              const Spacer(),
                                              GestureDetector(
                                                onTap: () async {
                                                  var url = await PrefUtils
                                                      .getEnterprise();

                                                  url =
                                                      '$url/package/info/${package.name}';

                                                  _showQRDialog(context, url);
                                                },
                                                child: Icon(
                                                  Icons.qr_code,
                                                  color: primaryColorApp,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              // if (package.isSticker == true)
                                              //   GestureDetector(
                                              //     onTap: () async {
                                              //       showDialog(
                                              //         context: context,
                                              //         builder: (BuildContext
                                              //             context) {
                                              //           return PrintDialog(
                                              //               model: PrintModel(
                                              //             batchName: batchModel
                                              //                     ?.name ??
                                              //                 '',
                                              //             batchId:
                                              //                 batchModel?.id ??
                                              //                     0,
                                              //             pickingTypeId: batchModel
                                              //                     ?.pickingTypeId ??
                                              //                 '',
                                              //             cantidadPedidos:
                                              //                 batchModel
                                              //                         ?.cantidadPedidos ??
                                              //                     0,
                                              //             //ddatos pedido
                                              //             namePedido:
                                              //                 packingModel
                                              //                         ?.name ??
                                              //                     '',
                                              //             referencia: packingModel
                                              //                     ?.referencia ??
                                              //                 '',
                                              //             contacto: packingModel
                                              //                     ?.contacto ??
                                              //                 '0',
                                              //             contactoName: packingModel
                                              //                     ?.contactoName ??
                                              //                 '',
                                              //             tipoOperacion:
                                              //                 packingModel
                                              //                         ?.tipoOperacion ??
                                              //                     '',
                                              //             cantidadProductos:
                                              //                 packingModel
                                              //                         ?.cantidadProductos ??
                                              //                     0,
                                              //             numeroPaquetes: context
                                              //                 .read<
                                              //                     WmsPackingBloc>()
                                              //                 .packages
                                              //                 .length,
                                              //             //datos paquete
                                              //             idPaquete: 0,
                                              //             namePaquete:
                                              //                 package.name,
                                              //             cantProductoPack: package
                                              //                 .cantidadProductos,
                                              //             zonaEntregaTms: batchModel
                                              //                     ?.zonaEntregaTms ??
                                              //                 '',
                                              //           ));
                                              //         },
                                              //       );
                                              //     },
                                              //     child: Icon(
                                              //       Icons.print,
                                              //       color: primaryColorApp,
                                              //       size: 20,
                                              //     ),
                                              //   )
                                            ],
                                          ),
                                        ],
                                      ),
                                      children: [
                                        // Aquí generamos la lista de productos filtrados
                                        SizedBox(
                                          height: 200,
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
                                                        if (product.barcode !=
                                                            null)
                                                          GestureDetector(
                                                            onTap: () {
                                                              //validar si el producto  actual se encuentra  la lista de por hacer

                                                              bool isInProgress = context
                                                                  .read<
                                                                      WmsPackingBloc>()
                                                                  .listOfProductosProgress
                                                                  .any((p) =>
                                                                      p.productId ==
                                                                      product
                                                                          .productId);
                                                              if (isInProgress) {
                                                                Get.defaultDialog(
                                                                  title:
                                                                      '360 Software Informa',
                                                                  titleStyle: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          18),
                                                                  middleText:
                                                                      "Este producto se encuentra en estado por hacer, por favor seleccione otro para desempacar",
                                                                  middleTextStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              black,
                                                                          fontSize:
                                                                              14),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  radius: 10,
                                                                  actions: [
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        Get.back();
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            primaryColorApp,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                        ),
                                                                      ),
                                                                      child: Text(
                                                                          'Aceptar',
                                                                          style:
                                                                              TextStyle(color: white)),
                                                                    ),
                                                                  ],
                                                                );
                                                                return;
                                                              }

                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (_) =>
                                                                    DialogUnPacking(
                                                                  product:
                                                                      product,
                                                                  package:
                                                                      package,
                                                                  onConfirm:
                                                                      () async {
                                                                    final idOperario =
                                                                        await PrefUtils
                                                                            .getUserId();

                                                                    context
                                                                        .read<
                                                                            WmsPackingBloc>()
                                                                        .add(UnPackingEvent(
                                                                            UnPackingRequest(
                                                                              idBatch: package.batchId ?? 0,
                                                                              idPaquete: package.id ?? 0,
                                                                              listItem: [
                                                                                ListItemUnpack(
                                                                                  idMove: product.idMove ?? 0,
                                                                                  productId: product.idProduct ?? 0,
                                                                                  lote: product.loteId,
                                                                                  locationId: product.idLocation ?? 0,
                                                                                  cantidadSeparada: product.isCertificate == 0 ? product.quantity ?? 0 : product.quantitySeparate ?? 0,
                                                                                  observacion: "Desempacado",
                                                                                  idOperario: idOperario,
                                                                                )
                                                                              ],
                                                                            ),
                                                                            product.pedidoId ?? 0,
                                                                            package.consecutivo ?? 0));
                                                                  },
                                                                ),
                                                              );
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
                                                                      text: product
                                                                          .quantitySeparate
                                                                          .toStringAsFixed(
                                                                              2), // La cantidad en color rojo
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
                                                                      text: product
                                                                          .quantity
                                                                          .toStringAsFixed(
                                                                              2), // La cantidad en color rojo
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
                                                                  .manejaTemperatura ==
                                                              1,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .thermostat,
                                                                color:
                                                                    primaryColorApp,
                                                                size: 15,
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
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
                                                                            "Temperatura: ",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                black)), // Parte del texto en color negro (o el color que prefieras)
                                                                    TextSpan(
                                                                      text: product.temperatura ==
                                                                              null
                                                                          ? "Sin temperatura"
                                                                          : "${product.temperatura}", // La cantidad en color rojo
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
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    )
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
