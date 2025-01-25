import 'package:flutter/material.dart';

class BottomCurveClipper extends CustomClipper<Path> {
  final double curveHeight;

  BottomCurveClipper({required this.curveHeight});

  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from the top left of the container
    path.lineTo(0, size.height - curveHeight);

    // Single smooth "U" shape curve using one control point
    var controlPoint = Offset(size.width / 2, size.height + curveHeight);
    var endPoint = Offset(size.width, size.height - curveHeight);
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // Line to the top right corner of the container
    path.lineTo(size.width, 0);

    // Line back to the starting point to close the shape
    path.lineTo(0, 0);

    // Close the path to form a complete shape
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
