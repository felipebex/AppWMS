
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
      elevation: 2,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Column(
          children: [
            Container(
                height: 60,
                width: 60,
                margin: const EdgeInsets.only(top: 10),
                // clipBehavior: Clip.hardEdge,
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(10),
                // ),
                // child: Image.network(urlImg, fit: BoxFit.cover),
                child: Image.asset("assets/icons/$urlImg", fit: BoxFit.cover)
                ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: primaryColorApp,
                  
                  
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

