import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ListConteoScreen extends StatelessWidget {
  const ListConteoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocBuilder<ConteoBloc, ConteoState>(
        builder: (context, state) {
          return Scaffold(
              backgroundColor: white,
              body: Column(
                children: [
                  //appBar
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
                                bottom: 0,
                                top:
                                    status != ConnectionStatus.online ? 0 : 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      size: 20, color: white),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                    );
                                  },
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.read<ConteoBloc>().add(
                                          GetConteosEvent(),
                                        );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * 0.18),
                                    child: Row(
                                      children: [
                                        const Text("CONTEO FISICO",
                                            style: TextStyle(
                                                color: white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                        const SizedBox(width: 5),
                                        Icon(Icons.refresh,
                                            color: white, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer()
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  (context.read<ConteoBloc>().ordenesDeConteo?.isEmpty ?? true)
                      ? Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Text('No hay conteos disponibles',
                                  style: TextStyle(fontSize: 14, color: grey)),
                              const Text('Intente nuevamente más tarde',
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
                              padding: const EdgeInsets.only(top: 10),
                              itemCount: context
                                  .read<ConteoBloc>()
                                  .ordenesDeConteo
                                  ?.length,
                              itemBuilder:
                                  (BuildContext contextList, int index) {
                                final conteo = context
                                    .read<ConteoBloc>()
                                    .ordenesDeConteo?[index];
                                return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        context.read<ConteoBloc>().add(
                                              LoadConteoAndProductsEvent(
                                                  ordenConteoId:
                                                      conteo?.id ?? 0
                                              ),
                                            );
                                        Navigator.pushReplacementNamed(
                                          context,
                                          'conteo-detail',
                                          arguments: [
                                            0,
                                            conteo,
                                          ],
                                        );
                                      },
                                      child: Card(
                                        elevation: 3,
                                        child: ListTile(
                                          trailing: Icon(
                                              Icons.arrow_forward_ios,
                                              color: primaryColorApp),
                                          title: Text(conteo?.name ?? '',
                                              style: TextStyle(
                                                  color: primaryColorApp,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Column(
                                            children: [
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        color: primaryColorApp,
                                                        size: 15,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        conteo?.responsableName ??
                                                            'Sin usuario',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                conteo?.responsableName !=
                                                                        null
                                                                    ? black
                                                                    : red),
                                                      ),
                                                    ],
                                                  )),
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Tipo de conteo:',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: black),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        conteo?.countType ??
                                                            'Sin tipo',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                primaryColorApp),
                                                      ),
                                                    ],
                                                  )),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .calendar_month_sharp,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      conteo?.dateCount != null
                                                          ? DateFormat(
                                                                  'dd/MM/yyyy hh:mm ')
                                                              .format(DateTime
                                                                  .parse(conteo!
                                                                      .dateCount
                                                                      .toString()))
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
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      'Cantidad de lineas:',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: black),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      conteo?.numeroLineas
                                                              .toString() ??
                                                          '0',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              primaryColorApp),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.warehouse,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      'Almacen:',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: black),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      conteo?.warehouseName !=
                                                                  null &&
                                                              conteo?.warehouseName !=
                                                                  ""
                                                          ? conteo!
                                                              .warehouseName!
                                                          : 'Sin almacen',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              primaryColorApp),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ));
                              }))
                ],
              ));
        },
      ),
    );
  }
}
