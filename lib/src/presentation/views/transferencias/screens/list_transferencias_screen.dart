import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/transferencias/screens/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/widgets/dialog_info_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ListTransferenciasScreen extends StatelessWidget {
  const ListTransferenciasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transferBloc = context.read<TransferenciaBloc>();
    final Size size = MediaQuery.sizeOf(context);
    return BlocConsumer<TransferenciaBloc, TransferenciaState>(
      listener: (context, state) {
        if (state is AssignUserToTransferFailure) {
          Get.snackbar(
            'Error',
            "Error al asignar el responsable a la transferencia",
            backgroundColor: white,
            colorText: primaryColorApp,
            icon: Icon(Icons.error, color: Colors.red),
          );
        }

        if (state is AssignUserToTransferSuccess) {
          Get.snackbar(
            'Exitoso',
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
      },
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigator.pushNamed(context, 'transferencia');
            },
            backgroundColor: primaryColorApp,
            child: Icon(Icons.add, color: white),
          ),
          backgroundColor: white,
          bottomNavigationBar: context
                  .read<TransferenciaBloc>()
                  .isKeyboardVisible
              ? CustomKeyboard(
                  controller: context
                      .read<TransferenciaBloc>()
                      .searchControllerTransfer,
                  onchanged: () {
                    context.read<TransferenciaBloc>().add(SearchTransferEvent(
                          context
                              .read<TransferenciaBloc>()
                              .searchControllerTransfer
                              .text,
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
                AppBar(size: size),
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
                                  hintText: "Buscar transferencia",
                                  hintStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  context
                                      .read<TransferenciaBloc>()
                                      .add(SearchTransferEvent(
                                        value,
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

                Expanded(
                    child: GroupedListView(
                  elements: transferBloc.transferenciasDbFilters,
                  groupBy: (element) =>
                      element.warehouseName ??
                      "", // Agrupamos por 'warehouseName'
                  itemBuilder: (context, dynamic transferenciaDetail) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 5),
                      child: Card(
                        elevation: 3,
                        color: transferenciaDetail.isSelected == 1
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
                                    Icon(
                                      Icons.calendar_month_sharp,
                                      color: primaryColorApp,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      transferenciaDetail.fechaCreacion != null
                                          ? DateFormat('dd/MM/yyyy hh:mm ')
                                              .format(DateTime.parse(
                                                  transferenciaDetail
                                                      .fechaCreacion!))
                                          : "Sin fecha",
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
                                      Icons.person,
                                      color: primaryColorApp,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      transferenciaDetail.responsable == ""
                                          ? 'sin responsable'
                                          : transferenciaDetail.responsable ??
                                              '',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              transferenciaDetail.responsable ==
                                                      ""
                                                  ? Colors.red
                                                  : black),
                                    ),
                                    Spacer(),
                                    transferenciaDetail.startTimeTransfer != ""
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
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
                                                color: primaryColorApp,
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
                                child: Row(
                                  children: [
                                    Text(
                                      'Tipo : ',
                                      style: TextStyle(
                                          fontSize: 12, color: primaryColorApp),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      transferenciaDetail.pickingType ?? "",
                                      style: const TextStyle(
                                          fontSize: 12, color: black),
                                    ),
                                  ],
                                ),
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
                                  transferenciaDetail.locationDestName ??
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
                                      Icons.download_for_offline_rounded,
                                      color: primaryColorApp,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      transferenciaDetail.origin == ""
                                          ? 'Sin orden de compra'
                                          : transferenciaDetail.origin ?? '',
                                      style: const TextStyle(
                                          fontSize: 12, color: black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            print(
                                'transferenciaDetail: ${transferenciaDetail.toMap()}');
                            //cargamos los permisos del usuario
                            context
                                .read<TransferenciaBloc>()
                                .add(LoadConfigurationsUserTransfer());

                            //verificamos si la orden de entrada tiene ya un responsable
                            if (transferenciaDetail.responsableId == null ||
                                transferenciaDetail.responsableId == 0) {
                              showDialog(
                                context: context,
                                barrierDismissible:
                                    false, // No permitir que el usuario cierre el diálogo manualmente
                                builder: (context) =>
                                    DialogAsignUserToOrderWidget(
                                  onAccepted: () async {
                                    //asignamos el responsable a esa orden de entrada
                                    context.read<TransferenciaBloc>().add(
                                          AssignUserToTransfer(
                                              transferenciaDetail),
                                        );
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            } else {
                              validateTime(transferenciaDetail, context);
                            }
                          },
                        ),
                      ),
                    );
                  },
                  groupSeparatorBuilder: (String groupByValue) => SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Card(
                        color: Colors.grey[200],
                        elevation: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              groupByValue, // Esto mostrará el nombre del "warehouseName"
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColorApp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  useStickyGroupSeparators:
                      true, // Esto hará que el encabezado de cada grupo se quede fijo
                  floatingHeader: true, // Habilita el encabezado flotante
                  order: GroupedListOrder.ASC, // Orden ascendente
                )),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
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

class AppBar extends StatelessWidget {
  const AppBar({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
                    top: status != ConnectionStatus.online ? 0 : 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: white),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          'home',
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.15),
                      child: const Text("TRANSFERENCIAS",
                          style: TextStyle(color: white, fontSize: 18)),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      shadowColor: Colors.white,
                      color: Colors.white,
                      icon: const Icon(Icons.more_vert,
                          color: Colors.white, size: 20),
                      onSelected: (String value) {
                        // Manejar la selección de opciones aquí
                        if (value.startsWith('warehouse_')) {
                          // Si el valor seleccionado es un warehouse, obtenemos su índice
                          int warehouseIndex = int.parse(value.split('_')[1]);
                          String warehouseName = context
                              .read<TransferenciaBloc>()
                              .warehouseName[warehouseIndex];

                          context
                              .read<TransferenciaBloc>()
                              .add(FilterTransferByWarehouse(warehouseName));

                          // Acción para warehouse seleccionado
                        } else {
                          // Acción para opciones generales
                          if (value == '1') {
                            context
                                .read<TransferenciaBloc>()
                                .add(FilterTransferByWarehouse('todas'));
                            // Acción para opción 1
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        // Creamos los PopupMenuItem dinámicamente basados en warehouseName
                        List<PopupMenuEntry<String>> menuItems = [];

                        // Iteramos sobre la lista de warehouseName
                        List<String> warehouseNameList =
                            context.read<TransferenciaBloc>().warehouseName;
                        for (int i = 0; i < warehouseNameList.length; i++) {
                          menuItems.add(
                            PopupMenuItem<String>(
                              value:
                                  'warehouse_$i', // Cada opción tiene un valor único basado en el índice
                              child: Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: primaryColorApp,
                                      size: 20), // Icono para el warehouse
                                  const SizedBox(width: 10),
                                  Text(
                                    warehouseNameList[
                                        i], // Nombre del warehouse
                                    style: const TextStyle(
                                        color: black, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // También podemos agregar las opciones fijas como "Ver detalles" y "Dejar pendiente"
                        menuItems.add(
                          PopupMenuItem<String>(
                            value: '1',
                            child: Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: primaryColorApp, size: 20),
                                const SizedBox(width: 10),
                                const Text('Ver todas',
                                    style:
                                        TextStyle(color: black, fontSize: 14)),
                              ],
                            ),
                          ),
                        );

                        return menuItems;
                      },
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
