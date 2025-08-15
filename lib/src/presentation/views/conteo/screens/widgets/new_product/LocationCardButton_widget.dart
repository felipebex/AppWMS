import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationCardButtonConteo extends StatelessWidget {
  final dynamic bloc;
  final bool ubicacionFija;
  final Color cardColor;
  final Color textAndIconColor;
  final Color lockCardColor;
  final String title;
  final String iconPath;
  final String dialogTitle;
  final String dialogMessage;
  final String routeName;

  const LocationCardButtonConteo({
    super.key,
    required this.bloc,
    required this.ubicacionFija,
    this.cardColor = Colors.white,
    this.textAndIconColor = Colors.blue,
    this.lockCardColor = Colors.white,
    this.title = 'Ubicación de existencias',
    this.iconPath = "assets/icons/ubicacion.png",
    this.dialogTitle = '360 Software Informa',
    this.dialogMessage =
        "No hay ubicaciones cargadas, por favor cargues las ubicaciones",
    this.routeName = 'search-location-conteo',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Card principal con GestureDetector
        Expanded(
          child: GestureDetector(
            onTap: !bloc.locationIsOk && !bloc.productIsOk && !bloc.quantityIsOk
                ? () {
                    Navigator.pushReplacementNamed(
                      context,
                      routeName,
                    );
                  }
                : null,
            child: Card(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          color: textAndIconColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Image.asset(
                      iconPath,
                      color: textAndIconColor,
                      width: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
