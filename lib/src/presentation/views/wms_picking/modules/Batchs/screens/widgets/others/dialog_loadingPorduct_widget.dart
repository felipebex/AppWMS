// ignore_for_file: file_names

import 'dart:ui';

import 'package:flutter/material.dart';


import '../../../../../../../../utils/constans/colors.dart';

class DialogLoading extends StatelessWidget {
   const DialogLoading({
    super.key,  this.message = 'Pasando al siguiente producto...'

  });

   final String message ;
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
                "assets/images/icono2.jpeg",
                fit: BoxFit.cover,
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
             Text(message,
                style: const TextStyle(color: grey, fontSize: 14)),
          ],
        )),
       
      ),
    );
  }
}
