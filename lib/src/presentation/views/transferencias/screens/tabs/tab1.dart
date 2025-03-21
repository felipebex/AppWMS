// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/transferencias/screens/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab1ScreenTrans extends StatelessWidget {
  const Tab1ScreenTrans({
    super.key,
    required this.transFerencia,
  });

  final ResultTransFerencias? transFerencia;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: BlocConsumer<TransferenciaBloc, TransferenciaState>(
        listener: (context, state) {},
        builder: (context, state) {
          final transferenciaDetail = transFerencia;

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
                            child: Text("${transferenciaDetail?.name}",
                                style: TextStyle(
                                    color: primaryColorApp,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text('Tipo de transferencia: ',
                                    style: TextStyle(
                                        fontSize: 14, color: primaryColorApp)),
                                const SizedBox(width: 5),
                                Text(
                                  "${transferenciaDetail?.pickingType}",
                                  style: const TextStyle(
                                      fontSize: 14, color: black),
                                ),
                              ],
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
                                  transferenciaDetail?.fechaCreacion != null
                                      ? DateFormat('dd/MM/yyyy hh:mm ').format(
                                          DateTime.parse(transferenciaDetail
                                                  ?.fechaCreacion ??
                                              ''))
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
                              transferenciaDetail?.locationDestName ??
                                  'Sin ubicacion',
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
                                  transferenciaDetail?.origin == ""
                                      ? 'Sin orden de compra'
                                      : transferenciaDetail?.origin ?? '',
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
                                  NumberFormat('0.00').format(
                                      transferenciaDetail?.pesoTotal ?? 0),
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
                                    transferenciaDetail?.numeroLineas
                                            .toString() ??
                                        '0',
                                    style:
                                        TextStyle(fontSize: 14, color: black),
                                  )),
                            ],
                          ),
                          Row(
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
                                    transferenciaDetail?.numeroItems
                                            .toString() ??
                                        '0',
                                    style:
                                        TextStyle(fontSize: 14, color: black),
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
                                  transferenciaDetail?.responsable == false
                                      ? 'Sin responsable'
                                      : transferenciaDetail?.responsable ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, color: black),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: primaryColorApp,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Tiempo de inicio : ',
                                  style: TextStyle(
                                      fontSize: 14, color: primaryColorApp),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  // transferenciaDetail?.startTimeReception ??
                                  "Sin tiempo",
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
                    onPressed: () {},
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
