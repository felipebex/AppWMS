
import 'dart:ui';

import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';

class CantidadWidget extends StatelessWidget {
  const CantidadWidget({
    super.key,
    required this.size, required this.product,
  });

  final Size size;

  final ProductsBatch product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size.width * 0.42,
            height: size.height * 0.05,
            child: TextFormField(
              readOnly: true,
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return _ModalCantidad(size: size);
                    });
              },
              decoration: const InputDecoration(
                labelText: '0',
                labelStyle: TextStyle(fontSize: 24),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            child: const Text(
              ' / ',
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(
            height: size.height * 0.05,
            width: size.width * 0.42,
            child: TextFormField(
              decoration:  InputDecoration(
                labelText: product.quantity.toString(),
                labelStyle: const TextStyle(fontSize: 24),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalCantidad extends StatelessWidget {
  const _ModalCantidad({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        title: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.black),
          ),
          width: size.width * 0.8,
          child: const Text('Cantidad Máxima: 8',
              style: TextStyle(color: Colors.white)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                labelStyle: TextStyle(fontSize: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 117, 175, 51),
                minimumSize: const Size(100, 40),
                //bordes
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Aceptar y pasar de producto',
                style: TextStyle(fontSize: 18, color: Colors.white),
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
              backgroundColor: grey,
              minimumSize: const Size(100, 40),
              //bordes
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColorApp,
              minimumSize: const Size(100, 40),
              //bordes
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Aceptar',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
