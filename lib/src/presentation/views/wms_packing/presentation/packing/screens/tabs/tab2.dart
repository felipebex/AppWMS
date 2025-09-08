// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/utils/sounds_utils.dart';
import 'package:wms_app/src/core/utils/vibrate_utils.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/screens/widgets/dialog_confirmated_packing_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/packing_pedido_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';

class Tab2PedidoScreen extends StatefulWidget {
  const Tab2PedidoScreen({
    super.key,
  });

  @override
  State<Tab2PedidoScreen> createState() => _Tab2ScreenState();
}

class _Tab2ScreenState extends State<Tab2PedidoScreen> {
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
    final bloc = context.read<PackingPedidoBloc>();

    // Normalizamos el valor escaneado
    final scan = (bloc.scannedValue5.isEmpty ? value : bloc.scannedValue5)
        .trim()
        .toLowerCase();

    _controllerToDo.clear();
    print('🔎 Scan barcode (packing pedido): $scan');

    final listOfProducts = bloc.listOfProductosProgress;

    /// Función auxiliar para procesar el producto encontrado
    void processProduct(ProductoPedido product) {
      bloc
        ..add(FetchProductEvent(product))
        ..add(ChangeLocationIsOkEvent(
          product.idProduct ?? 0,
          product.pedidoId ?? 0,
          product.idMove ?? 0,
        ))
        ..add(ChangeProductIsOkEvent(
          true,
          product.idProduct ?? 0,
          product.pedidoId ?? 0,
          0,
          product.idMove ?? 0,
        ))
        ..add(ChangeIsOkQuantity(
          true,
          product.idProduct ?? 0,
          product.pedidoId ?? 0,
          product.idMove ?? 0,
        ))
        ..add(ClearScannedValuePackEvent('toDo'));

      showDialog(
        context: context,
        builder: (_) => const DialogLoading(
          message: 'Cargando información del producto...',
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacementNamed(context, 'scan-pack');
      });

      print('✅ Producto procesado: ${product.toMap()}');
    }

    // 1️⃣ Buscar por código de barras principal
    final product = listOfProducts.firstWhere(
      (p) =>
          p.barcode?.toLowerCase() == scan ||
          p.productCode?.toLowerCase() == scan,
      orElse: () => ProductoPedido(),
    );

    if (product.idMove != null) {
      processProduct(product);
      return;
    }

    // 2️⃣ Buscar por barcodes secundarios
    final barcode = bloc.listAllOfBarcodes.firstWhere(
      (b) => b.barcode?.toLowerCase() == scan,
      orElse: () => Barcodes(),
    );

