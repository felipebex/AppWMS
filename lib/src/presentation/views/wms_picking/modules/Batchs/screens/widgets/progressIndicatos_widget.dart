// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress; // Valor de progreso (0.0 a 1.0)
  final int completed; // Cantidad completada
  final int total; // Cantidad total

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatchBloc, BatchState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Línea de progreso
            LinearProgressIndicator(
              value: progress, // Progreso entre 0.0 y 1.0
              minHeight: 5, // Altura de la barra
              backgroundColor: Colors.grey[300], // Color de fondo
              valueColor: const AlwaysStoppedAnimation<Color>(
                  green), // Color de la barra
            ),
            const SizedBox(height: 10), // Espaciado entre la barra y el texto
            // Texto de progreso
            Align(
              alignment: Alignment.center,
              child: Text(
                'Hecho $completed / Por hacer $total',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
