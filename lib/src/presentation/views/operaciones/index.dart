// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

import '../../providers/network/cubit/connection_status_cubit.dart';

class OperacionesScreen extends StatelessWidget {
  const OperacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: white,
      body: SizedBox(
          width: size.width * 1,
          height: size.height * 1,
          child: SingleChildScrollView(
            child: Column(
              children: [
                //* appbar
                AppBar(size: size),

                //listdo de operaciones
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 5, top: 5, left: 10, right: 10),
                  child: Card(
                    elevation: 3,
                    color: white,
                    child: ListTile(
                      leading: const Image(
                        image: AssetImage('assets/icons/recepcion.png'),
                        width: 50,
                        height: 50,
                      ),
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: primaryColorApp),
                      title: Text('Recepción',
                          style:
                              TextStyle(color: primaryColorApp, fontSize: 14)),
                      subtitle: const Text(
                        'Ordenes de compra',
                        style: TextStyle(color: black, fontSize: 12),
                      ),
                      onTap: () async {
                        context.read<RecepcionBloc>().add(FetchOrdenesCompraOfBd(
                            context)); // Llama al evento FetchOrdenesCompra
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const DialogLoading(
                                  message: 'Cargando interfaz...');
                            });

                        await Future.delayed(const Duration(
                            seconds: 1)); // Ajusta el tiempo si es necesario

                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                          context,
                          'list-ordenes-compra',
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 5, left: 10, right: 10),
                  child: Card(
                    elevation: 3,
                    color: white,
                    child: ListTile(
                      onTap: () async {},
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: const Image(
                          image: AssetImage('assets/icons/transferencia.png'),
                          width: 35,
                          height: 35,
                        ),
                      ),
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: primaryColorApp),
                      title: Text('Transferencias internas',
                          style:
                              TextStyle(color: primaryColorApp, fontSize: 14)),
                      subtitle: const Text(
                        'Transferencias internas',
                        style: TextStyle(color: black, fontSize: 12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
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
                          'home',
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.1),
                      child: const Text("OPERACIONES ALMACEN",
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
