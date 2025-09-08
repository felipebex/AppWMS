// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, prefer_is_empty

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/utils/sounds_utils.dart';
import 'package:wms_app/src/core/utils/vibrate_utils.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/others/products_empty_widget.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';

class Tab2ScreenConteo extends StatefulWidget {
  const Tab2ScreenConteo({
    super.key,
    required this.ordenConteo,
  });

  final DatumConteo? ordenConteo;

  @override
  State<Tab2ScreenConteo> createState() => _Tab2ScreenRecepState();
}

class _Tab2ScreenRecepState extends State<Tab2ScreenConteo> {
  FocusNode focusNode1 = FocusNode(); //location focus

  final TextEditingController _controllerToProduct = TextEditingController();
  final TextEditingController _controllerToLocation = TextEditingController();

  final AudioService _audioService = AudioService();
  final VibrationService _vibrationService = VibrationService();

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
    final bloc = context.read<ConteoBloc>();

    // Normalizar el valor escaneado
    final scan = (bloc.scannedValue5.isEmpty ? value : bloc.scannedValue5)
        .trim()
        .toLowerCase();

    _controllerToProduct.clear();
    print('🔎 Scan barcode: $scan');

    // Filtrar productos válidos dentro de la ubicación expandida
    // Normalizar ubicación una sola vez
    final ubicacionActual = (bloc.ubicacionExpanded ?? '').toLowerCase();

// Filtrar productos válidos dentro de la ubicación expandida
    final listOfProducts = bloc.lineasContadas.where((element) {
      final isSeparateOk = (element.isSeparate ?? 0) == 0;
      final isDoneItemOk = (element.isDoneItem ?? 0) == 0;
      final sameLocation =
          (element.locationName ?? '').toLowerCase() == ubicacionActual;

      return isSeparateOk && isDoneItemOk && sameLocation;
    }).toList();

    print(
        'Productos en ubicación "$ubicacionActual": ${listOfProducts.length}');

    /// Función auxiliar para procesar un producto encontrado
    void processProduct(CountedLine product) {
      showDialog(
        context: context,
        builder: (_) => const DialogLoading(
          message: 'Cargando información del producto...',
        ),
      );

      bloc
        ..add(ValidateFieldsEvent(field: "toProduct", isOk: true))
        ..add(ValidateFieldsEvent(field: "location", isOk: true))
        ..add(ChangeLocationIsOkEvent(false, ResultUbicaciones(),
            product.productId ?? 0, product.orderId ?? 0, product.idMove ?? 0))
        ..add(ValidateFieldsEvent(field: "product", isOk: true))
        ..add(ChangeLocationIsOkEvent(
          false,
          ResultUbicaciones(),
          product.productId ?? 0,
          product.orderId ?? 0,
          product.idMove ?? 0,
        ))
        ..add(ChangeProductIsOkEvent(
          false,
          Product(),
          product.orderId ?? 0,
          true,
          product.productId ?? 0,
          0,
          product.idMove ?? 0,
        ))
        ..add(ValidateFieldsEvent(field: "quantity", isOk: true))
        ..add(ChangeQuantitySeparate(
          false,
          0,
          product.productId ?? 0,
          product.orderId ?? 0,
          product.idMove ?? 0,
        ))
        ..add(LoadCurrentProductEvent(currentProduct: product));

      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(
          context,
          'scan-product-conteo',
        );
      });

      print('✅ Producto procesado: ${product.toMap()}');
    }

    // 1️⃣ Buscar producto por código de barras principal
    final product = listOfProducts.firstWhere(
      (p) => p.productBarcode?.toLowerCase() == scan ||
          p.productCode?.toLowerCase() == scan,
      orElse: () => CountedLine(),
    );

    if (product.idMove != null) {
      processProduct(product);
      bloc.add(ClearScannedValueEvent('toProduct'));
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
        orElse: () => CountedLine(),
      );

      if (productByBarcode.productId != null) {
        processProduct(productByBarcode);
        bloc.add(ClearScannedValueEvent('toProduct'));
        return;
      }
    }

    // 3️⃣ Si no se encuentra nada → mostrar error
    _vibrationService.vibrate();
    _audioService.playErrorSound();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("El producto no se encuentra en esta ubicación"),
      backgroundColor: Colors.red[200],
      duration: const Duration(milliseconds: 1000),
    ));
    bloc.add(ClearScannedValueEvent('toProduct'));
  }

  void validateLocation(String value, BuildContext context) {
    final bloc = context.read<ConteoBloc>();

    // Determinar cuál es el valor que vamos a validar (del escáner o del input)
    String scan = bloc.scannedValue6.trim().toLowerCase().isEmpty
        ? value.trim().toLowerCase()
        : bloc.scannedValue6.trim().toLowerCase();

    _controllerToLocation.text = "";

    // Obtener los productos sin terminar
    final productosSinTerminar = bloc.lineasContadas
        .where((element) => element.isDoneItem != 1)
        .toList();

    // Agrupar por ubicación
    final productosPorUbicacion = _groupByLocation(productosSinTerminar);

    // 🔹 Obtener solo los barcodes de ubicaciones con productos sin terminar
    final ubicacionesValidas = productosPorUbicacion.values
        .map((listaProductos) => listaProductos.first.locationBarcode ?? "")
        .map((barcode) => barcode.toLowerCase())
        .where((barcode) => barcode.isNotEmpty)
        .toSet();

    // Validar por barcode en lugar de nombre
    if (ubicacionesValidas.contains(scan)) {
      // Encontrar el nombre de ubicación que corresponde a ese barcode
      final ubicacionEncontrada = productosPorUbicacion.keys.firstWhere(
        (ubic) {
          final barcode =
              productosPorUbicacion[ubic]!.first.locationBarcode ?? "";
          return barcode.toLowerCase() == scan;
        },
        orElse: () => "",
      );

      if (ubicacionEncontrada.isNotEmpty) {
        bloc.add(
            ExpandLocationEvent(ubicacionEncontrada)); // Expande por nombre
      }

      bloc.add(ClearScannedValueEvent('toLocation'));
    } else {
      _vibrationService.vibrate();
      _audioService.playErrorSound();
      bloc.add(ClearScannedValueEvent('toLocation'));
      print("Ubicación no válida (barcode): $scan");
    }
  }

