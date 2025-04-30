// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/bloc/picking_pick_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DialogPickIncompleted extends StatelessWidget {
  const DialogPickIncompleted({
    super.key,
    required this.cantidad,
    required this.currentProduct,
    required this.onAccepted,
  });

  final double cantidad; // porcentaje de cantidades completadas
  final ProductsBatch currentProduct;
  final VoidCallback onAccepted; // Callback para la acción a ejecutar

  @override
  Widget build(BuildContext context) {
    final batchBloc = context.read<PickingPickBloc>();
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: BlocBuilder<PickingPickBloc, PickingPickState>(
        builder: (context, state) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            backgroundColor: Colors.white,
            title: const Center(
                child: Text('360 Software Informa',
                    style: TextStyle(color: yellow, fontSize: 14))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'El proceso del picking no esta completo en su ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14), // Color del texto normal
                      ),
                      const TextSpan(
                        text: '100%',
                        style: TextStyle(
                          color: green,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ), // Color verde para currentProduct?.quantity
                      ),
                      const TextSpan(
                        text: ' tiene un total de ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14), // Color del texto normal
                      ),
                      TextSpan(
                        text: '$cantidad% ',
                        style: TextStyle(
                          color: primaryColorApp,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        // Color rojo para quantity
                      ),
                      const TextSpan(
                        text: 'en unidades separadas.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        // Color rojo para quantity
                      ),
                      const TextSpan(
                        text: "\n¿Quiere continuar con el cierre del PICK ",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14), // Color del texto normal
                      ),
                      TextSpan(
                        text: "${batchBloc.pickWithProducts.pick?.name} ",
                        style: TextStyle(
                            color: primaryColorApp,
                            fontSize: 14), // Color del texto normal
                      ),
                      const TextSpan(
                        text: " o desea verficar?",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14), // Color del texto normal
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    batchBloc.add(
                        ValidateFieldsEvent(field: "locationDest", isOk: true));
                    batchBloc.add(ChangeLocationDestIsOkEvent(
                        true,
                        currentProduct.idProduct ?? 0,
                        batchBloc.pickWithProducts.pick?.id ?? 0,
                        currentProduct.idMove ?? 0));

                    batchBloc.add(PickingOkEvent(
                        batchBloc.pickWithProducts.pick?.id ?? 0,
                        currentProduct.idProduct ?? 0));

                    // batchBloc.add(EndTimePick(

                    //      batchBloc.pickWithProducts.pick?.id ?? 0,
                    //     DateTime.now()));

                    batchBloc.add(FetchPickingPickFromDBEvent(false));
                    batchBloc.index = 0;
                    batchBloc.isSearch = true;
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, 'pick',
                        arguments: 1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: Text('Cerrar Batch',
                      style: TextStyle(color: primaryColorApp, fontSize: 12))),
              ElevatedButton(
                  onPressed: () async {
                    onAccepted(); // Llama al callback
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text('Verificar',
                      style: TextStyle(color: Colors.white, fontSize: 12))),
            ],
          );
        },
      ),
    );
  }
}
