import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'glass_container.dart';

/// Consistent back/nav icon button used across all screens (glass pill).
class NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const NavIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: 52,
      height: 52,
      borderRadius: 16,
      blur: 10,
      alignment: Alignment.center,
      onTap: onPressed,
      child: Icon(icon, size: 26, color: AppColors.white(0.92)),
    );
  }
}
