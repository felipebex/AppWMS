import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DialogUpdateApp extends StatelessWidget {
  const DialogUpdateApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        backgroundColor: white,
        title: Center(
            child: Text('Nueva versión disponible',
                style: TextStyle(color: primaryColorApp, fontSize: 16))),
        content: const Text(
            'Actualiza a la nueva versión para seguir disfrutando de todas las funcionalidades de la aplicación',
            textAlign: TextAlign.justify,
            style: TextStyle(color: black, fontSize: 14)),
        actions: [
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // minimumSize: const Size(100, 40),
              backgroundColor: primaryColorApp,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await launchUrl(
                  Uri.parse(
                      'https://drive.google.com/drive/folders/19I2uEWxRUUpsrh8G4_J_cSFaBphGfgl-?usp=drive_link'),
                  mode: LaunchMode.inAppWebView);
            },
            child: const Text(
              'Actualizar',
              style: TextStyle(
                color: white,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
