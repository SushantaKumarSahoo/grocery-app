import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import '../theme/occasion_themes.dart';
import '../theme/theme_ext.dart';
import 'animated_blobs.dart';
import 'festive_motifs.dart';
import 'ikat_pattern.dart';
import 'odisha_landmarks.dart';

/// Wraps a screen's body with a faint, slowly-drifting gradient backdrop
/// plus a Sambalpuri-ikat diamond-weave texture, so otherwise flat screens
/// (Categories, Orders, Profile, empty carts...) don't read as plain
/// white/gray or a generic gradient fill. Purely procedural (no image
/// assets), so it stays lightweight.
///
/// When [themed] is true, the palette and any festive motif (see
/// core/theme/occasion_themes.dart) follow the shopper's selected occasion
/// instead of the default indigo look — e.g. picking "Wedding" warms the
/// backdrop toward a marigold/toran palette on every themed screen until
/// the occasion changes. [occasionOverride] lets a screen preview a theme
/// before it's committed to [CartProvider] (used by the guided-start
/// wizard's occasion step).
class ScreenBackdrop extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final bool themed;
  final String? occasionOverride;

  const ScreenBackdrop({
    super.key,
    required this.child,
    this.colors,
    this.themed = false,
    this.occasionOverride,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    OccasionTheme? theme;
    if (colors == null && (themed || occasionOverride != null)) {
      final occasionName =
          occasionOverride ?? context.watch<CartProvider>().eventDetails.occasion;
      theme = occasionTheme(occasionName);
    }

    final blobColors = colors ?? theme?.colors ?? const [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
    ];
    final weaveColor = blobColors.first;
    final motifOpacity = c.isDark ? 0.20 : 0.17;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            child: AnimatedBlobs(
              key: ValueKey(blobColors),
              colors: blobColors,
              opacity: c.isDark ? 0.38 : 0.28,
            ),
          ),
        ),
        Positioned.fill(
          child: IkatWeaveBackdrop(
            color: weaveColor,
            opacity: c.isDark ? 0.10 : 0.09,
            spacing: 30,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 130,
          child: OdishaSkylineBackdrop(
            color: weaveColor,
            opacity: c.isDark ? 0.10 : 0.09,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          child: _motifLayer(theme?.motif, weaveColor, motifOpacity),
        ),
        child,
      ],
    );
  }

  Widget _motifLayer(OccasionMotif? motif, Color color, double opacity) {
    switch (motif) {
      case OccasionMotif.toran:
        return Positioned(
          key: const ValueKey('motif-toran'),
          left: 0,
          right: 0,
          top: 0,
          height: 64,
          child: ToranGarlandBackdrop(color: color, opacity: opacity),
        );
      case OccasionMotif.diya:
        return Positioned(
          key: const ValueKey('motif-diya'),
          left: 0,
          right: 0,
          bottom: 0,
          height: 46,
          child: DiyaRowBackdrop(color: color, opacity: opacity),
        );
      case OccasionMotif.bunting:
        return Positioned(
          key: const ValueKey('motif-bunting'),
          left: 0,
          right: 0,
          top: 0,
          height: 40,
          child: BuntingBackdrop(color: color, opacity: opacity),
        );
      case OccasionMotif.none:
      case null:
        return const SizedBox.shrink(key: ValueKey('motif-none'));
    }
  }
}
