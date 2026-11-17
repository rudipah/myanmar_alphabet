import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'glass_container.dart';

class MenuButton extends StatelessWidget {
  final String label;
  final dynamic icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: 24,
      blur: 14,
      tint: isPrimary ? AppColors.primary.withValues(alpha: 0.55) : null,
      borderColor: isPrimary ? const Color(0x59B4A0FF) : null,
      onTap: onTap,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon is IconData) Icon(icon, color: Colors.white),
          if (icon is Widget) icon,
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onGlass,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
