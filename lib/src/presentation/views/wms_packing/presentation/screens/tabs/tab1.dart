// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab1Screen extends StatelessWidget {
  const Tab1Screen({
    super.key,
    required this.size,
    required this.packingModel,
  });

  final Size size;
  final PedidoPacking? packingModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WmsPackingBloc, WmsPackingState>(
      builder: (context, state) {
        return Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Detalles del pedido",
              style: TextStyle(
                  fontSize: 18, color: black, fontWeight: FontWeight.bold),
            ),

            //detalles del batch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: double.infinity,
              child: Card(
                color: Colors.white,
                elevation: 5,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            packingModel?.name ?? '',
                            style: const TextStyle(
                                fontSize: 20,
                                color: primaryColorApp,
                                fontWeight: FontWeight.bold),
                          )),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Contacto: ',
                            style: TextStyle(fontSize: 16, color: black),
                          )),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            packingModel?.contacto ?? '',
                            style: const TextStyle(
                                fontSize: 16, color: primaryColorApp),
                          )),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Fecha programada:",
                            style: TextStyle(fontSize: 16, color: black),
                          )),
                      // Builder(
                      //   builder: (context) {
                      //     // Verifica si `scheduledDate` es false o null
                      //     String displayDate;
                      //     if (packingModel?.scheduledDate == false ||
                      //         packingModel?.scheduledDate == null) {
                      //       displayDate = 'sin fecha';
                      //     } else {
                      //       try {
                      //         DateTime dateTime = DateTime.parse(
                      //             packingModel?.scheduledDate ??
                      //                 ''); // Parsear la fecha
                      //         // Formatear la fecha usando Intl
                      //         displayDate = DateFormat('dd MMMM yyyy', 'es_ES')
                      //             .format(dateTime);
                      //       } catch (e) {
                      //         displayDate =
                      //             'sin fecha'; // Si ocurre un error al parsear
                      //       }
                      //     }
                      //     return SizedBox(
                      //       width: size.width * 0.9,
                      //       child: Text(
                      //         displayDate,
                      //         style: const TextStyle(
                      //             fontSize: 16, color: primaryColorApp),
                      //         textAlign: TextAlign.left,
                      //       ),
                      //     );
                      //   },
                      // ),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Ubicacion de origen:",
                            style: TextStyle(fontSize: 16, color: black),
                          )),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // packingModel?.locationId[1].toString() ?? "",
                            "",
                            style: TextStyle(
                                fontSize: 16, color: primaryColorApp),
                          )),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Ubicacion de destino:",
                            style: TextStyle(fontSize: 16, color: black),
                          )),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // packingModel?.locationDestId[1].toString() ?? "",
                            "",
                            style: TextStyle(
                                fontSize: 16, color: primaryColorApp),
                          )),
                      Row(
                        children: [
                          const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Numero de productos: ',
                                style: TextStyle(fontSize: 16, color: black),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                              packingModel?.cantidadProductos.toString() ?? "",
                                style: const TextStyle(
                                    fontSize: 16, color: primaryColorApp),
                              )),
                        ],
                      ),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tipo de operacion: ',
                            style: TextStyle(fontSize: 16, color: black),
                          )),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            packingModel?.tipoOperacion ?? "",
                            style: const TextStyle(
                                fontSize: 16, color: primaryColorApp),
                          )),
                      Row(
                        children: [
                          const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Numero de paquetes: ',
                                style: TextStyle(fontSize: 16, color: black),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                context
                                    .read<WmsPackingBloc>()
                                    .numPackages
                                    .toString(),
                                style: const TextStyle(
                                    fontSize: 16, color: primaryColorApp),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Listado de empaques",
                style: TextStyle(
                    fontSize: 18,
                    color: primaryColorApp,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 55),
                  itemCount: context.read<WmsPackingBloc>().packages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ExpansionTile(
                      title: Text('Paquete ${index + 1}'),
                      children: [
                        ListTile(
                          title: Text(
                              'Detalles de: ${context.read<WmsPackingBloc>().packages[index]}'),
                          subtitle: const Text('Cantidad: 1'), // Puedes ajustar esto
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
