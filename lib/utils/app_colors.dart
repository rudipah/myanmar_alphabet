import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const int primaryValue = 0xFF6C5CE7;
  static const Color primaryLight = Color(0xFF9B8FF5);
  static const Color primaryDark = Color(0xFF5B4CC4);

  // Neutral Colors
  static const Color background = Color(0xFFF0EEFF);
  static const Color surface = Colors.white;
  static const Color textColor = Color(0xFF2D2D4E);
  static const Color textSecondary = Color(0xFF6B6B8A);

  // Liquid-glass palette (dark mesh background + translucent glass)
  static const Color meshBase = Color(0xFF150D2E);
  static const Color onGlass = Color(0xF2FFFFFF); // white 95%
  static const Color onGlassMuted = Color(0x8CFFFFFF); // white 55%
  static const Color glassCorrect = Color(0xFF34D399);
  static const Color glassWrong = Color(0xFFF87171);
  static const double glassFillAlpha = 0.10;
  static const double glassBorderAlpha = 0.20;
  static const double glassSpecularAlpha = 0.12;

  /// White at the given opacity — shorthand used all over the glass UI.
  static Color white(double alpha) => Colors.white.withValues(alpha: alpha);

  // Status Colors
  static const Color success = Colors.greenAccent;
  static const Color error = Colors.redAccent;
  static const Color warning = Colors.orangeAccent;
}
