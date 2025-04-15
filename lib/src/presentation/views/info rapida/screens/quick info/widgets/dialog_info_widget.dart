// ignore_for_file: file_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DialogInfoQuick extends StatelessWidget {
  const DialogInfoQuick({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: Colors.white,
        actionsAlignment: MainAxisAlignment.center,
        title: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('INFORMACION RAPIDA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColorApp,
                  fontSize: 20,
                )),
            const SizedBox(height: 10),
            Center(
              child: Text(
                  'Seleccione una de las siguientes opciones para realizar la busqueda manual',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: black,
                    fontSize: 12,
                  )),
            ),
            const SizedBox(height: 10),
            Card(
              color: primaryColorApp,
              elevation: 2,
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushReplacementNamed(
                    context,
                    'list-product',
                  );
                },
                title: Text('PRODUCTOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: white,
                      fontSize: 16,
                    )),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              color: primaryColorApp,
              child: ListTile(
                onTap: () {
                  //cerramos el dialogo
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(
                    context,
                    'list-location',
                  );
                },
                title: Text('UBICACIONES',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: white,
                      fontSize: 16,
                    )),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
