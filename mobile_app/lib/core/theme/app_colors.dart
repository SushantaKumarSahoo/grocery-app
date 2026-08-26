import 'package:flutter/material.dart';

/// "Sambalpuri Ikat" palette — indigo warp threads, rust-orange weft,
/// antique gold accents, warm handloom-cream surfaces. Inspired by the
/// tie-dye geometry of Odisha's Sambalpuri weave rather than a generic
/// green-grocer template.
class AppColors {
  AppColors._();

  // Indigo — the warp thread. Primary brand color.
  static const Color primary = Color(0xFF2B3A67);
  static const Color primaryDark = Color(0xFF1B2547);
  static const Color primaryLight = Color(0xFFE4E7F3);

  // Rust / terracotta — the weft thread. Secondary.
  static const Color secondary = Color(0xFFC1502E);
  static const Color secondaryLight = Color(0xFFF6E1D6);

  // Antique gold — thread highlight. Accent.
  static const Color accent = Color(0xFFC98A2C);
  static const Color accentLight = Color(0xFFF6E9CE);

  // Handloom cream surfaces.
  static const Color background = Color(0xFFF8F4EC);
  static const Color card = Color(0xFFFFFDF8);

  static const Color success = Color(0xFF3F7A4E);
  static const Color warning = Color(0xFFC98A2C);
  static const Color error = Color(0xFFB3412B);
  static const Color info = Color(0xFF2B3A67);

  static const Color textPrimary = Color(0xFF241F1B);
  static const Color textSecondary = Color(0xFF6E655B);
  static const Color textMuted = Color(0xFFA79C8C);
  static const Color border = Color(0xFFE8DFCD);

  // Dark mode — deep indigo night instead of default slate.
  static const Color backgroundDark = Color(0xFF12162A);
  static const Color cardDark = Color(0xFF1C2140);
  static const Color borderDark = Color(0xFF2E3559);
  static const Color textPrimaryDark = Color(0xFFF3EEE2);
  static const Color textSecondaryDark = Color(0xFFB3ADC7);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Signature "dip-dye" gradient — indigo bleeding through plum into rust,
  // mimicking the blurred resist-dye transitions of an ikat weave. Used for
  // hero/decorative surfaces so they read as a brand moment, not a flat fill.
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF23305C), Color(0xFF5C3A63), Color(0xFFC1502E)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFEACB7C), Color(0xFFC98A2C), Color(0xFF9C6B1F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Plum-to-rust accent thread — pairs with heroGradient for special /
  // decorative moments (splash rings, occasion tiles, badges).
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFF5B3B6B), Color(0xFFA6473F), Color(0xFFC98A2C)],
    stops: [0.0, 0.6, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFC1502E), Color(0xFFE0954A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // "Mahanadi" river gradient — teal-indigo, used where the palette needs a
  // cooler beat (e.g. an onboarding page) without reaching for blue.
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0E6E77), Color(0xFF2B3A67)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
