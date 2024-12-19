// ignore_for_file: unrelated_type_equality_checks

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/progressIndicatos_widget.dart';

import 'package:wms_app/src/utils/constans/colors.dart';

class WmsPackingScreen extends StatefulWidget {
  const WmsPackingScreen({super.key});

  @override
  State<WmsPackingScreen> createState() => _WmsPackingScreenState();
}

class _WmsPackingScreenState extends State<WmsPackingScreen> {
  NotchBottomBarController controller = NotchBottomBarController();

  @override
  void initState() {
    controller.index = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    .read<WmsPackingBloc>()
                    .add(FilterBatchPackingStatusEvent(
                      '',
                    ));
                break;
              case 1:
                context
                    .read<WmsPackingBloc>()
                    .add(FilterBatchPackingStatusEvent(
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
          child:

              ///*listado de bacths

              BlocConsumer<WmsPackingBloc, WmsPackingState>(
            listener: (context, state) {},
            builder: (context, state) {
              return Column(
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
                      child:
                          BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                              builder: (context, status) {
                        return Column(
                          children: [
                            const WarningWidgetCubit(),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: status != ConnectionStatus.online
                                      ? 0
                                      : 35,
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
                                          Navigator.pop(context);
                                        },
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: size.width * 0.2),
                                        child: const Text(
                                          'BATCH - PACKING',
                                          style: TextStyle(
                                              color: white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  ProgressIndicatorWidget(
                                    progress: context
                                            .read<WmsPackingBloc>()
                                            .listOfBatchs
                                            .isNotEmpty
                                        ? context
                                                .read<WmsPackingBloc>()
                                                .listOfBatchsDoneDB
                                                .length /
                                            context
                                                .read<WmsPackingBloc>()
                                                .listOfBatchs
                                                .length
                                        : 0.0,
                                    completed: context
                                        .read<WmsPackingBloc>()
                                        .listOfBatchsDoneDB
                                        .length,
                                    total: context
                                        .read<WmsPackingBloc>()
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

                  Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 60,
                      width: size.width * 1,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: size.width * 0.9,
                              child: Card(
                                color: Colors.white,
                                elevation: 3,
                                child: TextFormField(
                                  textAlignVertical: TextAlignVertical.center,
                                  controller: context
                                      .read<WmsPackingBloc>()
                                      .searchController,
                                  decoration: InputDecoration(
                                    prefixIcon:
                                        const Icon(Icons.search, color: grey),
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          context
                                              .read<WmsPackingBloc>()
                                              .searchController
                                              .clear();
                                          context.read<WmsPackingBloc>().add(
                                              SearchBatchPackingEvent(
                                                  '', controller.index));

                                          FocusScope.of(context).unfocus();
                                        },
                                        icon: const Icon(Icons.close,
                                            color: grey)),
                                    disabledBorder: const OutlineInputBorder(),
                                    hintText: "Buscar batch",
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    context.read<WmsPackingBloc>().add(
                                        SearchBatchPackingEvent(
                                            value, controller.index));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  //*listado de batchs
                  Expanded(
                    child: context
                            .read<WmsPackingBloc>()
                            .listOfBatchsDB
                            .isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: context
                                .read<WmsPackingBloc>()
                                .listOfBatchsDB
                                .length,
                            itemBuilder: (context, index) {
                              final List<BatchPackingModel> inProgressBatches =
                                  context
                                      .read<WmsPackingBloc>()
                                      .listOfBatchsDB; // Convertir a lista

                              // Asegurarse de que hay batches en progreso
                              if (inProgressBatches.isEmpty) {
                                return const Center(
                                    child: Text('No hay batches en progreso.'));
                              }

                              // Comprobar que el índice no está fuera de rango
                              if (index >= inProgressBatches.length) {
                                return const SizedBox(); // O manejar de otra forma
                              }

                              final batch = inProgressBatches[
                                  index]; // Acceder al batch filtrado

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: GestureDetector(
                                  onTap: () async {
                                    //mandamos a traer de la base de datos los pedidos del batch
                                    context
                                        .read<WmsPackingBloc>()
                                        .add(LoadAllPedidosFromBatchEvent(
                                          batch.id ?? 0,
                                        ));

                                    //viajamos a la vista de detalles del batch con sus pedidos
                                    Navigator.pushNamed(
                                      context,
                                      'packing-list',
                                      arguments: batch,
                                    );
                                  },
                                  child: Card(
                                    color: batch.isSeparate == 1
                                        ? Colors.green[100]
                                        : batch.isSelected == 1
                                            ? primaryColorAppLigth
                                            : Colors.white,
                                    elevation: 5,
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
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_month_sharp,
                                                  color: primaryColorApp,
                                                  size: 15,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  batch.scheduleddate != null
                                                      ? DateFormat('dd/MM/yyyy')
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
                                                        fontSize: 14,
                                                        color: black),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                  "Cantidad pedidos: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    batch.cantidadPedidos.toString(),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColorApp),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                ],
              );
            },
          ),
        ));
  }
}
