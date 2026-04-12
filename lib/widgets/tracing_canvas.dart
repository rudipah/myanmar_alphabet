import 'package:flutter/material.dart';

class TracingCanvas extends StatefulWidget {
  final String letter;
  final Color letterColor;
  final VoidCallback onDrawStart;

  const TracingCanvas({
    super.key,
    required this.letter,
    required this.letterColor,
    required this.onDrawStart,
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
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TracingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final String letter;
  final Color letterColor;

  _TracingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.letter,
    required this.letterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFFFFDF5),
    );

    // 2. Dot grid
    final dotPaint = Paint()..color = const Color(0xFFDDD5FF);
    for (double x = 20; x < size.width; x += 28) {
      for (double y = 20; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }

    // 3. Ghost letter
    final shortSide = size.width < size.height ? size.width : size.height;
    final ghostStyle = TextStyle(
      fontFamily: 'Pyidaungsu',
      fontSize: shortSide * 0.72,
      color: letterColor.withOpacity(0.18),
      fontWeight: FontWeight.bold,
    );
    final ghostPainter = TextPainter(
      text: TextSpan(text: letter, style: ghostStyle),
      textDirection: TextDirection.ltr,
    );
    ghostPainter.layout();
    ghostPainter.paint(
      canvas,
      Offset(
        (size.width - ghostPainter.width) / 2,
        (size.height - ghostPainter.height) / 2,
      ),
    );

    // 4. User strokes
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

  void _drawUserStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TracingPainter old) => true;
}
