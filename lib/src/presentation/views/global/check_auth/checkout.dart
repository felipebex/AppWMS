// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, avoid_print

import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:flutter/material.dart';

class CheckAuthPage extends StatelessWidget {
  const CheckAuthPage({super.key});

  // Método para validar la sesión
  Future<bool> validateSession() async {
    bool? token = await PrefUtils.getIsLoggedIn();
    if (!token) {
      return false; // No hay token, sesión no válida
    } else {
      return true; // La sesión es válida
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: validateSession(), // Cambiar a validateSession
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Si hubo un error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: const TextStyle(fontSize: 18),
                  ),
                );

                // Si obtuvimos datos
              } else if (snapshot.hasData) {
                if (snapshot.data == false) {
                  Future.microtask(() {
                    Navigator.pushReplacementNamed(context, 'enterprice');
                  });
                  return Container();
                } else {
                  Future.microtask(() {
                    Navigator.pushReplacementNamed(context, '/home');
                  });
                }
              }
            } else {
              return const CircularProgressIndicator();
            }

            return Container();
          },
        ),
      ),
    );
  }
}
