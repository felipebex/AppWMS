// ignore_for_file: file_names

import 'dart:ui';

import 'package:flutter/material.dart';


import '../../../../../../../../utils/constans/colors.dart';

class DialogLoading extends StatelessWidget {
  const DialogLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // context.read<BatchBloc>().add(FetchBatchWithProductsEvent(
    //     context.read<BatchBloc>().batchWithProducts.batch?.id ?? 0));
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
                "assets/images/icono.jpeg",
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
            const Text('Pasando al siguiente producto...',
                style: TextStyle(color: grey, fontSize: 14)),
          ],
        )),
        // content: Column(
        //   mainAxisSize: MainAxisSize.min,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Center(
        //       child: CircularProgressIndicator(
        //         color: primaryColorApp,
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
