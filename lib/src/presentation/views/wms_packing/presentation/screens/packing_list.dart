// ignore_for_file: use_super_parameters, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/progressIndicatos_widget.dart';
import 'package:wms_app/src/presentation/widgets/appbar.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class PakingListScreen extends StatelessWidget {
  const PakingListScreen({Key? key, required this.batchModel})
      : super(key: key);

  final BatchPackingModel? batchModel;
  //  LoadBatchPackingFromDBEvent

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<WmsPackingBloc, WmsPackingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: size.width * 1,
            height: size.height * 0.9,
            child: Column(
              children: [
                //appbar
                Container(
                  decoration:  BoxDecoration(
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
                                top:
                                    status != ConnectionStatus.online ? 0 : 35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: white),
                                  onPressed: () {
                                    context
                                        .read<WmsPackingBloc>()
                                        .add(LoadBatchPackingFromDBEvent());
                                    Navigator.pop(context);
                                  },
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: size.width * 0.3),
                                  child: const Text("PACKING",
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
                const SizedBox(height: 10),

                //*card informativa
                Card(
                  elevation: 5,
                  color: Colors.grey[200],
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    margin: const EdgeInsets.only(top: 10),
                    width: size.width * 0.9,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              batchModel?.name ?? '',
                              style:  TextStyle(
                                  fontSize: 20,
                                  color: primaryColorApp,
                                  fontWeight: FontWeight.bold),
                            )),
                        Row(
                          children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Responsable: ',
                                  style: TextStyle(fontSize: 14, color: black),
                                )),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  batchModel?.userId == false ||
                                          batchModel?.userId == ""
                                      ? 'Sin responsable'
                                      : "${batchModel?.userId}",
                                  style:  TextStyle(
                                      fontSize: 14, color: primaryColorApp),
                                )),
                          ],
                        ),
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Tipo de operación: ",
                              style: TextStyle(fontSize: 14, color: black),
                            )),
                        SizedBox(
                          width: size.width * 0.9,
                          child: Text(
                            batchModel?.pickingTypeId == false
                                ? 'Sin tipo de operación'
                                : "${batchModel?.pickingTypeId}",
                            style:  TextStyle(
                                fontSize: 14, color: primaryColorApp),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Fecha de programada:",
                                  style: TextStyle(fontSize: 14, color: black),
                                )),
                            const SizedBox(width: 10),
                            Builder(
                              builder: (context) {
                                // Verifica si `scheduledDate` es false o null
                                String displayDate;
                                if (batchModel?.scheduleddate == false ||
                                    batchModel?.scheduleddate == null) {
                                  displayDate = 'sin fecha';
                                } else {
                                  try {
                                    DateTime dateTime = DateTime.parse(
                                        batchModel?.scheduleddate.toString() ??
                                            ""); // Parsear la fecha
                                    // Formatear la fecha usando Intl
                                    displayDate =
                                        DateFormat('dd MMMM yyyy', 'es_ES')
                                            .format(dateTime);
                                  } catch (e) {
                                    displayDate =
                                        'sin fecha'; // Si ocurre un error al parsear
                                  }
                                }

                                return Container(
                                  width: size.width * 0.46,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    displayDate,
                                    style:  TextStyle(
                                        fontSize: 14, color: primaryColorApp),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Card(
                          elevation: 3,
                          color: primaryColorApp,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 5),
                            child: ProgressIndicatorWidget(
                              progress: context
                                      .read<WmsPackingBloc>()
                                      .listOfPedidos
                                      .isNotEmpty
                                  ? context
                                          .read<WmsPackingBloc>()
                                          .listOfPedidos
                                          .where((element) =>
                                              element.isTerminate == 1)
                                          .length /
                                      context
                                          .read<WmsPackingBloc>()
                                          .listOfPedidos
                                          .length
                                  : 0.0,
                              completed: context
                                  .read<WmsPackingBloc>()
                                  .listOfPedidos
                                  .where((element) => element.isTerminate == 1)
                                  .length,
                              total: context
                                  .read<WmsPackingBloc>()
                                  .listOfPedidos
                                  .length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Listado de pedidos",
                    style: TextStyle(
                        fontSize: 18,
                        color: black,
                        fontWeight: FontWeight.bold)),

                BlocBuilder<WmsPackingBloc, WmsPackingState>(
                  builder: (context, state) {
                    final packingBloc = context.read<WmsPackingBloc>();

                    // Ordenamos la lista de pedidos
                    final sortedPedidos = List.from(packingBloc
                        .listOfPedidos); // Copiamos la lista para no modificarla directamente
                    sortedPedidos.sort((a, b) {
                      // Si 'isTerminate' es diferente de 1, debe ir primero
                      return (a.isTerminate == 1 ? 1 : 0)
                          .compareTo(b.isTerminate == 1 ? 1 : 0);
                    });

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: ListView.builder(
                          itemCount:
                              sortedPedidos.length, // Usamos la lista ordenada
                          itemBuilder: (context, index) {
                            final packing = sortedPedidos[index];
                            return GestureDetector(
                              onTap: () {
                                // Limpiamos la lista de paquetes
                                context.read<WmsPackingBloc>().packages = [];
                                // Pedimos todos los productos de un pedido
                                context.read<WmsPackingBloc>().add(
                                    LoadAllProductsFromPedidoEvent(
                                        packing.id ?? 0));

                                // Viajamos a la vista de detalle de un pedido
                                Navigator.pushNamed(context, 'packing-detail',
                                    arguments: packing);
                              },
                              child: Card(
                                elevation: 5,
                                color: packing.isTerminate == 1
                                    ? Colors.green[100]
                                    : packing.isSelected == 1
                                        ? primaryColorAppLigth
                                        : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                           Text("Nombre:",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp)),
                                          const SizedBox(width: 10),
                                          SizedBox(
                                            width: size.width * 0.65,
                                            child: Text(packing.name ?? " ",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: black)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                           Text('Referencia:',
                                              style: TextStyle(
                                                  color: primaryColorApp,
                                                  fontSize: 14)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                                packing.referencia ?? '',
                                                style: const TextStyle(
                                                    color: black,
                                                    fontSize: 14)),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            width: 85,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color: packing.isTerminate == 1
                                                    ? primaryColorAppLigth
                                                    : packing.isSelected != 1
                                                        ? grey
                                                        : Colors.green[100],
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Center(
                                              child: Text(
                                                packing.isTerminate == 1
                                                    ? 'Terminado'
                                                    : packing.isSelected != 1
                                                        ? 'Sin procesar'
                                                        : 'En proceso',
                                                style: TextStyle(
                                                    color: packing
                                                                .isTerminate ==
                                                            1
                                                        ? black
                                                        : packing.isSelected !=
                                                                1
                                                            ? white
                                                            : black,
                                                    fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                       Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Tipo de operación:",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: primaryColorApp)),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: size.width * 0.9,
                                        child: Text(
                                            packing.tipoOperacion ?? " ",
                                            style: const TextStyle(
                                                fontSize: 14, color: black)),
                                      ),
                                       Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Contacto:",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: primaryColorApp)),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: size.width * 0.9,
                                        child: Text(packing.contacto ?? " ",
                                            style: const TextStyle(
                                                fontSize: 14, color: black)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
