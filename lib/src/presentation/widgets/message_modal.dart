import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

Future<dynamic> showModalDialog(BuildContext context, String titleDialog) {
  return AwesomeDialog(
    context: context,
    animType: AnimType.scale,
    dialogType: DialogType.infoReverse,
    body: Column(
      children: [
        Center(
          child: Text(
            titleDialog,
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    ),
  ).show();
}
