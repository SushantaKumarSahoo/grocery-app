import 'package:flutter/material.dart';

/// Which procedural motif a themed [ScreenBackdrop] layers on top of the
/// default ikat/skyline texture for a given occasion.
enum OccasionMotif {
  /// Hanging mango-leaf-and-marigold garland (toran/bandhanwar) along the
  /// top edge — the classic Indian doorway decoration for weddings,
  /// receptions and birthdays.
  toran,

  /// Row of lit diya (oil lamps) along the bottom edge — used for temple
  /// festivals.
  diya,

  /// String of triangular pennant flags along the top edge — the bunting
  /// used to dress up Indian corporate events, hostels, hotels,
  /// restaurants and catering setups (less specifically "wedding" than a
  /// toran, but still festive).
  bunting,

  /// No extra motif — just the occasion's color palette.
  none,
}

class OccasionTheme {
  final List<Color> colors;
  final OccasionMotif motif;

  const OccasionTheme({required this.colors, this.motif = OccasionMotif.none});
}

/// Palette + motif per occasion name (matches [Occasion.name] in
/// data/models/category.dart). "Celebrations" occasions get a toran/diya
/// treatment; "Business & Bulk" occasions get a cooler palette with a
/// bunting-flag motif instead — festive but not wedding-specific.
const Map<String, OccasionTheme> _occasionThemes = {
  'Wedding': OccasionTheme(
    colors: [Color(0xFFB3412B), Color(0xFFC98A2C), Color(0xFF7A2748)],
    motif: OccasionMotif.toran,
  ),
  'Reception': OccasionTheme(
    colors: [Color(0xFF7A2748), Color(0xFFC98A2C), Color(0xFFB3412B)],
    motif: OccasionMotif.toran,
  ),
  'Birthday': OccasionTheme(
    colors: [Color(0xFFC98A2C), Color(0xFF2B3A67), Color(0xFFC1502E)],
    motif: OccasionMotif.toran,
  ),
  'Temple Festival': OccasionTheme(
    colors: [Color(0xFFC98A2C), Color(0xFFB3412B), Color(0xFF2B3A67)],
    motif: OccasionMotif.diya,
  ),
  'Corporate Event': OccasionTheme(
    colors: [Color(0xFF0E6E77), Color(0xFF2B3A67), Color(0xFF1B2547)],
    motif: OccasionMotif.bunting,
  ),
  'Hostel': OccasionTheme(
    colors: [Color(0xFF2B3A67), Color(0xFF0E6E77), Color(0xFFC98A2C)],
    motif: OccasionMotif.bunting,
  ),
  'Hotel': OccasionTheme(
    colors: [Color(0xFF5B3B6B), Color(0xFFC98A2C), Color(0xFF2B3A67)],
    motif: OccasionMotif.bunting,
  ),
  'Restaurant': OccasionTheme(
    colors: [Color(0xFFC1502E), Color(0xFFE0954A), Color(0xFF9C6B1F)],
    motif: OccasionMotif.bunting,
  ),
  'Catering': OccasionTheme(
    colors: [Color(0xFFC98A2C), Color(0xFFC1502E), Color(0xFF5B3B6B)],
    motif: OccasionMotif.bunting,
  ),
};

/// Looks up the theme for [occasionName], or null for an empty/unrecognized
/// occasion — callers fall back to the default backdrop in that case.
OccasionTheme? occasionTheme(String? occasionName) {
  if (occasionName == null || occasionName.isEmpty) return null;
  return _occasionThemes[occasionName];
}
