// ignore_for_file: use_super_parameters, unrelated_type_equality_checks, deprecated_member_use, prefer_is_empty, avoid_print, use_build_context_synchronously

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/progressIndicatos_widget.dart';
import 'package:wms_app/src/presentation/widgets/jeyboard_numbers_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';

class WMSPickingPage extends StatefulWidget {
  const WMSPickingPage({Key? key, required this.indexSelected})
      : super(key: key);
  final int indexSelected;

  @override
  State<WMSPickingPage> createState() => _PickingPageState();
}

class _PickingPageState extends State<WMSPickingPage> {
  NotchBottomBarController controller = NotchBottomBarController();

  @override
  void initState() {
    print("indexSelected: ${widget.indexSelected}");
    controller.index = widget.indexSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<BatchBloc, BatchState>(
            listener: (context, state) {
              if (state is PickingOkState) {
                context.read<WMSPickingBloc>().add(LoadBatchsFromDBEvent());

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Separación realizada con éxito'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<WMSPickingBloc, PickingState>(
          builder: (context, state) {
            if (controller.index == 1) {
              context.read<WMSPickingBloc>().add(FilterBatchesBStatusEvent(
                    'done',
                  ));
            }

            double progress = context
                        .read<WMSPickingBloc>()
                        .listOfBatchs
                        .length >
                    0
                ? context.read<WMSPickingBloc>().batchsDone.where((element) {
                      return DateTime.parse(element.timeSeparateEnd ?? "")
                              .toString()
                              .substring(0, 10) ==
                          DateTime.now().toString().substring(0, 10);
                    }).length /
                    context.read<WMSPickingBloc>().listOfBatchs.length
                : 0.0;

            final size = MediaQuery.sizeOf(context);
            return Scaffold(
                bottomNavigationBar: context
                        .read<WMSPickingBloc>()
                        .isKeyboardVisible
                    ? CustomKeyboard(
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
                      )
                    : AnimatedNotchBottomBar(
                        /// Provide NotchBottomBarController
                        notchBottomBarController: controller,
                        color: Colors.white,
                        showLabel: true,
                        textOverflow: TextOverflow.visible,
                        maxLine: 1,
                        shadowElevation: 3,
                        kBottomRadius: 8.0,
                        notchColor: primaryColorApp,
                        removeMargins: false,
                        showShadow: false,
                        durationInMilliSeconds: 300,
                        itemLabelStyle: const TextStyle(fontSize: 10),
                        elevation: 12,
                        bottomBarItems: [
                          BottomBarItem(
                            inActiveItem: Icon(
                              Icons.batch_prediction,
                              color: primaryColorApp,
                            ),
                            activeItem: const Icon(
                              Icons.batch_prediction,
                              color: white,
                            ),
                            itemLabel: 'En Proceso',
                          ),
                          const BottomBarItem(
                            inActiveItem: Icon(
                              Icons.batch_prediction,
                              color: green,
                            ),
                            activeItem: Icon(
                              Icons.batch_prediction,
                              color: white,
                            ),
                            itemLabel: 'Hechos',
                          ),
                        ],
                        onTap: (index) {
                          setState(() {
                            controller.index = index;
                          });
                          switch (index) {
                            case 0:
                              context
                                  .read<WMSPickingBloc>()
                                  .add(FilterBatchesBStatusEvent(
                                    '',
                                  ));
                              break;
                            case 1:
                              context
                                  .read<WMSPickingBloc>()
                                  .add(FilterBatchesBStatusEvent(
                                    'done',
                                  ));
                              break;

                            default:
                          }
                        },
                        kIconSize: 24.0,
                      ),
                body: SizedBox(
                  width: size.width * 1,
                  height: size.height * 0.87,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<WMSPickingBloc>()
                          .add(LoadAllBatchsEvent(context, true));
                    },
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
                                                Navigator.pop(context);
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
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                            return DateTime.parse(element
                                                            .timeSeparateEnd ??
                                                        "")
                                                    .toString()
                                                    .substring(0, 10) ==
                                                DateTime.now()
                                                    .toString()
                                                    .substring(0, 10);
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

                        //*barra de buscar

                        SizedBox(
                            // color: Colors.amber,
                            height: 75, //120
                            width: size.width * 1,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10,),
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
                                                prefixIcon: const Icon(
                                                    Icons.search,
                                                    color: grey, size: 20),
                                                suffixIcon: IconButton(
                                                    onPressed: () {
                                                      context
                                                          .read<
                                                              WMSPickingBloc>()
                                                          .searchController
                                                          .clear();
                                                      context
                                                          .read<
                                                              WMSPickingBloc>()
                                                          .add(SearchBatchEvent(
                                                              '',
                                                              controller
                                                                  .index));
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                    },
                                                    icon: IconButton(
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                WMSPickingBloc>()
                                                            .add(
                                                                ShowKeyboardEvent(
                                                                    false));
                                                        context
                                                            .read<
                                                                WMSPickingBloc>()
                                                            .searchController
                                                            .clear();
                                                      },
                                                      icon: const Icon(
                                                          Icons.close,
                                                          color: grey, size:20),
                                                    )),
                                                disabledBorder:
                                                    const OutlineInputBorder(),
                                                hintText: "Buscar batch",
                                                hintStyle: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                                border: InputBorder.none,
                                              ),
                                              onChanged: (value) {
                                                context
                                                    .read<WMSPickingBloc>()
                                                    .add(SearchBatchEvent(value,
                                                        controller.index));
                                              },
                                              onTap: !context
                                                      .read<UserBloc>()
                                                      .fabricante
                                                      .contains("Zebra")
                                                  ? null
                                                  : () {
                                                      context
                                                          .read<
                                                              WMSPickingBloc>()
                                                          .add(
                                                              ShowKeyboardEvent(
                                                                  true));
                                                    }),
                                        ),
                                      ),
                                      Card(
                                        color: Colors.white,
                                        elevation: 3,
                                        child: IconButton(
                                          onPressed: () {
                                            showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now(),
                                            ).then((DateTime? value) {
                                              if (value != null) {
                                                context
                                                    .read<WMSPickingBloc>()
                                                    .add(
                                                        FilterBatchsByDateEvent(
                                                            value,
                                                            controller.index));
                                              }
                                            });
                                          },
                                          icon: const Icon(Icons.calendar_month,
                                              color: grey, size: 20,),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
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
                                        horizontal: 10,
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          context
                                              .read<BatchBloc>()
                                              .add(FetchBatchWithProductsEvent(
                                                batch.id ?? 0,
                                              ));

                                          context
                                              .read<BatchBloc>()
                                              .add(LoadInfoDeviceEvent());

                                          //todo navegamos a la vista de separacion de productos del batch
                                          if (batch.isSeparate == 1) {
                                            context.read<BatchBloc>().isSearch =
                                                true;
                                            Navigator.pushNamed(
                                              context,
                                              'batch-detail',
                                            );
                                          } else {
                                            // Mostrar un diálogo de carga antes de navegar a la vista "batch"
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const DialogLoading();
                                                });

                                            // Esperar 3 segundos antes de continuar
                                            Future.delayed(
                                                const Duration(seconds: 1), () {
                                              // Cerrar el diálogo de carga
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();

                                              // Ahora navegar a la vista "batch"
                                              Navigator.pushNamed(
                                                context,
                                                'batch',
                                              );
                                            });
                                          }

                                          DataBaseSqlite db = DataBaseSqlite();

                                          await db.getBacth(batch.id ?? 0);

                                          await db.getProductBacth(
                                              batch.id ?? 0, 3734);
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
                                                color: batch.state == 'done'
                                                    ? Colors.green
                                                    : batch.state == 'cancel'
                                                        ? Colors.red
                                                        : primaryColorApp,
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
                                                const Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      "Tipo de operación:",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: grey)),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    batch.pickingTypeId
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColorApp),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
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
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
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
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14,
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
                                                  alignment:
                                                      Alignment.centerLeft,
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
                                                            fontSize: 14,
                                                            color: black),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          batch.countItems
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 14,
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
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!context
                                          .read<WMSPickingBloc>()
                                          .isKeyboardVisible)
                                        Image.asset('assets/images/empty.png',
                                            height:
                                                150), // Ajusta la altura según necesites
                                      const SizedBox(height: 10),
                                      const Text('No se encontraron resultados',
                                          style: TextStyle(
                                              fontSize: 18, color: grey)),
                                      const Text('Intenta con otra búsqueda',
                                          style: TextStyle(
                                              fontSize: 14, color: grey)),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
