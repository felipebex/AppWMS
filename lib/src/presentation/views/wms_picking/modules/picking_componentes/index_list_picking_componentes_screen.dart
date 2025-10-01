import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/utils/sounds_utils.dart';
import 'package:wms_app/src/core/utils/vibrate_utils.dart';
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
import 'package:wms_app/src/presentation/widgets/barcode_scanner_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';

class IndexListPickComponentsScreen extends StatelessWidget {
  IndexListPickComponentsScreen({super.key});

  final AudioService _audioService = AudioService();
  final VibrationService _vibrationService = VibrationService();
  FocusNode focusNodeBuscar = FocusNode();
  final TextEditingController _controllerToDo = TextEditingController();

  void validateBarcode(String value, BuildContext context) {
    final bloc = context.read<PickingPickBloc>();
    final scan = (bloc.scannedValue5.isEmpty ? value : bloc.scannedValue5)
        .trim()
        .toLowerCase();

    _controllerToDo.clear();
    print('🔎 Scan barcode (batch picking): $scan');

    final listOfBatchs = bloc.listOfPickCompo;

    void processBatch(ResultPick batch) {
      bloc.add(ClearScannedValueEvent('toDo'));

      print(batch.toMap());
      try {
        _handlePickTap(context, batch, context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar los datos'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }

    // Buscar el producto usando el código de barras principal o el código de producto
    final batchs = listOfBatchs.firstWhere(
      (b) => b.name?.toLowerCase() == scan,
      orElse: () => ResultPick(),
    );

    if (batchs.id != null) {
      print('🔎 batch encontrado : ${batchs.id} ${batchs.name} ');
      processBatch(batchs);
      return;
    } else {
      _audioService.playErrorSound();
      _vibrationService.vibrate();
      bloc.add(ClearScannedValueEvent('toDo'));
    }
  }

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
                            bloc.searchPickController.text, true));
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
                                top:
                                    status != ConnectionStatus.online ? 20 : 20,
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
                                        bloc.searchPickController.clear();
                                        Navigator.pushReplacementNamed(
                                            context, '/home');
                                      },
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await DataBaseSqlite()
                                            .delePick('pick-componentes');
                                        bloc.add(
                                            FetchPickingComponentesEvent(true));
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: size.width * 0.05),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'PICKING COMPONENTES',
                                              style: TextStyle(
                                                  color: white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
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
                                            bloc.add(SearchPickEvent('', true));
                                            FocusScope.of(context).unfocus();
                                          },
                                          icon: IconButton(
                                            onPressed: () {
                                              bloc.add(ShowKeyboard(false));
                                              bloc.add(
                                                  SearchPickEvent('', true));
                                              bloc.searchPickController.clear();

                                              //pasamos el foco a focusNodeBuscar
                                              Future.delayed(
                                                  const Duration(seconds: 1),
                                                  () {
                                                // _handleDependencies();
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        focusNodeBuscar);
                                              });
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
                                      bloc.add(SearchPickEvent(value, true));
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

                  //*buscar por scan
                  BarcodeScannerField(
                    controller: _controllerToDo,
                    focusNode: focusNodeBuscar,
                    scannedValue5: "",
                    onBarcodeScanned: (value, context) {
                      return validateBarcode(value, context);
                    },
                    onKeyScanned: (keyLabel, type, context) {
                      return context.read<PickingPickBloc>().add(
                            UpdateScannedValueEvent(keyLabel, type),
                          );
                    },
                  ),

                  Expanded(
                    child: bloc.listOfPickCompoFiltered
                            .where((batch) => batch.isSeparate == 0)
                            .isNotEmpty
                        ? ListView.builder(
                            padding: EdgeInsets.only(
                                top: 10, bottom: size.height * 0.15),
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: bloc.listOfPickCompoFiltered
                                .where((batch) => batch.isSeparate == 0)
                                .length,
                            itemBuilder: (contextBuilder, index) {
                              final batch = bloc.listOfPickCompoFiltered
                                  .where((batch) => batch.isSeparate == 0)
                                  .toList()[index];
                              //convertimos la fecha

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    _handlePickTap(
                                        context, batch, contextBuilder);
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
                                      leading: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),

                                            //sombras
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2))
                                            ]),
                                        child: Image.asset(
                                          "assets/icons/producto.png",
                                          color: primaryColorApp,
                                          width: 24,
                                        ),
                                      ),
                                      title: Text(batch.name ?? '',
                                          style: const TextStyle(fontSize: 14)),
                                      subtitle: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    "Tipo de operación:",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: grey)),
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
                                                        color: primaryColorApp,
                                                        size: 15,
                                                      ),
                                                    )
                                                  : const SizedBox(),
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
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('Producto: ',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            primaryColorApp)),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  batch.productoFinalNombre ==
                                                          ''
                                                      ? 'Sin nombre'
                                                      : batch.productoFinalNombre ??
                                                          '',
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        batch.productoFinalNombre ==
                                                                ''
                                                            ? red
                                                            : black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Text('Referencia: ',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            primaryColorApp)),
                                                Text(
                                                  batch.productoFinalReferencia ==
                                                          ''
                                                      ? 'Sin referencia'
                                                      : batch.productoFinalReferencia ??
                                                          '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        batch.productoFinalReferencia ==
                                                                ''
                                                            ? red
                                                            : black,
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
                                            child: Text(
                                              batch.pickingType.toString(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
                                                  batch.fechaCreacion != null
                                                      ? DateFormat('dd/MM/yyyy')
                                                          .format(DateTime
                                                              .parse(batch
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
                                                  Icons.file_copy_rounded,
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

  void _handlePickTap(
      BuildContext context, dynamic batch, BuildContext contextBuilder) async {
    print("Batch: ${batch.toMap()}");
    final bloc = context
        .read<PickingPickBloc>(); // Asegúrate que el BLoC sea el correcto

    try {
      // Lógica para asignar responsable si no existe
      if (batch.responsableId == null || batch.responsableId == 0) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => DialogAsignUserToOrderWidget(
            title:
                'Esta seguro de tomar este pick, una vez aceptado no podrá ser cancelada desde la app, una vez asignada se registrará el tiempo de inicio de la operación.',
            onAccepted: () async {
              bloc.add(AssignUserToTransfer(batch.id ?? 0));
              Navigator.pop(dialogContext); // Cierra el diálogo de asignación
            },
          ),
        );
      }

      // Lógica para iniciar la transferencia si el tiempo no ha comenzado
      if (batch.startTimeTransfer == "") {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => DialogStartTimeWidget(
            title: 'Iniciar Pick',
            onAccepted: () async {
              bloc.add(StartOrStopTimeTransfer(
                  batch.id ?? 0, 'start_time_transfer'));
              Navigator.pop(dialogContext); // Cierra el diálogo de inicio
            },
          ),
        );
      }

      // Acciones comunes que se ejecutan después de los diálogos
      bloc.add(ShowKeyboard(false));
      bloc.searchPickController.clear();
      bloc.add(SearchPickEvent('', true));
      bloc.add(FetchPickWithProductsEvent(batch.id ?? 0));
      bloc.add(LoadConfigurationsUser());

      // Navegación final
      goBatchInfo(contextBuilder, bloc, batch);
    } catch (e) {
      // Manejo de errores centralizado
      ScaffoldMessenger.of(contextBuilder).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar los datos'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}
