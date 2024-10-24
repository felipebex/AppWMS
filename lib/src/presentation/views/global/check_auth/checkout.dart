// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/pages.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:flutter/material.dart';

class CheckAuthPage extends StatelessWidget {
  const CheckAuthPage({super.key});

  // Método para validar la sesión
  Future<bool> validateSession() async {
    String? token = await PrefUtils.getToken();
    if (token.isEmpty) {
      print('No hay token, sesión no válida');
      return false; // No hay token, sesión no válida
    }

    DateTime? expires = await PrefUtils.getExpirationDate();
    if (expires == null || DateTime.now().isAfter(expires)) {
      print('La cookie ha expirado');
      return false; // La cookie ha expirado
    }

    print('La sesión es válida');

    return true; // La sesión es válida
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
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            const SelectEnterpricePage(),
                        transitionDuration: const Duration(seconds: 0),
                      ),
                    );
                  });
                  return Container();
                } else {
                  Future.microtask(() {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HomePage(),
                        transitionDuration: const Duration(seconds: 0),
                      ),
                    );
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
