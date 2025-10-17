// ignore_for_file: use_super_parameters, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/utils/sounds_utils.dart';
import 'package:wms_app/src/core/utils/vibrate_utils.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/progressIndicatos_widget.dart';
import 'package:wms_app/src/presentation/widgets/barcode_scanner_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';

class PakingListScreen extends StatefulWidget {
  const PakingListScreen({Key? key, required this.batchModel})
      : super(key: key);

  final BatchPackingModel? batchModel;

  @override
  State<PakingListScreen> createState() => _PakingListScreenState();
}

bool isSearch = false;

class _PakingListScreenState extends State<PakingListScreen>
    with WidgetsBindingObserver {
  FocusNode focusNodeBuscar = FocusNode();
  final TextEditingController _controllerToDo = TextEditingController();
  final AudioService _audioService = AudioService();
  final VibrationService _vibrationService = VibrationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void validateBarcode(String value, BuildContext context) {
    final bloc = context.read<WmsPackingBloc>();
    final scan = (bloc.scannedValue5.isEmpty ? value : bloc.scannedValue5)
        .trim()
        .toLowerCase();

    _controllerToDo.clear();
    print('🔎 Scan barcode (batch picking): $scan');

    // 1. Obtener la lista original del BLoC (es una referencia)
    final List<dynamic> rawPedidos = bloc.listOfPedidosFilters;
// 2. Crear una copia modificable de la lista original
    final List<dynamic> sortedListOfPedidos = List.from(rawPedidos);
// 3. Aplicar el ordenamiento
// La lógica: Los pedidos con isTerminate != 1 (o sea, 0 o null) deben ir primero.
// El comparador hará que 0 vaya antes que 1.
    sortedListOfPedidos.sort((a, b) {
      // Converte a.isTerminate a un entero (0 si es null/0, 1 si es 1)
      final aTerminate = a.isTerminate == 1 ? 1 : 0;
      // Converte b.isTerminate a un entero (0 si es null/0, 1 si es 1)
      final bTerminate = b.isTerminate == 1 ? 1 : 0;
      // Compara: 0 (Pendiente/No Terminado) < 1 (Terminado)
      return aTerminate.compareTo(bTerminate);
    });

// ✅ 4. La variable final a usar es la lista ordenada
    final listOfPedidos = sortedListOfPedidos;

    void processBatch(PedidoPacking pedido) {
      bloc.add(ClearScannedValuePackEvent('toDo'));
      print(pedido.toMap());
      try {
        _handlePedidoTap(context, pedido, context);
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
    final batchs = listOfPedidos.firstWhere(
      (b) =>
          b.name?.toLowerCase() == scan || b.zonaEntrega?.toLowerCase() == scan,
      orElse: () => PedidoPacking(),
    );

    if (batchs.id != null) {
      print(
          '🔎 pedido encontrado : ${batchs.id} ${batchs.name} - ${batchs.zonaEntrega}');
      processBatch(batchs);
      return;
    } else {
      _audioService.playErrorSound();
      _vibrationService.vibrate();
      bloc.add(ClearScannedValuePackEvent('toDo'));
    }
  }

  void _handlePedidoTap(BuildContext context, PedidoPacking pedido,
      BuildContext contextBuilder) async {
    context.read<WmsPackingBloc>().add(ShowDetailvent(true));

    // Limpiamos la lista de paquetes
    context.read<WmsPackingBloc>().packages = [];
    // Pedimos todos los productos de un pedido
    context.read<WmsPackingBloc>().add(LoadAllProductsFromPedidoEvent(
          pedido.id ?? 0,
        ));

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

    //cerramos el teclado focus
    FocusScope.of(context).unfocus();

    // Viajamos a la vista de detalle de un pedido
    Navigator.pushReplacementNamed(context, 'packing-detail',
        arguments: [pedido, widget.batchModel, 0]);
    print('Pedido seleccionado: ${pedido.toMap()}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocConsumer<WmsPackingBloc, WmsPackingState>(
        listener: (context, state) {
          if (state is SendTemperatureLoading) {
            showDialog(
              context: context,
              builder: (context) {
                return const DialogLoading(
                  message: "Enviando temperatura...",
                );
              },
            );
          }

          if (state is SendTemperatureSuccess) {
            Navigator.pop(context);
            context.read<WmsPackingBloc>().add(LoadBatchPackingFromDBEvent());
            Get.snackbar("360 Software Informa", state.message,
                backgroundColor: white,
                colorText: primaryColorApp,
                icon: Icon(Icons.error, color: Colors.green));

            Navigator.pushReplacementNamed(
              context,
              'wms-packing',
            );
          }

          if (state is SendTemperatureFailure) {
            Navigator.pop(context);
            Get.snackbar("360 Software Informa", state.error,
                backgroundColor: white,
                colorText: primaryColorApp,
                icon: Icon(Icons.error, color: Colors.red));
          }
        },
        builder: (context, state) {
          print(
              'isKeyboardVisible: ${context.read<WmsPackingBloc>().isKeyboardVisible}');
          return Scaffold(
            bottomNavigationBar: context
                        .read<WmsPackingBloc>()
                        .isKeyboardVisible &&
                    context.read<UserBloc>().fabricante.contains("Zebra")
                ? CustomKeyboard(
                    isLogin: false,
                    controller:
                        context.read<WmsPackingBloc>().searchControllerPedido,
                    onchanged: () {
                      context.read<WmsPackingBloc>().add(
                          SearchPedidoPackingEvent(
                              context
                                  .read<WmsPackingBloc>()
                                  .searchControllerPedido
                                  .text,
                              widget.batchModel?.id ?? 0));
                    },
                  )
                : null,
            backgroundColor: Colors.white,
            body: SizedBox(
              width: size.width * 1,
              height: size.height * 1,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //appbar
                    Container(
                      decoration: BoxDecoration(
                        color: primaryColorApp,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      width: double.infinity,
                      child:
                          BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                              builder: (context, status) {
                        return Column(
                          children: [
                            const WarningWidgetCubit(),
                            Padding(
                              padding: EdgeInsets.only(
                                  // bottom: 10,
                                  top: status != ConnectionStatus.online
                                      ? 0
                                      : 25),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: white),
                                    onPressed: () {
                                      context
                                          .read<WmsPackingBloc>()
                                          .add(LoadBatchPackingFromDBEvent());
                                      context
                                          .read<WmsPackingBloc>()
                                          .add(ShowKeyboardEvent(false));

                                      context
                                          .read<WmsPackingBloc>()
                                          .searchControllerPedido
                                          .clear();
                                      Navigator.pushReplacementNamed(
                                        context,
                                        'wms-packing',
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * 0.27),
                                    child: const Text("PACKING",
                                        style: TextStyle(
                                            color: white, fontSize: 18)),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    SizedBox(
                      width: size.width,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            //*card informativa
                            GestureDetector(
                              onTap: () {
                                print(widget.batchModel?.toMap());
                              },
                              child: Visibility(
                                visible: !context
                                    .read<WmsPackingBloc>()
                                    .isKeyboardVisible,
                                child: Card(
                                  elevation: 5,
                                  color: Colors.grey[200],
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, bottom: 10),
                                    margin: const EdgeInsets.only(top: 10),
                                    width: size.width * 0.9,
                                    child: Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget.batchModel?.name ?? '',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: primaryColorApp,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Row(
                                          children: [
                                            const Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Responsable: ',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: black),
                                                )),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  widget.batchModel?.userName ==
                                                              false ||
                                                          widget.batchModel
                                                                  ?.userName ==
                                                              ""
                                                      ? 'Sin responsable'
                                                      : "${widget.batchModel?.userName}",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: primaryColorApp),
                                                )),
                                          ],
                                        ),
                                        const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Tipo de operación: ",
                                              style: TextStyle(
                                                  fontSize: 12, color: black),
                                            )),
                                        SizedBox(
                                          width: size.width * 0.9,
                                          child: Text(
                                            widget.batchModel?.pickingTypeId ==
                                                    false
                                                ? 'Sin tipo de operación'
                                                : "${widget.batchModel?.pickingTypeId}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "Fecha programada:",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: black),
                                                )),
                                            const SizedBox(width: 10),
                                            Builder(
                                              builder: (context) {
                                                // Verifica si `scheduledDate` es false o null
                                                String displayDate;
                                                if (widget.batchModel
                                                            ?.scheduleddate ==
                                                        false ||
                                                    widget.batchModel
                                                            ?.scheduleddate ==
                                                        null) {
                                                  displayDate = 'sin fecha';
                                                } else {
                                                  try {
                                                    DateTime dateTime =
                                                        DateTime.parse(widget
                                                                .batchModel
                                                                ?.scheduleddate
                                                                .toString() ??
                                                            ""); // Parsear la fecha
                                                    // Formatear la fecha usando Intl
                                                    displayDate = DateFormat(
                                                            'dd MMMM yyyy',
                                                            'es_ES')
                                                        .format(dateTime);
                                                  } catch (e) {
                                                    displayDate =
                                                        'sin fecha'; // Si ocurre un error al parsear
                                                  }
                                                }

                                                return Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    displayDate,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: primaryColorApp),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Card(
                                          elevation: 3,
                                          color: primaryColorApp,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                top: 10,
                                                bottom: 5),
                                            child: ProgressIndicatorWidget(
                                              progress: context
                                                      .read<WmsPackingBloc>()
                                                      .listOfPedidos
                                                      .isNotEmpty
                                                  ? context
                                                          .read<
                                                              WmsPackingBloc>()
                                                          .listOfPedidos
                                                          .where((element) =>
                                                              element
                                                                  .isTerminate ==
                                                              1)
                                                          .length /
                                                      context
                                                          .read<
                                                              WmsPackingBloc>()
                                                          .listOfPedidos
                                                          .length
                                                  : 0.0,
                                              completed: context
                                                  .read<WmsPackingBloc>()
                                                  .listOfPedidos
                                                  .where((element) =>
                                                      element.isTerminate == 1)
                                                  .length,
                                              total: context
                                                  .read<WmsPackingBloc>()
                                                  .listOfPedidos
                                                  .length,
                                            ),
                                          ),
                                        ),
                                        // Visibility(
                                        //   visible: widget.batchModel
                                        //               ?.manejaTemperatura ==
                                        //           1 &&
                                        //       widget.batchModel?.temperatura ==
                                        //           0.0,
                                        //   child: ElevatedButton(
                                        //       onPressed: () {
                                        //         showDialog(
                                        //           context: context,
                                        //           builder: (context) {
                                        //             return DialogTemperature(
                                        //               controller: context
                                        //                   .read<
                                        //                       WmsPackingBloc>()
                                        //                   .controllerTemperature,
                                        //               onConfirm: () {
                                        //                 //cerramos el dialog
                                        //                 Navigator.pop(context);
                                        //                 context
                                        //                     .read<
                                        //                         WmsPackingBloc>()
                                        //                     .add(SendTemperatureEvent(
                                        //                         widget.batchModel
                                        //                                 ?.id ??
                                        //                             0,
                                        //                         double.parse(context
                                        //                             .read<
                                        //                                 WmsPackingBloc>()
                                        //                             .controllerTemperature
                                        //                             .text)));
                                        //               },
                                        //               onCancel: () {
                                        //                 //cerramos el dialog
                                        //                 Navigator.pop(context);
                                        //               },
                                        //             );
                                        //           },
                                        //         );
                                        //       },
                                        //       style: ElevatedButton.styleFrom(
                                        //         backgroundColor:
                                        //             primaryColorApp,
                                        //         minimumSize:
                                        //             Size(size.width * 0.7, 40),
                                        //         shape: RoundedRectangleBorder(
                                        //           borderRadius:
                                        //               BorderRadius.circular(10),
                                        //         ),
                                        //       ),
                                        //       child: Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.center,
                                        //         children: [
                                        //           //*icono de temperatura
                                        //           const Icon(
                                        //             Icons.thermostat,
                                        //             color: white,
                                        //             size: 20,
                                        //           ),
                                        //           const SizedBox(width: 10),

                                        //           Text('Ingresar Temperatura',
                                        //               style: TextStyle(
                                        //                 fontSize: 14,
                                        //                 color: white,
                                        //               )),
                                        //         ],
                                        //       )),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            //*barra de buscar

                            SizedBox(
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
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            controller: context
                                                .read<WmsPackingBloc>()
                                                .searchControllerPedido,
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(
                                                Icons.search,
                                                color: grey,
                                                size: 20,
                                              ),
                                              suffixIcon: IconButton(
                                                  onPressed: () {
                                                    context
                                                        .read<WmsPackingBloc>()
                                                        .searchControllerPedido
                                                        .clear();

                                                    context
                                                        .read<WmsPackingBloc>()
                                                        .add(SearchPedidoPackingEvent(
                                                            '',
                                                            widget.batchModel
                                                                    ?.id ??
                                                                0));
                                                    context
                                                        .read<WmsPackingBloc>()
                                                        .add(ShowKeyboardEvent(
                                                            false));
                                                    //pasamos el foco a focusNodeBuscar
                                                    Future.delayed(
                                                        const Duration(
                                                            seconds: 1), () {
                                                      // _handleDependencies();
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              focusNodeBuscar);
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: grey,
                                                    size: 20,
                                                  )),
                                              disabledBorder:
                                                  const OutlineInputBorder(),
                                              hintText: "Buscar pedido",
                                              hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (value) {
                                              context
                                                  .read<WmsPackingBloc>()
                                                  .add(SearchPedidoPackingEvent(
                                                      value,
                                                      widget.batchModel?.id ??
                                                          0));
                                            },
                                            onTap: () {
                                              context
                                                  .read<WmsPackingBloc>()
                                                  .add(ShowKeyboardEvent(true));
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
                                return context.read<WmsPackingBloc>().add(
                                      UpdateScannedValuePackEvent(
                                          keyLabel, type),
                                    );
                              },
                            ),

                            //*listado de pedidos
                            BlocBuilder<WmsPackingBloc, WmsPackingState>(
                              builder: (context, state) {
                                final packingBloc =
                                    context.read<WmsPackingBloc>();

                                // Ordenamos la lista de pedidos
                                final sortedPedidos = List.from(packingBloc
                                    .listOfPedidosFilters); // Copiamos la lista para no modificarla directamente
                                sortedPedidos.sort((a, b) {
                                  // Si 'isTerminate' es diferente de 1, debe ir primero
                                  return (a.isTerminate == 1 ? 1 : 0)
                                      .compareTo(b.isTerminate == 1 ? 1 : 0);
                                });

                                return Container(
                                  width: size.width * 1,
                                  height: size.height * 0.46,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: (packingBloc.listOfPedidosFilters
                                          .where(
                                              (batch) => batch.isTerminate == 0)
                                          .isEmpty)
                                      ? Center(
                                          // Reemplazamos Expanded por Center
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text('No hay pedidos',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: grey)),
                                              const Text(
                                                  'Intente buscar otro producto',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: grey)),
                                              if (context
                                                  .read<UserBloc>()
                                                  .fabricante
                                                  .contains("Zebra"))
                                                const SizedBox(height: 60),
                                            ],
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: packingBloc
                                              .listOfPedidosFilters
                                              .where((batch) =>
                                                  batch.isTerminate == 0)
                                              .length,
                                          itemBuilder: (context, index) {
                                            // Asegúrate de que 'sortedPedidos' esté ordenado por 'orderTms'
                                            sortedPedidos.sort((a, b) {
                                              var orderA = a.orderTms;
                                              var orderB = b.orderTms;

                                              // Comprobamos si 'orderTms' es un número representado como String
                                              return (int.tryParse(
                                                          orderA ?? '0') ??
                                                      0)
                                                  .compareTo(int.tryParse(
                                                          orderB ?? '0') ??
                                                      0);
                                            });

                                            final PedidoPacking packing =
                                                sortedPedidos[index];

                                            return GestureDetector(
                                              onTap: () {
                                                _handlePedidoTap(
                                                    context, packing, context);
                                              },
                                              child: Card(
                                                elevation: 5,
                                                color: packing.isTerminate == 1
                                                    ? Colors.green[100]
                                                    : packing.isSelected == 1
                                                        ? primaryColorAppLigth
                                                        : Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15,
                                                      vertical: 15),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text("Nombre:",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      primaryColorApp)),
                                                          const SizedBox(
                                                              width: 10),
                                                          Flexible(
                                                            child: Text(
                                                                packing.name ??
                                                                    " ",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text("Zona:",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      primaryColorApp)),
                                                          const SizedBox(
                                                              width: 10),
                                                          Flexible(
                                                            child: Text(
                                                                packing.zonaEntrega ??
                                                                    "",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text("Zona TMS:",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      primaryColorApp)),
                                                          const SizedBox(
                                                              width: 10),
                                                          Flexible(
                                                            child: Text(
                                                                packing.zonaEntregaTms ??
                                                                    " ",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              "Cantidad de productos:",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      primaryColorApp)),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Text(
                                                                packing
                                                                    .cantidadProductos
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10),
                                                            width: 85,
                                                            height: 20,
                                                            decoration: BoxDecoration(
                                                                color: packing.isTerminate == 1
                                                                    ? primaryColorAppLigth
                                                                    : packing.isSelected != 1
                                                                        ? grey
                                                                        : Colors.green[100],
                                                                borderRadius: BorderRadius.circular(10)),
                                                            child: Center(
                                                              child: Text(
                                                                packing.isTerminate ==
                                                                        1
                                                                    ? 'Terminado'
                                                                    : packing.isSelected !=
                                                                            1
                                                                        ? 'Sin procesar'
                                                                        : 'En proceso',
                                                                style: TextStyle(
                                                                    color: packing.isTerminate == 1
                                                                        ? black
                                                                        : packing.isSelected != 1
                                                                            ? white
                                                                            : black,
                                                                    fontSize: 12),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text('Referencia:',
                                                              style: TextStyle(
                                                                  color:
                                                                      primaryColorApp,
                                                                  fontSize:
                                                                      12)),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Text(
                                                                packing.referencia ??
                                                                    '',
                                                                style: const TextStyle(
                                                                    color:
                                                                        black,
                                                                    fontSize:
                                                                        12)),
                                                          ),
                                                        ],
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                            "Tipo de operación:",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    primaryColorApp)),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      SizedBox(
                                                        width: size.width * 0.9,
                                                        child: Text(
                                                            packing.tipoOperacion ??
                                                                " ",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text("Contacto:",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    primaryColorApp)),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      SizedBox(
                                                        width: size.width * 0.9,
                                                        child: Text(
                                                            packing.contactoName ??
                                                                " ",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
