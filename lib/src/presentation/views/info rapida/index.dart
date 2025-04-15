import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/quick%20info/bloc/info_rapida_bloc.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/quick%20info/widgets/dialog_info_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class InfoRapidaScreen extends StatefulWidget {
  const InfoRapidaScreen({super.key});

  @override
  State<InfoRapidaScreen> createState() => _InfoRapidaScreenState();
}

class _InfoRapidaScreenState extends State<InfoRapidaScreen> {
  final TextEditingController _controllerSearch = TextEditingController();

  final FocusNode focusNode1 = FocusNode(); //product

  @override
  void dispose() {
    focusNode1.dispose();
    super.dispose();
  }

  void validateBarcode(String value, BuildContext context) {
    print('value: $value');

    final bloc = context.read<InfoRapidaBloc>();

    String scan =
        bloc.scannedValue1.trim() == "" ? value : bloc.scannedValue1.trim();
    _controllerSearch.text = "";
    //validamos que el scan no este vacio

    bloc.add(GetInfoRapida(scan.toUpperCase(), false, false));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<InfoRapidaBloc, InfoRapidaState>(
      listener: (context, state) {
        if (state is InfoRapidaError) {
          Navigator.pop(context);
          Get.snackbar(
            '360 Software Informa',
            'No se encontró producto, lote, paquete ni ubicación con ese código de barras',
            backgroundColor: white,
            colorText: primaryColorApp,
            icon: Icon(Icons.error, color: Colors.red),
          );
        }

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
          Get.snackbar(
            '360 Software Informa',
            'Información encontrada',
            backgroundColor: white,
            colorText: primaryColorApp,
            icon: Icon(Icons.error, color: Colors.green),
          );

          if (state.infoRapidaResult.type == 'product') {
            Navigator.pushReplacementNamed(
              context,
              'product-info',
            );
          } else if (state.infoRapidaResult.type == "ubicacion") {
            Navigator.pushReplacementNamed(context, 'location-info',
                arguments: [state.infoRapidaResult]);
          }
        }
      },
      builder: (context, state) {
        final bloc = context.watch<InfoRapidaBloc>();
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: primaryColorApp,
              onPressed: () {
                //mostramos dialogo
                showDialog(
                  context: context,
                  builder: (context) {
                    return DialogInfoQuick();
                  },
                );
              },
              child: const Icon(Icons.search, color: white),
            ),
            backgroundColor: white,
            body: SizedBox(
                width: size.width * 1,
                height: size.height * 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //appbar
                      AppBar(size: size),
                      Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Image.asset(
                                'assets/icons/barcode.png',
                                width: 150,
                                height: 150,
                                color: black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Este es el modulo de informacion rapida de 360 software para OnPoint, escanee un codigo de barras de PRODUCTO, LOTE/SERIE o una UBICACIÓN para obtener toda su informacion. ",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: black),
                            ),
                          ),

                          //*espacio para escanear y buscar

                          context.read<UserBloc>().fabricante.contains("Zebra")
                              ? Container(
                                  height: 15,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    autofocus: true,
                                    showCursor: false,
                                    controller: _controllerSearch,
                                    focusNode: focusNode1,
                                    onChanged: (value) {
                                      print('value: $value');
                                      // Llamamos a la validación al cambiar el texto
                                      validateBarcode(value, context);
                                    },
                                    decoration: InputDecoration(
                                      disabledBorder: InputBorder.none,
                                      hintStyle: const TextStyle(
                                          fontSize: 14, color: black),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                )
                              :

                              //*focus para leer
                              Focus(
                                  focusNode: focusNode1,
                                  autofocus: true,
                                  onKey: (FocusNode node, RawKeyEvent event) {
                                    if (event is RawKeyDownEvent) {
                                      if (event.logicalKey ==
                                          LogicalKeyboardKey.enter) {
                                        validateBarcode(
                                            bloc.scannedValue1, context);
                                        return KeyEventResult.handled;
                                      } else {
                                        bloc.add(UpdateScannedValueEvent(
                                          event.data.keyLabel,
                                        ));
                                        return KeyEventResult.handled;
                                      }
                                    }
                                    return KeyEventResult.ignored;
                                  },
                                  child: Container()),
                          //*espacio para escanear y buscar por ubicacion

                          SizedBox(
                            height: size.height * 0.15,
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
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
                          'home',
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
