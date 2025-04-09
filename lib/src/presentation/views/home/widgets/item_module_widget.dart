import 'package:flutter/material.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ImteModule extends StatelessWidget {
  const ImteModule({
    super.key,
    required this.urlImg,
    required this.title,
    this.count = 0, // Nuevo parámetro para la cantidad
  });

  final String urlImg;
  final String title;
  final int count; // Cantidad a mostrar

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          children: [
            // Contenido principal del módulo
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  margin: const EdgeInsets.only(top: 10),
                  child: Image.asset("assets/icons/$urlImg", fit: BoxFit.cover),
                ),
                const SizedBox(height: 2),
                Center(
                  child: Text(
                    title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColorApp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Indicador de cantidad (solo si count > 0)
            if (count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red, // Fondo rojo
                    shape: BoxShape.circle, // Forma circular
                    border: Border.all(
                      color: Colors.white, // Borde blanco
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white, // Texto blanco
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
