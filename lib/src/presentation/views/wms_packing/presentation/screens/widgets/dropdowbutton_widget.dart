// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DialogPackingAdvetenciaCantidadScreen extends StatefulWidget {
  const DialogPackingAdvetenciaCantidadScreen({
    super.key,
    required this.cantidad,
    required this.currentProduct,
    required this.onAccepted,
  });

  final int cantidad; // Variable para almacenar la cantidad
  final PorductoPedido currentProduct;
  final VoidCallback onAccepted; // Callback para la acción a ejecutar

  // Variable para almacenar el producto actual

  @override
  State<DialogPackingAdvetenciaCantidadScreen> createState() =>
      _DialogAdvetenciaCantidadScreenState();
}

class _DialogAdvetenciaCantidadScreenState
    extends State<DialogPackingAdvetenciaCantidadScreen> {
  String? selectedNovedad; // Variable para almacenar la opción seleccionada
  //*lista de novedades de separacion
  List<String> novedades = [
    'Producto dañado',
    'Producto vencido',
    'Producto en mal estado',
    'Producto no corresponde',
    'Producto no solicitado',
    'Producto no encontrado',
    'Producto no existe',
    'Producto no registrado',
    'Producto sin existencia',
  ]; // Ejemplo de opciones

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        backgroundColor: Colors.white,
        title: const Center(
            child: Text('Advertencia', style: TextStyle(color: yellow))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'La cantidad separada ',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16), // Color del texto normal
                  ),
                  TextSpan(
                    text: '${widget.cantidad} ',
                    style: const TextStyle(
                      color: primaryColorApp,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    // Color rojo para quantity
                  ),
                  const TextSpan(
                    text: 'es menor a la cantidad a recoger ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ), // Color del texto normal
                  ),
                  TextSpan(
                    text: '${widget.currentProduct.quantity}',
                    style: const TextStyle(
                      color: green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ), // Color verde para currentProduct?.quantity
                  ),
                ],
              ),
            ),
            const Text("Para continuar, seleccione la novedad",
                style: TextStyle(color: Colors.black, fontSize: 16)),
            const SizedBox(height: 10),
            Card(
              color: Colors.white,
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  underline: Container(height: 0),
                  selectedItemBuilder: (BuildContext context) {
                    return novedades.map<Widget>((String item) {
                      return Text(item);
                    }).toList();
                  },
                  borderRadius: BorderRadius.circular(10),
                  focusColor: Colors.white,
                  isExpanded: true,
                  isDense: true,
                  hint: const Text(
                    'Seleccionar novedad',
                    style: TextStyle(
                        fontSize: 16,
                        color: black), // Cambia primaryColorApp a tu color
                  ),
                  icon: Image.asset(
                    "assets/icons/novedad.png",
                    color: primaryColorApp,
                    width: 24,
                  ),
                  value: selectedNovedad, // Muestra la opción seleccionada
                  alignment: Alignment.centerLeft,
                  style: const TextStyle(
                      color: black,
                      fontSize: 16), // Cambia primaryColorApp a tu color
                  items: novedades.map((String novedad) {
                    return DropdownMenuItem<String>(
                      value: novedad,
                      child: Text(novedad),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedNovedad =
                          newValue; // Actualiza el estado con la nueva selección
                    });
                  },
                ),
              ),
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
                elevation: 3,
              ),
              child: const Text('Cancelar',
                  style: TextStyle(color: primaryColorApp))),
          ElevatedButton(
              onPressed: () async {
                // Validamos que tenga una novedad seleccionada
                if (selectedNovedad != null) {
                  DataBaseSqlite db = DataBaseSqlite();

                  await db.updateNovedadPacking(
                      widget.currentProduct.pedidoId ?? 0,
                      widget.currentProduct.productId ?? 0,
                      selectedNovedad ?? '');

                  Navigator.pop(context); // Cierra el diálogo
                  widget.onAccepted(); // Llama al callback
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColorApp,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child:
                  const Text('Aceptar', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
