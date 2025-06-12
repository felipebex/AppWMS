// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/individual/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/widgets/dialog_info_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/response_packing_pedido_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/screens/widgets/others/dialog_start_packing_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/packing_pedido_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';

import 'package:wms_app/src/utils/constans/colors.dart';

class ListPackingScreen extends StatefulWidget {
  const ListPackingScreen({super.key});

  @override
  State<ListPackingScreen> createState() => _WmsPackingScreenState();
}

class _WmsPackingScreenState extends State<ListPackingScreen> {
  NotchBottomBarController controller = NotchBottomBarController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocConsumer<PackingPedidoBloc, PackingPedidoState>(
        listener: (context, state) {
      if (state is AssignUserToPedidoError) {
        Get.snackbar(
          '360 Software Informa',
          state.error,
          backgroundColor: white,
          colorText: primaryColorApp,
          icon: Icon(Icons.error, color: Colors.red),
        );
      }
    
      if (state is AssignUserToPedidoLoading) {
        // mostramos un dialogo de carga y despues
        showDialog(
          context: context,
          barrierDismissible:
              false, // No permitir que el usuario cierre el diálogo manualmente
          builder: (_) => const DialogLoading(
            message: 'Cargando interfaz...',
          ),
        );
      }
    
      if (state is AssignUserToPedidoLoaded) {
        // cerramos el dialogo de carga
        Navigator.pop(context);
        context.read<PackingPedidoBloc>().add(LoadConfigurationsUser());
        //traemos el pedido y los productos
        context.read<PackingPedidoBloc>().add(LoadPedidoAndProductsEvent(
              state.id,
            ));
    
        // Navigator.pushReplacementNamed(context, 'scan-product-pick');
      }
    }, builder: (context, state) {
      return Scaffold(
          backgroundColor: white,
          bottomNavigationBar:
              context.read<PackingPedidoBloc>().isKeyboardVisible
                  ? CustomKeyboard(
                      isLogin: false,
                      controller:
                          context.read<PackingPedidoBloc>().searchController,
                      onchanged: () {},
                    )
                  : null,
          body: Container(
            margin: const EdgeInsets.only(bottom: 10),
            width: size.width * 1,
            child:
    
                ///*listado de bacths
    
                Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primaryColorApp,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                      builder: (context, status) {
                    return Column(
                      children: [
                        const WarningWidgetCubit(),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: status != ConnectionStatus.online ? 0 : 35,
                              bottom: 0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: white),
                                    onPressed: () {
                                      context
                                          .read<PackingPedidoBloc>()
                                          .add(ShowKeyboardEvent(false));
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/home',
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * 0.1),
                                    child: GestureDetector(
                                      onTap: () async {
                                        await DataBaseSqlite()
                                            .delePacking('packing-pack');
                                        context
                                            .read<PackingPedidoBloc>()
                                            .add(LoadAllPackingPedidoEvent(
                                              true,
                                            ));
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'PACKING PEDIDOS',
                                            style: TextStyle(
                                                color: white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
    
                //*barra de buscar
    
                Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: 60,
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
                                    .read<PackingPedidoBloc>()
                                    .searchController,
                                decoration: InputDecoration(
                                  prefixIcon:
                                      const Icon(Icons.search, color: grey),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        context
                                            .read<PackingPedidoBloc>()
                                            .searchController
                                            .clear();
    
                                        context
                                            .read<PackingPedidoBloc>()
                                            .add(SearchPedidoEvent(
                                              '',
                                            ));
                                        context
                                            .read<PackingPedidoBloc>()
                                            .add(ShowKeyboardEvent(false));
    
                                        FocusScope.of(context).unfocus();
                                      },
                                      icon: const Icon(Icons.close,
                                          color: grey)),
                                  disabledBorder: const OutlineInputBorder(),
                                  hintText: "Buscar pedido de packing",
                                  hintStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  context
                                      .read<PackingPedidoBloc>()
                                      .add(SearchPedidoEvent(
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
                                            .read<PackingPedidoBloc>()
                                            .add(ShowKeyboardEvent(true));
                                      },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
    
                //*listado de batchs
                Expanded(
                  child: context
                          .read<PackingPedidoBloc>()
                          .listOfPedidosFilters
                          .where((batch) => batch.isTerminate == 0)
                          .isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: context
                              .read<PackingPedidoBloc>()
                              .listOfPedidosFilters
                              .where((batch) => batch.isTerminate == 0)
                              .length,
                          itemBuilder: (contextBuilder, index) {
                            final List<PedidoPackingResult>
                                inProgressBatches = context
                                    .read<PackingPedidoBloc>()
                                    .listOfPedidosFilters
                                    .where((batch) => batch.isTerminate == 0)
                                    .toList(); // Convertir a lista
    
                            // Asegurarse de que hay batches en progreso
                            if (inProgressBatches.isEmpty) {
                              return const Center(
                                  child: Text('No hay batches en progreso.'));
                            }
    
                            // Comprobar que el índice no está fuera de rango
                            if (index >= inProgressBatches.length) {
                              return const SizedBox(); // O manejar de otra forma
                            }
    
                            final batch = inProgressBatches[
                                index]; // Acceder al batch filtrado
    
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: GestureDetector(
                                onTap: () async {
                                  try {
                                    // if (batch.responsableId == null ||
                                    //     batch.responsableId == 0) {
                                    //   showDialog(
                                    //     context: context,
                                    //     barrierDismissible:
                                    //         false, // No permitir que el usuario cierre el diálogo manualmente
                                    //     builder: (context) =>
                                    //         DialogAsignUserToOrderWidget(
                                    //       title:
                                    //           'Esta seguro de tomar este pedido de packing, una vez aceptado no podrá ser cancelada desde la app, una vez asignada se registrará el tiempo de inicio de la operación.',
                                    //       onAccepted: () async {
                                    //         // asignamos el tiempo de inicio
    
                                    //         //asignamos el responsable a esa orden de entrada
                                    //         //cerramos el dialogo
                                    //         Navigator.pop(context);
                                    //         context
                                    //             .read<PackingPedidoBloc>()
                                    //             .add(
                                    //                 ShowKeyboardEvent(false));
                                    //         context
                                    //             .read<PackingPedidoBloc>()
                                    //             .searchController
                                    //             .clear();
                                    //         context
                                    //             .read<PackingPedidoBloc>()
                                    //             .add(
                                    //               AssignUserToPedido(
                                    //                   batch.id ?? 0),
                                    //             );
                                    //       },
                                    //     ),
                                    //   );
                                    // }

                                    //cargamos las configuraciones
                                    context
                                        .read<PackingPedidoBloc>()
                                        .add(LoadConfigurationsUser(
                                        ));
                                    //cargamos la info del pedido seleccionado y los productos, paquetes del pedido
                                    context
                                        .read<PackingPedidoBloc>()
                                        .add(LoadPedidoAndProductsEvent(
                                          batch.id ?? 0,
                                        ));
    
                                    Navigator.pushReplacementNamed(
                                        context, 'detail-packing-pedido',
                                        arguments: [0]);
                                  } catch (e) {
                                    // Manejo de errores, por si ocurre algún problema
    
                                    ScaffoldMessenger.of(contextBuilder)
                                        .showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Error al cargar los datos'),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                },
                                child: Card(
                                  color: batch.isTerminate == 1
                                      ? Colors.green[100]
                                      : batch.isSelected == 1
                                          ? primaryColorAppLigth
                                          : Colors.white,
                                  elevation: 5,
                                  child: ListTile(
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      color: primaryColorApp,
                                    ),
                                    title: Text(batch.name ?? '',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: primaryColorApp,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(batch.zonaEntrega ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: black)),
                                        ),
                                        Row(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text("Operación: ",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          primaryColorApp)),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                batch.pickingType.toString(),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: black),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
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
                                                batch.priority == '0'
                                                    ? 'Normal'
                                                    : 'Alta'
                                                        "",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: batch.priority == '0'
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
                                                batch.fechaCreacion != null
                                                    ? DateFormat('dd/MM/yyyy')
                                                        .format(DateTime
                                                            .parse(batch
                                                                .fechaCreacion
                                                                .toString()))
                                                    : "Sin fecha",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: black),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: batch.backorderId != 0,
                                          child: Row(
                                            children: [
                                              Align(
                                                alignment:
                                                    Alignment.centerLeft,
                                                child: Icon(
                                                    Icons
                                                        .shopping_cart_rounded,
                                                    color: primaryColorApp,
                                                    size: 15),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(batch.backorderName ?? '',
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
                                                Icons.shopping_cart_rounded,
                                                color: primaryColorApp,
                                                size: 15,
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                "Doc. Origen: ",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: black),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  batch.referencia.toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: primaryColorApp),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
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
                                              Expanded(
                                                child: Text(
                                                  batch.proveedor == "" ||
                                                          batch.proveedor ==
                                                              null
                                                      ? "Sin proveedor"
                                                      : batch.proveedor ?? '',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: batch.proveedor ==
                                                                  "" ||
                                                              batch.proveedor ==
                                                                  null
                                                          ? red
                                                          : black),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
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
                                              const Text(
                                                "Cantidad de items: ",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: black),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  batch.cantidadProductos
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: primaryColorApp),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
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
                                              const Text(
                                                "Cantidad de paquetes: ",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: black),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  batch.numeroPaquetes
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: primaryColorApp),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
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
                                              Expanded(
                                                child: Text(
                                                  batch.responsable == "" ||
                                                          batch.responsable ==
                                                              null
                                                      ? "Sin responsable"
                                                      : batch.responsable ??
                                                          '',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: batch.responsable ==
                                                                  "" ||
                                                              batch.responsable ==
                                                                  null
                                                          ? red
                                                          : black),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Spacer(),
                                              batch.startTimeTransfer != ""
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    DialogInfo(
                                                                      title:
                                                                          'Tiempo de inicio',
                                                                      body:
                                                                          'Este batch fue iniciado a las ${batch.startTimeTransfer}',
                                                                    ));
                                                      },
                                                      child: Icon(
                                                        Icons.timer_sharp,
                                                        color:
                                                            primaryColorApp,
                                                        size: 15,
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 10),
                              Text('No se encontraron resultados',
                                  style:
                                      TextStyle(fontSize: 14, color: grey)),
                              Text('Intenta con otra búsqueda',
                                  style:
                                      TextStyle(fontSize: 12, color: grey)),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ));
    });
  }

  // void goBatchInfo(BuildContext context, PackingPedidoBloc batchBloc,
  //     BatchPackingModel batch) async {
  //   // mostramos un dialogo de carga y despues
  //   showDialog(
  //     context: context,
  //     barrierDismissible:
  //         false, // No permitir que el usuario cierre el diálogo manualmente
  //     builder: (_) => const DialogLoading(
  //       message: 'Cargando interfaz...',
  //     ),
  //   );

  //   await Future.delayed(const Duration(seconds: 1));
  //   Navigator.pop(context);

  //   Navigator.pushReplacementNamed(
  //     context,
  //     'packing-list',
  //     arguments: [batch],
  //   );
  // }
}
