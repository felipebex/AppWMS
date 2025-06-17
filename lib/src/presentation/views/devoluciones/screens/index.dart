// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/views/devoluciones/models/product_devolucion_model.dart';
// Asegúrate de que las rutas de tus imports sean correctas
import 'package:wms_app/src/presentation/views/devoluciones/screens/bloc/devoluciones_bloc.dart';
import 'package:wms_app/src/presentation/views/devoluciones/screens/widgets/buildBarcodeInputField_widget.dart';
import 'package:wms_app/src/presentation/views/devoluciones/screens/widgets/custom_bar_widget.dart';
import 'package:wms_app/src/presentation/views/devoluciones/screens/widgets/dialog_delete_product_widget.dart';
import 'package:wms_app/src/presentation/views/devoluciones/screens/widgets/dialog_edit_product_widget.dart';
import 'package:wms_app/src/presentation/views/devoluciones/screens/widgets/product_card_widget.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DevolucionesScreen extends StatefulWidget {
  const DevolucionesScreen({super.key});

  @override
  State<DevolucionesScreen> createState() => _DevolucionesScreenState();
}

class _DevolucionesScreenState extends State<DevolucionesScreen> {
  final TextEditingController _controllerSearch = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNodeQuantity = FocusNode();
  final FocusNode focusNodeQuantityManual = FocusNode();

