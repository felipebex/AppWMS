// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:ui';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/cronometro/cronometro_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/appBarInfo_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/cantidad_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/cronometro_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/titulo_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class BatchPickingScreen extends StatelessWidget {
  const BatchPickingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void showScanner() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              title: const Center(
                  child: Text(
                'Escanear Código',
                style: TextStyle(fontSize: 24, color: Colors.black),
              )),
              content: SizedBox(
                width: double.maxFinite,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MobileScanner(
                    onDetect: (BarcodeCapture barcodeCapture) {
                      final List<Barcode> barcodes = barcodeCapture.barcodes;
                      if (barcodes.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Código escaneado: ${barcodes[0].rawValue}')));
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColorApp,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(fontSize: 18, color: Colors.white))),
              ],
            ),
          );
        },
      );
    }

    Future<void> checkCameraPermission() async {
      try {
        var status = await Permission.camera.status;

        if (status.isDenied || status.isRestricted) {
          var result = await Permission.camera.request();
          if (result.isGranted) {
            showScanner();
          } else if (result.isDenied) {
            print("Permiso de cámara denegado. Pidiendo de nuevo.");
            await checkCameraPermission();
          } else if (result.isPermanentlyDenied) {
            print(
                "Permiso de cámara denegado permanentemente. Abre configuración.");
            openAppSettings();
          }
        } else if (status.isGranted) {
          print("Permiso de cámara ya concedido.");
          showScanner();
        }
      } catch (e, s) {
        print('Error checkCameraPermission: $e, $s');
      }
    }

    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<BatchBloc, BatchState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoadProductsBatchSuccesState) {
          print(state.listOfProductsBatch);
          // Buscar el producto seleccionado
          final currentProduct = state.listOfProductsBatch.firstWhere(
              (product) => product.isSelected,
              orElse: () => ProductsBatch());

          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                AppBarInfo(size: size),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        const TitleWidget(title: 'POSICIÓN'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Card(
                                color: const Color.fromARGB(255, 249, 193, 24),
                                elevation: 2,
                                child: SizedBox(
                                  width: size.width * 0.7,
                                  height: size.height * 0.07,
                                  child: Center(
                                    child: Text(
                                      currentProduct.locationId ?? '',
                                      style: const TextStyle(fontSize: 18),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await checkCameraPermission();
                                },
                                child: Card(
                                  color:
                                      const Color.fromARGB(255, 167, 244, 80),
                                  child: SizedBox(
                                    width: size.width * 0.2,
                                    height: size.height * 0.07,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Image.asset(
                                        "assets/icons/barcode.png",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const TitleWidget(title: 'PRODUCTO:'),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 10),
                            decoration: BoxDecoration(
                              color: lightGrey,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: size.height * 0.07,
                            child: Center(
                              child: Text(
                                '${currentProduct.productId}',
                                style: const TextStyle(fontSize: 18),
                                maxLines: 2,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 10),
                            decoration: BoxDecoration(
                              color: lightGrey,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: size.height * 0.07,
                            child: const Center(
                              child: Text(
                                '',
                                style:
                                    TextStyle(fontSize: 17, color: black),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        const TitleWidget(title: 'CANTIDADES:'),
                        CantidadWidget(size: size, product: currentProduct),
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                color: lightGrey,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: size.width * 0.5,
                              height: size.height * 0.07,
                              child: Center(
                                child: Text(
                                  'Resta ${currentProduct.quantity} Unidad(es)\nTiempo transcurrido',
                                  style: const TextStyle(
                                      fontSize: 14, color: black),
                                ),
                              ),
                            ),
                            Cronometro(size: size),
                          ],
                        ),
                        const TitleWidget(title: 'MUELLE:'),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          decoration: BoxDecoration(
                            color: lightGrey,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: size.height * 0.05,
                          child: const Center(
                            child: Text(
                              'BOG/Salida',
                              style: TextStyle(fontSize: 24, color: black),
                              maxLines: 1,
                            ),
                          ),
                        ),
                        const TitleWidget(title: 'LECTOR:'),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: size.width * 1,
                          height: size.height * 0.05,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: '0',
                              labelStyle: TextStyle(fontSize: 24),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context.read<BatchBloc>().add(NextProductEvent());
                          },
                          child: const Text("Siguiente Producto"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<CronometroBloc>()
                                .add(StartCronometroEvent());
                          },
                          child: const Text(" Empezar cronómetro"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<CronometroBloc>()
                                .add(StopCronometroEvent());
                          },
                          child: const Text(" Detener cronómetro"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ProductsBatchLoadingState) {
          return const Scaffold(
            backgroundColor: primaryColorApp,
            body: Center(
              child: FlutterLogo(size: 100),
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: Text('Error al cargar los productos'),
          ),
        );
      },
    );
  }
}
