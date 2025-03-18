// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab1ScreenRecep extends StatelessWidget {
  const Tab1ScreenRecep({
    super.key,
    required this.ordenCompra,
  });

  final ResultEntrada? ordenCompra;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: BlocConsumer<RecepcionBloc, RecepcionState>(
        listener: (context, state) {
          if (state is AssignUserToOrderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green[200],
              content: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Text(
                    "Se ha asignado el responsable correctamente",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ));
          }
        },
        builder: (context, state) {
          return Scaffold(
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
                            child: Row(
                              children: [
                                Text('Tipo de entrada: ',
                                    style: TextStyle(
                                        fontSize: 14, color: primaryColorApp)),
                                const SizedBox(width: 5),
                                Text(
                                  ordenCompra?.pickingType ?? "",
                                  style: const TextStyle(
                                      fontSize: 14, color: black),
                                ),
                              ],
                            ),
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
                                  ordenCompra?.fechaCreacion != null
                                      ? DateFormat('dd/MM/yyyy hh:mm ').format(
                                          DateTime.parse(
                                              ordenCompra?.fechaCreacion ?? ''))
                                      : "Sin fecha",
                                  style: const TextStyle(
                                      fontSize: 14, color: black),
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
                                  ordenCompra?.purchaseOrderName == ""
                                      ? 'Sin orden de compra'
                                      : ordenCompra?.purchaseOrderName ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, color: black),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Peso: ',
                                    style: TextStyle(
                                        fontSize: 14, color: primaryColorApp),
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
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Total productos : ',
                                    style: TextStyle(
                                        fontSize: 14, color: primaryColorApp),
                                  )),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    ordenCompra?.numeroLineas.toString() ?? '0',
                                    style:
                                        TextStyle(fontSize: 14, color: black),
                                  )),
                            ],
                          ),
                          Visibility(
                            visible: context.read<RecepcionBloc>().configurations.result?.result?.hideExpectedQty == false,
                            child: Row(
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Total de unidades: ',
                                      style: TextStyle(
                                          fontSize: 14, color: primaryColorApp),
                                    )),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      ordenCompra?.numeroItems.toString() ?? '0',
                                      style:
                                          TextStyle(fontSize: 14, color: black),
                                    )),
                              ],
                            ),
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
                                  ordenCompra?.responsable == false
                                      ? 'Sin responsable'
                                      : ordenCompra?.responsable ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, color: black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                ElevatedButton(
                    onPressed: context
                            .read<RecepcionBloc>()
                            .listProductsEntrada
                            .where((element) {
                      return element.isSeparate == 0 ||
                          element.isSeparate == null;
                    }).isNotEmpty
                        ? null
                        : () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: AlertDialog(
                                      backgroundColor: Colors.white,
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      title: Text(
                                        'Confirmar Recepcion',
                                        style: TextStyle(
                                            color: primaryColorApp,
                                            fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            width: 200,
                                            child: Image.asset(
                                              "assets/images/icono.jpeg",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '¿Estás seguro de confirmar la recepcion y dejarla lista para ser enviada?',
                                              style: TextStyle(
                                                  color: black, fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: grey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancelar',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            // await DataBaseSqlite()
                                            //     .pedidosPackingRepository
                                            //     .setFieldTablePedidosPacking(
                                            //       packingModel?.batchId ?? 0,
                                            //       packingModel?.id ?? 0,
                                            //       "is_terminate",
                                            //       1,
                                            //     );
                                            // context.read<WmsPackingBloc>().add(
                                            //         LoadAllPedidosFromBatchEvent(
                                            //       packingModel?.batchId ?? 0,
                                            //     ));

                                            Navigator.pop(context);


                                            // Navigator.of(context).pop();
                                            // Navigator.pushReplacementNamed(
                                            //     context, 'packing-list',
                                            //     arguments: [batchModel]);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColorApp,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Aceptar',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColorApp,
                      minimumSize: Size(size.width * 0.9, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: Text('Terminar Recepcion',
                        style: TextStyle(color: white))),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
