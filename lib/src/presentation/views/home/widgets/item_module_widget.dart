import 'package:flutter/material.dart';
import 'package:wms_app/src/core/constans/colors.dart';

class ImteModule extends StatelessWidget {
  final String urlImg;
  final String title;
  final int count;

  const ImteModule({
    super.key,
    required this.urlImg,
    required this.title,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: SizedBox(
        width: 100,
        height: 100,
        child: _ImteModuleContent(
          urlImg: urlImg,
          title: title,
          count: count,
        ),
      ),
    );
  }
}

class _ImteModuleContent extends StatelessWidget {
  final String urlImg;
  final String title;
  final int count;

  const _ImteModuleContent({
    required this.urlImg,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(top: 10),
              child: Image.asset(
                "assets/icons/$urlImg",
                fit: BoxFit.cover,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text(
                title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: primaryColorApp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (count > 0)
          _CountBadge(count: count),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 2,
      right: 2,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        child: Center(
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
