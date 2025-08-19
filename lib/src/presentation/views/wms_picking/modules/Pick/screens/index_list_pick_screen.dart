import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/individual/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/widgets/dialog_info_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/bloc/picking_pick_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/models/response_pick_model.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';

class IndexListPickScreen extends StatelessWidget {
  const IndexListPickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bloc = context.read<PickingPickBloc>();

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocConsumer<PickingPickBloc, PickingPickState>(
        listener: (context, state) {
          if (state is AssignUserToPickError) {
            Get.snackbar(
              '360 Software Informa',
              state.error,
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: Icon(Icons.error, color: Colors.red),
            );
          }

          if (state is AssignUserToPickLoading) {
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

          if (state is AssignUserToPickSuccess) {
            // cerramos el dialogo de carga
            Navigator.pop(context);
            bloc.add(FetchPickWithProductsEvent(state.id));
            bloc.add(LoadConfigurationsUser());
            Navigator.pushReplacementNamed(context, 'scan-product-pick');
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: white,
            bottomNavigationBar: bloc.isKeyboardVisible
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: CustomKeyboard(
                      isLogin: false,
                      controller: bloc.searchPickController,
                      onchanged: () {
                        bloc.add(SearchPickEvent(
                            bloc.searchPickController.text, false));
                      },
                    ),
                  )
                : null,
            body: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  //*appbar
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
                            top: status != ConnectionStatus.online
                                ? 20
                                : 20,
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
                                    Navigator.pushReplacementNamed(
                                        context, '/home');
                                  },
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await DataBaseSqlite()
                                        .delePick('pick');
                                    bloc.add(FetchPickingPickEvent(true));
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * 0.15),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'PICKING - PICK',
                                          style: TextStyle(
                                              color: white,
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                    
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        //icono de refres
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

                  SizedBox(
                      // color: Colors.amber,
                      height: 60, //120
                      width: size.width * 1,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: SizedBox(
                              width: size.width * 0.95,
                              height: 55,
                              child: Card(
                                color: Colors.white,
                                elevation: 3,
                                child: TextFormField(
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: bloc.searchPickController,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search,
                                          color: grey, size: 20),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            bloc.searchPickController.clear();
                                            bloc.add(
                                                SearchPickEvent('', false));
                                            FocusScope.of(context).unfocus();
                                          },
                                          icon: IconButton(
                                            onPressed: () {
                                              bloc.add(ShowKeyboard(false));
                                              bloc.add(
                                                  SearchPickEvent('', false));
                                              bloc.searchPickController.clear();
                                            },
                                            icon: const Icon(Icons.close,
                                                color: grey, size: 20),
                                          )),
                                      disabledBorder:
                                          const OutlineInputBorder(),
                                      hintText: "Buscar pick",
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      bloc.add(SearchPickEvent(value, false));
                                    },
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    onTap: !context
                                            .read<UserBloc>()
                                            .fabricante
                                            .contains("Zebra")
                                        ? null
                                        : () {
                                            bloc.add(ShowKeyboard(true));
                                          }),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Expanded(
                    child: bloc.listOfPickFiltered
                            .where((batch) => batch.isSeparate == 0)
                            .isNotEmpty
                        ? ListView.builder(
                            padding: EdgeInsets.only(
                                top: 10, bottom: size.height * 0.15),
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: bloc.listOfPickFiltered
                                .where((batch) => batch.isSeparate == 0)
                                .length,
                            itemBuilder: (contextBuilder, index) {
                              final batch = bloc.listOfPickFiltered
                                  .where((batch) => batch.isSeparate == 0)
                                  .toList()[index];
                              //convertimos la fecha

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    // Agrupar eventos de BatchBloc si es necesario
                                    print("Batch: ${batch.toMap()}");

                                    try {
                                      if (batch.responsableId == null ||
                                          batch.responsableId == 0) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible:
                                              false, // No permitir que el usuario cierre el diálogo manualmente
                                          builder: (context) =>
                                              DialogAsignUserToOrderWidget(
                                            title:
                                                'Esta seguro de tomar este pick, una vez aceptado no podrá ser cancelada desde la app, una vez asignada se registrará el tiempo de inicio de la operación.',
                                            onAccepted: () async {
                                              // asignamos el tiempo de inicio

                                              //asignamos el responsable a esa orden de entrada
                                              //cerramos el dialogo
                                              Navigator.pop(context);
                                              bloc.add(ShowKeyboard(false));
                                              bloc.searchPickController.clear();
                                              bloc.add(
                                                AssignUserToTransfer(
                                                    batch.id ?? 0),
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        if (batch.startTimeTransfer == "") {
                                          showDialog(
                                            context: context,
                                            barrierDismissible:
                                                false, // No permitir que el usuario cierre el diálogo manualmente
                                            builder: (context) =>
                                                DialogStartTimeWidget(
                                              onAccepted: () async {
                                                bloc.add(ShowKeyboard(false));
                                                bloc.searchPickController
                                                    .clear();
                                                bloc.add(
                                                    SearchPickEvent('', false));

                                                bloc.add(
                                                    FetchPickWithProductsEvent(
                                                        batch.id ?? 0));
                                                bloc.add(
                                                    LoadConfigurationsUser());

                                                bloc.add(
                                                    StartOrStopTimeTransfer(
                                                  batch.id ?? 0,
                                                  'start_time_transfer',
                                                ));
                                                bloc.add(ShowKeyboard(false));
                                                bloc.searchPickController
                                                    .clear();
                                                Navigator.pop(context);
                                                Navigator.pushReplacementNamed(
                                                    context,
                                                    'scan-product-pick');
                                              },
                                              title: 'Iniciar Pick',
                                            ),
                                          );
                                        } else {
                                          bloc.add(FetchPickWithProductsEvent(
                                              batch.id ?? 0));
                                          bloc.add(LoadConfigurationsUser());

                                          goBatchInfo(
                                            contextBuilder,
                                            bloc,
                                            batch,
                                          );
                                        }
                                      }
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
                                    color: batch.isSeparate == 1
                                        ? Colors.green[100]
                                        : batch.isSelected == 1
                                            ? primaryColorAppLigth
                                            : Colors.white,
                                    elevation: 3,
                                    child: ListTile(
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        color: primaryColorApp,
                                      ),
                                      title: Text(batch.name ?? '',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: primaryColorApp,
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    batch.zonaEntrega ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: black)),
                                              ),
                                            ],
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
                                                                  .fechaCreacion!))
                                                      : "Sin fecha",
                                                  style: const TextStyle(
                                                      color: black,
                                                      fontSize: 12),
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
                                                    batch.proveedor == ""
                                                        ? "Sin contacto"
                                                        : batch.proveedor ?? '',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            batch.proveedor ==
                                                                    ""
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
                                                  Icons.receipt,
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
                                                    batch.origin.toString(),
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
                                          Visibility(
                                          visible: batch.backorderId != 0,
                                          child: Row(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Icon(
                                                    Icons.file_copy,
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
                                                  Icons.add,
                                                  color: primaryColorApp,
                                                  size: 15,
                                                ),
                                                const SizedBox(width: 5),
                                                const Text(
                                                  "Cantidad Productos: ",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: black),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    batch.numeroLineas
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
                                                  "Cantidad unidades: ",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: black),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    batch.numeroItems
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
                                                    batch.responsable == ""
                                                        ? "Sin responsable"
                                                        : batch.responsable ??
                                                            '',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            batch.responsable ==
                                                                    ""
                                                                ? red
                                                                : black),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const Spacer(),
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
                                                                            'Este Pick fue iniciado a las ${batch.startTimeTransfer}',
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
                                        TextStyle(fontSize: 18, color: grey)),
                                Text('Intenta con otra búsqueda',
                                    style:
                                        TextStyle(fontSize: 14, color: grey)),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void goBatchInfo(
    BuildContext context,
    PickingPickBloc batchBloc,
    ResultPick batch,
  ) async {
    // mostramos un dialogo de carga y despues
    showDialog(
      context: context,
      barrierDismissible:
          false, // No permitir que el usuario cierre el diálogo manualmente
      builder: (_) => const DialogLoading(
        message: 'Cargando interfaz...',
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context);
    // Si batch.isSeparate es 1, entonces navegamos a "batch-detail"
    if (batch.isSeparate != 1) {
      batchBloc.add(ShowKeyboard(false));
      batchBloc.searchPickController.clear();
      Navigator.pushReplacementNamed(context, 'scan-product-pick');
    } else {}
  }
}
