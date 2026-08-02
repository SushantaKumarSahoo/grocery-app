import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/theme_ext.dart';
import 'animated_blobs.dart';

/// Wraps a screen's body with a faint, slowly-drifting gradient backdrop so
/// otherwise flat screens (Categories, Orders, Profile, empty carts...)
/// don't read as plain white/gray. Purely procedural (no image assets), so
/// it stays lightweight.
class ScreenBackdrop extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const ScreenBackdrop({super.key, required this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: AnimatedBlobs(
            colors:
                colors ??
                const [
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.accent,
                ],
            opacity: c.isDark ? 0.38 : 0.28,
          ),
        ),
        child,
      ],
    );
  }
}
