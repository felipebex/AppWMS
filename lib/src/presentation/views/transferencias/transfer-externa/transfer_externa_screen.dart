import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-externa/bloc/transfer_externa_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class TransferExternaScreen extends StatefulWidget {
  const TransferExternaScreen({super.key});

  @override
  State<TransferExternaScreen> createState() => _TransferExternaScreenState();
}

class _TransferExternaScreenState extends State<TransferExternaScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Añadimos el observer para escuchar el ciclo de vida de la app.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        // Aquí se ejecutan las acciones solo si la pantalla aún está montada
        showDialog(
          context: context,
          builder: (context) {
            return const DialogLoading(
              message: "Espere un momento...",
            );
          },
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    }
  }

//focus para escanear

  FocusNode focusNode1 = FocusNode(); // location
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfieldƒ
  FocusNode focusNode5 = FocusNode(); //location dest

  String? selectedLocation;
  String? selectedMuelle;

  //controller
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerLocationDest = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  @override
  void dispose() {
    focusNode1.dispose(); //product
    focusNode2.dispose(); //product
    focusNode3.dispose(); //quantity
    focusNode4.dispose(); //quantity
    focusNode5.dispose(); //quantity
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleDependencies();
  }

  void _handleDependencies() {}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocProvider(
        create: (context) => TransferExternaBloc(),
        child: Scaffold(
          backgroundColor: white,
          body: SizedBox(
              width: size.width * 1,
              height: size.height * 1,
              child: Column(children: [
                //apbar

                Container(
                  padding: const EdgeInsets.only(top: 20),
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
                    child:
                        BlocConsumer<TransferExternaBloc, TransferExternaState>(
                            listener: (context, state) {},
                            builder: (context, status) {
                              return Column(
                                children: [
                                  const WarningWidgetCubit(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        // bottom: 5,
                                        top: status != ConnectionStatus.online
                                            ? 0
                                            : 35),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back,
                                              color: white),
                                          onPressed: () {},
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: size.width * 0.2),
                                          child: Text('TRANSFERENCIA EXTERNA',
                                              style: TextStyle(
                                                  color: white, fontSize: 18)),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                  ),
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 2),
                    child: SingleChildScrollView(
                      child: Column(children: [
                        //todo : ubicacion de origen
                        // Row(
                        //   children: [
                        //     Padding(
                        //       padding:
                        //           const EdgeInsets.symmetric(horizontal: 10),
                        //       child: Container(
                        //         width: 10,
                        //         height: 10,
                        //         decoration: BoxDecoration(
                        //           color: bloc.locationIsOk ? green : yellow,
                        //           shape: BoxShape.circle,
                        //         ),
                        //       ),
                        //     ),
                        //     Card(
                        //       color: bloc.isLocationOk
                        //           ? bloc.locationIsOk
                        //               ? Colors.green[100]
                        //               : Colors.grey[300]
                        //           : Colors.red[200],
                        //       elevation: 5,
                        //       child: Container(
                        //         // color: Colors.amber,
                        //         width: size.width * 0.85,
                        //         padding: const EdgeInsets.symmetric(
                        //             horizontal: 10, vertical: 2),
                        //         child: context
                        //                 .read<UserBloc>()
                        //                 .fabricante
                        //                 .contains("Zebra")
                        //             ? Column(
                        //                 children: [
                        //                   LocationDropdownTransferWidget(
                        //                     isPDA: false,
                        //                     selectedLocation: selectedLocation,
                        //                     positionsOrigen:
                        //                         bloc.positionsOrigen,
                        //                     currentLocationId: bloc
                        //                             .currentProduct
                        //                             .locationName ??
                        //                         "",
                        //                     batchBloc: bloc,
                        //                     currentProduct: bloc.currentProduct,
                        //                   ),
                        //                   Container(
                        //                     height: 15,
                        //                     margin: const EdgeInsets.only(
                        //                         bottom: 5),
                        //                     child: TextFormField(
                        //                       autofocus: true,
                        //                       showCursor: false,
                        //                       controller:
                        //                           _controllerLocation, // Asignamos el controlador
                        //                       enabled: !bloc
                        //                               .locationIsOk && // false
                        //                           !bloc.productIsOk && // false
                        //                           !bloc.quantityIsOk && // false
                        //                           !bloc.locationDestIsOk,

                        //                       focusNode: focusNode1,
                        //                       onChanged: (value) {
                        //                         // Llamamos a la validación al cambiar el texto
                        //                         validateLocation(value);
                        //                       },
                        //                       decoration: InputDecoration(
                        //                         hintText: bloc
                        //                             .currentProduct.locationName
                        //                             .toString(),
                        //                         disabledBorder:
                        //                             InputBorder.none,
                        //                         hintStyle: const TextStyle(
                        //                             fontSize: 14, color: black),
                        //                         border: InputBorder.none,
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ],
                        //               )
                        //             : Focus(
                        //                 focusNode: focusNode1,
                        //                 onKey: (FocusNode node,
                        //                     RawKeyEvent event) {
                        //                   if (event is RawKeyDownEvent) {
                        //                     if (event.logicalKey ==
                        //                         LogicalKeyboardKey.enter) {
                        //                       validateLocation(
                        //                           //validamos la ubicacion
                        //                           bloc.scannedValue1);

                        //                       return KeyEventResult.handled;
                        //                     } else {
                        //                       bloc.add(UpdateScannedValueEvent(
                        //                           event.data.keyLabel,
                        //                           'location'));

                        //                       return KeyEventResult.handled;
                        //                     }
                        //                   }
                        //                   return KeyEventResult.ignored;
                        //                 },
                        //                 child: LocationDropdownTransferWidget(
                        //                   isPDA: true,
                        //                   selectedLocation: selectedLocation,
                        //                   positionsOrigen: bloc.positionsOrigen,
                        //                   currentLocationId: bloc
                        //                       .currentProduct.locationName
                        //                       .toString(),
                        //                   batchBloc: bloc,
                        //                   currentProduct: bloc.currentProduct,
                        //                 ),
                        //               ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ]),
                    ),
                  ),
                ),
              ])),
        ),
      ),
    );
  }
}
