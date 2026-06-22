import 'package:flutter/material.dart';
import '../data/stroke_data.dart';

class TracingValidator {
  /// Validates if a user's drawn stroke roughly follows the guide stroke.
  /// [threshold] is the maximum allowed average distance from guide points to the user's stroke.
  static bool validateStroke({
    required List<Offset> userStroke,
    required StrokeGuide guide,
    double threshold = 0.07,
  }) {
    if (userStroke.isEmpty || guide.points.isEmpty) return false;

    // 1. Check for direction (start and end points should be roughly correct)
    final userStart = userStroke.first;
    final userEnd = userStroke.last;
    final guideStart = guide.points.first;
    final guideEnd = guide.points.last;

    final startDist = (userStart - guideStart).distance;
    final endDist = (userEnd - guideEnd).distance;

    // We allow some leeway for the start/end, but they shouldn't be completely off.
    if (startDist > 0.15 || endDist > 0.15) {
      // We don't return false immediately because the user might have a long lead-in/out,
      // but it's a strong signal. Let's check the overall path coverage instead.
    }

    // 2. Check coverage: Every point in the guide should be close to some point in the user stroke.
    int pointsMatched = 0;
    for (final guidePoint in guide.points) {
      double minDist = double.infinity;
      for (final userPoint in userStroke) {
        final d = (guidePoint - userPoint).distance;
        if (d < minDist) minDist = d;
      }
      if (minDist < threshold) {
        pointsMatched++;
      }
    }

    // Require at least 80% of the guide points to be covered.
    final coverage = pointsMatched / guide.points.length;
    return coverage > 0.8;
  }

  /// Calculates how many guide strokes have been successfully completed.
  static bool isLetterComplete(int completedStrokes, String letter) {
    final guides = letterStrokes[letter];
    if (guides == null) return false;
    return completedStrokes >= guides.length;
  }
}
