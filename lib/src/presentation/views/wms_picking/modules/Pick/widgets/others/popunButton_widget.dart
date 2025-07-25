import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/bloc/picking_pick_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';



class PopupMenuButtonPickWidget extends StatelessWidget {
  const PopupMenuButtonPickWidget({
    super.key,
    required this.currentProduct,
  });

  final ProductsBatch currentProduct;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickingPickBloc, PickingPickState>(
      builder: (context, state) {
        final batchBloc = BlocProvider.of<PickingPickBloc>(context);
        return PopupMenuButton<String>(
          shadowColor: Colors.white,
          color: Colors.white,
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          onSelected: (String value) {
            // Manejar la selección de opciones aquí
            if (value == '1') {
              //verficamos si tenemos permisos
              if (batchBloc
                      .configurations.result?.result?.showDetallesPicking ==
                  true) {
                //cerramos el focus
                FocusScope.of(context).unfocus();
                batchBloc.isSearch = true;
                batchBloc.add(FetchPickWithProductsEvent(
                  batchBloc.pickWithProducts.pick?.id ?? 0,
                ));

                Navigator.pushReplacementNamed(
                  context,
                  'pick-detail',
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    duration: Duration(milliseconds: 1000),
                    content: Text('No tienes permisos para ver detalles'),
                  ),
                );
              }

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
                        title: Center(
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
                              child: Text('Cancelar',
                                  style: TextStyle(color: primaryColorApp))),
                          ElevatedButton(
                              onPressed: () {
                                batchBloc.add(ProductPendingEvent(
                                    batchBloc.pickWithProducts.pick?.id ?? 0,
                                    currentProduct));
                                Navigator.pop(context);
                              },
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
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: '1',
                child: Row(
                  children: [
                    Icon(Icons.info, color: primaryColorApp, size: 20),
                    const SizedBox(width: 10),
                    const Text('Ver detalles',
                        style: TextStyle(color: black, fontSize: 14)),
                  ],
                ),
              ),
             if (batchBloc.locationIsOk == true &&
                  batchBloc.index + 1 <
                      batchBloc.pickWithProducts.products!.where(
                          (element) => element.isSeparate != 1,
                        ).
                      length &&
                  currentProduct.isPending != 1)
                PopupMenuItem<String>(
                  value: '2',
                  child: Row(
                    children: [
                      Icon(Icons.timelapse_rounded,
                          color: primaryColorApp, size: 20),
                      const SizedBox(width: 10),
                      const Text('Dejar pendiente',
                          style: TextStyle(color: black, fontSize: 14)),
                    ],
                  ),
                ),
            ];
          },
        );
      },
    );
  }
}
