// ignore_for_file: use_super_parameters, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/widgets/appbar.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class PakingListScreen extends StatelessWidget {
  const PakingListScreen({Key? key, required this.batchModel})
      : super(key: key);

  final BatchPackingModel? batchModel;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<WmsPackingBloc, WmsPackingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBarGlobal(tittle: 'PACKING', actions: const SizedBox()),
          body: Container(
            margin: const EdgeInsets.only(top: 10),
            width: size.width * 1,
            height: size.height * 0.9,
            child: Column(
              children: [
                //*card informativa
                Card(
                  elevation: 5,
                  color: Colors.grey[200],
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(top: 10),
                    width: size.width * 0.9,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              batchModel?.name ?? '',
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: primaryColorApp,
                                  fontWeight: FontWeight.bold),
                            )),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Responsable: ',
                                  style: TextStyle(fontSize: 16, color: black),
                                )),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  batchModel?.userId == false ||
                                          batchModel?.userId == ""
                                      ? 'Sin responsable'
                                      : "${batchModel?.userId}",
                                  style: const TextStyle(
                                      fontSize: 16, color: primaryColorApp),
                                )),
                          ],
                        ),
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Tipo de operación: ",
                              style: TextStyle(fontSize: 16, color: black),
                            )),
                        SizedBox(
                          width: size.width * 0.9,
                          child: Text(
                            batchModel?.pickingTypeId == false
                                ? 'Sin tipo de operación'
                                : "${batchModel?.pickingTypeId}",
                            style: const TextStyle(
                                fontSize: 16, color: primaryColorApp),
                          ),
                        ),
                        Row(
                          children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Fecha de programada:",
                                  style: TextStyle(fontSize: 16, color: black),
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

                                return SizedBox(
                                  width: size.width * 0.35,
                                  child: Text(
                                    displayDate,
                                    style: const TextStyle(
                                        fontSize: 16, color: primaryColorApp),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Listado de pedidos",
                    style: TextStyle(
                        fontSize: 20,
                        color: black,
                        fontWeight: FontWeight.bold)),

                BlocBuilder<WmsPackingBloc, WmsPackingState>(
                  builder: (context, state) {
                    final packingBloc = context.read<WmsPackingBloc>();
                    return Expanded(
                        child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      child: ListView.builder(
                          itemCount: packingBloc.listOfPedidos.length,
                          itemBuilder: (context, index) {
                            final packing = packingBloc.listOfPedidos[index];
                            return GestureDetector(
                              onTap: () {

                                //pedimos todos los productos de un pedido
                                context.read<WmsPackingBloc>().add(
                                    LoadAllProductsFromPedidoEvent(
                                        packing.id ?? 0));




                                //viajamos a la vista de detalle de un pedido
                                Navigator.pushNamed(context, 'packing-detail',
                                    arguments: packing);




                              },
                              child: Card(
                                  elevation: 5,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 15),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Text("Nombre:",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: primaryColorApp)),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              width: size.width * 0.65,
                                              child: Text(packing.name ?? " ",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: black)),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text('Referencia:',
                                                style: TextStyle(
                                                    color: primaryColorApp,
                                                    fontSize: 16)),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                  packing.referencia ?? '',
                                                  style: const TextStyle(
                                                      color: black)),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                              width: 80,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: primaryColorApp,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: const Center(
                                                child: Text(
                                                  // packing.state == 'assigned'
                                                  //     ? 'Listo'
                                                  'En proceso',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Tipo de operación:",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: primaryColorApp)),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: size.width * 0.9,
                                          child: Text(
                                              packing.tipoOperacion ?? " ",
                                              style: const TextStyle(
                                                  fontSize: 16, color: black)),
                                        ),

                                        // const SizedBox(height: 5),
                                        // Row(
                                        //   children: [
                                        //     const Text("A:",
                                        //         style: TextStyle(
                                        //             fontSize: 16,
                                        //             color: primaryColorApp)),
                                        //     const SizedBox(width: 10),
                                        //     SizedBox(
                                        //       width: size.width * 0.7,
                                        //       child: Text(
                                        //           // packing.locationDestId[1]
                                        //           // .toString(),
                                        //           " ",
                                        //           style: const TextStyle(
                                        //               fontSize: 16,
                                        //               color: black)),
                                        //     ),
                                        //   ],
                                        // ),
                                        // const SizedBox(height: 5),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Contacto:",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: primaryColorApp)),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: size.width * 0.9,
                                          child: Text(packing.contacto ?? " ",
                                              style: const TextStyle(
                                                  fontSize: 16, color: black)),
                                        ),
                                      ],
                                    ),
                                  )),
                            );
                          }),
                    ));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
