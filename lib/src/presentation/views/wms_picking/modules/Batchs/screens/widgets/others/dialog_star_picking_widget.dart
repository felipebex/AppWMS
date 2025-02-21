import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/routes/app_router.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/index.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DialogStartPickingWidget extends StatelessWidget {
  final VoidCallback onAccepted; // Callback para la acción a ejecutar

  const DialogStartPickingWidget({Key? key, required this.onAccepted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5,
        sigmaY: 5,
      ),
      child: AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        title: Center(
          child: Text(
            'Iniciar proceso de picking',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryColorApp,
              fontSize: 18,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Recuerde que una vez iniciado el proceso se registrará en el sistema su fecha y hora de inicio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: black,
                    fontSize: 14,
                  )),
              const SizedBox(height: 10),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<BatchBloc>().add(ResetValuesEvent());
                context.read<WMSPickingBloc>().add(FilterBatchesBStatusEvent(
                      '',
                    ));

                Navigator.pushReplacementNamed(context, 'wms-picking',
                    arguments: 0);

              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: white),
              )),
          ElevatedButton(
              onPressed: () {
                onAccepted(); // Llama al callback
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColorApp,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text(
                'Empezar',
                style: TextStyle(color: white),
              ))
        ],
      ),
    );
  }
}
