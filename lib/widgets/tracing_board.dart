import 'package:flutter/material.dart';
import 'tracing_canvas.dart';
import '../painters/background_painter.dart';

class TracingBoard extends StatelessWidget {
  final String letter;
  final Color color;
  final VoidCallback onDrawStart;

  const TracingBoard({
    super.key,
    required this.letter,
    required this.color,
    required this.onDrawStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // BACKGROUND LAYER (grid + ghost later)
          CustomPaint(
            painter: BackgroundPainter(letter),
          ),

          // USER DRAWING LAYER
          TracingCanvas(
            letter: letter,
            letterColor: color,
            onDrawStart: onDrawStart,
          ),
        ],
      ),
    );
  }
}
