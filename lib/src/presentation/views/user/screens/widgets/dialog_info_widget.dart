
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DialogInfo extends StatelessWidget {
  const DialogInfo({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: Center(
            child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: primaryColorApp, fontSize: 20),
        )),
        content: Text(
          body,
          style: const TextStyle(color: black, fontSize: 16),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Aceptar"))
        ],
      ),
    );
  }
}
