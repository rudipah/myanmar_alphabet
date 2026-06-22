import 'dart:math';
import 'package:flutter/material.dart';
import '../data/stroke_data.dart';
import '../services/tracing_validator.dart';

// ─────────────────────────────────────────────
// Canvas Configuration
// ─────────────────────────────────────────────
class CanvasConfig {
  static const double strokeWidth = 14.0;
  static const double guideLineWidth = 3.0;
  static const double dotSpacing = 28.0;
  static const double dotRadius = 2.0;
  static const double circleRadius = 14.0;
  static final Color bgColor = Color(0xFFFFFDF5);
  static final Color dotColor = Color(0xFFDDD5FF);
}

class TracingCanvas extends StatefulWidget {
  final String letter;
  final Color letterColor;
  final VoidCallback onDrawStart;
  final Function(bool success) onStrokeValidated;
  final bool showGuide;

  const TracingCanvas({
    super.key,
    required this.letter,
    required this.letterColor,
    required this.onDrawStart,
    required this.onStrokeValidated,
    this.showGuide = true,
  });

  @override
  State<TracingCanvas> createState() => TracingCanvasState();
}

class TracingCanvasState extends State<TracingCanvas> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasDrawn = false;
  Size? _canvasSize;
  final Set<int> _validatedStrokes = {};

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
    if (_currentStroke.isEmpty) return;

    bool isValid = false;
    if (_canvasSize != null) {
      final normalizedStroke = _currentStroke.map((p) => Offset(
        p.dx / _canvasSize!.width,
        p.dy / _canvasSize!.height,
      )).toList();

      final guides = letterStrokes[widget.letter];
      if (guides != null && _strokes.length < guides.length) {
        final guide = guides[_strokes.length];
        isValid = TracingValidator.validateStroke(
          userStroke: normalizedStroke,
          guide: guide,
        );
        if (isValid) {
          _validatedStrokes.add(_strokes.length);
        }
      }
    }

    setState(() {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });

    widget.onStrokeValidated(isValid);
  }

  bool isFullyValidated() {
    final guides = letterStrokes[widget.letter];
    if (guides == null) return false;
    return _validatedStrokes.length >= guides.length;
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _hasDrawn = false;
      _validatedStrokes.clear();
    });
  }

  bool get hasDrawn => _hasDrawn;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
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
              validatedStrokes: _validatedStrokes,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _TracingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final String letter;
  final Color letterColor;
  final bool showGuide;
  final Set<int> validatedStrokes;

  // Pre-allocated paints to avoid GC pressure
  final Paint _bgPaint = Paint();
  final Paint _dotPaint = Paint();
  final Paint _guidePaint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final Paint _userPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  _TracingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.letter,
    required this.letterColor,
    required this.showGuide,
    required this.validatedStrokes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _bgPaint.color = CanvasConfig.bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _bgPaint);

    _dotPaint.color = CanvasConfig.dotColor;
    for (double x = 20; x < size.width; x += CanvasConfig.dotSpacing) {
      for (double y = 20; y < size.height; y += CanvasConfig.dotSpacing) {
        canvas.drawCircle(Offset(x, y), CanvasConfig.dotRadius, _dotPaint);
      }
    }

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
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));

    if (showGuide) {
      final guides = letterStrokes[letter];
      if (guides != null) {
        for (int i = 0; i < guides.length; i++) {
          if (!validatedStrokes.contains(i)) {
            _drawStrokeGuide(canvas, size, guides[i]);
          }
        }
      }
    }

    for (int i = 0; i < strokes.length; i++) {
      _userPaint.color = validatedStrokes.contains(i) ? letterColor : letterColor.withOpacity(0.6);
      _userPaint.strokeWidth = CanvasConfig.strokeWidth;
      _drawUserStroke(canvas, strokes[i], _userPaint);
    }
    
    _userPaint.color = letterColor;
    _userPaint.strokeWidth = CanvasConfig.strokeWidth;
    _drawUserStroke(canvas, currentStroke, _userPaint);
  }

  Offset _px(Offset norm, Size size) => Offset(norm.dx * size.width, norm.dy * size.height);

  void _drawStrokeGuide(Canvas canvas, Size size, StrokeGuide guide) {
    if (guide.points.length < 2) return;
    final pts = guide.points.map((p) => _px(p, size)).toList();

    _guidePaint.color = Colors.black.withOpacity(0.28);
    _guidePaint.strokeWidth = CanvasConfig.guideLineWidth;
    _drawDashed(canvas, pts, _guidePaint);

    _drawArrow(canvas, pts[pts.length - 2], pts.last, Colors.black.withOpacity(0.50));
    _drawNumberCircle(canvas, pts.first, guide.label, letterColor);
  }

  void _drawDashed(Canvas canvas, List<Offset> pts, Paint paint, {double dash = 9, double gap = 6}) {
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
          if (drawing) canvas.drawLine(Offset(a.dx + ux * traveled, a.dy + uy * traveled), b, paint);
          rem = len - traveled;
          traveled = len;
        } else {
          if (drawing) {
            canvas.drawLine(Offset(a.dx + ux * traveled, a.dy + uy * traveled), Offset(a.dx + ux * next, a.dy + uy * next), paint);
          }
          traveled = next;
          rem = 0;
          drawing = !drawing;
        }
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    const sz = 13.0;
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - sz * cos(angle - 0.42), to.dy - sz * sin(angle - 0.42))
      ..lineTo(to.dx - sz * cos(angle + 0.42), to.dy - sz * sin(angle + 0.42))
      ..close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  void _drawNumberCircle(Canvas canvas, Offset center, String label, Color color) {
    const r = CanvasConfig.circleRadius;
    canvas.drawCircle(center, r, Paint()..color = color);
    canvas.drawCircle(center, r, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5);
    final tp = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Arial')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawUserStroke(Canvas canvas, List<Offset> pts, Paint paint) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TracingPainter old) => 
      old.strokes != strokes || 
      old.currentStroke != currentStroke || 
      old.validatedStrokes != validatedStrokes;
}
