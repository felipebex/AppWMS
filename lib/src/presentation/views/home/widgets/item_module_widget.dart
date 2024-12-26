
import 'package:flutter/material.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ImteModule extends StatelessWidget {
  const ImteModule({super.key, 
    required this.urlImg,
    required this.title,
  });

  final String urlImg;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6,
      child: SizedBox(
        width: 140,
        height: 150,
        child: Column(
          children: [
            Container(
                height: 100,
                width: 100,
                margin: const EdgeInsets.only(top: 10),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                // child: Image.network(urlImg, fit: BoxFit.cover),
                child: Image.asset("assets/icons/$urlImg", fit: BoxFit.cover)
                ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  color: primaryColorApp,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