    if (barcode.barcode != null) {
      final productByBarcode = listOfProducts.firstWhere(
        (p) => p.productId == barcode.idProduct,
        orElse: () => ProductoPedido(),
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
    bloc.add(ClearScannedValuePackEvent('toDo'));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<PackingPedidoBloc, PackingPedidoState>(
      listener: (context, state) {
        print('state: $state');
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: context
                          .read<PackingPedidoBloc>()
                          .configurations
                          .result
                          ?.result
                          ?.scanProduct ==
                      true &&
                  context
                      .read<PackingPedidoBloc>()
                      .listOfProductosProgress
                      .isNotEmpty
              ? Stack(
                  children: [
                    // El FloatingActionButton
                    Positioned(
                      bottom:
                          0.0, // Ajusta según sea necesario para colocar en la parte inferior
                      right:
                          0.0, // Ajusta según sea necesario para colocar en la parte derecha
                      child: FloatingActionButton(
                        onPressed: context
                                .read<PackingPedidoBloc>()
                                .listOfProductosProgress
                                .isEmpty
                            ? null
                            : () {
                                context
                                    .read<PackingPedidoBloc>()
                                    .add(ChangeStickerEvent(false));

                                FocusScope.of(context).unfocus();

                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    final bloc =
                                        context.read<PackingPedidoBloc>();
                                    return DialogConfirmatedPacking(
                                      productos: context
                                          .read<PackingPedidoBloc>()
                                          .listOfProductsForPacking,
                                      isCertificate: false,
                                      isSticker: bloc.isSticker,
                                      onToggleSticker: (value) {
                                        bloc.add(ChangeStickerEvent(value));
                                      },
                                      onConfirm: () {
                                        bloc.add(SetPackingsEvent(
                                            context
                                                .read<PackingPedidoBloc>()
                                                .listOfProductsForPacking,
                                            bloc.isSticker,
                                            false));
                                      },
                                    );
                                  },
                                );
                              },
                        backgroundColor: primaryColorApp,
                        child: Image.asset(
                          'assets/icons/packing.png',
                          width: 30,
                          height: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // El número de productos seleccionados
                    Positioned(
                      bottom: 40.0, // Posición hacia arriba
                      right: 0.0, // Posición hacia la derecha
                      child: context
                              .read<PackingPedidoBloc>()
                              .listOfProductsForPacking
                              .isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                context
                                    .read<PackingPedidoBloc>()
                                    .listOfProductsForPacking
                                    .length
                                    .toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : const SizedBox
                              .shrink(), // No mostrar el número si no hay productos seleccionados
                    ),
                  ],
                )
              : null,
          body: BlocBuilder<PackingPedidoBloc, PackingPedidoState>(
            builder: (context, state) {
              // Copiamos la lista de productos
              final productosOrdenados = List<ProductoPedido>.from(
                context.read<PackingPedidoBloc>().listOfProductosProgress,
              );

              // Ordenamos por ubicación
              productosOrdenados.sort((a, b) {
                return compareUbicaciones(a.locationId, b.locationId);
              });

              return Container(
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
                                  // hintText:
                                  //     batchBloc.currentProduct.locationId.toString(),
                                  disabledBorder: InputBorder.none,
                                  hintStyle: const TextStyle(
                                      fontSize: 14, color: black),
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
                                    validateBarcode(
                                        context
                                            .read<PackingPedidoBloc>()
                                            .scannedValue5,
                                        context);
                                    return KeyEventResult.handled;
                                  } else {
                                    context.read<PackingPedidoBloc>().add(
                                        UpdateScannedValuePackEvent(
                                            event.data.keyLabel, 'toDo'));
                                    return KeyEventResult.handled;
                                  }
                                }
                                return KeyEventResult.ignored;
                              },
                              child: Container()),

                      (context
                              .read<PackingPedidoBloc>()
                              .listOfProductosProgress
                              .isEmpty)
                          ? Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Text('No hay productos',
                                      style:
                                          TextStyle(fontSize: 14, color: grey)),
                                  const Text('Intente buscar otro producto',
                                      style:
                                          TextStyle(fontSize: 12, color: grey)),
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
                                itemCount: productosOrdenados.length,
                                itemBuilder: (context, index) {
                                  final product = productosOrdenados[index];

                                  //ordenar los productos por ubicación

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Card(
                                      // Cambia el color de la tarjeta si el producto está seleccionado
                                      color: context
                                              .read<PackingPedidoBloc>()
                                              .listOfProductsForPacking
                                              .contains(product)
                                          ? primaryColorAppLigth // Color amarillo si está seleccionado
                                          : Colors
                                              .white, // Color blanco si no está seleccionado
                                      elevation: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        child: Row(
                                          children: [
                                            //* Checkbox para seleccionar o deseleccionar el producto
                                            //* se activa segun el permiso
                                            Visibility(
                                              visible: context
                                                      .read<PackingPedidoBloc>()
                                                      .configurations
                                                      .result
                                                      ?.result
                                                      ?.scanProduct ==
                                                  true,
                                              child: Checkbox(
                                                value: context
                                                    .read<PackingPedidoBloc>()
                                                    .listOfProductsForPacking
                                                    .contains(product),
                                                onChanged: (bool? selected) {
                                                  if (selected == true) {
                                                    // Seleccionar producto
                                                    context
                                                        .read<
                                                            PackingPedidoBloc>()
                                                        .add(
                                                            SelectProductPackingEvent(
                                                                product));
                                                  } else {
                                                    // Deseleccionar producto
                                                    context
                                                        .read<
                                                            PackingPedidoBloc>()
                                                        .add(
                                                            UnSelectProductPackingEvent(
                                                                product));
                                                  }
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  print(
                                                      "Producto seleccionado: ${product.toMap()}");
                                                  // validamos si este articulo se encuentra en la lista de productos preparados
                                                  if (context
                                                      .read<PackingPedidoBloc>()
                                                      .productsDone
                                                      .any((doneProduct) =>
                                                          doneProduct.idMove ==
                                                          product.idMove)) {
                                                    // Mostramos el error
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: const Text(
                                                          "Este producto se encuentra en estado preparado, por favor seleccione otro"),
                                                      backgroundColor:
                                                          Colors.red[200],
                                                    ));
                                                    return;
                                                  }

                                                  context
                                                      .read<PackingPedidoBloc>()
                                                      .add(FetchProductEvent(
                                                          product));

                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const DialogLoading(
                                                        message:
                                                            'Cargando información del producto...',
                                                      );
                                                    },
                                                  );

                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 1), () {
                                                    // Cerrar el diálogo de carga
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();

                                                    // Ahora navegar a la vista "batch"
                                                    Navigator
                                                        .pushReplacementNamed(
                                                      context,
                                                      'scan-pack',
                                                    );
                                                  });
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        "${product.productId}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: black),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Ubicación: ",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                primaryColorApp,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Visibility(
                                                          visible: product
                                                                  .manejaTemperatura ==
                                                              1,
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Icon(
                                                              Icons
                                                                  .thermostat_outlined,
                                                              color:
                                                                  primaryColorApp,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      "${product.locationId}",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: black,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Pedido: ",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                primaryColorApp,
                                                          ),
                                                        ),
                                                        Text(
                                                            "${product.pedidoId}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Cantidad: ",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                primaryColorApp,
                                                          ),
                                                        ),
                                                        Text(
                                                          (product.isProductSplit == 1 &&
                                                                      product.isSeparate ==
                                                                          1
                                                                  ? product
                                                                      .pendingQuantity
                                                                  : product
                                                                      .quantity)
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: black,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          "Unidad de medida: ",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                primaryColorApp,
                                                          ),
                                                        ),
                                                        Text(
                                                            "${product.unidades}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                      ],
                                                    ),
                                                    if (product.tracking ==
                                                        'lot')
                                                      Column(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              "Número de serie/lote: ",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    primaryColorApp,
                                                              ),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                                "${product.lotId}",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        black)),
                                                          ),
                                                        ],
                                                      ),
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
                            ),
                    ],
                  ));
            },
          ),
        );
      },
    );
  }
}

int compareUbicaciones(String? a, String? b) {
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;

  final partsA = a.toLowerCase().split('/');
  final partsB = b.toLowerCase().split('/');

  for (int i = 0; i < partsA.length && i < partsB.length; i++) {
    final segA = partsA[i];
    final segB = partsB[i];

    final numA = int.tryParse(RegExp(r'\d+').stringMatch(segA) ?? '');
    final numB = int.tryParse(RegExp(r'\d+').stringMatch(segB) ?? '');

    if (numA != null && numB != null && numA != numB) {
      return numA.compareTo(numB);
    }

    if (segA != segB) {
      return segA.compareTo(segB);
    }
  }

  return partsA.length.compareTo(partsB.length);
}
