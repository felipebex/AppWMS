import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  // ✅ PROPIEDADES REQUERIDAS (Independientes de cualquier BLoC)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Línea de progreso
        LinearProgressIndicator(
          // ✅ Usamos la propiedad `progress` pasada
          value: progress.clamp(0.0, 1.0), // Asegura que el valor esté entre 0 y 1
          minHeight: 5, 
          backgroundColor:  Colors.grey[300], // Fondo (ajustado para ser más seguro)
          valueColor: AlwaysStoppedAnimation<Color>(
              Colors.green), // Color de la barra
        ),
        const SizedBox(height: 5), // Espaciado entre la barra y el texto
        // Texto de progreso
        Align(
          alignment: Alignment.center,
          child: Text(
            // ✅ Usamos las propiedades `completed` y `total`
            'Hecho $completed / Total $total',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }
}