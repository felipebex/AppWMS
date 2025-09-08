// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, prefer_is_empty

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/utils/sounds_utils.dart';
import 'package:wms_app/src/core/utils/vibrate_utils.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';

class Tab2ScreenTrans extends StatefulWidget {
  const Tab2ScreenTrans({
    super.key,
    required this.transFerencia,
  });

  final ResultTransFerencias? transFerencia;

  @override
  State<Tab2ScreenTrans> createState() => _Tab2ScreenTransState();
}

class _Tab2ScreenTransState extends State<Tab2ScreenTrans> {
  final AudioService _audioService = AudioService();
  final VibrationService _vibrationService = VibrationService();
  FocusNode focusNode1 = FocusNode(); //cantidad textformfield

  final TextEditingController _controllerToDo = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(focusNode1);
  }

  @override
  void dispose() {
    focusNode1.dispose();
    super.dispose();
  }

  void validateBarcode(String value, BuildContext context) {
    final bloc = context.read<TransferenciaBloc>();

    // Normalizamos el valor escaneado
    final scan = (bloc.scannedValue5.isEmpty ? value : bloc.scannedValue5)
        .trim()
        .toLowerCase();

    _controllerToDo.clear();
    print('🔎 Scan barcode: $scan');

    // Filtrar productos válidos
    final listOfProducts = bloc.listProductsTransfer
        .where(
          (p) => p.isSeparate == 0 || p.isSeparate == null,
        )
        .toList();

    /// Función auxiliar para procesar un producto encontrado
    void processProduct(LineasTransferenciaTrans product) {
      showDialog(
        context: context,
        builder: (_) => const DialogLoading(
          message: 'Cargando información del producto...',
        ),
      );

      // Eventos de ubicación
      bloc
        ..add(LoadLocations())
        ..add(ValidateFieldsEvent(field: "location", isOk: true))
        ..add(ChangeLocationIsOkEvent(
          int.parse(product.productId),
          product.idTransferencia ?? 0,
          product.idMove ?? 0,
        ))
        ..add(ClearScannedValueEvent('location'));

      bloc.oldLocation = product.locationId.toString();

      // Eventos de producto
      bloc
        ..add(ValidateFieldsEvent(field: "product", isOk: true))
        ..add(ChangeProductIsOkEvent(
          true,
          int.parse(product.productId),
          product.idTransferencia ?? 0,
          0,
          product.idMove ?? 0,
        ))
        ..add(ClearScannedValueEvent('product'))
        ..add(ChangeQuantitySeparate(
          0,
          int.parse(product.productId),
          product.idTransferencia ?? 0,
          product.idMove ?? 0,
        ))
        ..add(ChangeIsOkQuantity(
          true,
          int.parse(product.productId),
          product.idTransferencia ?? 0,
          product.idMove ?? 0,
        ))
        ..add(FetchPorductTransfer(product))
        ..add(ClearScannedValueEvent('toDo'));

      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(
          context,
          'scan-product-transfer',
          arguments: [product],
        );
      });

      print('✅ Producto procesado: ${product.toMap()}');
    }

    // 1️⃣ Buscar producto por código de barras principal
    final product = listOfProducts.firstWhere(
      (p) => p.productBarcode?.toLowerCase() == scan
          || p.productCode?.toLowerCase() == scan,
      orElse: () => LineasTransferenciaTrans(),
    );

    if (product.idMove != null) {
      processProduct(product);
      return;
    }

    // 2️⃣ Buscar en lista de barcodes asociados
    final barcode = bloc.listAllOfBarcodes.firstWhere(
      (b) => b.barcode?.toLowerCase() == scan,
      orElse: () => Barcodes(),
    );

    if (barcode.barcode != null) {
      final productByBarcode = listOfProducts.firstWhere(
        (p) => p.productId == barcode.idProduct,
        orElse: () => LineasTransferenciaTrans(),
      );

      if (productByBarcode.productId != null) {
        processProduct(productByBarcode);
        return;
      }
    }

    _audioService.playErrorSound();
    _vibrationService.vibrate();

    // 3️⃣ Si no se encuentra nada → mostrar error
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Código erróneo"),
      backgroundColor: Colors.red[200],
      duration: const Duration(milliseconds: 500),
    ));
    bloc.add(ClearScannedValueEvent('toDo'));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocConsumer<TransferenciaBloc, TransferenciaState>(
        listener: (context, state) {
          print('state: $state');
          if (state is SendProductToTransferSuccess) {
            Get.snackbar(
              '360 Software Informa',
              "Se ha enviado el producto correctamente",
              backgroundColor: white,
              colorText: primaryColorApp,
              icon: Icon(Icons.error, color: Colors.green),
            );
          }

          if (state is SendProductToTransferFailure) {
            Get.defaultDialog(
              title: '360 Software Informa',
              titleStyle: TextStyle(color: Colors.red, fontSize: 18),
              middleText: state.error,
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
          }
        },
        builder: (context, state) {
          final bloc = context.read<TransferenciaBloc>();

          return Scaffold(
            backgroundColor: white,
            body: Container(
              margin: const EdgeInsets.only(top: 5),
              width: double.infinity,
              height: size.height * 0.8,
              child: Column(
                children: [
                  //*espacio para escanear y buscar el producto

                  context.read<UserBloc>().fabricante.contains("Zebra")
                      ? Container(
                          height: 15,
                          margin: const EdgeInsets.only(bottom: 5),
                          child: TextFormField(
                            autofocus: true,
                            showCursor: false,
                            controller: _controllerToDo,
                            focusNode: focusNode1,
                            onChanged: (value) {
                              // Llamamos a la validación al cambiar el texto
                              validateBarcode(value, context);
                            },
                            decoration: InputDecoration(
                              disabledBorder: InputBorder.none,
                              hintStyle:
                                  const TextStyle(fontSize: 14, color: black),
                              border: InputBorder.none,
                            ),
                          ),
                        )
                      :

                      //*focus para leer los productos
                      Focus(
                          focusNode: focusNode1,
                          autofocus: true,
                          onKey: (FocusNode node, RawKeyEvent event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.enter) {
                                validateBarcode(bloc.scannedValue5, context);
                                return KeyEventResult.handled;
                              } else {
                                bloc.add(UpdateScannedValueEvent(
                                    event.data.keyLabel, 'toDo'));
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: Container()),

                  (bloc.listProductsTransfer.where((element) {
                            return (element.isSeparate == 0 ||
                                    element.isSeparate == null) &&
                                (element.isDoneItem == 0 ||
                                    element.isDoneItem == null);
                          }).length ==
                          0)
                      ? Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Text('No hay productos',
                                  style: TextStyle(fontSize: 14, color: grey)),
                              const Text('Intente buscar otro producto',
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
                            itemCount:
                                bloc.listProductsTransfer.where((element) {
                              return (element.isSeparate == 0 ||
                                      element.isSeparate == null) &&
                                  (element.isDoneItem == 0 ||
                                      element.isDoneItem == null);
                            }).length,
                            itemBuilder: (context, index) {
                              final product =
                                  bloc.listProductsTransfer.where((element) {
                                return (element.isSeparate == 0 ||
                                        element.isSeparate == null) &&
                                    (element.isDoneItem == 0 ||
                                        element.isDoneItem == null);
                              }).elementAt(index);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const DialogLoading(
                                            message:
                                                'Cargando información del producto',
                                          );
                                        });
                                    bloc.add(LoadLocations());
                                    bloc.add(FetchPorductTransfer(
                                      product,
                                    ));

                                    Future.delayed(
                                        const Duration(milliseconds: 300), () {
                                      Navigator.pop(context);

                                      Navigator.pushReplacementNamed(
                                        context,
                                        'scan-product-transfer',
                                        arguments: [product],
                                      );
                                    });
                                    print(product.toMap());
                                  },
                                  child: Card(
                                    color: product.isSelected == 1
                                        ? primaryColorAppLigth
                                        : white, // Color blanco si no está seleccionado
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Producto: ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              product.productName ??
                                                  'Sin nombre',
                                              style: const TextStyle(
                                                  fontSize: 12, color: black),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Codigo: ",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              Text(
                                                  product.productCode ??
                                                      'Sin código',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: black)),
                                            ],
                                          ),
                                          Visibility(
                                            visible: product.productTracking ==
                                                'lot',
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Lote: ",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: primaryColorApp,
                                                  ),
                                                ),
                                                Text(
                                                    product.lotName ??
                                                        'Sin lote',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: black)),
                                                Text(
                                                    "/${product.fechaVencimiento}",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: black)),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            "Ubicación de origen: ",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: primaryColorApp,
                                            ),
                                          ),
                                          Text(
                                              product.locationName ??
                                                  'Sin ubicación',
                                              style: const TextStyle(
                                                  fontSize: 12, color: black)),
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Cantidad pendiente: ",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: primaryColorApp,
                                                    ),
                                                  ),
                                                  Text(
                                                      (product.cantidadFaltante)
                                                          .toStringAsFixed(2),
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: black)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
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
}
