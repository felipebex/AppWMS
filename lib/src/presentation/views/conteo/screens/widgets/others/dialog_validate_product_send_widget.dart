// ignore_for_file: file_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';

class DialogValidateProductSendWidget extends StatelessWidget {
  const DialogValidateProductSendWidget({
    super.key,
    required this.product,
    required this.productExist,
    required this.cantidadController,
  });

  final CountedLine product;
  final CountedLine productExist;
  final TextEditingController cantidadController;

  @override
  Widget build(BuildContext context) {
    double cantidad = double.parse(cantidadController.text.isEmpty
        ? context.read<ConteoBloc>().quantitySelected.toString()
        : cantidadController.text);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: Colors.white,
        actionsAlignment: MainAxisAlignment.center,
        title: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                '360 Software Informa',
                style: TextStyle(color: red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: 'Este producto esta registrado con una cantidad de: ',
                  style: TextStyle(
                    color: black,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '(${productExist.quantityCounted}) ',
                      style: TextStyle(
                        color: primaryColorApp,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: 'en la ubicación ',
                      style: TextStyle(
                        color: black,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: '${productExist.locationName}',
                      style: TextStyle(
                        color: primaryColorApp,
                        fontSize: 14,
                      ),
                    ),
                    if (product.productTracking == "lot") ...[
                      TextSpan(
                        text: ' con lote ',
                        style: TextStyle(
                          color: black,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: '${productExist.lotName}.',
                        style: TextStyle(
                          color: primaryColorApp,
                          fontSize: 14,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  text: '¿Desea reemplazar la cantidad registrada por: ',
                  style: TextStyle(
                    color: black,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '($cantidad)',
                      style: TextStyle(
                        color: primaryColorApp,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: '?',
                      style: TextStyle(
                        color: black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  text: '¿Desea actualizar la cantidad exitente ',
                  style: TextStyle(
                    color: black,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '(${productExist.quantityCounted}) +  ($cantidad) ',
                      style: TextStyle(
                        color: primaryColorApp,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: 'para un total de: ',
                      style: TextStyle(
                        color: black,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: '(${(productExist.quantityCounted) + (cantidad)})',
                      style: TextStyle(
                        color: green,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: '?',
                      style: TextStyle(
                        color: black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    context.read<ConteoBloc>().add(UpdateProductConteoEvent(
                        product, productExist, cantidad, true)); //sobrescribir
                    //CERRAMOS EL DIALOGO SI ESTA ABIERO
                    
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorApp,
                    minimumSize: const Size(250, 40),
                  ),
                  child: Text('REEMPLAZAR', style: TextStyle(color: white))),
              ElevatedButton(
                  onPressed: () {
                    context.read<ConteoBloc>().add(UpdateProductConteoEvent(
                        product, productExist, cantidad, false));
                   
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorApp,
                    minimumSize: const Size(250, 40),
                  ),
                  child: Text('ACTUALIZAR', style: TextStyle(color: white))),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: grey,
                    minimumSize: const Size(250, 40),
                  ),
                  child: Text('CANCELAR', style: TextStyle(color: white))),
            ],
          ),
        ),
      ),
    );
  }
}
