import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/modules/quick%20info/bloc/info_rapida_bloc.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/modules/quick%20info/widgets/dialog_info_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import '../../providers/network/cubit/warning_widget_cubit.dart';

class InfoRapidaScreen extends StatefulWidget {
  const InfoRapidaScreen({super.key});

  @override
  State<InfoRapidaScreen> createState() => _InfoRapidaScreenState();
}

class _InfoRapidaScreenState extends State<InfoRapidaScreen> {
  final TextEditingController _controllerSearch = TextEditingController();
  final FocusNode focusNode1 = FocusNode();

  @override
  void dispose() {
    focusNode1.dispose();
    _controllerSearch.dispose();
    super.dispose();
  }

  void validateBarcode(String value) {
    final bloc = context.read<InfoRapidaBloc>();
    final scan = bloc.scannedValue1.trim().isEmpty ? value : bloc.scannedValue1.trim();
    _controllerSearch.text = '';
    bloc.add(GetInfoRapida(scan.toUpperCase(), false, false));
  }

  @override
  Widget build(BuildContext context) {
    final isZebra = context.select((UserBloc b) => b.fabricante).contains("Zebra");

    return BlocConsumer<InfoRapidaBloc, InfoRapidaState>(
      listenWhen: (previous, current) => current is! InfoRapidaInitial,
      buildWhen: (previous, current) => current is InfoRapidaInitial || current is InfoRapidaLoaded,
      listener: (context, state) {
        if (state is InfoRapidaError) {
          Navigator.pop(context);
          Get.snackbar(
            '360 Software Informa',
            'No se encontró producto, lote, paquete ni ubicación con ese código de barras',
            backgroundColor: white,
            colorText: primaryColorApp,
            icon: const Icon(Icons.error, color: Colors.red),
          );
        } else if (state is InfoRapidaLoading) {
          showDialog(
            context: context,
            builder: (context) => const DialogLoading(message: "Buscando información..."),
          );
        } else if (state is InfoRapidaLoaded) {
          Navigator.pop(context);
          Future.microtask(() {
            Get.snackbar(
              '360 Software Informa',
              'Información encontrada',
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: const Icon(Icons.check_circle, color: Colors.green),
            );
            if (state.infoRapidaResult.type == 'product') {
              Navigator.pushReplacementNamed(context, 'product-info');
            } else if (state.infoRapidaResult.type == 'ubicacion') {
              Navigator.pushReplacementNamed(
                context,
                'location-info',
                arguments: [state.infoRapidaResult],
              );
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: white,
          floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColorApp,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const DialogInfoQuick(),
            ),
            child: const Icon(Icons.search, color: white),
          ),
          body: Column(
            children: [
              const CustomAppBar(),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Image.asset(
                      'assets/icons/barcode.png',
                      width: 150,
                      height: 150,
                      color: black,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Este es el módulo de información rápida de 360 software para OnPoint. Escanee un código de barras de PRODUCTO, LOTE/SERIE o una UBICACIÓN para obtener toda su información.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    isZebra
                        ? TextFormField(
                            controller: _controllerSearch,
                            focusNode: focusNode1,
                            autofocus: true,
                            showCursor: false,
                            onChanged: validateBarcode,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 14, color: black),
                            ),
                          )
                        : Focus(
                            focusNode: focusNode1,
                            autofocus: true,
                            onKey: (node, event) {
                              if (event is RawKeyDownEvent) {
                                if (event.logicalKey == LogicalKeyboardKey.enter) {
                                  validateBarcode(context.read<InfoRapidaBloc>().scannedValue1);
                                  return KeyEventResult.handled;
                                } else {
                                  context.read<InfoRapidaBloc>().add(UpdateScannedValueEvent(event.data.keyLabel));
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: const SizedBox(),
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
      builder: (context, status) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryColorApp,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const WarningWidgetCubit(),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                  top: status != ConnectionStatus.online ? 0 : 35,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: white),
                      onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    ),
                    const Spacer(),
                    const Text(
                      "INFORMACIÓN RÁPIDA",
                      style: TextStyle(color: white, fontSize: 18),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
