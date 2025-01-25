import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Color color;

  DashedLinePainter({required this.dashWidth, required this.dashSpace, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
