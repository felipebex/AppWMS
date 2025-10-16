// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/utils/sounds_utils.dart';
import 'package:wms_app/src/core/utils/vibrate_utils.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/new_product/location/LocationCardButton_widget.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/new_product/location/LocationScanner_widget.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/new_product/lote/lote_scannear_widget.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/new_product/product/ProductScanner_widget.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/transferencias/modules/create-transfer/bloc/crate_transfer_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/modules/create-transfer/screens/widgets/product/product_dropdown_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';

class CreateTransferScreen extends StatefulWidget {
  const CreateTransferScreen({super.key});

  @override
  State<CreateTransferScreen> createState() => _CreateTransferScreenState();
}

class _CreateTransferScreenState extends State<CreateTransferScreen>
    with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();
  final VibrationService _vibrationService = VibrationService();

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

  String? selectedLocation;

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
    final bloc = context.read<CreateTransferBloc>();
    final hasLote = bloc.currentProduct?.tracking == "lot";

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
    final bloc = context.read<CreateTransferBloc>();
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
      bloc.add(ChangeLocationIsOkEvent(matchedUbicacion));
    } else {
      _vibrationService.vibrate();
      _audioService.playErrorSound();
      print('Ubicacion no encontrada');
      bloc.add(ValidateFieldsEvent(field: "location", isOk: false));
    }

    bloc.add(ClearScannedValueTransferEvent('location'));
  }

  void validateProduct(String value) {
    final bloc = context.read<CreateTransferBloc>();
    final scan = bloc.scannedValue2.trim().toLowerCase() == ""
        ? value.trim().toLowerCase()
        : bloc.scannedValue2.trim().toLowerCase();

    _controllerProduct.clear();
    print('🔎 Scan barcode: $scan');

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
      bloc.add(ChangeProductIsOkEvent(matchedProducts, true));
      return;
    }

    // Buscar en barcodes adicionales
    final matchedBarcode = bloc.listAllOfBarcodes.firstWhere(
      (b) => b.barcode?.toLowerCase() == scan,
      orElse: () => Barcodes(),
    );

    if (matchedBarcode.barcode == null) {
      print('❌ Producto no encontrado en barcodes');
      _audioService.playErrorSound();
      _vibrationService.vibrate();
      bloc
        ..add(ValidateFieldsEvent(field: "product", isOk: false))
        ..add(ClearScannedValueTransferEvent('product'));
      return;
    }

    // Buscar producto por id relacionado al barcode encontrado
    final matchedById = bloc.productos.firstWhere(
      (p) => p.productId == matchedBarcode.idProduct,
      orElse: () => Product(),
    );

    if (matchedById.productId != null) {
      print('✅ Producto encontrado por ID: ${matchedById.name}');
      bloc
        ..add(ValidateFieldsEvent(field: "product", isOk: true))
        ..add(ChangeProductIsOkEvent(matchedById, true));

      return;
    } else {
      print('❌ Producto no encontrado por ID');
      _audioService.playErrorSound();
      _vibrationService.vibrate();
      bloc
        ..add(ValidateFieldsEvent(field: "product", isOk: false))
        ..add(ClearScannedValueTransferEvent('product'));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return BlocConsumer<CreateTransferBloc, CreateTransferState>(
      listener: (context, state) {
        //*estado cuando la ubicacion de origen es cambiada
        if (state is ChangeLocationIsOkState) {
          //cambiamos el foco
          Future.delayed(const Duration(seconds: 1), () {
            FocusScope.of(context).requestFocus(focusNode2);
          });
          _handleDependencies();
        }
        //*estado cuando el producto es leido ok
        else if (state is ChangeProductOrderIsOkState) {
          //validamos si el producto tiene lote, si es asi pasamos el foco al lote
          if (context.read<CreateTransferBloc>().currentProduct?.tracking ==
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
      },
      builder: (context, state) {
        return Scaffold(
            backgroundColor: white,
            body: Column(
              children: [
                //*AppBar
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
                              top: status != ConnectionStatus.online ? 0 : 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.arrow_back, color: white),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    'transferencias',
                                  );
                                },
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: size.width * 0.12),
                                child: const Text("CREAR TRANSFERENCIA",
                                    style:
                                        TextStyle(color: white, fontSize: 18)),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 2),
                    child: SingleChildScrollView(
                      child: Column(children: [
                        //todo ubicacion de origen
                        LocationScannerAll(
                          isLocationOk:
                              context.read<CreateTransferBloc>().isLocationOk,
                          locationIsOk:
                              context.read<CreateTransferBloc>().locationIsOk,
                          productIsOk:
                              context.read<CreateTransferBloc>().productIsOk,
                          quantityIsOk:
                              context.read<CreateTransferBloc>().quantityIsOk,
                          currentLocationName: context
                              .read<CreateTransferBloc>()
                              .currentUbication
                              ?.name,
                          onLocationScanned: (value) {
                            validateLocation(value);
                          },
                          onKeyScanned: (keyLabel) {
                            context.read<CreateTransferBloc>().add(
                                UpdateScannedValueTransferEvent(
                                    keyLabel, 'location'));
                          },
                          focusNode: focusNode1,
                          controller: _controllerLocation,
                          locationDropdown: LocationCardButtonConteo(
                            bloc: context.read<
                                CreateTransferBloc>(), // Tu instancia de BLoC/Controlador
                            cardColor:
                                white, // Asegúrate que 'white' esté definido en tus colores
                            textAndIconColor:
                                primaryColorApp, // Usa tu color primario
                            title: 'Ubicación de existencias',
                            routeName: 'search-location-create-transfer',
                            ubicacionFija: true,
                          ), // Pasamos el widget del dropdown como parámetro
                        ),

                        //todo: producto
                        ProductScannerAll(
                          isCreateTransfer: true,
                          focusNode: focusNode2,
                          controller: _controllerProduct,
                          locationIsOk:
                              context.read<CreateTransferBloc>().locationIsOk,
                          productIsOk:
                              context.read<CreateTransferBloc>().productIsOk,
                          quantityIsOk:
                              context.read<CreateTransferBloc>().quantityIsOk,
                          isProductOk:
                              context.read<CreateTransferBloc>().isProductOk,
                          currentProduct:
                              context.read<CreateTransferBloc>().currentProduct,
                          onValidateProduct: (value) {
                            validateProduct(value);
                          },
                          onKeyScanned: (value) {
                            context.read<CreateTransferBloc>().add(
                                UpdateScannedValueTransferEvent(
                                    value, 'product'));
                          },
                          productDropdown:
                              ProductDropdownCreateTransferWidget(),
                        ),

                        //todo lote
                        Visibility(
                          // El padre controla la visibilidad
                          visible: context
                                  .read<CreateTransferBloc>()
                                  .currentProduct
                                  ?.tracking ==
                              "lot",
                          child: LoteScannerWidget(
                            routeName: 'search-lote-create-transfer',
                            focusNode: focusNode5,
                            controller: _controllerLote,
                            isLoteOk: context.read<CreateTransferBloc>().isLoteOk,
                            loteIsOk: context.read<CreateTransferBloc>().loteIsOk,
                            locationIsOk:
                                context.read<CreateTransferBloc>().locationIsOk,
                            productIsOk: context.read<CreateTransferBloc>().productIsOk,
                            quantityIsOk:
                                context.read<CreateTransferBloc>().quantityIsOk,
                            viewQuantity:
                                context.read<CreateTransferBloc>().viewQuantity,
                            currentProduct:
                                context.read<CreateTransferBloc>().currentProduct,
                            currentProductLote:
                                context.read<CreateTransferBloc>().currentProductLote,
                            onValidateLote: (value) {
                              // validateLote(value);
                            },
                            onKeyScanned: (value) {
                              context
                                  .read<CreateTransferBloc>()
                                  .add(UpdateScannedValueTransferEvent(value, 'lote'));
                            },
                          ),
                        ),
                      ]),
                    ),
                  ),
                )
              ],
            ));
      },
    );
  }
}
