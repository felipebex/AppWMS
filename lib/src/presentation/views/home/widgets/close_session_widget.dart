import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

import '../../../../utils/prefs/pref_utils.dart';

class CloseSession extends StatelessWidget {
  const CloseSession({
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
            child: Text('Cerrar sesión',
                style: TextStyle(color: primaryColorApp))),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 40),
              backgroundColor: grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: white,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 40),
              backgroundColor: primaryColorApp,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              PrefUtils.clearPrefs();
              //limpiamos toda la base de datos

              Preferences.removeUrlWebsite();
              DataBaseSqlite().deleteAll();

              PrefUtils.setIsLoggedIn(false);
              Navigator.pushNamedAndRemoveUntil(
                  context, 'enterprice', (route) => false);
            },
            child: const Text(
              'Aceptar',
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
