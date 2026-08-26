import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic, theme-aware colors. Use `context.colors.xxx` anywhere a widget
/// needs to look right in both light and dark mode instead of reaching for
/// the raw AppColors constants (which are light-mode values only).
class SemanticColors {
  final bool isDark;
  const SemanticColors(this.isDark);

  Color get bg => isDark ? AppColors.backgroundDark : AppColors.background;
  Color get card => isDark ? AppColors.cardDark : AppColors.card;
  Color get cardAlt =>
      isDark ? const Color(0xFF262C4E) : const Color(0xFFF1E9D8);
  Color get border => isDark ? AppColors.borderDark : AppColors.border;
  Color get textPrimary =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color get textSecondary =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color get textMuted =>
      isDark ? const Color(0xFF8B84A0) : AppColors.textMuted;
  Color get shadow => isDark
      ? Colors.black.withValues(alpha: 0.35)
      : Colors.black.withValues(alpha: 0.05);
}

extension ThemeColorsX on BuildContext {
  SemanticColors get colors =>
      SemanticColors(Theme.of(this).brightness == Brightness.dark);
}
