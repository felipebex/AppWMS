import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/new_product/LocationCardButton_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class NewProductConteoScreen extends StatefulWidget {
  const NewProductConteoScreen({Key? key}) : super(key: key);

  @override
  State<NewProductConteoScreen> createState() => _NewProductConteoScreenState();
}

class _NewProductConteoScreenState extends State<NewProductConteoScreen>
    with WidgetsBindingObserver {
  //*focus
  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfield
  FocusNode focusNode5 = FocusNode(); // lote

  //controller
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _controllerLote = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && mounted) {
      showDialog(
        context: context,
        builder: (context) =>
            const DialogLoading(message: "Espere un momento..."),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
      // _handleFocusAccordingToState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
            builder: (context, status) {
              return Container(
                width: size.width,
                color: primaryColorApp,
                child: BlocConsumer<ConteoBloc, ConteoState>(
                    listener: (context, state) {
                  print("❤️‍🔥 state : $state");

                  // * validamos en todo cambio de estado de cantidad separada

                  if (state is SendProductConteoSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(milliseconds: 1000),
                      content: Text(state.response.result?.msg ?? ""),
                      backgroundColor: Colors.green[200],
                    ));
                    //limpiamos los valores pa volver a iniciar con otro producto
                    cantidadController.clear();
                    context.read<ConteoBloc>().add(ResetValuesEvent());

                    context.read<ConteoBloc>().add(
                          LoadConteoAndProductsEvent(
                              ordenConteoId:
                                  state.response.result?.data?.orderId ?? 0),
                        );

                    Navigator.pushReplacementNamed(
                      context,
                      'conteo-detail',
                      arguments: [
                        1,
                        context.read<ConteoBloc>().ordenConteo,
                      ],
                    );
                  }

                  if (state is ChangeLoteIsOkState) {
                    //cambiamos el foco a cantidad cuando hemos seleccionado un lote
                    Future.delayed(const Duration(seconds: 1), () {
                      FocusScope.of(context).requestFocus(focusNode3);
                    });
                    // _handleFocusAccordingToState();
                  }

                  if (state is ChangeQuantitySeparateStateError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(milliseconds: 1000),
                      content: Text(state.msg),
                      backgroundColor: Colors.red[200],
                    ));
                  }

                  if (state is ValidateFieldsStateError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(milliseconds: 1000),
                      content: Text(state.msg),
                      backgroundColor: Colors.red[200],
                    ));
                  }

                  //*estado cando la ubicacion de origen es cambiada
                  if (state is ChangeLocationIsOkState) {
                    //cambiamos el foco
                    Future.delayed(const Duration(seconds: 1), () {
                      FocusScope.of(context).requestFocus(focusNode2);
                    });
                    // _handleFocusAccordingToState();
                  }

                  //*estado cuando el producto es leido ok
                  if (state is ChangeProductOrderIsOkState) {
                    //validamos si el producto tiene lote, si es asi pasamos el foco al lote
                    if (context
                            .read<ConteoBloc>()
                            .currentProduct
                            .productTracking ==
                        "lot") {
                      Future.delayed(const Duration(seconds: 1), () {
                        FocusScope.of(context).requestFocus(focusNode5);
                      });
                    } else {
                      Future.delayed(const Duration(seconds: 1), () {
                        FocusScope.of(context).requestFocus(focusNode3);
                      });
                    }

                    // _handleFocusAccordingToState();
                  }
                }, builder: (context, status) {
                  return Column(
                    children: [
                      const WarningWidgetCubit(),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                cantidadController.clear();

                                context
                                    .read<ConteoBloc>()
                                    .add(ResetValuesEvent());
                                // context
                                //     .read<WMSPickingBloc>()
                                //     .add(FilterBatchesBStatusEvent(
                                //       '',
                                //     ));

                                Navigator.pushReplacementNamed(
                                  context,
                                  'conteo-detail',
                                  arguments: [
                                    1,
                                    context.read<ConteoBloc>().ordenConteo,
                                  ],
                                );
                              },
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 20),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(right: size.width * 0.015),
                              child: Text(
                                'CONTEO FISICO',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              );
            },
          ),

          //todo: scaners
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 2),
              child: SingleChildScrollView(
                child: Column(children: [
                  //todo : ubicacion de origen
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: context.read<ConteoBloc>().locationIsOk
                                ? green
                                : yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Card(
                        color: context.read<ConteoBloc>().isLocationOk
                            ? context.read<ConteoBloc>().locationIsOk
                                ? Colors.green[100]
                                : Colors.grey[300]
                            : Colors.red[200],
                        elevation: 5,
                        child: Row(
                          children: [
                            Container(
                              // color: Colors.amber,
                              width: size.width * 0.85,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                              child: context
                                      .read<UserBloc>()
                                      .fabricante
                                      .contains("Zebra")
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          LocationCardButtonConteo(
                                            bloc: context.read<
                                                ConteoBloc>(), // Tu instancia de BLoC/Controlador
                                            cardColor:
                                                white, // Asegúrate que 'white' esté definido en tus colores
                                            textAndIconColor:
                                                primaryColorApp, // Usa tu color primario
                                            title: 'Ubicación de existencias',
                                            iconPath:
                                                "assets/icons/ubicacion.png",
                                            dialogTitle: '360 Software Informa',
                                            dialogMessage:
                                                "No hay ubicaciones cargadas, por favor cargues las ubicaciones",
                                            routeName: 'search-location',
                                            ubicacionFija: true,
                                          ),
                                          Container(
                                            height: 20,
                                            margin: const EdgeInsets.only(
                                                bottom: 5, top: 5),
                                            child: TextFormField(
                                              autofocus: true,
                                              showCursor: false,
                                              controller:
                                                  _controllerLocation, // Asignamos el controlador
                                              enabled: !context
                                                      .read<ConteoBloc>()
                                                      .locationIsOk && // false
                                                  !context
                                                      .read<ConteoBloc>()
                                                      .productIsOk && // false
                                                  !context
                                                      .read<ConteoBloc>()
                                                      .quantityIsOk,

                                              focusNode: focusNode1,
                                              onChanged: (value) {
                                                // Llamamos a la validación al cambiar el texto
                                                // validateLocation(value);
                                              },
                                              decoration: InputDecoration(
                                                hintText: context
                                                                .read<
                                                                    ConteoBloc>()
                                                                .currentUbication
                                                                ?.name ==
                                                            "" ||
                                                        context
                                                                .read<
                                                                    ConteoBloc>()
                                                                .currentUbication
                                                                ?.name ==
                                                            null
                                                    ? 'Esperando escaneo'
                                                    : context
                                                        .read<ConteoBloc>()
                                                        .currentUbication
                                                        ?.name,
                                                disabledBorder:
                                                    InputBorder.none,
                                                hintStyle: const TextStyle(
                                                    fontSize: 12, color: black),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Focus(
                                      focusNode: focusNode1,
                                      onKey:
                                          (FocusNode node, RawKeyEvent event) {
                                        if (event is RawKeyDownEvent) {
                                          if (event.logicalKey ==
                                              LogicalKeyboardKey.enter) {
                                            // validateLocation(
                                            //     //validamos la ubicacion
                                            //     bloc.scannedValue1);

                                            return KeyEventResult.handled;
                                          } else {
                                            // bloc.add(UpdateScannedValueEvent(
                                            //     event.data.keyLabel,
                                            //     'location'));

                                            return KeyEventResult.handled;
                                          }
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            LocationCardButtonConteo(
                                              bloc: context.read<
                                                  ConteoBloc>(), // Tu instancia de BLoC/Controlador
                                              cardColor:
                                                  white, // Asegúrate que 'white' esté definido en tus colores
                                              textAndIconColor:
                                                  primaryColorApp, // Usa tu color primario
                                              title: 'Ubicación de existencias',
                                              iconPath:
                                                  "assets/icons/ubicacion.png",
                                              dialogTitle:
                                                  '360 Software Informa',
                                              dialogMessage:
                                                  "No hay ubicaciones cargadas, por favor cargues las ubicaciones",
                                              routeName: 'search-location-conteo',
                                              ubicacionFija: true,
                                            ),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  context
                                                                  .read<
                                                                      ConteoBloc>()
                                                                  .currentUbication
                                                                  ?.name ==
                                                              "" ||
                                                          context
                                                                  .read<
                                                                      ConteoBloc>()
                                                                  .currentUbication
                                                                  ?.name ==
                                                              null
                                                      ? 'Esperando escaneo'
                                                      : context
                                                              .read<
                                                                  ConteoBloc>()
                                                              .currentUbication
                                                              ?.name ??
                                                          "",
                                                  style: TextStyle(
                                                      color: black,
                                                      fontSize: 14),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
