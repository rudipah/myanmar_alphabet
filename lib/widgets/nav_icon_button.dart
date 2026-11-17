import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Consistent back/nav icon button used across all screens.
/// Replaces the identical _buildNavButton() method repeated in
/// quiz_screen, flashcard_screen, progress_screen, and matching_game_screen.
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 32, color: AppColors.primary),
        onPressed: onPressed,
      ),
    );
  }
}
