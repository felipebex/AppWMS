// ignore_for_file: file_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wms_app/environment/environment.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DialogLoadingNetwork extends StatelessWidget {
  const DialogLoadingNetwork({
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
            SizedBox(
              height: 100,
              width: 200,
              child: Image.asset(
                Environment.flavor.appName == "BexPicking"
                    ? "assets/icons/iconBex.png"
                    : "assets/images/icono.jpeg",
                fit: Environment.flavor.appName == "BexPicking"
                    ? BoxFit.contain
                    : BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Cargando Información...',
                style: TextStyle(color: primaryColorApp, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const Text('Espera un momento...',
                style: TextStyle(color: grey, fontSize: 14)),
          ],
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: CircularProgressIndicator(
                color: primaryColorApp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