// Método para agrupar productos por ubicación
  Map<String, List<CountedLine>> _groupByLocation(List<CountedLine> productos) {
    final map = <String, List<CountedLine>>{};
    for (final producto in productos) {
      final location = producto.locationName ?? 'Sin ubicación';
      map.putIfAbsent(location, () => []).add(producto);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocConsumer<ConteoBloc, ConteoState>(
        listener: (context, state) {},
        builder: (context, state) {
          final conteoBloc = context.read<ConteoBloc>();
          final productosPorContar = conteoBloc.lineasContadas
              .where((element) => element.isDoneItem != 1)
              .toList();

          final productosPorUbicacion = _groupByLocation(productosPorContar);

          return Scaffold(
            backgroundColor: white,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                //new-product-conteo
                context.read<ConteoBloc>().add(LoadNewProductEvent());
                Navigator.pushReplacementNamed(context, 'new-product-conteo');
              },
              child: const Icon(Icons.add),
            ),
            body: Container(
              margin: const EdgeInsets.only(top: 5),
              width: double.infinity,
              height: size.height * 0.8,
              child: Column(
                children: [
                  context.read<UserBloc>().fabricante.contains("Zebra")
                      ? Container(
                          height: 15,
                          margin: const EdgeInsets.only(bottom: 5),
                          child: TextFormField(
                            autofocus: true,
                            showCursor: false,
                            controller: focusNode1.hasFocus
                                ? _controllerToLocation
                                : _controllerToProduct,
                            focusNode: focusNode1,
                            onChanged: (value) {
                              //Validacion segun el focus
                              if (conteoBloc.ubicacionExpanded.isEmpty) {
                                validateLocation(value, context);
                              } else {
                                validateBarcode(value, context);
                              }
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 14, color: black),
                            ),
                          ),
                        )
                      :

                      //*focus para leer los productos
                      Focus(
                          focusNode: //validacion segun el focus
                              focusNode1,
                          autofocus: true,
                          onKey: (FocusNode node, RawKeyEvent event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.enter) {
                                //validacion segun el focus
                                if (conteoBloc.ubicacionExpanded.isEmpty) {
                                  validateLocation(
                                      context.read<ConteoBloc>().scannedValue6,
                                      context);
                                } else {
                                  validateBarcode(
                                      context.read<ConteoBloc>().scannedValue5,
                                      context);
                                }
                                return KeyEventResult.handled;
                              } else {
                                if (conteoBloc.ubicacionExpanded.isEmpty) {
                                  context.read<ConteoBloc>().add(
                                      UpdateScannedValueEvent(
                                          event.data.keyLabel, 'toLocation'));
                                  return KeyEventResult.handled;
                                } else {
                                  context.read<ConteoBloc>().add(
                                      UpdateScannedValueEvent(
                                          event.data.keyLabel, 'toProduct'));
                                  return KeyEventResult.handled;
                                }
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: Container()),
                  productosPorUbicacion.isEmpty
                      ? ProductEmpty()
                      : Expanded(
                          child: ListView.builder(
                            // Obtener las claves y ordenar con el comparador personalizado
                            itemCount: productosPorUbicacion.keys.length,
                            itemBuilder: (context, index) {
                              final sortedLocations =
                                  productosPorUbicacion.keys.toList();

                              // Aquí es donde aplicas el comparador personalizado
                              sortedLocations.sort(sortLocations);

                              final ubicacion = sortedLocations[index];
                              final productos =
                                  productosPorUbicacion[ubicacion]!;

                              return CustomExpansionTile(
                                key: ValueKey(ubicacion.toLowerCase()),
                                title: ubicacion,
                                subtitle: '${productos.length} producto(s)',
                                isExpanded: conteoBloc.ubicacionExpanded
                                        .toLowerCase() ==
                                    ubicacion.toLowerCase(),
                                onTap: () {
                                  if (conteoBloc.ubicacionExpanded
                                          .toLowerCase() ==
                                      ubicacion.toLowerCase()) {
                                    conteoBloc
                                        .add(ClearExpandedLocationEvent());
                                  } else {
                                    conteoBloc
                                        .add(ExpandLocationEvent(ubicacion));
                                  }
                                },
                                children: productos
                                    .map((product) =>
                                        _buildProductItem(product, size))
                                    .toList(),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductItem(CountedLine product, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Card(
        elevation: 2,
        child: GestureDetector(
          onTap: () => _handleProductTap(context, product),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("Producto", product.productName ?? ''),
                _buildInfoRow("Código", product.productCode ?? ''),
                _buildInfoRow("Categoria", product.categoryName ?? ''),
                if (product.productTracking == 'lot')
                  _buildInfoRow("Lote", product.lotName ?? ''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 12,
              color: primaryColorApp,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value == "" ? "Sin $label" : value,
              style: TextStyle(fontSize: 12, color: value == "" ? red : black),
            ),
          ),
        ],
      ),
    );
  }

  void _handleProductTap(BuildContext context, CountedLine product) {
    showDialog(
      context: context,
      builder: (context) => const DialogLoading(
        message: 'Cargando información del producto',
      ),
    );
    context.read<ConteoBloc>().add(
          LoadCurrentProductEvent(currentProduct: product),
        );
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(
        context,
        'scan-product-conteo',
      );
    });
    print('Producto seleccionado: ${product.toJson()}');
  }

  // Función para ordenar ubicaciones con formato específico
  int sortLocations(String a, String b) {
    // 1. Dividir las cadenas por el separador '/'
    final partsA = a.split('/');
    final partsB = b.split('/');

    // 2. Iterar sobre las partes y comparar
    for (int i = 0; i < partsA.length && i < partsB.length; i++) {
      // Intentar convertir la parte a un número
      final intValueA = int.tryParse(partsA[i]);
      final intValueB = int.tryParse(partsB[i]);

      if (intValueA != null && intValueB != null) {
        // Si ambas partes son números, comparar numéricamente
        final comparison = intValueA.compareTo(intValueB);
        if (comparison != 0) {
          return comparison; // Devuelve el resultado si son diferentes
        }
      } else {
        // Si no son números, comparar como strings
        final comparison = partsA[i].compareTo(partsB[i]);
        if (comparison != 0) {
          return comparison;
        }
      }
    }

    // Si llegan a este punto, una cadena es un prefijo de la otra
    return partsA.length.compareTo(partsB.length);
  }
}

class CustomExpansionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isExpanded;
  final VoidCallback onTap;
  final List<Widget> children;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isExpanded,
    required this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isExpanded ? primaryColorAppLigth : white,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            title: Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColorApp),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Column(children: children),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
