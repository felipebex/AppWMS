import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:introduction_screen/introduction_screen.dart';

class DialogUpdateApp extends StatefulWidget {
  const DialogUpdateApp({
    super.key,
  });

  @override
  State<DialogUpdateApp> createState() => _DialogUpdateAppState();
}

class _DialogUpdateAppState extends State<DialogUpdateApp> {
  List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      title: "",
      body:
          "Actualiza a la nueva versión para seguir disfrutando de todas las funcionalidades de la aplicación",
      image: SizedBox(
        height: 100,
        width: 200,
        child: Image.asset(
          "assets/images/icono.jpeg",
          fit: BoxFit.cover,
        ),
      ),
      decoration: PageDecoration(
        pageColor: white,
        imagePadding: const EdgeInsets.all(0),
        titlePadding: const EdgeInsets.all(0),
        bodyPadding: const EdgeInsets.only(top: 5),
        footerPadding: const EdgeInsets.all(0),
        titleTextStyle: TextStyle(color: primaryColorApp, fontSize: 14.0),
        bodyTextStyle: const TextStyle(color: black, fontSize: 14.0),
      ),
    ),
    PageViewModel(
      title: "",
      body:
          "Para actualizar la aplicación, presiona el botón de actualizar y descarga la nueva versión de la aplicación, una vez descargada, desinstala la versión actual y procede a instalar la nueva versión, recuerda que debes volver a iniciar sesión.",
      decoration: PageDecoration(
        pageColor: white,
        imagePadding: const EdgeInsets.all(0),
        titlePadding: const EdgeInsets.all(0),
        bodyPadding: const EdgeInsets.only(top: 5),
        footerPadding: const EdgeInsets.all(0),
        titleTextStyle: TextStyle(color: primaryColorApp, fontSize: 14.0),
        bodyTextStyle: const TextStyle(color: black, fontSize: 14.0),
        bodyAlignment: Alignment.centerLeft,
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        backgroundColor: white,
        contentPadding: const EdgeInsets.all(10),
        title: Center(
            child: Text('Nueva versión disponible',
                style: TextStyle(color: primaryColorApp, fontSize: 16))),
        // content: const Text(
        //     'Actualiza a la nueva versión para seguir disfrutando de todas las funcionalidades de la aplicación',
        //     textAlign: TextAlign.justify,
        //     style: TextStyle(color: black, fontSize: 14)),
        content: IntroductionScreen(
          pages: listPagesViewModel,
          showSkipButton: true,
          showNextButton: false,
          isProgress: true,

          skip: const Text("Saltar"),
          done: const Text("Listo"),
          //estilo de texto
          onDone: () async {
            // On button pressed
            await launchUrl(
                Uri.parse(
                    'https://drive.google.com/drive/folders/19I2uEWxRUUpsrh8G4_J_cSFaBphGfgl-?usp=drive_link'),
                mode: LaunchMode.inAppWebView);
          },
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: Theme.of(context).colorScheme.secondary,
            color: white,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
          ),
        ),
        // actions: [
        //   const SizedBox(width: 10),
        //   ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       // minimumSize: const Size(100, 40),
        //       backgroundColor: primaryColorApp,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //     ),
        //     onPressed: () async {
        //       // await launchUrl(
        //       //     Uri.parse(
        //       //         'https://drive.google.com/drive/folders/19I2uEWxRUUpsrh8G4_J_cSFaBphGfgl-?usp=drive_link'),
        //       //     mode: LaunchMode.inAppWebView);
        //       //cerramos el dialogo
        //       Navigator.of(context).pop();
        //     },
        //     child: const Text(
        //       'Actualizar',
        //       style: TextStyle(
        //         color: white,
        //         fontSize: 14,
        //         fontFamily: 'Poppins',
        //         fontWeight: FontWeight.w500,
        //       ),
        //     ),
        //   ),
        // ],
      ),
    );
  }
}
