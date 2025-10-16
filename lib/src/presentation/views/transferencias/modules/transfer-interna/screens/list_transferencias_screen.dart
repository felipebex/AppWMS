// ignore_for_file: use_build_context_synchronously

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
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/transferencias/modules/create-transfer/bloc/crate_transfer_bloc.dart';
// import 'package:wms_app/src/presentation/views/transferencias/transfer-externa/bloc/transfer_externa_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/modules/transfer-interna/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/widgets/dialog_info_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_start_picking_widget.dart';
import 'package:wms_app/src/presentation/widgets/barcode_scanner_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';

class ListTransferenciasScreen extends StatefulWidget {
  const ListTransferenciasScreen({
    super.key,
  });

  @override
  State<ListTransferenciasScreen> createState() =>
      _ListTransferenciasScreenState();
}

class _ListTransferenciasScreenState extends State<ListTransferenciasScreen> {
  final AudioService _audioService = AudioService();
  final VibrationService _vibrationService = VibrationService();
  FocusNode focusNodeBuscar = FocusNode();
  final TextEditingController _controllerToDo = TextEditingController();

  void validateBarcode(String value, BuildContext context) {
    final bloc = context.read<TransferenciaBloc>();
    final scan = (bloc.scannedValue5.isEmpty ? value : bloc.scannedValue5)
        .trim()
        .toLowerCase();

    _controllerToDo.clear();
    print('🔎 Scan barcode (batch picking): $scan');

    final listOfBatchs = bloc.transferenciasDB;

    void processBatch(ResultTransFerencias batch) {
      bloc.add(ClearScannedValueEvent('toDo'));

      print(batch.toMap());
      try {
        _handleTransferTap(
          context,
          batch,
        );
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
      orElse: () => ResultTransFerencias(),
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
    final Size size = MediaQuery.sizeOf(context);

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: BlocConsumer<TransferenciaBloc, TransferenciaState>(
            listener: (context, state) {
          print("state transferencia: $state");

          if (state is NeedUpdateVersionState) {
            Get.snackbar(
              '360 Software Informa',
              'Hay una nueva versión disponible. Actualiza desde la configuración de la app, pulsando el nombre de usuario en el Home',
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: Icon(Icons.error, color: Colors.amber),
              showProgressIndicator: true,
              duration: Duration(seconds: 5),
            );
          } else if (state is TransferenciaLoading) {
            context.read<TransferenciaBloc>().add(LoadLocations());
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const DialogLoading(
                message: 'Cargando transferencias...',
              ),
            );
          } else if (state is TransferenciaError) {
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
          } else if (state is TransferenciaLoaded) {
            Navigator.pop(context);
          } else if (state is DeviceNotAuthorized) {
            Navigator.pop(context);
            Get.defaultDialog(
              title: 'Dispositivo no autorizado',
              titleStyle: TextStyle(
                  color: primaryColorApp,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              middleText:
                  'Este dispositivo no está autorizado para usar la aplicación. su suscripción ha expirado o no está activa, por favor contacte con el administrador.',
              middleTextStyle: TextStyle(color: black, fontSize: 14),
              backgroundColor: Colors.white,
              radius: 10,
              barrierDismissible:
                  false, // Evita que se cierre al tocar fuera del diálogo
              onWillPop: () async => false,
            );
          } else if (state is AssignUserToTransferFailure) {
            Get.snackbar(
              '360 Software Informa',
              "Error al asignar el responsable a la transferencia",
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: Icon(Icons.error, color: Colors.red),
            );
          } else if (state is AssignUserToTransferSuccess) {
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
                          'transfer'));
                    },
                  )
                : null,
            floatingActionButton: FloatingActionButton(
              backgroundColor: primaryColorApp,
              onPressed: () async {
                context.read<CreateTransferBloc>()
                  ..add(GetLocationsEvent())
                  ..add(GetProductsFromDBEvent());
                Navigator.pushReplacementNamed(context, 'create-transfer');
              },
              child: const Icon(Icons.add),
            ),
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
                                bottom: 0,
                                top:
                                    status != ConnectionStatus.online ? 0 : 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: white),
                                  onPressed: () {
                                    context.read<TransferenciaBloc>().add(
                                        ShowKeyboardEvent(showKeyboard: false));

                                    context
                                        .read<TransferenciaBloc>()
                                        .searchControllerTransfer
                                        .clear();

                                    context.read<TransferenciaBloc>().add(
                                        SearchTransferEvent("", 'transfer'));

                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                    );
                                  },
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: size.width * 0.12),
                                  child: GestureDetector(
                                    onTap: () async {
                                      await DataBaseSqlite()
                                          .deleTrasnferencia('transfer');
                                      context
                                          .read<TransferenciaBloc>()
                                          .add(FetchAllTransferencias(false));
                                    },
                                    child: Row(
                                      children: [
                                        const Text("TRANSFERENCIAS",
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
                                                    color: black, fontSize: 12),
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

                                          context.read<TransferenciaBloc>().add(
                                              SearchTransferEvent(
                                                  "", 'transfer'));

                                          context.read<TransferenciaBloc>().add(
                                              ShowKeyboardEvent(
                                                  showKeyboard: false));
//pasamos el foco a focusNodeBuscar
                                          Future.delayed(
                                              const Duration(seconds: 1), () {
                                            // _handleDependencies();
                                            FocusScope.of(context)
                                                .requestFocus(focusNodeBuscar);
                                          });
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
                                    context.read<TransferenciaBloc>().add(
                                        SearchTransferEvent(value, 'transfer'));
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

                  //*buscar por scan
                  BarcodeScannerField(
                    controller: _controllerToDo,
                    focusNode: focusNodeBuscar,
                    scannedValue5: "",
                    onBarcodeScanned: (value, context) {
                      return validateBarcode(value, context);
                    },
                    onKeyScanned: (keyLabel, type, context) {
                      return context.read<TransferenciaBloc>().add(
                            UpdateScannedValueEvent(keyLabel, type),
                          );
                    },
                  ),

                  (transferBloc.transferenciasDbFilters
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
                              itemCount: transferBloc.transferenciasDbFilters
                                  .where((element) =>
                                      element.isFinish == 0 ||
                                      element.isFinish == null)
                                  .toList()
                                  .length,
                              itemBuilder: (context, index) {
                                final transferenciaDetail = transferBloc
                                    .transferenciasDbFilters
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
                                                    ? 'Sin proveedor'
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
                                                const SizedBox(width: 5),
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
                                                    transferenciaDetail
                                                        .numeroLineas
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
                                                    transferenciaDetail
                                                        .numeroItems
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
                                                const Spacer(),
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
                                        _handleTransferTap(
                                            context, transferenciaDetail);
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

  void validateTime(ResultTransFerencias transfer, BuildContext context) async {
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
                .add(SearchTransferEvent("", 'transfer'));

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

      context
          .read<TransferenciaBloc>()
          .add(SearchTransferEvent("", 'transfer'));

      context
          .read<TransferenciaBloc>()
          .add(GetPorductsToTransfer(transfer.id ?? 0));
      //traemos la orden de entrada actual desde la bd actualizada
      context.read<TransferenciaBloc>().add(CurrentTransferencia(transfer));
      context.read<TransferenciaBloc>().add(LoadLocations());

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

      Navigator.pushReplacementNamed(
        context,
        'transferencia-detail',
        arguments: [transfer, 0],
      );
    }
  }

  void _handleTransferTap(
      BuildContext context, dynamic transferenciaDetail) async {
    print('transferenciaDetail: ${transferenciaDetail.toMap()}');
    final transferenciaBloc = context.read<TransferenciaBloc>();

    // 1. Cargamos las configuraciones una sola vez
    transferenciaBloc.add(LoadConfigurationsUserTransfer());

    // 2. Lógica para asignar el responsable o continuar
    if (transferenciaDetail.responsableId == null ||
        transferenciaDetail.responsableId == 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => DialogAsignUserToOrderWidget(
          title:
              'Esta seguro de tomar esta orden, una vez aceptada no podrá ser cancelada desde la app, una vez asignada se registrará el tiempo de inicio de la operación.',
          onAccepted: () async {
            // Lógica para asignar el usuario
            transferenciaBloc.add(ShowKeyboardEvent(showKeyboard: false));
            transferenciaBloc.searchControllerTransfer.clear();
            transferenciaBloc.add(SearchTransferEvent("", 'transfer'));
            transferenciaBloc.add(AssignUserToTransfer(transferenciaDetail));

            Navigator.pop(dialogContext); // Cierra el diálogo de asignación
          },
        ),
      );
    } else {
      // Si el responsable ya existe, validar el tiempo directamente
      validateTime(transferenciaDetail, context);
    }
  }
}
