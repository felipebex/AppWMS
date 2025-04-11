// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, prefer_is_empty

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
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
        return false;
      },
      child: BlocConsumer<TransferenciaBloc, TransferenciaState>(
        listener: (context, state) {
          if (state is LoadLocationsFailure) {
            Get.snackbar(
              '360 Software Informa',
              "No se han podido cargar las ubicaciones",
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: Icon(Icons.error, color: Colors.red),
            );
          }

          if (state is AssignUserToTransferSuccess) {
            Get.snackbar(
              '360 Software Informa',
              "Se ha asignado el responsable correctamente",
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: Icon(Icons.error, color: Colors.green),
            );
          }

          if (state is CheckAvailabilitySuccess) {
            Navigator.pop(context);
            Get.snackbar(
              '360 Software Informa',
              "Se ha comprobado la disponibilidad correctamente",
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: Icon(Icons.error, color: Colors.green),
            );
          }

          if (state is CreateBackOrderOrNotLoading) {
            showDialog(
              context: context,
              builder: (context) {
                return const DialogLoading(
                  message: "Validando informacion...",
                );
              },
            );
          }
          if (state is CheckAvailabilityLoading) {
            showDialog(
              context: context,
              builder: (context) {
                return const DialogLoading(
                  message: "Comprobando disponibilidad...",
                );
              },
            );
          }

          if (state is CheckAvailabilityFailure) {
            Navigator.pop(context);
            Get.defaultDialog(
              title: '360 Software Informa',
              titleStyle: TextStyle(color: Colors.red, fontSize: 18),
              middleText: state.error,
              middleTextStyle: TextStyle(color: black, fontSize: 14),
              backgroundColor: Colors.white,
              radius: 10,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Aceptar', style: TextStyle(color: white)),
                ),
              ],
            );
          }
          if (state is CreateBackOrderOrNotFailure) {
            Navigator.pop(context);
            Get.defaultDialog(
              title: '360 Software Informa',
              titleStyle: TextStyle(color: Colors.red, fontSize: 18),
              middleText: state.error,
              middleTextStyle: TextStyle(color: black, fontSize: 14),
              backgroundColor: Colors.white,
              radius: 10,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Aceptar', style: TextStyle(color: white)),
                ),
              ],
            );
          }

          if (state is CreateBackOrderOrNotSuccess) {
            context.read<TransferenciaBloc>().add(FetchAllTransferencias(true));
            //volvemos a llamar las entradas que tenemos guardadas en la bd
            if (state.isBackorder) {
              Get.snackbar("360 Software Informa", state.msg,
                  backgroundColor: white,
                  colorText: primaryColorApp,
                  icon: Icon(Icons.error, color: Colors.green));
            } else {
              Get.snackbar("360 Software Informa", state.msg,
                  backgroundColor: white,
                  colorText: primaryColorApp,
                  icon: Icon(Icons.error, color: Colors.green));
            }

            Navigator.pop(context);
            Navigator.pushReplacementNamed(
              context,
              'transferencias',
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<TransferenciaBloc>();
          final transferenciaDetail = bloc.currentTransferencia;

          final totalEnviadas = context
              .read<TransferenciaBloc>()
              .listProductsTransfer
              .map((e) => e.quantityDone ?? 0)
              .fold<double>(0, (a, b) => a + b);

          return Scaffold(
            backgroundColor: white,
            body: Container(
              width: size.width,
              height: size.height * 0.95,
              child: Column(
                children: [
                  //*detalles del batch
                  GestureDetector(
                    onTap: () {
                      print(
                          'Detalle de la transferencia: ${transferenciaDetail.toMap()} ');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text('Tipo de transferencia: ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: primaryColorApp)),
                                    Text(
                                      "${transferenciaDetail?.pickingType}",
                                      style: const TextStyle(
                                          fontSize: 12, color: black),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text('Prioridad: ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: primaryColorApp)),
                                    Text(
                                      transferenciaDetail.priority == '0'
                                          ? 'Normal'
                                          : 'Alta'
                                              "",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            transferenciaDetail.priority == '0'
                                                ? black
                                                : red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: black,
                                thickness: 1,
                                height: 5,
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
                                          ? DateFormat('dd/MM/yyyy hh:mm ')
                                              .format(DateTime.parse(
                                                  transferenciaDetail
                                                          ?.fechaCreacion ??
                                                      ''))
                                          : "Sin fecha",
                                      style: const TextStyle(
                                          fontSize: 12, color: black),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    transferenciaDetail.proveedor == ""
                                        ? 'Sin provedor'
                                        : transferenciaDetail.proveedor ?? '',
                                    style: TextStyle(
                                      color: transferenciaDetail.proveedor == ""
                                          ? red
                                          : black,
                                      fontSize: 12,
                                    )),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_sharp,
                                      color: primaryColorApp,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      transferenciaDetail?.origin == ""
                                          ? 'Sin orden de compra'
                                          : transferenciaDetail?.origin ?? '',
                                      style: const TextStyle(
                                          fontSize: 12, color: black),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: transferenciaDetail.backorderId != 0,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.file_copy,
                                      color: primaryColorApp,
                                      size: 15,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          transferenciaDetail.backorderName ??
                                              '',
                                          style: TextStyle(
                                              color: black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
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
                                            fontSize: 12,
                                            color: primaryColorApp),
                                      )),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      // Formateamos el número a 2 decimales
                                      NumberFormat('0.00').format(
                                          transferenciaDetail?.pesoTotal ?? 0),
                                      style: TextStyle(
                                        fontSize: 12,
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
                                            fontSize: 12,
                                            color: primaryColorApp),
                                      )),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        transferenciaDetail?.numeroLineas
                                                .toString() ??
                                            '0',
                                        style: TextStyle(
                                            fontSize: 12, color: black),
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
                                            fontSize: 12,
                                            color: primaryColorApp),
                                      )),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        transferenciaDetail?.numeroItems
                                                .toString() ??
                                            '0',
                                        style: TextStyle(
                                            fontSize: 12, color: black),
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Unidades recibidas: ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: primaryColorApp),
                                      )),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        totalEnviadas.toString(),
                                        style: TextStyle(
                                            fontSize: 12, color: black),
                                      )),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Ubicacion destino: ',
                                  style: TextStyle(
                                      fontSize: 12, color: primaryColorApp),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  transferenciaDetail?.locationDestName ??
                                      'Sin ubicacion',
                                  style: const TextStyle(
                                      fontSize: 12, color: black),
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
                                      transferenciaDetail.responsable == false
                                          ? 'Sin responsable'
                                          : transferenciaDetail.responsable ??
                                              '',
                                      style: const TextStyle(
                                          fontSize: 12, color: black),
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
                                          fontSize: 12, color: primaryColorApp),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      transferenciaDetail.startTimeTransfer ??
                                          "Sin tiempo",
                                      style: const TextStyle(
                                          fontSize: 12, color: black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: transferenciaDetail.showCheckAvailability == 1 ||
                        transferenciaDetail.showCheckAvailability == true,
                    child: ElevatedButton(
                        onPressed: () {
                          context.read<TransferenciaBloc>().add(
                              CheckAvailabilityEvent(
                                  transferenciaDetail.id ?? 0));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColorAppLigth,
                          minimumSize: Size(size.width * 0.9, 33),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: Text('Comprobar Disponibilidad',
                            style: TextStyle(color: white))),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: AlertDialog(
                                  backgroundColor: Colors.white,
                                  actionsAlignment: MainAxisAlignment.center,
                                  title: Text(
                                    'Confirmar Transferencia',
                                    style: TextStyle(
                                        color: primaryColorApp, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        width: 150,
                                        child: Image.asset(
                                          "assets/images/icono.jpeg",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          (totalEnviadas ==
                                                  transferenciaDetail
                                                      .numeroItems)
                                              ? '¿Estás seguro de confirmar la transferencia y dejarla lista para ser enviada?'
                                              : "Usted ha procesado cantidades de productos menores que los requeridos en el movimiento orignal.",
                                          style: TextStyle(
                                              color: black, fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    Visibility(
                                      visible: (totalEnviadas !=
                                          transferenciaDetail.numeroItems),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.read<TransferenciaBloc>().add(
                                              CreateBackOrderOrNot(
                                                  transFerencia?.id ?? 0,
                                                  true));
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColorApp,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          minimumSize:
                                              Size(size.width * 0.9, 40),
                                        ),
                                        child: const Text(
                                          'Confirmar y Crear un Backorder',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        context.read<TransferenciaBloc>().add(
                                            CreateBackOrderOrNot(
                                                transFerencia?.id ?? 0, false));
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColorApp,
                                        minimumSize: Size(size.width * 0.9, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'Confirmar Transferencia',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(size.width * 0.9, 40),
                                        backgroundColor: grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColorApp,
                        minimumSize: Size(size.width * 0.9, 33),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: Text('Terminar Transferencia',
                          style: TextStyle(color: white))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
