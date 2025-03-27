// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/info_rapida_model.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/bloc/info_rapida_bloc.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/widgets/info_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class LocationInfoScreen extends StatelessWidget {
  final InfoRapidaResult? infoRapidaResult;

  const LocationInfoScreen({Key? key, this.infoRapidaResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => InfoRapidaBloc(),
      child: BlocConsumer<InfoRapidaBloc, InfoRapidaState>(
        listener: (context, state) {
          if (state is InfoRapidaLoading) {
            showDialog(
              context: context,
              builder: (context) {
                return const DialogLoading(
                  message: "Buscando informacion...",
                );
              },
            );
          }

          if (state is InfoRapidaLoaded) {
            Navigator.pop(context);
            if (state.infoRapidaResult.type == 'product') {
              Navigator.pushReplacementNamed(context, 'product-info',
                  arguments: [state.infoRapidaResult]);
            }
          }
          if (state is InfoRapidaError) {
            Navigator.pop(context);
            Get.snackbar(
              '360 Software Informa',
              'No se encontró información.',
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: Icon(Icons.error, color: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final ubicacion = infoRapidaResult?.result;
          return Scaffold(
            backgroundColor: white,
            body: SizedBox(
              width: size.width * 1,
              height: size.height * 1,
              child: Column(
                children: [
                  AppBar(size: size),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ubicación",
                        style: TextStyle(
                            color: black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: size.width * 1,
                      child: Card(
                        elevation: 3,
                        color: white,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    ubicacion?.nombre ?? 'Sin nombre',
                                    style: TextStyle(
                                        color: black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ProductInfoRow(
                                  title: 'Ubicación padre:',
                                  value:
                                      ubicacion?.ubicacionPadre ?? "Sin nombre",
                                ),
                                ProductInfoRow(
                                  title: 'Ubicación tipo: ',
                                  value: '${ubicacion?.tipoUbicacion}',
                                ),
                                ProductInfoRow(
                                  title: 'Ubicación barcode: ',
                                  value: '${ubicacion?.codigoBarras}',
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Productos",
                        style: TextStyle(
                            color: black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  //listado de ubicaciones
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: ubicacion?.productos?.length ?? 0,
                            itemBuilder: (context, index) {
                              final producto = ubicacion?.productos?[index];
                              return Card(
                                  color: white,
                                  elevation: 3,
                                  child: ListTile(
                                    trailing: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          size: 20, color: primaryColorApp),
                                      onPressed: () async {
                                        if (producto!
                                                .codigoBarras?.isNotEmpty ==
                                            true) {
                                          getInfoProduct(
                                              producto.codigoBarras ?? '',
                                              context);
                                        } else {
                                          Get.snackbar(
                                            '360 Software Informa',
                                            'El producto no tiene codigo de barras',
                                            backgroundColor: white,
                                            colorText: primaryColorApp,
                                            icon: Icon(Icons.error,
                                                color: Colors.green),
                                          );
                                        }
                                      },
                                    ),
                                    onTap: () async {
                                      // showDialog(
                                      //     context: context,
                                      //     builder: (context) {
                                      //       return const DialogLoading(
                                      //           message:
                                      //               'Buscando Producto ...');
                                      //     });

                                      // await Future.delayed(const Duration(
                                      //     seconds:
                                      //         1)); // Ajusta el tiempo si es necesario

                                      // Navigator.pop(context);
                                      // Navigator.pushReplacementNamed(
                                      //   context,
                                      //   'product-info',
                                      // );
                                      if (producto!.codigoBarras?.isNotEmpty ==
                                          true) {
                                        getInfoProduct(
                                            producto.codigoBarras ?? '',
                                            context);
                                      } else {
                                        Get.snackbar(
                                          '360 Software Informa',
                                          'El producto no tiene codigo de barras',
                                          backgroundColor: white,
                                          colorText: primaryColorApp,
                                          icon: Icon(Icons.error,
                                              color: Colors.green),
                                        );
                                      }
                                    },
                                    title: Text(
                                      producto?.producto ?? 'Sin nombre',
                                      style: TextStyle(
                                          color: primaryColorApp,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      children: [
                                        ProductInfoRow(
                                          title: 'Cantidad: ',
                                          value: '${producto?.cantidad}',
                                        ),
                                      ],
                                    ),
                                  ));
                            })),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void getInfoProduct(String barcode, BuildContext context) {
    context.read<InfoRapidaBloc>().add(GetInfoRapida(barcode));
  }
}

class AppBar extends StatelessWidget {
  const AppBar({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    bottom: 10,
                    top: status != ConnectionStatus.online ? 0 : 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: white),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          'info-rapida',
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.1),
                      child: const Text("INFORMACIÓN RÁPIDA",
                          style: TextStyle(color: white, fontSize: 18)),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
