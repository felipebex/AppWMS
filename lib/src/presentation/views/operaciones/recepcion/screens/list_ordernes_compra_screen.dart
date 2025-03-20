// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/widgets/dialog_info_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ListOrdenesCompraScreen extends StatelessWidget {
  const ListOrdenesCompraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocConsumer<RecepcionBloc, RecepcionState>(
      listener: (context, state) {
        print('State ❤️‍🔥 $state');

        if (state is FetchOrdenesCompraFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final ordenCompra = context
            .read<RecepcionBloc>()
            .listFiltersOrdenesCompra
            .where(
                (element) => element.isFinish == 0 || element.isFinish == null)
            .toList();
        // ;
        return Scaffold(
            backgroundColor: white,
            bottomNavigationBar: context.read<RecepcionBloc>().isKeyboardVisible
                ? CustomKeyboard(
                    controller:
                        context.read<RecepcionBloc>().searchControllerOrderC,
                    onchanged: () {
                      context.read<RecepcionBloc>().add(SearchOrdenCompraEvent(
                            context
                                .read<RecepcionBloc>()
                                .searchControllerOrderC
                                .text,
                          ));
                    },
                  )
                : null,
            body: SizedBox(
              width: size.width * 1,
              height: size.height * 1,
              child: Column(
                children: [
                  //* appbar
                  AppBar(size: size),
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
                                      .read<RecepcionBloc>()
                                      .searchControllerOrderC,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: grey,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          context
                                              .read<RecepcionBloc>()
                                              .searchControllerOrderC
                                              .clear();

                                          context
                                              .read<RecepcionBloc>()
                                              .add(SearchOrdenCompraEvent(
                                                '',
                                              ));

                                          context
                                              .read<RecepcionBloc>()
                                              .add(ShowKeyboardEvent(false));

                                          FocusScope.of(context).unfocus();
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: grey,
                                          size: 20,
                                        )),
                                    disabledBorder: const OutlineInputBorder(),
                                    hintText: "Buscar orden de compra",
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    context
                                        .read<RecepcionBloc>()
                                        .add(SearchOrdenCompraEvent(
                                          value,
                                        ));
                                  },
                                  onTap: !context
                                          .read<UserBloc>()
                                          .fabricante
                                          .contains("Zebra")
                                      ? null
                                      : () {
                                          context
                                              .read<RecepcionBloc>()
                                              .add(ShowKeyboardEvent(true));
                                        },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  // (state is FetchOrdenesCompraOfBdSuccess ||
                  //         state is ShowKeyboardState ||
                  //         state is SearchOrdenCompraSuccess ||
                  //         state is ConfigurationLoadedOrder ||
                  //         state is AssignUserToOrderLoading)
                  //     ?

                  Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.only(top: 2),
                        itemCount: ordenCompra.length,
                        itemBuilder: (BuildContext contextList, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Card(
                              elevation: 3,
                              color: ordenCompra[index].isSelected == 1
                                  ? primaryColorAppLigth
                                  : ordenCompra[index].isFinish == 1
                                      ? Colors.green[200]
                                      : white,
                              child: ListTile(
                                trailing: Icon(Icons.arrow_forward_ios,
                                    color: primaryColorApp),
                                title: Text(ordenCompra[index].name ?? '',
                                    style: TextStyle(
                                        color: primaryColorApp,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
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
                                            ordenCompra[index].fechaCreacion !=
                                                    null
                                                ? DateFormat(
                                                        'dd/MM/yyyy hh:mm ')
                                                    .format(DateTime.parse(
                                                        ordenCompra[index]
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
                                            ordenCompra[index].responsable == ""
                                                ? 'sin responsable'
                                                : ordenCompra[index]
                                                        .responsable ??
                                                    '',
                                            style: const TextStyle(
                                                fontSize: 12, color: black),
                                          ),
                                          Spacer(),
                                          ordenCompra[index]
                                                      .startTimeReception !=
                                                  ""
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              DialogInfo(
                                                                title:
                                                                    'Tiempo de inicio de operacion',
                                                                body:
                                                                    'Este orden fue iniciada a las ${ordenCompra[index].startTimeReception}',
                                                              ));
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
                                          Text('Tipo de entrada: ',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp)),
                                          const SizedBox(width: 5),
                                          Text(
                                            ordenCompra[index].pickingType ??
                                                "",
                                            style: const TextStyle(
                                                fontSize: 12, color: black),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          ordenCompra[index].proveedor ?? '',
                                          style: TextStyle(
                                            color: black,
                                            fontSize: 12,
                                          )),
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
                                        ordenCompra[index].locationDestName ??
                                            '',
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
                                            ordenCompra[index]
                                                        .purchaseOrderName ==
                                                    ""
                                                ? 'Sin orden de compra'
                                                : ordenCompra[index]
                                                        .purchaseOrderName ??
                                                    '',
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
                                      'ordenCompra: ${ordenCompra[index].toMap()}');
                                  //cargamos los permisos del usuario
                                  context
                                      .read<RecepcionBloc>()
                                      .add(LoadConfigurationsUserOrder());

                                  //verficamos is la orden de entrada tiene ya un responsable
                                  if (ordenCompra[index].responsableId ==
                                          null ||
                                      ordenCompra[index].responsableId == 0) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible:
                                          false, // No permitir que el usuario cierre el diálogo manualmente
                                      builder: (context) =>
                                          DialogAsignUserToOrderWidget(
                                        onAccepted: () async {
                                          // obtenemos los productos de esa entrada
                                          context.read<RecepcionBloc>().add(
                                              GetPorductsToEntrada(
                                                  ordenCompra[index].id ?? 0));
                                          //asignamos el responsable a esa orden de entrada
                                          context.read<RecepcionBloc>().add(
                                              AssignUserToOrder(
                                                  ordenCompra[index].id ?? 0,
                                                  ));
                                          context.read<RecepcionBloc>().add(
                                              CurrentOrdenesCompra(
                                                   ordenCompra[index]));
                                          Navigator.pop(context);
                                          Navigator.pushReplacementNamed(
                                            context,
                                            'recepcion',
                                            arguments: [ordenCompra[index], 0],
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    validateTime(ordenCompra[index], context);
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ),
            ));
      },
    );
  }

  void validateTime(ResultEntrada ordenCompra, BuildContext context) {
    if (ordenCompra.startTimeReception == "" ||
        ordenCompra.startTimeReception == null) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // No permitir que el usuario cierre el diálogo manualmente
        builder: (context) => DialogStartTimeWidget(
          onAccepted: () async {
            context.read<RecepcionBloc>().add(StartOrStopTimeOrder(
                ordenCompra.id ?? 0, "start_time_reception", ));
            context
                .read<RecepcionBloc>()
                .add(GetPorductsToEntrada(ordenCompra.id ?? 0));
            //traemos la orden de entrada actual desde la bd actualizada
            context
                .read<RecepcionBloc>()
                .add(CurrentOrdenesCompra (ordenCompra));
            Navigator.pop(context);
            Navigator.pushReplacementNamed(
              context,
              'recepcion',
              arguments: [ordenCompra, 0],
            );
          },
          title: 'Iniciar Recepcion',
        ),
      );
    } else {
      context
          .read<RecepcionBloc>()
          .add(GetPorductsToEntrada(ordenCompra.id ?? 0));
      //traemos la orden de entrada actual desde la bd actualizada
      context
          .read<RecepcionBloc>()
          .add(CurrentOrdenesCompra( ordenCompra));
      Navigator.pushReplacementNamed(
        context,
        'recepcion',
        arguments: [ordenCompra, 0],
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
                      padding: EdgeInsets.only(left: size.width * 0.1),
                      child: const Text("ORDENES DE COMPRA",
                          style: TextStyle(color: white, fontSize: 18)),
                    ),
                    const Spacer(),
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
