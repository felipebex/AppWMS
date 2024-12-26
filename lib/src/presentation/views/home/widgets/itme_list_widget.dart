
import 'package:flutter/material.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ItemList extends StatelessWidget {
  const ItemList({super.key, 
    required this.size,
    required this.color,
    required this.title,
    required this.value,
  });

  final Size size;
  final Color color;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * 0.6,
      child: Card(
        elevation: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.batch_prediction,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 5),
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(value,
                style: TextStyle(
                    color: primaryColorApp,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
