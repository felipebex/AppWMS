import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ListOrdenesCompraScreen extends StatelessWidget {
  const ListOrdenesCompraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocConsumer<RecepcionBloc, RecepcionState>(
      listener: (context, state) {
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
        final ordenCompra = context.read<RecepcionBloc>().ordenesCompra;
        return Scaffold(
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
                              // readOnly: context
                              //         .read<UserBloc>()
                              //         .fabricante
                              //         .contains("Zebra")
                              //     ? true
                              //     : false,
                              textAlignVertical: TextAlignVertical.center,
                              // controller: context
                              //     .read<WmsPackingBloc>()
                              //     .searchControllerPedido,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: grey,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      // context
                                      //     .read<WmsPackingBloc>()
                                      //     .searchControllerPedido
                                      //     .clear();

                                      // context
                                      //     .read<WmsPackingBloc>()
                                      //     .add(
                                      //         SearchPedidoPackingEvent(
                                      //             '',
                                      //             batchModel
                                      //                     ?.id ??
                                      //                 0));

                                      // context
                                      //     .read<WmsPackingBloc>()
                                      //     .add(ShowKeyboardEvent(
                                      //         false));

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
                                // context
                                //     .read<WmsPackingBloc>()
                                //     .add(SearchPedidoPackingEvent(
                                //         value,
                                //         batchModel?.id ?? 0));
                              },
                              // onTap: !context
                              //         .read<UserBloc>()
                              //         .fabricante
                              //         .contains("Zebra")
                              //     ? null
                              //     : () {
                              //         context
                              //             .read<WmsPackingBloc>()
                              //             .add(ShowKeyboardEvent(
                              //                 true));
                              //       },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.only(top: 2),
                    itemCount: ordenCompra.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Card(
                          elevation: 3,
                          color: white,
                          child: ListTile(
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: primaryColorApp),
                            title: Text(ordenCompra[index].name ?? '',
                                style: TextStyle(
                                    color: primaryColorApp,
                                    fontSize: 14,
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
                                        ordenCompra[index].scheduledDate != null
                                            ? DateFormat('dd/MM/yyyy hh:mm ')
                                                .format(DateTime.parse(
                                                    ordenCompra[index]
                                                        .scheduledDate!))
                                            : "Sin fecha",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child:
                                      Text(ordenCompra[index].proveedor ?? '',
                                          style: TextStyle(
                                            color: black,
                                            fontSize: 14,
                                          )),
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
                                    ordenCompra[index].locationDestName ?? '',
                                    style: const TextStyle(
                                        fontSize: 14, color: black),
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
                                        ordenCompra[index].purchaseOrderName ??
                                            'Sin orden de compra',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              Navigator.pushReplacementNamed(
                                context,
                                'recepcion',
                                arguments: [ordenCompra[index]],
                              );
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
                          'operaciones',
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
