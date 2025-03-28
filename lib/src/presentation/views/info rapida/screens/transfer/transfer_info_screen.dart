// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/info_rapida_model.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/transfer_info_request.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/quick%20info/bloc/info_rapida_bloc.dart';
// import 'package:wms_app/src/presentation/views/info%20rapida/screens/quick%20info/bloc/info_rapida_bloc.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/transfer/bloc/transfer_info_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_barcodes_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class TransferInfoScreen extends StatefulWidget {
  final InfoRapidaResult? infoRapidaResult;
  final Ubicacion? ubicacion;

  const TransferInfoScreen(
      {super.key, required this.infoRapidaResult, this.ubicacion});

  @override
  State<TransferInfoScreen> createState() => _TransferInfoScreenState();
}

class _TransferInfoScreenState extends State<TransferInfoScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Añadimos el observer para escuchar el ciclo de vida de la app.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        // Aquí se ejecutan las acciones solo si la pantalla aún está montada
        showDialog(
          context: context,
          builder: (context) {
            return const DialogLoading(
              message: "Espere un momento...",
            );
          },
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    }
  }

//focus para escanear

  FocusNode focusNode1 = FocusNode(); // ubicacion Dest

  String? selectedLocation;
  String? selectedMuelle;

  //controller
  final TextEditingController _controllerLocationDest = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleDependencies();
  }

  void validateMuelle(String value) {
    final bloc = context.read<TransferInfoBloc>();
    String scan = bloc.scannedValue1.toLowerCase() == ""
        ? value.toLowerCase()
        : bloc.scannedValue1.toLowerCase();

    _controllerLocationDest.text = "";

    // Buscar el barcode que coincida con el valor escaneado
    ResultUbicaciones? matchedUbicacion = bloc.ubicaciones.firstWhere(
        (ubicacion) => ubicacion.barcode?.toLowerCase() == scan,
        orElse: () =>
            ResultUbicaciones() // Si no se encuentra ningún match, devuelve null
        );

    if (matchedUbicacion.barcode != null) {
      bloc.add(ValidateFieldsEventTransfer(field: "muelle", isOk: true));
      bloc.add(ChangeLocationDestIsOkEventTransfer(
        true,
        matchedUbicacion,
      ));

      bloc.add(ClearScannedValueEventTransfer('muelle'));
    } else {
      print('Ubicacion no encontrada');
      bloc.add(ValidateFieldsEventTransfer(field: "muelle", isOk: false));
      bloc.add(ClearScannedValueEventTransfer('muelle'));
    }
  }

  void _handleDependencies() {
    FocusScope.of(context).requestFocus(focusNode1);
    setState(() {});
  }

  void validateQuantity(int quantity, BuildContext context) {
    final bloc = context.read<TransferInfoBloc>();
    if (quantity > widget.ubicacion!.cantidad!.toInt()) {
      Get.snackbar(
        '360 Software Informa',
        'Cantidad superior a la cantidad en ubicacion',
        backgroundColor: white,
        colorText: primaryColorApp,
        icon: Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    if (bloc.selectedLocation == "") {
      Get.snackbar(
        '360 Software Informa',
        'Ubicacion de destino no valida',
        backgroundColor: white,
        colorText: primaryColorApp,
        icon: Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    if (quantity == 0) {
      Get.snackbar(
        '360 Software Informa',
        'Cantidad no valida',
        backgroundColor: white,
        colorText: primaryColorApp,
        icon: Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    bloc.add(SendTransferInfo(
        TransferInfoRequest(
          idAlmacen: widget.ubicacion?.idAlmacen ?? 0,
          idMove: widget.ubicacion?.idMove ?? 0,
          idProducto: widget.infoRapidaResult?.result?.id ?? 0,
          idLote: widget.ubicacion?.loteId,
          idUbicacionOrigen: widget.ubicacion?.idUbicacion ?? 0,
          timeLine: 0,
          observacion: "sin novedad",
        ),
        quantity));
  }

  @override
  void dispose() {
    focusNode1.dispose(); //ubicaicon Dest
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocBuilder<TransferInfoBloc, TransferInfoState>(
      builder: (context, state) {
        final product = widget.infoRapidaResult?.result;
        final bloc = context.read<TransferInfoBloc>();
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            backgroundColor: white,
            body: SizedBox(
              width: size.width * 1,
              height: size.height * 1,
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.only(top: 20),
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
                    child: BlocConsumer<TransferInfoBloc, TransferInfoState>(
                        listener: (context, state) {
                      if (state is SendTransferInfoSuccess) {
                        Get.snackbar(
                          '360 Software Informa',
                          state.msg,
                          backgroundColor: white,
                          colorText: primaryColorApp,
                          icon: const Icon(Icons.check, color: Colors.green),
                        );

                        //acutalizamos la informacion del producto volviendo a llamar su info
                        context.read<InfoRapidaBloc>().add((GetInfoRapida(
                            widget.infoRapidaResult?.result?.codigoBarras ??
                                "")));

                        Navigator.pushReplacementNamed(context, 'product-info',
                            arguments: [
                              widget.infoRapidaResult,
                            ]);
                      } else if (state is SendTransferInfoFailureTransfer) {
                        Get.snackbar(
                          '360 Software Informa',
                          state.error,
                          backgroundColor: white,
                          colorText: primaryColorApp,
                          icon: const Icon(Icons.error, color: Colors.red),
                        );
                      }
                    }, builder: (context, status) {
                      return Column(
                        children: [
                          const WarningWidgetCubit(),
                          Padding(
                            padding: EdgeInsets.only(
                                // bottom: 5,
                                top:
                                    status != ConnectionStatus.online ? 0 : 35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: white),
                                  onPressed: () {
                                    context
                                        .read<TransferInfoBloc>()
                                        .clearFields();

                                    Navigator.pushReplacementNamed(
                                        context, 'product-info',
                                        arguments: [
                                          widget.infoRapidaResult,
                                        ]);
                                  },
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: size.width * 0.2),
                                  child: Text('TRANSFERENCIA',
                                      style: TextStyle(
                                          color: white, fontSize: 18)),
                                ),
                                const Spacer(),
                              ],
                            ),

                            //
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 2),
                    child: SingleChildScrollView(
                      child: Column(children: [
                        //todo : ubicacion de origen
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Card(
                              color: Colors.green[100],
                              elevation: 5,
                              child: Container(
                                  // color: Colors.amber,
                                  width: size.width * 0.85,
                                  height: 60,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10, bottom: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Ubicación de origen',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: primaryColorApp,
                                            ),
                                          ),
                                          Spacer(),
                                          Image.asset(
                                            "assets/icons/ubicacion.png",
                                            color: primaryColorApp,
                                            width: 20,
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            Text(
                                              widget.ubicacion?.ubicacion ??
                                                  'Sin nombre',
                                              style: const TextStyle(
                                                  fontSize: 14, color: black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                        //todo : product
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Card(
                              color: Colors.green[100],
                              elevation: 5,
                              child: Container(
                                  // color: Colors.amber,
                                  width: size.width * 0.85,
                                  height: 100,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10, bottom: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Product',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: primaryColorApp,
                                            ),
                                          ),
                                          Spacer(),
                                          Image.asset(
                                            "assets/icons/producto.png",
                                            color: primaryColorApp,
                                            width: 20,
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            Text(
                                              product?.nombre ?? 'Sin nombre',
                                              style: const TextStyle(
                                                  fontSize: 14, color: black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              "assets/icons/barcode.png",
                                              color: primaryColorApp,
                                              width: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              product?.codigoBarras == false ||
                                                      product?.codigoBarras ==
                                                          null ||
                                                      product?.codigoBarras ==
                                                          ""
                                                  ? "Sin codigo de barras"
                                                  : product?.codigoBarras ?? "",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: product?.codigoBarras ==
                                                              false ||
                                                          product?.codigoBarras ==
                                                              null ||
                                                          product?.codigoBarras ==
                                                              ""
                                                      ? red
                                                      : black),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return DialogBarcodes(
                                                          listOfBarcodes: product
                                                                  ?.codigosBarrasPaquetes ??
                                                              []);
                                                    });
                                              },
                                              child: Visibility(
                                                visible: product
                                                        ?.codigosBarrasPaquetes
                                                        ?.isNotEmpty ==
                                                    true,
                                                child: Image.asset(
                                                    "assets/icons/package_barcode.png",
                                                    color: primaryColorApp,
                                                    width: 20),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          // ExpiryDateWidget(
                                          //     expireDate: currentProduct
                                          //                     .expireDate ==
                                          //                 "" ||
                                          //             currentProduct
                                          //                     .expireDate ==
                                          //                 null
                                          //         ? DateTime.now()
                                          //         : DateTime.parse(
                                          //             currentProduct
                                          //                 .expireDate),
                                          //     size: size,
                                          //     isDetaild: false,
                                          //     isNoExpireDate:
                                          //         currentProduct.expireDate ==
                                          //                 ""
                                          //             ? true
                                          //             : false),
                                          if (widget.ubicacion?.loteId != null)
                                            Row(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Lote/serie:',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: primaryColorApp),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    widget.ubicacion?.lote ??
                                                        'Sin nombre',
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: black),
                                                  ),
                                                ),
                                                const Spacer(),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),

                        //todo: muelle
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: bloc.locationDestIsOk ? green : yellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Card(
                              color: bloc.isLocationDestOk
                                  ? bloc.locationDestIsOk
                                      ? Colors.green[100]
                                      : Colors.grey[300]
                                  : Colors.red[200],
                              elevation: 5,
                              child: Container(
                                width: size.width * 0.85,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: context
                                        .read<UserBloc>()
                                        .fabricante
                                        .contains("Zebra")
                                    ? Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Ubicación de destino',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              Spacer(),
                                              Image.asset(
                                                "assets/icons/packing.png",
                                                color: primaryColorApp,
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 15,
                                            margin: const EdgeInsets.only(
                                                bottom: 5, top: 10),
                                            child: TextFormField(
                                              autofocus: true,
                                              showCursor: false,
                                              // enabled: false,
                                              controller:
                                                  _controllerLocationDest, // Controlador que maneja el texto
                                              focusNode: focusNode1,
                                              onChanged: (value) {
                                                validateMuelle(value);
                                              },
                                              decoration: InputDecoration(
                                                hintText: bloc.selectedLocation,
                                                disabledBorder:
                                                    InputBorder.none,
                                                hintStyle: const TextStyle(
                                                    fontSize: 14, color: black),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Focus(
                                        focusNode: focusNode1,
                                        onKey: (FocusNode node,
                                            RawKeyEvent event) {
                                          if (event is RawKeyDownEvent) {
                                            if (event.logicalKey ==
                                                LogicalKeyboardKey.enter) {
                                              validateMuelle(
                                                  bloc.scannedValue1);
                                              return KeyEventResult.handled;
                                            } else {
                                              bloc.add(
                                                  UpdateScannedValueEventTransfer(
                                                      event.data.keyLabel,
                                                      'muelle'));
                                              return KeyEventResult.handled;
                                            }
                                          }
                                          return KeyEventResult.ignored;
                                        },
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Ubicación de destino',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: primaryColorApp,
                                                  ),
                                                ),
                                                Spacer(),
                                                Image.asset(
                                                  "assets/icons/packing.png",
                                                  color: primaryColorApp,
                                                  width: 20,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                bloc.selectedLocation,
                                                style: TextStyle(
                                                    fontSize: 14, color: black),
                                              ),
                                            ),
                                          ],
                                        )),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                )
                //todo: cantidad

                ,
                SizedBox(
                  width: size.width,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Card(
                          color: white,
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  const Text('Cant:',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 13)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Text(
                                      widget.ubicacion?.cantidad
                                              ?.toInt()
                                              .toString() ??
                                          "",
                                      style: TextStyle(
                                          color: primaryColorApp, fontSize: 15),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      height: 30,
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextFormField(
                                              enabled: false,
                                              readOnly: false,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly, // Solo permite dígitos
                                              ],
                                              onChanged: (value) {
                                                // Verifica si el valor no está vacío y si es un número válido
                                                if (value.isNotEmpty) {
                                                  try {
                                                    bloc.quantitySelected =
                                                        int.parse(value);
                                                  } catch (e) {
                                                    // Manejo de errores si la conversión falla
                                                    print(
                                                        'Error al convertir a entero: $e');
                                                    // Aquí puedes mostrar un mensaje al usuario o manejar el error de otra forma
                                                  }
                                                } else {
                                                  // Si el valor está vacío, puedes establecer un valor por defecto
                                                  bloc.quantitySelected =
                                                      0; // O cualquier valor que consideres adecuado
                                                }
                                              },
                                              controller: _cantidadController,
                                              showCursor: false,
                                              style: TextStyle(
                                                color: black,
                                                fontSize: 15,
                                              ),
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLines: 1,
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          child: ElevatedButton(
                            onPressed: () {
                              validateQuantity(
                                  _cantidadController.text == "" ||
                                          _cantidadController.text.isEmpty
                                      ? 0
                                      : int.parse(_cantidadController.text),
                                  context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColorApp,
                              minimumSize: Size(size.width * 0.93, 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'APLICAR CANTIDAD',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          )),
                      //teclado de la app
                      CustomKeyboardNumber(
                        controller: _cantidadController,
                        onchanged: () {
                          validateQuantity(
                              _cantidadController.text == "" ||
                                      _cantidadController.text.isEmpty
                                  ? 0
                                  : int.parse(_cantidadController.text),
                              context);
                        },
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
