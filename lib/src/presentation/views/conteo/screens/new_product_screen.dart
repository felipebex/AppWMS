// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/new_product/location/LocationCardButton_widget.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/new_product/location/LocationScanner_widget.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/new_product/lote/lote_scannear_widget.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/new_product/product/ProductScanner_widget.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/new_product/product/product_dropdown_widget.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';

class NewProductConteoScreen extends StatefulWidget {
  const NewProductConteoScreen({Key? key}) : super(key: key);

  @override
  State<NewProductConteoScreen> createState() => _NewProductConteoScreenState();
}

class _NewProductConteoScreenState extends State<NewProductConteoScreen>
    with WidgetsBindingObserver {
  //*focus
  FocusNode focusNode1 = FocusNode(); // ubicacion  de origen
  FocusNode focusNode2 = FocusNode(); // producto
  FocusNode focusNode3 = FocusNode(); // cantidad por pda
  FocusNode focusNode4 = FocusNode(); //cantidad textformfield
  FocusNode focusNode5 = FocusNode(); // lote

  //controller
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerProduct = TextEditingController();
  final TextEditingController _controllerQuantity = TextEditingController();
  final TextEditingController _controllerLote = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && mounted) {
      showDialog(
        context: context,
        builder: (context) =>
            const DialogLoading(message: "Espere un momento..."),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
      _handleDependencies();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleDependencies();
  }

  void _focus(FocusNode node, String label) {
    print("🚼 $label");
    FocusScope.of(context).requestFocus(node);
    _unfocusOthers(except: node);
  }

  void _unfocusOthers({required FocusNode except}) {
    for (final node in [
      focusNode1,
      focusNode2,
      focusNode3,
      focusNode4,
      focusNode5
    ]) {
      if (node != except) node.unfocus();
    }
  }

  void _handleDependencies() {
    final bloc = context.read<ConteoBloc>();
    final hasLote = bloc.currentProduct.productTracking == "lot";

    final focusMap = {
      "location": () =>
          !bloc.locationIsOk && !bloc.productIsOk && !bloc.quantityIsOk,
      "product": () =>
          bloc.locationIsOk && !bloc.productIsOk && !bloc.quantityIsOk,
      "lote": () =>
          hasLote &&
          bloc.locationIsOk &&
          bloc.productIsOk &&
          !bloc.loteIsOk &&
          !bloc.quantityIsOk &&
          !bloc.viewQuantity,
      "quantity": () =>
          bloc.locationIsOk &&
          bloc.productIsOk &&
          (hasLote ? bloc.loteIsOk : true) &&
          bloc.quantityIsOk &&
          !bloc.viewQuantity,
    };

    final focusNodeByKey = {
      "location": focusNode1,
      "product": focusNode2,
      "lote": focusNode5,
      "quantity": focusNode3,
    };

    for (final entry in focusMap.entries) {
      if (entry.value()) {
        _focus(focusNodeByKey[entry.key]!, entry.key);
        return;
      }
    }

    setState(() {}); // Si necesitas un rebuild explícito
  }

  void validateLocation(String value) {
    final bloc = context.read<ConteoBloc>();
    final scan = bloc.scannedValue1.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue1.trim().toLowerCase();

    print('scan location: $scan');
    _controllerLocation.clear();

    ResultUbicaciones? matchedUbicacion = bloc.ubicacionesFilters.firstWhere(
        (ubicacion) => ubicacion.barcode?.toLowerCase() == scan.trim(),
        orElse: () =>
            ResultUbicaciones() // Si no se encuentra ningún match, devuelve null
        );

    if (matchedUbicacion.barcode != null) {
      print('Ubicacion encontrada: ${matchedUbicacion.name}');
      bloc.add(ValidateFieldsEvent(field: "location", isOk: true));
      bloc.add(ChangeLocationIsOkEvent(true, matchedUbicacion, 0, 0, 0));
    } else {
      print('Ubicacion no encontrada');
      bloc.add(ValidateFieldsEvent(field: "location", isOk: false));
    }

    bloc.add(ClearScannedValueEvent('location'));
  }

  void validateProduct(String value) {
    final bloc = context.read<ConteoBloc>();
    final scan = bloc.scannedValue2.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue2.trim().toLowerCase();

    print('scan product: $scan');
    _controllerProduct.clear();

    Product? matchedProducts = bloc.productosFilters.firstWhere(
        (productoUbi) =>
            productoUbi.barcode?.toLowerCase() == scan.trim() ||
            productoUbi.code?.toLowerCase() == scan.trim(),
        orElse: () =>
            Product() // Si no se encuentra ningún match, devuelve null
        );

    if (matchedProducts.barcode != null) {
      print('producto encontrado: ${matchedProducts.name}');
      bloc.add(ValidateFieldsEvent(field: "product", isOk: true));
      bloc.add(ChangeProductIsOkEvent(true, matchedProducts, 0, true, 0, 0, 0));
    } else {
      print('producto encontrado: ${matchedProducts.name}');
      bloc.add(ValidateFieldsEvent(field: "product", isOk: false));
    }

    bloc.add(ClearScannedValueEvent('product'));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<ConteoBloc, ConteoState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: white,
          body: Column(
            children: [
              BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                builder: (context, status) {
                  return Container(
                    width: size.width,
                    color: primaryColorApp,
                    child: BlocConsumer<ConteoBloc, ConteoState>(
                        listener: (context, state) {
                      print("❤️‍🔥 state : $state");

                      // * validamos en todo cambio de estado de cantidad separada

                      if (state is SendProductConteoSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(milliseconds: 1000),
                          content: Text(state.response.result?.msg ?? ""),
                          backgroundColor: Colors.green[200],
                        ));
                        //limpiamos los valores pa volver a iniciar con otro producto
                        cantidadController.clear();
                        context.read<ConteoBloc>().add(ResetValuesEvent());

                        context.read<ConteoBloc>().add(
                              LoadConteoAndProductsEvent(
                                  ordenConteoId:
                                      state.response.result?.data?.orderId ??
                                          0),
                            );

                        Navigator.pushReplacementNamed(
                          context,
                          'conteo-detail',
                          arguments: [
                            1,
                            context.read<ConteoBloc>().ordenConteo,
                          ],
                        );
                      }

                      if (state is ChangeLoteIsOkState) {
                        //cambiamos el foco a cantidad cuando hemos seleccionado un lote
                        Future.delayed(const Duration(seconds: 1), () {
                          FocusScope.of(context).requestFocus(focusNode3);
                        });
                        _handleDependencies();
                      }

                      if (state is ChangeQuantitySeparateStateError) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(milliseconds: 1000),
                          content: Text(state.msg),
                          backgroundColor: Colors.red[200],
                        ));
                      }

                      if (state is ValidateFieldsStateError) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(milliseconds: 1000),
                          content: Text(state.msg),
                          backgroundColor: Colors.red[200],
                        ));
                      }

                      //*estado cando la ubicacion de origen es cambiada
                      if (state is ChangeLocationIsOkState) {
                        //cambiamos el foco
                        Future.delayed(const Duration(seconds: 1), () {
                          FocusScope.of(context).requestFocus(focusNode2);
                        });
                        _handleDependencies();
                      }

                      //*estado cuando el producto es leido ok
                      if (state is ChangeProductOrderIsOkState) {
                        //validamos si el producto tiene lote, si es asi pasamos el foco al lote
                        if (context
                                .read<ConteoBloc>()
                                .currentProduct
                                .productTracking ==
                            "lot") {
                          Future.delayed(const Duration(seconds: 1), () {
                            FocusScope.of(context).requestFocus(focusNode5);
                          });
                        } else {
                          Future.delayed(const Duration(seconds: 1), () {
                            FocusScope.of(context).requestFocus(focusNode3);
                          });
                        }

                        _handleDependencies();
                      }
                    }, builder: (context, status) {
                      return Column(
                        children: [
                          const WarningWidgetCubit(),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    cantidadController.clear();

                                    context
                                        .read<ConteoBloc>()
                                        .add(ResetValuesEvent());
                                    // context
                                    //     .read<WMSPickingBloc>()
                                    //     .add(FilterBatchesBStatusEvent(
                                    //       '',
                                    //     ));

                                    Navigator.pushReplacementNamed(
                                      context,
                                      'conteo-detail',
                                      arguments: [
                                        1,
                                        context.read<ConteoBloc>().ordenConteo,
                                      ],
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white, size: 20),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: size.width * 0.015),
                                  child: Text(
                                    'CONTEO FISICO',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  );
                },
              ),

              //todo: scaners
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 2),
                  child: SingleChildScrollView(
                    child: Column(children: [
                      //todo : ubicacion de origen
                      const SizedBox(height: 10),

                      LocationScannerAll(
                        isLocationOk: context.read<ConteoBloc>().isLocationOk,
                        locationIsOk: context.read<ConteoBloc>().locationIsOk,
                        productIsOk: context.read<ConteoBloc>().productIsOk,
                        quantityIsOk: context.read<ConteoBloc>().quantityIsOk,
                        currentLocationName:
                            context.read<ConteoBloc>().currentUbication?.name,
                        onLocationScanned: (value) {
                          validateLocation(value);
                        },
                        onKeyScanned: (keyLabel) {
                          context.read<ConteoBloc>().add(
                              UpdateScannedValueEvent(keyLabel, 'location'));
                        },
                        focusNode: focusNode1,
                        controller: _controllerLocation,
                        locationDropdown: LocationCardButtonConteo(
                          bloc: context.read<
                              ConteoBloc>(), // Tu instancia de BLoC/Controlador
                          cardColor:
                              white, // Asegúrate que 'white' esté definido en tus colores
                          textAndIconColor:
                              primaryColorApp, // Usa tu color primario
                          title: 'Ubicación de existencias',
                          iconPath: "assets/icons/ubicacion.png",
                          dialogTitle: '360 Software Informa',
                          dialogMessage:
                              "No hay ubicaciones cargadas, por favor cargues las ubicaciones",
                          routeName: 'search-location-conteo',
                          ubicacionFija: true,
                        ), // Pasamos el widget del dropdown como parámetro
                      ),

                      //todo: producto
                      ProductScannerAll(
                        focusNode: focusNode2,
                        controller: _controllerProduct,
                        locationIsOk: context.read<ConteoBloc>().locationIsOk,
                        productIsOk: context.read<ConteoBloc>().productIsOk,
                        quantityIsOk: context.read<ConteoBloc>().quantityIsOk,
                        isProductOk: context.read<ConteoBloc>().isProductOk,
                        currentProduct:
                            context.read<ConteoBloc>().currentProduct,
                        onValidateProduct: (value) {
                          validateProduct(value);
                        },
                        onKeyScanned: (value) {
                          context.read<ConteoBloc>().add(
                              UpdateScannedValueEvent(value, 'product'));
                        },
                        productDropdown: ProductDropdowmnWidget(),
                      ),

                      //todo lote
                      Visibility(
                        // El padre controla la visibilidad
                        visible: context
                                .read<ConteoBloc>()
                                .currentProduct
                                ?.productTracking ==
                            "lot",
                        child: LoteScannerWidget(
                          focusNode: focusNode5,
                          controller: _controllerLote,
                          isLoteOk: context.read<ConteoBloc>().isLoteOk,
                          loteIsOk: context.read<ConteoBloc>().loteIsOk,
                          locationIsOk: context.read<ConteoBloc>().locationIsOk,
                          productIsOk: context.read<ConteoBloc>().productIsOk,
                          quantityIsOk: context.read<ConteoBloc>().quantityIsOk,
                          viewQuantity: context.read<ConteoBloc>().viewQuantity,
                          currentProduct:
                              context.read<ConteoBloc>().currentProduct,
                          currentProductLote:
                              context.read<ConteoBloc>().currentProductLote,
                          onValidateLote: (value) {},
                          onKeyScanned: (value) {},
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
