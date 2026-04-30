import 'dart:math';
import 'package:flutter/material.dart';
import '../data/stroke_data.dart';

class TracingCanvas extends StatefulWidget {
  final String letter;
  final Color letterColor;
  final VoidCallback onDrawStart;
  final bool showGuide;

  const TracingCanvas({
    super.key,
    required this.letter,
    required this.letterColor,
    required this.onDrawStart,
    this.showGuide = true,
  });

  @override
  State<TracingCanvas> createState() => TracingCanvasState();
}

class TracingCanvasState extends State<TracingCanvas> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasDrawn = false;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
      if (!_hasDrawn) {
        _hasDrawn = true;
        widget.onDrawStart();
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_currentStroke.isNotEmpty) {
        _strokes.add(List.from(_currentStroke));
        _currentStroke = [];
      }
    });
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _hasDrawn = false;
    });
  }

  bool get hasDrawn => _hasDrawn;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: _TracingPainter(
          strokes: _strokes,
          currentStroke: _currentStroke,
          letter: widget.letter,
          letterColor: widget.letterColor,
          showGuide: widget.showGuide,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────
class _TracingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final String letter;
  final Color letterColor;
  final bool showGuide;

  _TracingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.letter,
    required this.letterColor,
    required this.showGuide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1 ── Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFFFFDF5),
    );

    // 2 ── Dot grid
    final dotPaint = Paint()..color = const Color(0xFFDDD5FF);
    for (double x = 20; x < size.width; x += 28) {
      for (double y = 20; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }

    // 3 ── Ghost letter (very faint)
    final short = size.width < size.height ? size.width : size.height;
    final ghostStyle = TextStyle(
      fontFamily: 'Pyidaungsu',
      fontSize: short * 0.72,
      color: letterColor.withOpacity(0.10),
      fontWeight: FontWeight.bold,
    );
    final tp = TextPainter(
      text: TextSpan(text: letter, style: ghostStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));

    // 4 ── Stroke guides
    if (showGuide) {
      final guides = letterStrokes[letter];
      if (guides != null) {
        for (final guide in guides) {
          _drawStrokeGuide(canvas, size, guide);
        }
      }
    }

    // 5 ── User strokes
    final strokePaint = Paint()
      ..color = letterColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawUserStroke(canvas, stroke, strokePaint);
    }
    _drawUserStroke(canvas, currentStroke, strokePaint);
  }

  // ── Convert normalised point → canvas pixels ──
  Offset _px(Offset norm, Size size) =>
      Offset(norm.dx * size.width, norm.dy * size.height);

  // ── Draw one stroke guide ─────────────────────
  void _drawStrokeGuide(Canvas canvas, Size size, StrokeGuide guide) {
    if (guide.points.length < 2) return;

    final pts = guide.points.map((p) => _px(p, size)).toList();

    // Dashed path
    _drawDashed(
        canvas,
        pts,
        Paint()
          ..color = Colors.black.withOpacity(0.28)
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);

    // Arrow at end
    _drawArrow(
        canvas, pts[pts.length - 2], pts.last, Colors.black.withOpacity(0.50));

    // Numbered circle at start
    _drawNumberCircle(canvas, pts.first, guide.label, letterColor);
  }

  // ── Dashed polyline ───────────────────────────
  void _drawDashed(Canvas canvas, List<Offset> pts, Paint paint,
      {double dash = 9, double gap = 6}) {
    bool drawing = true;
    double rem = 0;
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i], b = pts[i + 1];
      final dx = b.dx - a.dx, dy = b.dy - a.dy;
      final len = sqrt(dx * dx + dy * dy);
      if (len == 0) continue;
      final ux = dx / len, uy = dy / len;
      double traveled = 0;
      while (traveled < len) {
        final step = drawing ? (dash - rem) : (gap - rem);
        final next = traveled + step;
        if (next >= len) {
          if (drawing) {
            canvas.drawLine(
              Offset(a.dx + ux * traveled, a.dy + uy * traveled),
              b,
              paint,
            );
          }
          rem = len - traveled;
          traveled = len;
        } else {
          final ex = a.dx + ux * next, ey = a.dy + uy * next;
          if (drawing) {
            canvas.drawLine(
              Offset(a.dx + ux * traveled, a.dy + uy * traveled),
              Offset(ex, ey),
              paint,
            );
          }
          traveled = next;
          rem = 0;
          drawing = !drawing;
        }
      }
    }
  }

  // ── Arrowhead ─────────────────────────────────
  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    const sz = 13.0;
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - sz * cos(angle - 0.42), to.dy - sz * sin(angle - 0.42))
      ..lineTo(to.dx - sz * cos(angle + 0.42), to.dy - sz * sin(angle + 0.42))
      ..close();
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  // ── Numbered start circle ─────────────────────
  void _drawNumberCircle(
      Canvas canvas, Offset center, String label, Color color) {
    const r = 14.0;
    // Filled circle
    canvas.drawCircle(center, r, Paint()..color = color);
    // White border
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    // Number text
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            fontFamily: 'Arial'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  // ── User freehand stroke ──────────────────────
  void _drawUserStroke(Canvas canvas, List<Offset> pts, Paint paint) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TracingPainter old) => true;
}
