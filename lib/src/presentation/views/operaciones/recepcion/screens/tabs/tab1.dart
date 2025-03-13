// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab1ScreenRecep extends StatelessWidget {
  const Tab1ScreenRecep({
    super.key,
    required this.ordenCompra,
  });

  final OrdenCompra? ordenCompra;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: BlocBuilder<WmsPackingBloc, WmsPackingState>(
        builder: (context, state) {
          return BlocListener<WmsPackingBloc, WmsPackingState>(
            listener: (context, state) {
              if (state is UnPackignSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(milliseconds: 1000),
                  content: Text(state.message),
                  backgroundColor: Colors.green[200],
                ));
              }
            },
            child: Scaffold(
              backgroundColor: white,
              body: Column(
                children: [
                  //*detalles del batch
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(ordenCompra?.name ?? '',
                                  style: TextStyle(
                                      color: primaryColorApp,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(ordenCompra?.proveedor ?? '',
                                  style: TextStyle(
                                    color: black,
                                    fontSize: 14,
                                  )),
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
                                    ordenCompra?.scheduledDate != null
                                        ? DateFormat('dd/MM/yyyy hh:mm ')
                                            .format(DateTime.parse(
                                                ordenCompra?.scheduledDate ??
                                                    ''))
                                        : "Sin fecha",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Ubicacion destino: ',
                                style: TextStyle(
                                    fontSize: 14, color: primaryColorApp),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                ordenCompra?.locationDestName ?? '',
                                style:
                                    const TextStyle(fontSize: 14, color: black),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.download_for_offline_rounded,
                                    color: primaryColorApp,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    ordenCompra?.purchaseOrderName ??
                                        'Sin orden de compra',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Peso: ',
                                      style:
                                          TextStyle(fontSize: 14, color: black),
                                    )),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    // Formateamos el número a 2 decimales
                                    NumberFormat('0.00')
                                        .format(ordenCompra?.pesoTotal ?? 0),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: black,
                                    ),
                                  ),
                                )
                              ],
                            ),
                        
                           
                            Row(
                              children: [
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Total productos : ',
                                      style:
                                          TextStyle(fontSize: 14, color: black),
                                    )),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      ordenCompra?.numeroLineas.toString() ?? '0',
                                      style: TextStyle(
                                          fontSize: 14, color: primaryColorApp),
                                    )),
                              ],
                            ),
                            Row(
                              children: [
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Total de unidades: ',
                                      style:
                                          TextStyle(fontSize: 14, color: black),
                                    )),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      ordenCompra?.numeroItems.toString() ?? '0',
                                      style: TextStyle(
                                          fontSize: 14, color: primaryColorApp),
                                    )),
                              ],
                            ),
                             Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    color: primaryColorApp,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    ordenCompra?.responsable ??
                                        'Sin responsable',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
