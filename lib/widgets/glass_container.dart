import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Master switch for real backdrop blur. The mesh background behind the glass
/// is a smooth gradient, so blurring it changes nothing visible — but each
/// BackdropFilter costs a full-screen re-blur every frame (and a saveLayer
/// during fade/scale transitions), which made screens like Flashcards janky.
/// Set to true only if you put detailed content (images, text) BEHIND glass.
const bool kGlassBackdropBlur = false;

/// The core "liquid glass" surface:
///   translucent white fill + 1px light border + soft top specular highlight,
///   optionally with a real backdrop blur.
///
/// Performance note: every [BackdropFilter] re-blurs what is behind it each
/// frame. The mesh background is already smooth, so for big grids of small
/// tiles pass `blur: 0` — they look identical but cost nothing.
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  /// Backdrop blur sigma. 0 disables the BackdropFilter entirely.
  final double blur;

  /// Fill opacity when [tint] is not given.
  final double fillOpacity;

  /// Overrides the fill colour (use a translucent colour, e.g. purple @ 0.55).
  final Color? tint;
  final Color? borderColor;

  /// Opacity of the white highlight over the top half. 0 = none.
  final double specularOpacity;

  final VoidCallback? onTap;

  /// Re-themes Material widgets inside (ListTile, Switch, Radio, Divider...)
  /// for light-on-dark. Use for Settings-style cards.
  final bool darkMaterial;

  const GlassContainer({
    super.key,
    this.child,
    this.borderRadius = 20,
    this.padding,
    this.width,
    this.height,
    this.alignment,
    this.blur = 14,
    this.fillOpacity = AppColors.glassFillAlpha,
    this.tint,
    this.borderColor,
    this.specularOpacity = AppColors.glassSpecularAlpha,
    this.onTap,
    this.darkMaterial = false,
  });

  static ThemeData _darkTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      dividerTheme: DividerThemeData(color: AppColors.white(0.12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Widget content = child ?? const SizedBox.shrink();
    if (padding != null || alignment != null) {
      content = Container(
        alignment: alignment,
        padding: padding,
        child: content,
      );
    }

    // Specular highlight: white -> transparent over the top half.
    content = Stack(
      fit: StackFit.passthrough,
      children: [
        if (specularOpacity > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: 1,
                  heightFactor: 0.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.white(specularOpacity),
                          AppColors.white(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        content,
      ],
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      );
    }

    // Transparent Material so ink splashes / ListTiles inside paint ABOVE
    // the glass fill instead of being hidden beneath it.
    content = Material(type: MaterialType.transparency, child: content);

    Widget glass = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tint ?? AppColors.white(fillOpacity),
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? AppColors.white(AppColors.glassBorderAlpha),
        ),
      ),
      child: content,
    );

    if (kGlassBackdropBlur && blur > 0) {
      glass = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: glass,
      );
    }

    glass = ClipRRect(borderRadius: radius, child: glass);

    if (darkMaterial) {
      glass = Theme(data: _darkTheme(context), child: glass);
    }
    return glass;
  }
}