  @override
  void initState() {
    super.initState();
    // Opcional: Enfocar el nodo al iniciar si la UI lo permite
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode1.requestFocus();
    });
  }

  @override
  void dispose() {
    focusNode1.dispose();
    _controllerSearch.dispose();
    super.dispose();
  }

  void validateBarcode(String value) {
    final bloc = context.read<DevolucionesBloc>();
    final scan = _getScannedOrManual(bloc.scannedValue1, value);
    _controllerSearch.text = ''; // Limpia el campo de texto

    bloc.add(GetProductEvent(
      scan.toUpperCase(),
      false, // Asumiendo que false es para escaneo
    ));
    focusNode1
        .requestFocus(); // Vuelve a enfocar para seguir escaneando/tecleando
  }

  void validateQuantity(String value) {
    print("Validando cantidad: $value");
    final bloc = context.read<DevolucionesBloc>();
    final scan = _getScannedOrManual(bloc.scannedValue2, value);
    _controllerQuantity.text = ''; // Limpia el campo de texto
    if (scan == bloc.currentProduct.barcode?.toLowerCase()) {
      bloc.add(SetQuantityEvent(1));
    } else {
      bloc.add(ClearScannedValueEvent('quantity'));
    }

    // focusNodeQuantity
    //     .requestFocus(); // Vuelve a enfocar para seguir escaneando/tecleando
  }

  String _getScannedOrManual(String scanned, String manual) {
    print("Scanned: $scanned, Manual: $manual");
    final scan = scanned.trim().toLowerCase();
    return scan.isEmpty ? manual.trim().toLowerCase() : scan;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DevolucionesBloc, DevolucionesState>(
      listener: (context, state) {
        print('Estado actual ❤️‍🔥: $state');
        if (state is GetProductLoading) {
          showDialog(
            context: context, // Usa el context del listener
            barrierDismissible:
                false, // Evita que el usuario cierre el diálogo tocando fuera
            builder:
                (dialogContext) => // Usa un nombre diferente para el contexto del diálogo
                    const DialogLoading(message: "Buscando información..."),
          );
        } else if (state is GetProductFailure) {
          //esperamos 1 y cerramos el diálogo de carga
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context); // Cierra el diálogo de carga
          });

          Get.snackbar(
            '360 Software Informa',
            'No se encontró producto con ese código de barras',
            backgroundColor: white,
            colorText: primaryColorApp,
            icon: const Icon(Icons.error, color: Colors.red),
          );
        } else if (state is GetProductSuccess) {
          Navigator.pop(context); // Cierra el diálogo de carga

          //mostrar un dialogo para agregar el producto con cantidad y lote si es necesario
          showDialog(
            context: context,
            builder: (context) {
              return DialogEditProduct(
                functionValidate: (value) {
                  validateQuantity(value);
                },
                focusNode: focusNodeQuantity,
                focusNodeQuantityManual: focusNodeQuantityManual,
                controller: _controllerQuantity,
                isEdit: false,
              );
            },
          );
        } else if (state is RemoveProductSuccess) {}
      },
      builder: (context, state) {
        final devolucionesBloc = context.read<DevolucionesBloc>();

        // Determina si la lista de productos está vacía

        return Scaffold(
          backgroundColor: white,
          body: Column(
            children: [
              const CustomAppBar(), // Tu barra de aplicación personalizada
              Expanded(
                child: Column(
                  children: [
                    BuildBarcodeInputField(
                      devolucionesBloc: devolucionesBloc,
                      focusNode: focusNode1,
                      functionValidate: (value) {
                        validateBarcode(value);
                      },
                      controller: _controllerSearch,
                      functionUpdate: (keyLabel) {
                        context
                            .read<DevolucionesBloc>()
                            .add(UpdateScannedValueEvent(keyLabel, 'product'));
                      },
                    ),
                    // El contenido condicional basado en si la lista está vacía o no
                    if (context
                        .read<DevolucionesBloc>()
                        .productosDevolucion
                        .isEmpty)
                      // UI para cuando la lista de productos está vacía
                      _buildEmptyListUI(context, devolucionesBloc)
                    else
                      // UI para cuando hay productos en la lista
                      _buildProductListUI(context, devolucionesBloc,
                          context.read<DevolucionesBloc>().productosDevolucion),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Widgets Auxiliares para Construir la UI Condicionalmente ---

  Widget _buildEmptyListUI(
      BuildContext context, DevolucionesBloc devolucionesBloc) {
    return Expanded(
      // Envuelve en Expanded para que ocupe el espacio y no desborde
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centra el contenido verticalmente
        children: [
          Image.asset(
            'assets/icons/barcode.png',
            width: 150,
            height: 150,
            color: black,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Escanea el código de barras o ingresa el producto manualmente para añadirlo a la devolución.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListUI(
      BuildContext context,
      DevolucionesBloc devolucionesBloc,
      List<ProductDevolucion> productosDevolucion) {
    final size = MediaQuery.sizeOf(context);
    return Expanded(
      // Envuelve en Expanded para que la lista ocupe el espacio y sea scrollable
      child: Column(
        children: [
          // Mensaje superior para escanear/agregar

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3,
              color: white,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 2, bottom: 5),
                      child: Row(
                        children: [
                          Text('Ubicación destino: ',
                              style: TextStyle(
                                  fontSize: 12, color: primaryColorApp)),
                          Text(
                            'No asignada',
                            style: const TextStyle(fontSize: 12, color: red),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.location_on,
                            color: primaryColorApp,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 2, bottom: 5),
                      child: Row(
                        children: [
                          Text('Proveedor: ',
                              style: TextStyle(
                                  fontSize: 12, color: primaryColorApp)),
                          Text(
                            'No asignado',
                            style: const TextStyle(fontSize: 12, color: red),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.person,
                            color: primaryColorApp,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 2, bottom: 5),
                      child: Row(
                        children: [
                          Text('Productos: ',
                              style: TextStyle(
                                  fontSize: 12, color: primaryColorApp)),
                          Text(
                            '0.0',
                            style: const TextStyle(fontSize: 12, color: red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5), // Espacio entre los campos
                  ],
                ),
              ),
            ),
          ),
          // La lista de productos existentes
          Expanded(
            // Esto es crucial para que ListView.builder no desborde dentro de una Column
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              itemCount: productosDevolucion.length,
              itemBuilder: (context, index) {
                final product = productosDevolucion[index];
                return ProductDevolucionCard(
                  product: product,
                  onRemove: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DialogDeletedProduct(product: product);
                      },
                    );
                  },
                  onEdit: () {
                    print('Editando producto: ${product.toMap()}');
                    context
                        .read<DevolucionesBloc>()
                        .add(LoadCurrentProductEvent(Product(
                          productId: product.productId,
                          name: product.name,
                          code: product.code,
                          barcode: product.barcode,
                          quantity: product.quantity,
                          lotId: product.lotId,
                          lotName: product.lotName,
                          tracking: product.tracking,
                          useExpirationDate: product.useExpirationDate,
                          expirationTime: product.expirationTime,
                          expirationDate: product.expirationDate,
                          weight: product.weight,
                          weightUomName: product.weightUomName,
                          volume: product.volume,
                          volumeUomName: product.volumeUomName,
                          uom: product.uom,
                          locationId: product.locationId,
                          locationName: product.locationName,
                          otherBarcodes: product.otherBarcodes,
                          productPacking: product.productPacking,
                          category: product.category,
                          
                        )));
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DialogEditProduct(
                          functionValidate: (value) {
                            validateQuantity(value);
                          },
                          focusNode: focusNodeQuantity,
                          focusNodeQuantityManual: focusNodeQuantityManual,
                          controller: _controllerQuantity,
                          isEdit: true,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 5), // Espacio inferior
          ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColorApp,
                  minimumSize: (Size(size.width * 0.9, 30)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text('CREAR DEVOLUCION', style: TextStyle(color: white))),
          const SizedBox(height: 5), // Espacio inferior
        ],
      ),
    );
  }

  // Widget auxiliar para el campo de entrada de código de barras
}
