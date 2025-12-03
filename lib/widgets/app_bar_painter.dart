import 'dart:ui';
import 'package:flutter/material.dart';

class AppBarPainter extends CustomPainter {
  final List<Color> gradientColors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  AppBarPainter({
    required this.gradientColors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: gradientColors,
      begin: begin,
      end: end,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Paint paint_1 = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    Path path_1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * .12, 0.0)
      ..cubicTo(
          size.width * 0.06, 0.0, 
          0.0, 0.06, 
          0.0, 0.15 * size.width 
          );

    Path path_2 = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * .88, 0.0)
      ..cubicTo(
          size.width * .94, 0.0, 
          size.width, 0.06, 
          size.width, 0.15 * size.width 
          );

    Paint paint_2 = Paint()
      ..shader = gradient
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    Path path_3 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path_1, paint_1);
    canvas.drawPath(path_2, paint_1);
    canvas.drawPath(path_3, paint_2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

