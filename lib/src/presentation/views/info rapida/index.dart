import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class InfoRapidaScreen extends StatefulWidget {
  const InfoRapidaScreen({super.key});

  @override
  State<InfoRapidaScreen> createState() => _InfoRapidaScreenState();
}

class _InfoRapidaScreenState extends State<InfoRapidaScreen> {
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerLocation = TextEditingController();

  final FocusNode focusNodeProduct = FocusNode(); //product
  final FocusNode focusNodeLocation = FocusNode(); //location

  @override
  void dispose() {
    focusNodeProduct.dispose();
    focusNodeLocation.dispose();
    super.dispose();
  }

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
                //appbar
                AppBar(size: size),
                Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Image.asset(
                          'assets/icons/barcode.png',
                          width: 150,
                          height: 150,
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

                    //*espacio para escanear y buscar el producto

                    context.read<UserBloc>().fabricante.contains("Zebra")
                        ? Container(
                            height: 15,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              autofocus: true,
                              showCursor: false,
                              controller: _controllerProduct,
                              focusNode: focusNodeProduct,
                              onChanged: (value) {
                                // Llamamos a la validación al cambiar el texto
                                // validateBarcode(value, context);
                              },
                              decoration: InputDecoration(
                                disabledBorder: InputBorder.none,
                                hintStyle:
                                    const TextStyle(fontSize: 14, color: black),
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        :

                        //*focus para leer los productos
                        Focus(
                            focusNode: focusNodeProduct,
                            autofocus: true,
                            onKey: (FocusNode node, RawKeyEvent event) {
                              if (event is RawKeyDownEvent) {
                                if (event.logicalKey ==
                                    LogicalKeyboardKey.enter) {
                                  // validateBarcode(bloc.scannedValue5, context);
                                  return KeyEventResult.handled;
                                } else {
                                  // bloc.add(UpdateScannedValueEvent(
                                  //     event.data.keyLabel, 'toDo'));
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Container()),
                    //*espacio para escanear y buscar por ubicacion

                    context.read<UserBloc>().fabricante.contains("Zebra")
                        ? Container(
                            height: 15,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              autofocus: true,
                              showCursor: false,
                              controller: _controllerLocation,
                              focusNode: focusNodeLocation,
                              onChanged: (value) {
                                // Llamamos a la validación al cambiar el texto
                                // validateBarcode(value, context);
                              },
                              decoration: InputDecoration(
                                disabledBorder: InputBorder.none,
                                hintStyle:
                                    const TextStyle(fontSize: 14, color: black),
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        :

                        //*focus para leer las ubicaciones
                        Focus(
                            focusNode: focusNodeLocation,
                            autofocus: true,
                            onKey: (FocusNode node, RawKeyEvent event) {
                              if (event is RawKeyDownEvent) {
                                if (event.logicalKey ==
                                    LogicalKeyboardKey.enter) {
                                  // validateBarcode(bloc.scannedValue5, context);
                                  return KeyEventResult.handled;
                                } else {
                                  // bloc.add(UpdateScannedValueEvent(
                                  //     event.data.keyLabel, 'toDo'));
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Container()),

                    SizedBox(
                      height: size.height * 0.15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // FocusScope.of(context)
                            //     .requestFocus(focusNodeProduct);

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
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColorApp,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: Text(
                            "PRODUCTO",
                            style: TextStyle(
                              fontSize: 14,
                              color: white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        ElevatedButton(
                          onPressed: () async{
                            // FocusScope.of(context)
                            //     .requestFocus(focusNodeLocation);

                             showDialog(
                                context: context,
                                builder: (context) {
                                  return const DialogLoading(
                                      message: 'Buscando Ubicacion ...');
                                });

                            await Future.delayed(const Duration(
                                seconds:
                                    1)); // Ajusta el tiempo si es necesario

                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(
                              context,
                              'location-info',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColorApp,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: Text(
                            "UBICACIÓN",
                            style: TextStyle(
                              fontSize: 14,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }

  //validar codigo producto
  void validateCodeProduct(String value, BuildContext context) {}

  //validar codigo ubicacion
  void validateCodeLocation(String value, BuildContext context) {}
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
