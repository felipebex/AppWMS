// ignore_for_file: use_super_parameters, unrelated_type_equality_checks

import 'dart:ui';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/widgets/appbar.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class WMSPickingPage extends StatefulWidget {
  const WMSPickingPage({Key? key}) : super(key: key);

  @override
  State<WMSPickingPage> createState() => _PickingPageState();
}

class _PickingPageState extends State<WMSPickingPage> {
  NotchBottomBarController controller = NotchBottomBarController();

  @override
  void initState() {
    controller.index = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WMSPickingBloc, PickingState>(
      listener: (context, state) {},
      builder: (context, state) {
        final size = MediaQuery.sizeOf(context);
        return Scaffold(
            // bottomNavigationBar: AnimatedNotchBottomBar(
            //   /// Provide NotchBottomBarController
            //   notchBottomBarController: controller,
            //   color: Colors.white,
            //   showLabel: true,
            //   textOverflow: TextOverflow.visible,
            //   maxLine: 1,
            //   shadowElevation: 3,
            //   kBottomRadius: 28.0,
            //   notchColor: primaryColorApp,

            //   /// restart app if you change removeMargins
            //   removeMargins: false,
            //   bottomBarWidth: 500,
            //   showShadow: false,
            //   durationInMilliSeconds: 300,
            //   itemLabelStyle: const TextStyle(fontSize: 10),
            //   elevation: 12,
            //   bottomBarItems: [
            //     BottomBarItem(
            //       inActiveItem: Image.asset(
            //         "assets/icons/producto.png",
            //         color: grey,
            //         width: 24,
            //       ),

            //       // Icon(
            //       //   Icons.batch_prediction,
            //       //   color: grey,
            //       // ),
            //       activeItem:
            //           // Icon(
            //           //   Icons.batch_prediction,
            //           //   color: white,
            //           // ),

            //           Image.asset(
            //         "assets/icons/producto.png",
            //         color: white,
            //         width: 24,
            //       ),

            //       itemLabel: 'Todos',
            //     ),
            //     BottomBarItem(
            //       inActiveItem: Image.asset(
            //         "assets/icons/producto.png",
            //         color: primaryColorApp,
            //         width: 24,
            //       ),
            //       activeItem: Image.asset(
            //         "assets/icons/producto.png",
            //         color: white,
            //         width: 24,
            //       ),
            //       itemLabel: 'En Proceso',
            //     ),
            //     BottomBarItem(
            //       inActiveItem: Image.asset(
            //         "assets/icons/producto.png",
            //         color: Colors.green[300],
            //         width: 24,
            //       ),
            //       activeItem: Image.asset(
            //         "assets/icons/producto.png",
            //         color: white,
            //         width: 24,
            //       ),
            //       itemLabel: 'Hecho',
            //     ),
            //   ],
            //   onTap: (index) {
            //     setState(() {
            //       controller.index = index;
            //     });
            //     switch (index) {
            //       case 0:
            //         context
            //             .read<WMSPickingBloc>()
            //             .add(FilterBatchesBStatusEvent(''));
            //         break;
            //       case 1:
            //         context
            //             .read<WMSPickingBloc>()
            //             .add(FilterBatchesBStatusEvent('in_progress'));
            //         break;
            //       case 2:
            //         context
            //             .read<WMSPickingBloc>()
            //             .add(FilterBatchesBStatusEvent('done'));

            //         break;
            //       default:
            //         context
            //             .read<WMSPickingBloc>()
            //             .add(FilterBatchesBStatusEvent(''));
            //     }
            //   },
            //   kIconSize: 24.0,
            // ),

            appBar: AppBarGlobal(tittle: 'BATCHS', actions: const SizedBox()),
            body: SizedBox(
              width: size.width * 1,
              height: size.height * 0.87,
              child: Column(
                children: [
                  //*barra de buscar

                  SizedBox(
                      height: 120,
                      width: size.width * 1,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: size.width * 0.75,
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 3,
                                    child: TextFormField(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      controller: context
                                          .read<WMSPickingBloc>()
                                          .searchController,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.search,
                                            color: grey),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              context
                                                  .read<WMSPickingBloc>()
                                                  .searchController
                                                  .clear();
                                              context
                                                  .read<WMSPickingBloc>()
                                                  .add(SearchBatchEvent(''));
                                              FocusScope.of(context).unfocus();
                                            },
                                            icon: const Icon(Icons.close,
                                                color: grey)),
                                        disabledBorder:
                                            const OutlineInputBorder(),
                                        hintText: "Buscar batch",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        context
                                            .read<WMSPickingBloc>()
                                            .add(SearchBatchEvent(value));
                                      },
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.white,
                                  elevation: 3,
                                  child: PopupMenuButton<String>(
                                    shadowColor: Colors.white,
                                    color: Colors.white,
                                    icon: const Icon(Icons.more_vert,
                                        color: grey, size: 25),
                                    onSelected: (String value) {
                                      switch (value) {
                                        case '1':
                                          context.read<WMSPickingBloc>().add(
                                              FilterBatchesByOperationTypeEvent(
                                                  'Órdenes de Entrega',
                                                  controller.index));
                                          break;
                                        case '2':
                                          context.read<WMSPickingBloc>().add(
                                              FilterBatchesByOperationTypeEvent(
                                                  'Recogida',
                                                  controller.index));
                                          break;
                                        case '3':
                                          context.read<WMSPickingBloc>().add(
                                              FilterBatchesByOperationTypeEvent(
                                                  'Recibos', controller.index));
                                          break;
                                        case '4':
                                          context.read<WMSPickingBloc>().add(
                                              FilterBatchesByOperationTypeEvent(
                                                  'Todos', controller.index));
                                          break;
                                        default:
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem<String>(
                                          value: '1',
                                          child: Text('Órdenes de Entrega'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: '2',
                                          child: Text('Recogida'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: '3',
                                          child: Text('Recibos'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: '4',
                                          child: Text('Todos'),
                                        ),
                                      ];
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, bottom: 5),
                              child: SizedBox(
                                  width: size.width * 0.8,
                                  height: 45,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          context.read<WMSPickingBloc>().add(
                                              FilterBatchesByTypeEvent(
                                                  "false", controller.index));
                                        },
                                        child: const Card(
                                            color: Colors.white,
                                            elevation: 2,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                              child: Text(
                                                "BATCH",
                                              ),
                                            )),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.read<WMSPickingBloc>().add(
                                              FilterBatchesByTypeEvent(
                                                  "true", controller.index));
                                        },
                                        child: const Card(
                                            color: Colors.white,
                                            elevation: 2,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                              child: Text(
                                                "WAVE",
                                              ),
                                            )),
                                      ),
                                    ],
                                  ))),
                        ],
                      )),

                  //filtro por tipo de batch

                  //*listado de batchs
                  Expanded(
                    child: context
                            .read<WMSPickingBloc>()
                            .filteredBatchs
                            .isNotEmpty
                        ? ListView.builder(
                            padding: EdgeInsets.only(
                                top: 10, bottom: size.height * 0.15),
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: context
                                .read<WMSPickingBloc>()
                                .filteredBatchs
                                .length,
                            itemBuilder: (context, index) {
                              final batch = context
                                  .read<WMSPickingBloc>()
                                  .filteredBatchs[index];
                              //convertimos la fecha

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: GestureDetector(
                                  onTap: () async {
                                    // // //*cargamos los productos de un batch

                                    // if (batch.state == 'done' ||
                                    //     batch.state == 'cancel') {
                                    //   showDialog(
                                    //       context: context,
                                    //       builder: (context) {
                                    //         return BackdropFilter(
                                    //           filter: ImageFilter.blur(
                                    //               sigmaX: 5, sigmaY: 5),
                                    //           child: AlertDialog(
                                    //             backgroundColor: white,
                                    //             actionsAlignment:
                                    //                 MainAxisAlignment.center,
                                    //             title: const Center(
                                    //               child: Text('Información',
                                    //                   style: TextStyle(
                                    //                       color:
                                    //                           primaryColorApp,
                                    //                       fontSize: 18)),
                                    //             ),
                                    //             content: Column(
                                    //               mainAxisSize: MainAxisSize
                                    //                   .min, // Minimiza el contenido
                                    //               children: [
                                    //                 RichText(
                                    //                   textAlign:
                                    //                       TextAlign.justify,
                                    //                   text: const TextSpan(
                                    //                     style: TextStyle(
                                    //                         color: Colors
                                    //                             .black), // Color por defecto
                                    //                     children: <TextSpan>[
                                    //                       TextSpan(
                                    //                         text:
                                    //                             'Para consultar la información de un batch en el estado de ',
                                    //                       ),
                                    //                       TextSpan(
                                    //                         text: 'hecho',
                                    //                         style: TextStyle(
                                    //                             color: Colors
                                    //                                 .green),
                                    //                       ),
                                    //                       TextSpan(
                                    //                         text:
                                    //                             ' es necesario contar con conexión a internet',
                                    //                       ),
                                    //                     ],
                                    //                   ),
                                    //                 )
                                    //               ],
                                    //             ),
                                    //             actions: [
                                    //               ElevatedButton(
                                    //                   onPressed: () {
                                    //                     Navigator.pop(context);
                                    //                   },
                                    //                   style: ElevatedButton
                                    //                       .styleFrom(
                                    //                           elevation: 3,
                                    //                           backgroundColor:
                                    //                               white,
                                    //                           shape:
                                    //                               RoundedRectangleBorder(
                                    //                             borderRadius:
                                    //                                 BorderRadius
                                    //                                     .circular(
                                    //                                         10),
                                    //                           )),
                                    //                   child: const Text(
                                    //                       "Cancelar",
                                    //                       style: TextStyle(
                                    //                           color:
                                    //                               primaryColorApp))),
                                    //               ElevatedButton(
                                    //                   onPressed: () {
                                    //                     //todo hacemos la consulta a odoo para obtener los productos del batch
                                    //                     context
                                    //                         .read<BatchBloc>()
                                    //                         .add(LoadAllProductsBatchsEvent(
                                    //                             batchId:
                                    //                                 batch.id ??
                                    //                                     0));
                                    //                     Navigator.pop(context);

                                    //                     //todo navegamos a la vista de separacion de productos del batch
                                    //                     Navigator.pushNamed(
                                    //                       context,
                                    //                       'batch',
                                    //                     );
                                    //                   },
                                    //                   style: ElevatedButton
                                    //                       .styleFrom(
                                    //                           backgroundColor:
                                    //                               primaryColorApp,
                                    //                           shape:
                                    //                               RoundedRectangleBorder(
                                    //                             borderRadius:
                                    //                                 BorderRadius
                                    //                                     .circular(
                                    //                                         10),
                                    //                           )),
                                    //                   child: const Text(
                                    //                       "Continuar",
                                    //                       style: TextStyle(
                                    //                           color: Colors
                                    //                               .white))),
                                    //             ],
                                    //           ),
                                    //         );
                                    //       });
                                    // } else {
                                      context.read<BatchBloc>().add(
                                          FetchBatchWithProductsEvent(
                                              batch.id ?? 0));

                                      //todo navegamos a la vista de separacion de productos del batch
                                      Navigator.pushNamed(
                                        context,
                                        'batch',
                                      );


                                    // }
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 3,
                                    child: ListTile(
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: primaryColorApp,
                                      ),
                                      leading: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),

                                            //sombras
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2))
                                            ]),
                                        child: Image.asset(
                                          "assets/icons/producto.png",
                                          color: batch.state == 'done'
                                              ? Colors.green
                                              : batch.state == 'cancel'
                                                  ? Colors.red
                                                  : primaryColorApp,
                                          width: 24,
                                        ),
                                      ),
                                      title: Text(batch.name ?? '',
                                          style: const TextStyle(fontSize: 14)),
                                      subtitle: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Tipo de operación:",
                                                style: TextStyle(
                                                    fontSize: 14, color: grey)),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              batch.pickingTypeId.toString(),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Builder(
                                              builder: (context) {
                                                // Verifica si `scheduledDate` es false o null
                                                String displayDate;
                                                if (batch.scheduledDate ==
                                                        false ||
                                                    batch.scheduledDate ==
                                                        null) {
                                                  displayDate = 'sin fecha';
                                                } else {
                                                  try {
                                                    DateTime dateTime =
                                                        DateTime.parse(batch
                                                            .scheduledDate!);
                                                    // Formatear la fecha usando Intl
                                                    displayDate = DateFormat(
                                                            'dd MMMM yyyy',
                                                            'es_ES')
                                                        .format(dateTime);
                                                  } catch (e) {
                                                    displayDate =
                                                        'sin fecha'; // Si ocurre un error al parsear
                                                  }
                                                }

                                                return Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .calendar_month_sharp,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      displayDate,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                          Builder(builder: (context) {
                                            dynamic nameUser = batch.userId;

                                            if (batch.userId is List) {
                                              nameUser = batch.userId[1] ??
                                                  'Sin responsable';
                                            }
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person,
                                                    color: primaryColorApp,
                                                    size: 15,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      nameUser == false
                                                          ? 'Sin responsable'
                                                          : nameUser.toString(),
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: black),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/empty.png',
                                    height:
                                        150), // Ajusta la altura según necesites
                                const SizedBox(height: 10),
                                const Text('No se encontraron resultados',
                                    style:
                                        TextStyle(fontSize: 18, color: grey)),
                                const Text('Intenta con otra búsqueda',
                                    style:
                                        TextStyle(fontSize: 14, color: grey)),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ));
      },
    );
  }
}
