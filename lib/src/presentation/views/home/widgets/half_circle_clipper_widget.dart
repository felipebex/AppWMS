// Clipper para crear la forma de medio círculo

import 'package:flutter/material.dart';

class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.5);
    path.arcToPoint(Offset(0.0, size.height * 0.5),
        radius: Radius.circular(size.width), clockwise: true);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
