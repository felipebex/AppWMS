import 'package:flutter/material.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

// Widget reutilizable para mostrar las filas con título y valor
class ProductInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const ProductInfoRow({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '$title: ',
            style: TextStyle(fontSize: 12, color: primaryColorApp),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: black),
          ),
        ),
      ],
    );
  }
}
