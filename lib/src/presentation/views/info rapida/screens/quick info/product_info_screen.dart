// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/info_rapida_model.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/quick%20info/bloc/info_rapida_bloc.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/quick%20info/widgets/info_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ProductInfoScreen extends StatelessWidget {
  final InfoRapidaResult? infoRapidaResult;

  const ProductInfoScreen({Key? key, required this.infoRapidaResult})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<InfoRapidaBloc, InfoRapidaState>(
      builder: (context, state) {
        final product = context.read<InfoRapidaBloc>().infoRapidaResult.result;
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
                      "Producto",
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
                                product?.nombre ?? 'Sin nombre',
                                style: TextStyle(
                                    color: black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ProductInfoRow(
                              title: 'Referencia: ',
                              value: product?.referencia ?? 'Sin referencia',
                            ),
                            ProductInfoRow(
                              title: 'Precio: ',
                              value: '\$${product?.precio ?? 0}',
                            ),
                            ProductInfoRow(
                              title: 'Disponible: ',
                              value: '${product?.cantidadDisponible} UND',
                            ),
                            ProductInfoRow(
                              title: 'Previsto: ',
                              value: '${product?.previsto} UND',
                            ),
                            ProductInfoRow(
                              title: 'Peso: ',
                              value: '${product?.peso} Kg',
                            ),
                            ProductInfoRow(
                              title:
                                  'Volumen: ', // Este parece repetido, si es correcto, déjalo así
                              value: '${product?.volumen} m3',
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Categoria del Producto:',
                                style: TextStyle(
                                  color: primaryColorApp,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${product?.categoria}',
                                style: TextStyle(
                                  color: black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
    
                            ProductInfoRow(
                              title: 'Barcode: ',
                              value: '${product?.codigoBarras}',
                            ),
    
                            //listado de ubicaciones
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ubicaciones",
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
                    itemCount: product?.ubicaciones?.length ?? 0,
                    itemBuilder: (context, index) {
                      final ubicacion = product?.ubicaciones?[index];
                      return Card(
                        elevation: 2,
                        color: white,
                        child: ListTile(
                          title: Text(
                            ubicacion?.ubicacion ?? 'Sin nombre',
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
                                value: '${ubicacion?.cantidad} UND',
                              ),
                              ProductInfoRow(
                                title:
                                    'CANT Reservada: ', // Este parece repetido, si es correcto, déjalo así
                                value: '${ubicacion?.reservado} UND',
                              ),
                              ProductInfoRow(
                                title:
                                    'Lote: ', // Este parece repetido, si es correcto, déjalo así
                                value: '${ubicacion?.lote}',
                              ),
                              ProductInfoRow(
                                title:
                                    'Fecha de entrada: ', // Este parece repetido, si es correcto, déjalo así
                                value: '${ubicacion?.fechaEntrada}',
                              ),
                              ProductInfoRow(
                                title:
                                    'Fecha de eliminacion: ', // Este parece repetido, si es correcto, déjalo así
                                value: '${ubicacion?.fechaEliminacion}',
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const DialogLoading(
                                        message: "Cargando informacion...",
                                      );
                                    },
                                  );
    
                                  //esperamos 1 segundo
                                  await Future.delayed(
                                    const Duration(seconds: 1),
                                  );
    
                                  Navigator.pop(context);
                                  Navigator.pushReplacementNamed(
                                      context, 'transfer-info', arguments: [
                                    infoRapidaResult,
                                    ubicacion
                                  ]);
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: size.width * 0.4,
                                    child: Card(
                                      color: white,
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.compare_arrows_sharp,
                                              color: primaryColorApp,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 5),
                                            Text('TRANSFERIR',
                                                style: TextStyle(
                                                    color: primaryColorApp,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        );
      },
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
