import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/theme_ext.dart';
import 'tappable.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final List<BoxShadow>? shadow;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.shadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: shadow ??
            [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
        border: border ?? Border.all(color: colors.border, width: colors.isDark ? 1 : 0),
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Tappable(onTap: onTap, pressedScale: 0.97, child: card);
  }
}
