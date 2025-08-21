
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wms_app/src/core/constans/colors.dart';

class DialogUnauthorizedDevice extends StatelessWidget {
  const DialogUnauthorizedDevice({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          title: Center(
            child: Text(
              'Dispositivo no autorizado',
              style: TextStyle(
                  color: primaryColorApp,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          content: const Text(
            'Este dispositivo no está autorizado para usar la aplicación. su suscripción ha expirado o no está activa, por favor contacte con el administrador.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: black,
            ),
          ),
        ),
      ),
    );
  }
}
