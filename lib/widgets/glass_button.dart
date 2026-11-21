import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'glass_container.dart';

/// Tinted glass button. Pass `onPressed: null` for the disabled look.
/// Give it a bounded width (Expanded / SizedBox(width: double.infinity)).
class GlassButton extends StatelessWidget {
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;

  /// Accent colour. Defaults to the brand purple. Pass `Colors.white` (or
  /// `neutral: true`) for a plain, untinted glass button.
  final Color? tint;
  final bool neutral;
  final double height;
  final double fontSize;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.tint,
    this.neutral = false,
    this.height = 54,
    this.fontSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final base = tint ?? AppColors.primary;

    Color fill;
    Color border;
    if (!enabled) {
      fill = AppColors.white(0.06);
      border = AppColors.white(0.12);
    } else if (neutral) {
      fill = AppColors.white(0.12);
      border = AppColors.white(0.25);
    } else {
      fill = base.withValues(alpha: 0.55);
      border = Color.lerp(base, Colors.white, 0.55)!.withValues(alpha: 0.45);
    }

    return GlassContainer(
      height: height,
      borderRadius: 18,
      blur: 12,
      tint: fill,
      borderColor: border,
      onTap: onPressed,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: enabled ? AppColors.onGlass : AppColors.white(0.4),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
