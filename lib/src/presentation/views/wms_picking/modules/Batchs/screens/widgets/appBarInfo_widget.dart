// ignore_for_file: file_names

import 'dart:ui';

import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBarInfo extends StatelessWidget {
  const AppBarInfo({
    super.key,
    required this.currentProduct, required this.bathId,
  });

  final ProductsBatch currentProduct;
  final int bathId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatchBloc, BatchState>(
      builder: (context, state) {
        return Row(
          children: [
            IconButton(
              onPressed: () {
                context.read<BatchBloc>().index = 0;

                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.read<BatchBloc>().batchWithProducts.batch?.name ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              shadowColor: Colors.white,
              color: Colors.white,
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 30),
              onSelected: (String value) {
                // Manejar la selección de opciones aquí
                if (value == '1') {
                  
                  context.read<BatchBloc>().add(FetchBatchWithProductsEvent(bathId));

                  Navigator.pushNamed(
                    context,
                    'batch-detail',
                  );
                  // Acción para opción 1
                } else if (value == '2') {
                  // Acción para opción 2
                  showDialog(
                      context: context,
                      builder: (context) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: AlertDialog(
                            backgroundColor: Colors.white,
                            actionsAlignment: MainAxisAlignment.center,
                            title: const Center(
                                child: Text('Dejar pendiente',
                                    style: TextStyle(color: primaryColorApp))),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Text(
                                      '¿Estás seguro de dejar pendiente este producto al final de la lista?'),
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 3),
                                  child: const Text('Cancelar',
                                      style:
                                          TextStyle(color: primaryColorApp))),
                              ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColorApp,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: const Text('Aceptar',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ))),
                            ],
                          ),
                        );
                      });
                }
                // Agrega más opciones según sea necesario
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: '1',
                    child: Row(
                      children: [
                        Icon(Icons.info, color: primaryColorApp, size: 20),
                        SizedBox(width: 10),
                        Text('Ver detalles'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: '2',
                    child: Row(
                      children: [
                        Icon(Icons.timelapse_rounded,
                            color: primaryColorApp, size: 20),
                        SizedBox(width: 10),
                        Text('Dejar pendiente'),
                      ],
                    ),
                  ),
                  // Agrega más PopupMenuItems aquí
                ];
              },
            ),
          ],
        );
      },
    );
  }
}
