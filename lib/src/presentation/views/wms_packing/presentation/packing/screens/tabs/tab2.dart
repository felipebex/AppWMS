// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/screens/widgets/dialog_confirmated_packing_widget.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/packing_pedido_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab2PedidoScreen extends StatefulWidget {
  const Tab2PedidoScreen({
    super.key,
  });

  @override
  State<Tab2PedidoScreen> createState() => _Tab2ScreenState();
}

class _Tab2ScreenState extends State<Tab2PedidoScreen> {
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

    String scan = bloc.scannedValue5.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue5.trim().toLowerCase();

    _controllerToDo.text = "";

    // Obtener la lista de productos desde el Bloc
    final listOfProducts = bloc.listOfProductosProgress;

    // Buscar el producto que coincide con el código de barras escaneado
    final product = listOfProducts.firstWhere(
      (product) => product.barcode.toLowerCase() == scan,
      orElse: () =>
          ProductoPedido(), // Devuelve null si no se encuentra ningún producto
    );

    if (product.idMove != null) {
      // Si el producto existe, ejecutar los estados necesarios
      bloc.add(
          FetchProductEvent(product)); // Pasar el producto encontrado al evento

      showDialog(
        context: context,
        builder: (context) {
          return const DialogLoading(
            message: 'Cargando información del producto...',
          );
        },
      );
//validamos la ubicacion de origen
      bloc.add(ChangeLocationIsOkEvent(
          product.idProduct ?? 0, product.pedidoId ?? 0, product.idMove ?? 0));

      //validamos el producto
      bloc.add(ChangeProductIsOkEvent(true, product.idProduct ?? 0,
          product.pedidoId ?? 0, 0, product.idMove ?? 0));
      //validamos la cantidad pa usarla
      bloc.add(ChangeIsOkQuantity(true, product.idProduct ?? 0,
          product.pedidoId ?? 0, product.idMove ?? 0));

      Future.delayed(const Duration(seconds: 1), () {
        // Cerrar el diálogo de carga
        Navigator.of(context, rootNavigator: true).pop();
        // Ahora navegar a la vista "batch"
        Navigator.pushReplacementNamed(
          context,
          'scan-pack',
        );
      });

      // Limpiar el valor escaneado
      bloc.add(ClearScannedValuePackEvent('toDo'));
    } else {
      // Mostrar alerta de error si el producto no se encuentra
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Código erroneo"),
        backgroundColor: Colors.red[200],
        duration: const Duration(milliseconds: 500),
      ));
      bloc.add(ClearScannedValuePackEvent('toDo'));
    }
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
                                itemCount: context
                                    .read<PackingPedidoBloc>()
                                    .listOfProductosProgress
                                    .length,
                                itemBuilder: (context, index) {
                                  final product = context
                                      .read<PackingPedidoBloc>()
                                      .listOfProductosProgress[index];

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
                                                    Visibility(
                                                      visible: product
                                                              .manejaTemperatura ==
                                                          1,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Temperatura: ",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  primaryColorApp,
                                                            ),
                                                          ),
                                                          Text(
                                                              "${product.temperatura}",
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          black)),
                                                          const Spacer(),
                                                          Icon(
                                                            Icons
                                                                .thermostat_outlined,
                                                            color:
                                                                primaryColorApp,
                                                            size: 16,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      "Ubicación: ",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: primaryColorApp,
                                                      ),
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
