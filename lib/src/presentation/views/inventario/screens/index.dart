import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/bloc/inventario_bloc.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/widgets/others/appbar_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen>
    with WidgetsBindingObserver {
  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfield

  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleDependencies();
  }

  void _handleDependencies() {}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => InventarioBloc(),
      child: BlocConsumer<InventarioBloc, InventarioState>(
        listener: (context, state) {},
        builder: (context, state) {
          final bloc = context.read<InventarioBloc>();
          return Scaffold(
            backgroundColor: white,
            body: SizedBox(
                width: size.width * 1,
                height: size.height * 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //appbar
                      AppBarInfo(size: size),

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
                                color: bloc.locationIsOk ? green : yellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Card(
                            color: bloc.isLocationOk
                                ? bloc.locationIsOk
                                    ? Colors.green[100]
                                    : Colors.grey[300]
                                : Colors.red[200],
                            elevation: 5,
                            child: Container(
                              // color: Colors.amber,
                              width: size.width * 0.85,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              child: context
                                      .read<UserBloc>()
                                      .fabricante
                                      .contains("Zebra")
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Ubicación de origen',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: primaryColorApp,
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Image.asset(
                                                "assets/icons/ubicacion.png",
                                                color: primaryColorApp,
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 15,
                                            margin: const EdgeInsets.only(
                                                bottom: 5, top: 5),
                                            child: TextFormField(
                                              autofocus: true,
                                              showCursor: false,
                                              controller:
                                                  _controllerLocation, // Asignamos el controlador
                                              enabled: !bloc
                                                      .locationIsOk && // false
                                                  !bloc.productIsOk && // false
                                                  !bloc.quantityIsOk,

                                              focusNode: focusNode1,
                                              onChanged: (value) {
                                                // Llamamos a la validación al cambiar el texto
                                                // validateLocation(value);
                                              },
                                              decoration: InputDecoration(
                                                hintText:
                                                    bloc.selectedLocation == ""
                                                        ? 'Esperando escaneo'
                                                        : bloc.selectedLocation,
                                                disabledBorder:
                                                    InputBorder.none,
                                                hintStyle: const TextStyle(
                                                    fontSize: 14, color: black),
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
                                            //     context
                                            //         .read<BatchBloc>()
                                            //         .scannedValue1);

                                            return KeyEventResult.handled;
                                          } else {
                                            // context.read<BatchBloc>().add(
                                            //     UpdateScannedValueEvent(
                                            //         event.data.keyLabel,
                                            //         'location'));

                                            return KeyEventResult.handled;
                                          }
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                      child: Container(),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      //todo : producto
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: bloc.productIsOk ? green : yellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Card(
                            color: bloc.isProductOk
                                ? bloc.productIsOk
                                    ? Colors.green[100]
                                    : Colors.grey[300]
                                : Colors.red[200],
                            elevation: 5,
                            child: Container(
                              // color: Colors.amber,
                              width: size.width * 0.85,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              child: context
                                      .read<UserBloc>()
                                      .fabricante
                                      .contains("Zebra")
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Producto',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: primaryColorApp),
                                                ),
                                              ),
                                              Spacer(),
                                              Image.asset(
                                                "assets/icons/producto.png",
                                                color: primaryColorApp,
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 15,
                                            margin: const EdgeInsets.only(
                                                bottom: 5, top: 5),
                                            child: TextFormField(
                                              autofocus: true,
                                              showCursor: false,
                                              controller:
                                                  _controllerProduct, // Asignamos el controlador
                                              // enabled: !bloc
                                              //         .locationIsOk && // false
                                              //     !bloc.productIsOk && // false
                                              //     !bloc.quantityIsOk,

                                              focusNode: focusNode2,
                                              onChanged: (value) {
                                                // Llamamos a la validación al cambiar el texto
                                                // validateLocation(value);
                                              },
                                              decoration: InputDecoration(
                                                hintText:
                                                    bloc.selectedProduct == ""
                                                        ? 'Esperando escaneo'
                                                        : bloc.selectedProduct,
                                                disabledBorder:
                                                    InputBorder.none,
                                                hintStyle: const TextStyle(
                                                    fontSize: 14, color: black),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Focus(
                                      focusNode: focusNode2,
                                      onKey:
                                          (FocusNode node, RawKeyEvent event) {
                                        if (event is RawKeyDownEvent) {
                                          if (event.logicalKey ==
                                              LogicalKeyboardKey.enter) {
                                            // validateLocation(
                                            //     //validamos la ubicacion
                                            //     context
                                            //         .read<BatchBloc>()
                                            //         .scannedValue1);

                                            return KeyEventResult.handled;
                                          } else {
                                            // context.read<BatchBloc>().add(
                                            //     UpdateScannedValueEvent(
                                            //         event.data.keyLabel,
                                            //         'location'));

                                            return KeyEventResult.handled;
                                          }
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                      child: Container(),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      // Expanded(child: Container()),

                      //todo: cantidad

                      // SizedBox(
                      //   width: size.width,
                      //   height: bloc.viewQuantity == true &&
                      //           context
                      //               .read<UserBloc>()
                      //               .fabricante
                      //               .contains("Zebra")
                      //       ? 300
                      //       : !bloc.viewQuantity
                      //           ? 110
                      //           : 150,
                      //   child: Column(
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 10,
                      //         ),
                      //         child: Card(
                      //           color: bloc.isQuantityOk
                      //               ? bloc.quantityIsOk
                      //                   ? white
                      //                   : Colors.grey[300]
                      //               : Colors.red[200],
                      //           elevation: 1,
                      //           child: Padding(
                      //             padding: const EdgeInsets.symmetric(
                      //               horizontal: 10,
                      //             ),
                      //             child: Center(
                      //               child: Row(
                      //                 children: [
                      //                   const Text('Cant:',
                      //                       style: TextStyle(
                      //                           color: Colors.black,
                      //                           fontSize: 13)),
                      //                   Padding(
                      //                     padding: const EdgeInsets.symmetric(
                      //                         horizontal: 5),
                      //                     child: Text(
                      //                       "10",
                      //                       style: TextStyle(
                      //                           color: primaryColorApp,
                      //                           fontSize: 13),
                      //                     ),
                      //                   ),
                      //                   Expanded(
                      //                     child: Container(
                      //                       padding: const EdgeInsets.only(
                      //                           bottom: 5),
                      //                       height: 30,
                      //                       alignment: Alignment.center,
                      //                       child: Padding(
                      //                         padding:
                      //                             const EdgeInsets.symmetric(
                      //                                 horizontal: 10),
                      //                         child: Container(
                      //                             alignment: Alignment.center,
                      //                             child: context
                      //                                     .read<UserBloc>()
                      //                                     .fabricante
                      //                                     .contains("Zebra")
                      //                                 ? Center(
                      //                                     child: TextFormField(
                      //                                       showCursor: false,
                      //                                       textAlign: TextAlign
                      //                                           .center,
                      //                                       enabled: bloc
                      //                                               .locationIsOk && //true
                      //                                           bloc.productIsOk && //true
                      //                                           bloc.quantityIsOk,
                      //                                       // showCursor: false,
                      //                                       controller:
                      //                                           _controllerQuantity, // Controlador que maneja el texto
                      //                                       focusNode:
                      //                                           focusNode3,
                      //                                       onChanged: (value) {
                      //                                         // validateQuantity(
                      //                                         //     value);
                      //                                       },
                      //                                       decoration:
                      //                                           InputDecoration(
                      //                                         // hintText: batchBloc
                      //                                         //     .quantitySelected
                      //                                         //     .toString(),
                      //                                         disabledBorder:
                      //                                             InputBorder
                      //                                                 .none,
                      //                                         hintStyle:
                      //                                             const TextStyle(
                      //                                                 fontSize:
                      //                                                     13,
                      //                                                 color:
                      //                                                     black),
                      //                                         border:
                      //                                             InputBorder
                      //                                                 .none,
                      //                                       ),
                      //                                     ),
                      //                                   )
                      //                                 : Focus(
                      //                                     focusNode: focusNode3,
                      //                                     onKey:
                      //                                         (FocusNode node,
                      //                                             RawKeyEvent
                      //                                                 event) {
                      //                                       if (event
                      //                                           is RawKeyDownEvent) {
                      //                                         if (event
                      //                                                 .logicalKey ==
                      //                                             LogicalKeyboardKey
                      //                                                 .enter) {
                      //                                           // validateQuantity(context
                      //                                           //     .read<
                      //                                           //         BatchBloc>()
                      //                                           //     .scannedValue3);
                      //                                           return KeyEventResult
                      //                                               .handled;
                      //                                         } else {
                      //                                           // context
                      //                                           //     .read<
                      //                                           //         BatchBloc>()
                      //                                           //     .add(UpdateScannedValueEvent(
                      //                                           //         event
                      //                                           //             .data
                      //                                           //             .keyLabel,
                      //                                           //         'quantity'));

                      //                                           return KeyEventResult
                      //                                               .handled;
                      //                                         }
                      //                                       }
                      //                                       return KeyEventResult
                      //                                           .ignored;
                      //                                     },
                      //                                     child: Text(
                      //                                         bloc.quantitySelected
                      //                                             .toString(),
                      //                                         maxLines: 1,
                      //                                         overflow:
                      //                                             TextOverflow
                      //                                                 .ellipsis,
                      //                                         style:
                      //                                             const TextStyle(
                      //                                           color: Colors
                      //                                               .black,
                      //                                           fontSize: 14,
                      //                                         )),
                      //                                   )),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),

                      //       //teclado de la app
                      //       // Visibility(
                      //       //   // visible: bloc.viewQuantity &&
                      //       //   //     context
                      //       //   //         .read<UserBloc>()
                      //       //   //         .fabricante
                      //       //   //         .contains("Zebra"),
                      //       //   child: CustomKeyboardNumber(
                      //       //     controller: cantidadController,
                      //       //     onchanged: () {
                      //       //       // _validatebuttonquantity();
                      //       //     },
                      //       //   ),
                      //       // ),
                      //       Padding(
                      //           padding: const EdgeInsets.symmetric(
                      //               horizontal: 10, vertical: 0),
                      //           child: ElevatedButton(
                      //             onPressed: bloc.quantityIsOk &&
                      //                     bloc.quantitySelected >= 0
                      //                 ? () {
                      //                     //cerramos el teclado
                      //                     // FocusScope.of(context).unfocus();
                      //                     // _validatebuttonquantity();
                      //                   }
                      //                 : null,
                      //             style: ElevatedButton.styleFrom(
                      //               backgroundColor: primaryColorApp,
                      //               minimumSize: Size(size.width * 0.93, 30),
                      //               shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(10),
                      //               ),
                      //             ),
                      //             child: const Text(
                      //               'ACTUALIZAR INVENTARIO',
                      //               style: TextStyle(
                      //                   color: Colors.white, fontSize: 14),
                      //             ),
                      //           )),




                      //     ],
                      //   ),




                      // ),
                   
                   
                    ],
                  ),
                )),
          );
        },
      ),
    );
  }
}
