import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

/// One clock for the whole app, so the background drift is continuous when
/// moving between screens (each screen has its own MeshBackground).
final Stopwatch _meshClock = Stopwatch()..start();

/// Dark base + four soft colour blobs that drift slowly (the "mesh").
/// Opaque, so page transitions never show the previous screen through it.
class MeshBackground extends StatefulWidget {
  final Widget child;
  const MeshBackground({super.key, required this.child});

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _time = ValueNotifier<double>(0);
  Ticker? _ticker;
  int _lastMs = 0;

  @override
  void initState() {
    super.initState();
    _time.value = _meshClock.elapsedMilliseconds / 1000.0;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the system "remove animations" setting.
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _ticker?.muted = reduce;
  }

  void _onTick(Duration _) {
    final ms = _meshClock.elapsedMilliseconds;
    if (ms - _lastMs < 66) return; // ~15 fps is plenty for a slow drift
    _lastMs = ms;
    _time.value = ms / 1000.0;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.meshBase,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _MeshPainter(_time)),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Blob {
  final double x; // 0..1 of width
  final double y; // 0..1 of height
  final Color color;
  final double radius; // fraction of the screen's longest side
  final double drift; // fraction of width/height the blob wanders
  final double speed; // radians per second
  final double phase;
  const _Blob(this.x, this.y, this.color, this.radius, this.drift, this.speed,
      this.phase);
}

class _MeshPainter extends CustomPainter {
  final ValueListenable<double> time;
  _MeshPainter(this.time) : super(repaint: time);

  static const List<_Blob> _blobs = [
    _Blob(0.25, 0.15, Color(0xFF5C2FA8), 0.65, 0.07, 0.22, 0.0),
    _Blob(0.80, 0.70, Color(0xFF8B1A6B), 0.60, 0.08, 0.18, 1.7),
    _Blob(0.10, 0.85, Color(0xFF0D5C9A), 0.55, 0.06, 0.26, 3.1),
    _Blob(0.75, 0.20, Color(0xFF1B6E8F), 0.50, 0.07, 0.20, 4.6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.meshBase);

    final t = time.value;
    final base = size.longestSide;
    for (final b in _blobs) {
      final dx = math.sin(t * b.speed + b.phase) * b.drift;
      final dy = math.cos(t * b.speed * 0.8 + b.phase) * b.drift;
      final center = Offset((b.x + dx) * size.width, (b.y + dy) * size.height);
      final r = base * b.radius;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [b.color, b.color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: r));
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) =>
      oldDelegate.time != time;
}

/// Drop-in replacement for the `Scaffold(backgroundColor: ...)` used on every
/// screen: mesh background behind everything (including the banner ad area
/// and the system bars) with a transparent Scaffold on top.
class GlassScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;

  const GlassScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: bottomNavigationBar,
        body: body,
      ),
    );
  }
}
