import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  final String letter;

  BackgroundPainter(this.letter);

  @override
  void paint(Canvas canvas, Size size) {
    // background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFFDF5),
    );

    // dot grid
    final dotPaint = Paint()..color = const Color(0xFFDDD5FF);

    for (double x = 20; x < size.width; x += 28) {
      for (double y = 20; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }

    // ghost letter (simple + safe)
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: size.shortestSide * 0.7,
          fontFamily: 'Pyidaungsu',
          color: Colors.black.withOpacity(0.08),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
