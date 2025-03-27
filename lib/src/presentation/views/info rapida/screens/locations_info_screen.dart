// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/widgets/info_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class LocationInfoScreen extends StatelessWidget {
  const LocationInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: white,
      body: Container(
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
                      color: black, fontSize: 13, fontWeight: FontWeight.bold),
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
                              "R13B1",
                              style: TextStyle(
                                  color: black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ProductInfoRow(
                            title: 'Ubicación padre: ',
                            value: 'SM/Stock/Nivel1',
                          ),
                          ProductInfoRow(
                            title: 'Ubicación tipo: ',
                            value: 'Ubicación interna',
                          ),
                          ProductInfoRow(
                            title: 'Ubicación barcode: ',
                            value: 'WH/Stock/Nivel1/',
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
                      color: black, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            //listado de ubicaciones
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Card(
                            color: white,
                            elevation: 3,
                            child: ListTile(
                              trailing: IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    size: 20, color: primaryColorApp),
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const DialogLoading(
                                            message: 'Buscando Producto ...');
                                      });

                                  await Future.delayed(const Duration(
                                      seconds:
                                          1)); // Ajusta el tiempo si es necesario

                                  Navigator.pop(context);
                                  Navigator.pushReplacementNamed(
                                    context,
                                    'product-info',
                                  );
                                },
                              ),
                              onTap: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const DialogLoading(
                                          message: 'Buscando Producto ...');
                                    });

                                await Future.delayed(const Duration(
                                    seconds:
                                        1)); // Ajusta el tiempo si es necesario

                                Navigator.pop(context);
                                Navigator.pushReplacementNamed(
                                  context,
                                  'product-info',
                                );
                              },
                              title: Text(
                                '[$index] 0971238- Limpiador PVC PALC X 12 ONZAS (355CC)',
                                style: TextStyle(
                                    color: primaryColorApp,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                children: [
                                  ProductInfoRow(
                                    title:
                                        'Cantidad: ', // Este parece repetido, si es correcto, déjalo así
                                    value: '60.0',
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
