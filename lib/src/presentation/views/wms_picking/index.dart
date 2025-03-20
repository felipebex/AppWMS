// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/widgets/dialog_info_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/progressIndicatos_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WMSPickingPage extends StatefulWidget {
  const WMSPickingPage({super.key, required this.indexSelected});
  final int indexSelected;

  @override
  State<WMSPickingPage> createState() => _PickingPageState();
}

class _PickingPageState extends State<WMSPickingPage> {
  NotchBottomBarController controller = NotchBottomBarController();


  FocusNode focusNodeBuscar = FocusNode();


  @override
  void initState() {
    controller.index = widget.indexSelected;
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<BatchBloc, BatchState>(
            listener: (context, state) {
              if (state is PickingOkState) {
                context.read<WMSPickingBloc>().add(FilterBatchesBStatusEvent(
                      '',
                    ));
              }
            },
          ),
        ],
        child: BlocBuilder<WMSPickingBloc, PickingState>(
          builder: (context, state) {
            double progress = context
                    .read<WMSPickingBloc>()
                    .listOfBatchs
                    .isNotEmpty
                ? context.read<WMSPickingBloc>().batchsDone.where((element) {
                      return element.isSeparate == 1;
                    }).length /
                    context.read<WMSPickingBloc>().listOfBatchs.length
                : 0.0;

            return Scaffold(
              backgroundColor: white,
                bottomNavigationBar: context
                        .read<WMSPickingBloc>()
                        .isKeyboardVisible
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 36),
                        child: CustomKeyboard(
                          controller:
                              context.read<WMSPickingBloc>().searchController,
                          onchanged: () {
                            context.read<WMSPickingBloc>().add(SearchBatchEvent(
                                context
                                    .read<WMSPickingBloc>()
                                    .searchController
                                    .text,
                                controller.index));
                          },
                        ),
                      )
                    : null,
                body: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColorApp,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: BlocProvider(
                          create: (context) => ConnectionStatusCubit(),
                          child: BlocBuilder<ConnectionStatusCubit,
                              ConnectionStatus>(builder: (context, status) {
                            return Column(
                              children: [
                                const WarningWidgetCubit(),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: status != ConnectionStatus.online
                                          ? 20
                                          : 20,
                                      bottom: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.arrow_back,
                                                color: white),
                                            onPressed: () {
                                              context
                                                  .read<WMSPickingBloc>()
                                                  .searchController
                                                  .clear();
                                              Navigator.pushReplacementNamed(
                                                  context, 'home');
                                            },
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: size.width * 0.27),
                                            child: const Text(
                                              'BATCHS',
                                              style: TextStyle(
                                                  color: white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const Spacer(),
                                        ],
                                      ),
                                      ProgressIndicatorWidget(
                                        progress: progress,
                                        completed: context
                                            .read<WMSPickingBloc>()
                                            .batchsDone
                                            .where((element) {
                                          return element.isSeparate == 1;
                                        }).length,
                                        total: context
                                            .read<WMSPickingBloc>()
                                            .listOfBatchs
                                            .length,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<WMSPickingBloc>()
                                      .add(FilterBatchesBStatusEvent(''));
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.batch_prediction,
                                      color: primaryColorApp,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'En Proceso',
                                      style: TextStyle(
                                          color: primaryColorApp, fontSize: 12),
                                    )
                                  ],
                                )),
                            ElevatedButton(
                              onPressed: () async {
                                // Primero, asegúrate de que el FocusNode esté activo
                                FocusScope.of(context).unfocus();
                                var pickedDate =
                                    await DatePicker.showSimpleDatePicker(
                                  titleText: 'Seleccione una fecha',
                                  context,
                                  confirmText: 'Buscar',
                                  cancelText: 'Cancelar',
                                  // initialDate: DateTime(2020),
                                  firstDate:
                                      //un mes atras
                                      DateTime.now()
                                          .subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now(),
                                  dateFormat: "dd-MMMM-yyyy",
                                  locale: DateTimePickerLocale.es,
                                  looping: false,
                                );

                                // Verificar si el usuario seleccionó una fecha
                                if (pickedDate != null) {
                                  // Formatear la fecha al formato "yyyy-MM-dd"
                                  final formattedDate = DateFormat('yyyy-MM-dd')
                                      .format(pickedDate);

                                  // Disparar el evento con la fecha seleccionada
                                  context.read<WMSPickingBloc>().add(
                                        LoadHistoryBatchsEvent(
                                             true, formattedDate),
                                      );

                                  // Navegar a la pantalla de historial
                                  Navigator.pushNamed(context, 'history-list');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.history,
                                    color: green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Histórico',
                                    style: TextStyle(
                                      color: primaryColorApp,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      //*barra de buscar

                      // SizedBox(
                      //     // color: Colors.amber,
                      //     height: 60, //120
                      //     width: size.width * 1,
                      //     child: Column(
                      //       children: [
                      //         Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 10,
                      //             right: 10,
                      //           ),
                      //           child: SizedBox(
                      //             width: size.width * 0.95,
                      //             height: 55,
                      //             child: Card(
                      //               color: Colors.white,
                      //               elevation: 3,
                      //               child: TextFormField(
                      //                 focusNode: focusNodeBuscar,
                      //                   textAlignVertical:
                      //                       TextAlignVertical.center,
                      //                   controller: context
                      //                       .read<WMSPickingBloc>()
                      //                       .searchController,
                      //                   decoration: InputDecoration(
                      //                     prefixIcon: const Icon(Icons.search,
                      //                         color: grey, size: 20),
                      //                     suffixIcon: IconButton(
                      //                         onPressed: () {
                      //                           context
                      //                               .read<WMSPickingBloc>()
                      //                               .searchController
                      //                               .clear();
                      //                           context
                      //                               .read<WMSPickingBloc>()
                      //                               .add(SearchBatchEvent(
                      //                                   '', controller.index));
                      //                           FocusScope.of(context)
                      //                               .unfocus();
                      //                         },
                      //                         icon: IconButton(
                      //                           onPressed: () {
                      //                             context
                      //                                 .read<WMSPickingBloc>()
                      //                                 .add(ShowKeyboardEvent(
                      //                                     false));
                      //                             context
                      //                                 .read<WMSPickingBloc>()
                      //                                 .searchController
                      //                                 .clear();
                      //                           },
                      //                           icon: const Icon(Icons.close,
                      //                               color: grey, size: 20),
                      //                         )),
                      //                     disabledBorder:
                      //                         const OutlineInputBorder(),
                      //                     hintText: "Buscar batch",
                      //                     hintStyle: const TextStyle(
                      //                         color: Colors.grey, fontSize: 12),
                      //                     border: InputBorder.none,
                      //                   ),
                      //                   onChanged: (value) {
                      //                     context.read<WMSPickingBloc>().add(
                      //                         SearchBatchEvent(
                      //                             value, controller.index));
                      //                   },
                      //                   style: const TextStyle(
                      //                       color: Colors.black, fontSize: 14),
                      //                   onTap: !context
                      //                           .read<UserBloc>()
                      //                           .fabricante
                      //                           .contains("Zebra")
                      //                       ? null
                      //                       : () {
                      //                           context
                      //                               .read<WMSPickingBloc>()
                      //                               .add(ShowKeyboardEvent(
                      //                                   true));
                      //                         }),
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     )),

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
                                itemBuilder: (contextBuilder, index) {
                                  final batch = context
                                      .read<WMSPickingBloc>()
                                      .filteredBatchs[index];
                                  //convertimos la fecha

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: GestureDetector(
                                      onTap: () async {
                                        // Agrupar eventos de BatchBloc si es necesario
                                        final batchBloc =
                                            context.read<BatchBloc>();
                                        print(batch.toMap());
                                        try {
                                          print(batch.toMap());

                                          if (batch.startTimePick != "") {
                                            batchBloc.add(
                                                FetchBatchWithProductsEvent(
                                                    batch.id ?? 0));
                                            batchBloc
                                                .add(LoadInfoDeviceEvent());
                                            batchBloc
                                                .add(LoadConfigurationsUser());

                                            goBatchInfo(contextBuilder,
                                                batchBloc, batch);
                                          } else {
                                            showDialog(
                                              context: context,
                                              barrierDismissible:
                                                  false, // No permitir que el usuario cierre el diálogo manualmente
                                              builder: (context) =>
                                                  DialogStartTimeWidget(
                                                    
                                                onAccepted: () async {
                                                  // Disparar eventos de BatchBloc
                                                  batchBloc.add(
                                                      FetchBatchWithProductsEvent(
                                                          batch.id ?? 0));
                                                  batchBloc.add(
                                                      LoadInfoDeviceEvent());
                                                  batchBloc.add(
                                                      LoadConfigurationsUser());

                                                  batchBloc.add(StartTimePick(
                                             
                                                      batch.id ?? 0,
                                                      DateTime.now()));

                                                  Navigator.pop(context);

                                                  goBatchInfo(contextBuilder,
                                                      batchBloc, batch);
                                                }, title: 'Iniciar Picking',
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          // Manejo de errores, por si ocurre algún problema

                                          ScaffoldMessenger.of(contextBuilder)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Error al cargar los datos'),
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                        }
                                      },
                                      child: Card(
                                        color: batch.isSeparate == 1
                                            ? Colors.green[100]
                                            : batch.isSelected == 1
                                                ? primaryColorAppLigth
                                                : Colors.white,
                                        elevation: 3,
                                        child: ListTile(
                                          trailing: Icon(
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
                                              color: primaryColorApp,
                                              width: 24,
                                            ),
                                          ),
                                          title: Text(batch.name ?? '',
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                          subtitle: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(batch.zonaEntrega ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: black)),
                                              ),
                                              Row(
                                                children: [
                                                  const Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                        "Tipo de operación:",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: grey)),
                                                  ),
                                                  Spacer(),
                                                  batch.startTimePick != ""
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        DialogInfo(
                                                                          title:
                                                                              'Tiempo de inicio',
                                                                          body:
                                                                              'Este batch fue iniciado a las ${batch.startTimePick}',
                                                                        ));
                                                          },
                                                          child: Icon(
                                                            Icons.timer_sharp,
                                                            color:
                                                                primaryColorApp,
                                                            size: 15,
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  batch.pickingTypeId
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: primaryColorApp),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .calendar_month_sharp,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      batch.scheduleddate !=
                                                              null
                                                          ? DateFormat(
                                                                  'dd/MM/yyyy')
                                                              .format(DateTime
                                                                  .parse(batch
                                                                      .scheduleddate!))
                                                          : "Sin fecha",
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.person,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Expanded(
                                                      child: Text(
                                                        batch.userName ??
                                                            "Sin usuario",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text(
                                                      "Cantidad Productos: ",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: black),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        batch.countItems
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                primaryColorApp),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text(
                                                      "Cantidad unidades: ",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: black),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        batch.totalQuantityItems
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                primaryColorApp),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 10),
                                    Text('No se encontraron resultados',
                                        style: TextStyle(
                                            fontSize: 18, color: grey)),
                                    Text('Intenta con otra búsqueda',
                                        style: TextStyle(
                                            fontSize: 14, color: grey)),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ));
          },
        ),
      ),
    );
  }

  void goBatchInfo(
      BuildContext context, BatchBloc batchBloc, BatchsModel batch) async {
    // mostramos un dialogo de carga y despues
    showDialog(
      context: context,
      barrierDismissible:
          false, // No permitir que el usuario cierre el diálogo manualmente
      builder: (_) => const DialogLoading(
        message: 'Cargando interfaz...',
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context);

    // Si batch.isSeparate es 1, entonces navegamos a "batch-detail"
    if (batch.isSeparate != 1) {
      Navigator.pushReplacementNamed(context, 'batch');
    } else {}
  }
}
