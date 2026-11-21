import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Frosted track with a lilac -> pink gradient fill (animates on change).
class GlassProgressBar extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final double height;

  const GlassProgressBar({super.key, required this.value, this.height = 6});

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white(0.12),
          borderRadius: BorderRadius.circular(height),
          border: Border.all(color: AppColors.white(0.08)),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: target),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, v, _) => Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xE6AA8CFF), Color(0xE6FFA0D2)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
