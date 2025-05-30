// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/individual/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
// import 'package:wms_app/src/presentation/views/transferencias/transfer-externa/bloc/transfer_externa_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/widgets/dialog_info_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ListEntradaProductsScreen extends StatefulWidget {
  const ListEntradaProductsScreen({
    super.key,
  });

  @override
  State<ListEntradaProductsScreen> createState() =>
      _ListTransferenciasScreenState();
}

class _ListTransferenciasScreenState extends State<ListEntradaProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: BlocConsumer<TransferenciaBloc, TransferenciaState>(
            listener: (context, state) {
          if (state is EntregaLoading) {
            context.read<TransferenciaBloc>().add(LoadLocations());
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const DialogLoading(
                message: 'Cargando transferencias...',
              ),
            );
          }
          if (state is EntregaError) {
            Navigator.pop(context);
            Get.defaultDialog(
              title: '360 Software Informa',
              titleStyle: TextStyle(color: Colors.red, fontSize: 18),
              middleText: state.message,
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
          if (state is EntregaLoaded) {
            Navigator.pop(context);
          }

          if (state is AssignUserToTransferFailure) {
            Get.snackbar(
              '360 Software Informa',
              "Error al asignar el responsable a la transferencia",
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
            // obtenemos los productos de esa entrada
            context
                .read<TransferenciaBloc>()
                .add(GetPorductsToTransfer(state.transfer.id ?? 0));

            context
                .read<TransferenciaBloc>()
                .add(CurrentTransferencia(state.transfer));

            Navigator.pushReplacementNamed(
              context,
              'transferencia-detail',
              arguments: [state.transfer, 0],
            );
          }
        }, builder: (context, state) {
          final transferBloc = context.read<TransferenciaBloc>();

          return Scaffold(
            backgroundColor: white,
            bottomNavigationBar: context
                    .read<TransferenciaBloc>()
                    .isKeyboardVisible
                ? CustomKeyboard(
                    isLogin: false,
                    controller: context
                        .read<TransferenciaBloc>()
                        .searchControllerTransfer,
                    onchanged: () {
                      context.read<TransferenciaBloc>().add(SearchTransferEvent(
                            context
                                .read<TransferenciaBloc>()
                                .searchControllerTransfer
                                .text,
                            "entrega",
                          ));
                    },
                  )
                : null,
            body: SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                children: [
                  //* appbar
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColorApp,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    width: double.infinity,
                    child: BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                        builder: (context, status) {
                                            return Column(
                    children: [
                      const WarningWidgetCubit(),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: 10,
                            top: status != ConnectionStatus.online
                                ? 0
                                : 35),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: white),
                              onPressed: () {
                                context.read<TransferenciaBloc>().add(
                                    ShowKeyboardEvent(
                                        showKeyboard: false));
                    
                                context
                                    .read<TransferenciaBloc>()
                                    .searchControllerTransfer
                                    .clear();
                    
                                context
                                    .read<TransferenciaBloc>()
                                    .add(SearchTransferEvent(
                                      "",
                                      "entrega",
                                    ));
                    
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                );
                              },
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: size.width * 0.1),
                              child: GestureDetector(
                                onTap: () async {
                                  await DataBaseSqlite()
                                      .deleTrasnferencia('entrega');
                                  context
                                      .read<TransferenciaBloc>()
                                      .add(FetchAllEntrega(false));
                                },
                                child: Row(
                                  children: [
                                    const Text("ENTREGA PRODUCTOS",
                                        style: TextStyle(
                                            color: white, fontSize: 18)),
                                    //icono de refrescar
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.refresh,
                                      color: white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            Visibility(
                              visible: context
                                      .read<TransferenciaBloc>()
                                      .tiposTransferencia
                                      .length >
                                  1,
                              child: PopupMenuButton<String>(
                                color: white,
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onSelected: (value) {
                                  context.read<TransferenciaBloc>().add(
                                        FilterTransferByTypeEvent(value),
                                      );
                                },
                                itemBuilder: (BuildContext context) {
                                  // Lista fija de tipos de transferencia que ya tienes
                                  final tipos = [
                                    ...context
                                        .read<TransferenciaBloc>()
                                        .tiposTransferencia,
                                    'todas'
                                  ];
                    
                                  return tipos.map((tipo) {
                                    final isTodas =
                                        tipo.toLowerCase() == 'todas';
                    
                                    return PopupMenuItem<String>(
                                      value: tipo,
                                      child: Row(
                                        children: [
                                          Icon(
                                            isTodas
                                                ? Icons.select_all
                                                : Icons
                                                    .file_upload_outlined,
                                            color: isTodas
                                                ? Colors.grey
                                                : primaryColorApp,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            isTodas ? 'Todas' : tipo,
                                            style: const TextStyle(
                                                color: black,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                                            );
                                          }),
                  ),
                  //*buscar
                  Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      height: 55,
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
                                  readOnly: context
                                          .read<UserBloc>()
                                          .fabricante
                                          .contains("Zebra")
                                      ? true
                                      : false,
                                  showCursor: true,
                                  textAlignVertical: TextAlignVertical.center,
                                  controller: context
                                      .read<TransferenciaBloc>()
                                      .searchControllerTransfer,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: grey,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          context
                                              .read<TransferenciaBloc>()
                                              .searchControllerTransfer
                                              .clear();

                                          context
                                              .read<TransferenciaBloc>()
                                              .add(SearchTransferEvent(
                                                "",
                                                "entrega",
                                              ));

                                          context.read<TransferenciaBloc>().add(
                                              ShowKeyboardEvent(
                                                  showKeyboard: false));

                                          FocusScope.of(context).unfocus();
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: grey,
                                          size: 20,
                                        )),
                                    disabledBorder: const OutlineInputBorder(),
                                    hintText: "Buscar entrega de productos",
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    context
                                        .read<TransferenciaBloc>()
                                        .add(SearchTransferEvent(
                                          value,
                                          "entrega",
                                        ));
                                  },
                                  onTap: !context
                                          .read<UserBloc>()
                                          .fabricante
                                          .contains("Zebra")
                                      ? null
                                      : () {
                                          context.read<TransferenciaBloc>().add(
                                              ShowKeyboardEvent(
                                                  showKeyboard: true));
                                        },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  (transferBloc.entregaProductosBDFilters
                          .where((element) =>
                              element.isFinish == 0 || element.isFinish == null)
                          .toList()
                          .isEmpty)
                      ? Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Text('No hay transferencias',
                                  style: TextStyle(fontSize: 14, color: grey)),
                              const Text('Intente buscar otra transferencia',
                                  style: TextStyle(fontSize: 12, color: grey)),
                              Visibility(
                                visible: context
                                    .read<UserBloc>()
                                    .fabricante
                                    .contains("Zebra"),
                                child: Container(
                                  height: 60,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                              itemCount: transferBloc.entregaProductosBDFilters
                                  .where((element) =>
                                      element.isFinish == 0 ||
                                      element.isFinish == null)
                                  .toList()
                                  .length,
                              itemBuilder: (context, index) {
                                final transferenciaDetail = transferBloc
                                    .entregaProductosBDFilters
                                    .where((element) =>
                                        element.isFinish == 0 ||
                                        element.isFinish == null)
                                    .toList()[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5),
                                  child: Card(
                                    elevation: 3,
                                    color:
                                        transferenciaDetail.startTimeTransfer !=
                                                ""
                                            ? primaryColorAppLigth
                                            : transferenciaDetail.isFinish == 1
                                                ? Colors.green[200]
                                                : white,
                                    child: ListTile(
                                      trailing: Icon(Icons.arrow_forward_ios,
                                          color: primaryColorApp),
                                      title: Text(
                                        '${transferenciaDetail.name}',
                                        style: TextStyle(
                                            color: primaryColorApp,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Tipo : ',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: primaryColorApp),
                                                ),
                                                Text(
                                                  transferenciaDetail
                                                          .pickingType ??
                                                      "",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: black),
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
                                                        color:
                                                            primaryColorApp)),
                                                Text(
                                                  transferenciaDetail
                                                              .priority ==
                                                          '0'
                                                      ? 'Normal'
                                                      : 'Alta'
                                                          "",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: transferenciaDetail
                                                                .priority ==
                                                            '0'
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
                                                  transferenciaDetail
                                                              .fechaCreacion !=
                                                          null
                                                      ? DateFormat(
                                                              'dd/MM/yyyy hh:mm ')
                                                          .format(DateTime.parse(
                                                              transferenciaDetail
                                                                  .fechaCreacion!))
                                                      : "Sin fecha",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: black),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                transferenciaDetail.proveedor ==
                                                        ""
                                                    ? 'Sin provedor'
                                                    : transferenciaDetail
                                                            .proveedor ??
                                                        '',
                                                style: TextStyle(
                                                  color: transferenciaDetail
                                                              .proveedor ==
                                                          ""
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
                                                Text(
                                                  transferenciaDetail.origin ==
                                                          ""
                                                      ? 'Sin orden de compra'
                                                      : transferenciaDetail
                                                              .origin ??
                                                          '',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: black),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible: transferenciaDetail
                                                    .backorderId !=
                                                0,
                                            child: Row(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Icon(
                                                      Icons.file_copy_rounded,
                                                      color: primaryColorApp,
                                                      size: 15),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    transferenciaDetail
                                                            .backorderName ??
                                                        '',
                                                    style: TextStyle(
                                                        color: black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold)),
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
                                                Text(
                                                  transferenciaDetail
                                                              .responsable ==
                                                          ""
                                                      ? 'sin responsable'
                                                      : transferenciaDetail
                                                              .responsable ??
                                                          '',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: transferenciaDetail
                                                                  .responsable ==
                                                              ""
                                                          ? Colors.red
                                                          : black),
                                                ),
                                                Spacer(),
                                                transferenciaDetail
                                                            .startTimeTransfer !=
                                                        ""
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 5),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      DialogInfo(
                                                                title:
                                                                    'Tiempo de inicio de operacion',
                                                                body:
                                                                    'Este orden fue iniciada a las ${transferenciaDetail.startTimeTransfer}',
                                                              ),
                                                            );
                                                          },
                                                          child: Icon(
                                                            Icons.timer_sharp,
                                                            color:
                                                                primaryColorApp,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Ubicacion destino: ',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              transferenciaDetail
                                                      .locationDestName ??
                                                  'Sin ubicacion',
                                              style: const TextStyle(
                                                  fontSize: 12, color: black),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        print(
                                            'transferenciaDetail: ${transferenciaDetail.toMap()}');
                                        //cargamos los permisos del usuario
                                        context.read<TransferenciaBloc>().add(
                                            LoadConfigurationsUserTransfer());

                                        //verificamos si la orden de entrada tiene ya un responsable
                                        if (transferenciaDetail.responsableId ==
                                                null ||
                                            transferenciaDetail.responsableId ==
                                                0) {
                                          showDialog(
                                            context: context,
                                            barrierDismissible:
                                                false, // No permitir que el usuario cierre el diálogo manualmente
                                            builder: (context) =>
                                                DialogAsignUserToOrderWidget(
                                              title:
                                                  'Esta seguro de tomar esta orden, una vez aceptada no podrá ser cancelada desde la app, una vez asignada se registrará el tiempo de inicio de la operación.',
                                              onAccepted: () async {
                                                context
                                                    .read<TransferenciaBloc>()
                                                    .add(ShowKeyboardEvent(
                                                        showKeyboard: false));

                                                context
                                                    .read<TransferenciaBloc>()
                                                    .searchControllerTransfer
                                                    .clear();

                                                context
                                                    .read<TransferenciaBloc>()
                                                    .add(SearchTransferEvent(
                                                      "",
                                                      'entrega',
                                                    ));
                                                //asignamos el responsable a esa orden de entrada
                                                context
                                                    .read<TransferenciaBloc>()
                                                    .add(
                                                      AssignUserToTransfer(
                                                          transferenciaDetail),
                                                    );
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                        } else {
                                          validateTime(
                                              transferenciaDetail, context);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              })),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        }));
  }

  void validateTime(ResultTransFerencias transfer, BuildContext context) {
    if (transfer.startTimeTransfer == "" ||
        transfer.startTimeTransfer == null) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // No permitir que el usuario cierre el diálogo manualmente
        builder: (context) => DialogStartTimeWidget(
          onAccepted: () async {
            context
                .read<TransferenciaBloc>()
                .add(ShowKeyboardEvent(showKeyboard: false));

            context.read<TransferenciaBloc>().searchControllerTransfer.clear();

            context
                .read<TransferenciaBloc>()
                .add(SearchTransferEvent("", 'entrega'));

            context.read<TransferenciaBloc>().add(StartOrStopTimeTransfer(
                  transfer.id ?? 0,
                  "start_time_transfer",
                ));
            context
                .read<TransferenciaBloc>()
                .add(GetPorductsToTransfer(transfer.id ?? 0));
            //traemos la orden de entrada actual desde la bd actualizada
            context
                .read<TransferenciaBloc>()
                .add(CurrentTransferencia(transfer));
            Navigator.pop(context);
            Navigator.pushReplacementNamed(
              context,
              'transferencia-detail',
              arguments: [transfer, 0],
            );
          },
          title: 'Iniciar Transferencia',
        ),
      );
    } else {
      context
          .read<TransferenciaBloc>()
          .add(ShowKeyboardEvent(showKeyboard: false));

      context.read<TransferenciaBloc>().searchControllerTransfer.clear();

      context.read<TransferenciaBloc>().add(SearchTransferEvent(
            "",
            'entrega'
          ));

      context
          .read<TransferenciaBloc>()
          .add(GetPorductsToTransfer(transfer.id ?? 0));
      //traemos la orden de entrada actual desde la bd actualizada
      context.read<TransferenciaBloc>().add(CurrentTransferencia(transfer));
      context.read<TransferenciaBloc>().add(LoadLocations());
      Navigator.pushReplacementNamed(
        context,
        'transferencia-detail',
        arguments: [transfer, 0],
      );
    }
  }
}
