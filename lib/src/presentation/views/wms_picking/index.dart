// ignore_for_file: use_super_parameters, unrelated_type_equality_checks

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/widgets/appbar.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

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
            bottomNavigationBar: AnimatedNotchBottomBar(
              /// Provide NotchBottomBarController
              notchBottomBarController: controller,
              color: Colors.white,
              showLabel: true,
              textOverflow: TextOverflow.visible,
              maxLine: 1,
              shadowElevation: 3,
              kBottomRadius: 28.0,

              notchColor: primaryColorApp,

              /// restart app if you change removeMargins
              removeMargins: false,
              bottomBarWidth: 500,
              showShadow: false,
              durationInMilliSeconds: 300,
              itemLabelStyle: const TextStyle(fontSize: 10),
              elevation: 12,
              bottomBarItems: [
                const BottomBarItem(
                  inActiveItem: Icon(
                    Icons.batch_prediction,
                    color: grey,
                  ),
                  activeItem: Icon(
                    Icons.batch_prediction,
                    color: white,
                  ),
                  itemLabel: 'Todos',
                ),
                const BottomBarItem(
                  inActiveItem: Icon(
                    Icons.batch_prediction,
                    color: primaryColorApp,
                  ),
                  activeItem: Icon(
                    Icons.batch_prediction,
                    color: white,
                  ),
                  itemLabel: 'En Proceso',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.batch_prediction,
                    color: Colors.red[300],
                  ),
                  activeItem: const Icon(
                    Icons.batch_prediction,
                    color: Colors.white,
                  ),
                  itemLabel: 'Cancelado',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.batch_prediction,
                    color: Colors.green[300],
                  ),
                  activeItem: const Icon(
                    Icons.batch_prediction,
                    color: Colors.white,
                  ),
                  itemLabel: 'Hecho',
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
                        .add(FilterBatchesBStatusEvent(''));
                    break;
                  case 1:
                    context
                        .read<WMSPickingBloc>()
                        .add(FilterBatchesBStatusEvent('in_progress'));
                    break;
                  case 2:
                    context
                        .read<WMSPickingBloc>()
                        .add(FilterBatchesBStatusEvent('cancel'));
                    break;
                  case 3:
                    context
                        .read<WMSPickingBloc>()
                        .add(FilterBatchesBStatusEvent('done'));
                    break;
                  default:
                    context
                        .read<WMSPickingBloc>()
                        .add(FilterBatchesBStatusEvent(''));
                }
              },
              kIconSize: 24.0,
            ),
            appBar: AppBarGlobal(tittle: 'Picking', actions: const SizedBox()),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<WMSPickingBloc>().add(LoadBatchsFromDBEvent());
              },
              child: SizedBox(
                width: size.width,
                height: size.height * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //*barra de buscar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Card(
                          color: Colors.white,
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: context
                                  .read<WMSPickingBloc>()
                                  .searchController,
                              decoration: InputDecoration(
                                prefixIcon:
                                    const Icon(Icons.search, color: grey),
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      context
                                          .read<WMSPickingBloc>()
                                          .searchController
                                          .clear();
                                      context
                                          .read<WMSPickingBloc>()
                                          .add(SearchBatchEvent(''));
                                    },
                                    icon: const Icon(Icons.close, color: grey)),
                                disabledBorder: const OutlineInputBorder(),
                                hintText: "Buscar batch",
                                hintStyle: const TextStyle(color: Colors.grey),
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
                      ),
                      //*listado de batchs
                      SizedBox(
                        height: size.height * 0.7,
                        child: context
                                .read<WMSPickingBloc>()
                                .filteredBatchs
                                .isNotEmpty
                            ? ListView.builder(
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
                                        //*cargamos los productos de un batch
                                        context
                                            .read<BatchBloc>()
                                            .add(LoadAllProductsBatchsEvent(
                                              batchId: batch.id ?? 0,
                                            ));

                                        // //*navegamos a la vista de separación del batch
                                        Navigator.pushNamed(
                                          context,
                                          // 'batch-picking',
                                          'batch-products',
                                          // 'batch-products2',
                                        );

                                        // print('batch.id: ${batch.toMap()}');
                                      },
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 3,
                                        child: ListTile(
                                          leading: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Icon(
                                              Icons.living_rounded,
                                              color: batch.state == 'done'
                                                  ? Colors.green
                                                  : batch.state == 'cancel'
                                                      ? Colors.red
                                                      : primaryColorApp,
                                              size: 40,
                                            ),
                                          ),
                                          title: Text(batch.name ?? '',
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                          subtitle: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    "Tipo de operación:",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: grey)),
                                              ),
                                              const SizedBox(width: 10),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  batch.pickingTypeId
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: primaryColorApp),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                          Icons.calendar_month_sharp,
                                                          color: primaryColorApp,
                                                          size: 20,
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
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.person,
                                                        color: primaryColorApp,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        nameUser == false
                                                            ? 'Sin responsable'
                                                            : nameUser
                                                                .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: black),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                            200), // Ajusta la altura según necesites
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
              ),
            ));
      },
    );
  }
}
