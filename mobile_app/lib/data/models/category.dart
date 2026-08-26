import 'package:flutter/material.dart';

class ProductCategory {
  final String name;
  final int productCount;

  const ProductCategory({required this.name, this.productCount = 0});

  IconData get icon => categoryIcon(name);

  /// Null for shop-tagged categories outside the fixed taxonomy below —
  /// callers fall back to [icon] when there's no photo.
  String? get imageUrl => categoryImageUrl(name);
}

/// Representative photo per fixed category (Pexels, free-to-use). Only
/// covers [staticCategories] — free-text shop categories fall back to an
/// icon since there's no photo to look up for those.
const Map<String, String> _categoryImages = {
  'Rice':
      'https://images.pexels.com/photos/1311771/pexels-photo-1311771.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Dal':
      'https://images.pexels.com/photos/12737916/pexels-photo-12737916.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Salt':
      'https://images.pexels.com/photos/8991461/pexels-photo-8991461.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Sugar':
      'https://images.pexels.com/photos/19243767/pexels-photo-19243767.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Dairy Grocery Items':
      'https://images.pexels.com/photos/4324320/pexels-photo-4324320.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Spices/Masala items':
      'https://images.pexels.com/photos/10126645/pexels-photo-10126645.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Flours':
      'https://images.pexels.com/photos/6287581/pexels-photo-6287581.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Oil':
      'https://images.pexels.com/photos/7953254/pexels-photo-7953254.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Dry fruits':
      'https://images.pexels.com/photos/9811639/pexels-photo-9811639.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Sweetener':
      'https://images.pexels.com/photos/19243767/pexels-photo-19243767.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Sauces':
      'https://images.pexels.com/photos/6605175/pexels-photo-6605175.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Papad':
      'https://images.pexels.com/photos/12737803/pexels-photo-12737803.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Plates & glasses':
      'https://images.pexels.com/photos/2019859/pexels-photo-2019859.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Other individual items':
      'https://images.pexels.com/photos/264636/pexels-photo-264636.jpeg?auto=compress&cs=tinysrgb&w=400',
};

String? categoryImageUrl(String name) => _categoryImages[name];

/// Best-effort icon lookup for a free-text category name coming from the
/// shop owner's product catalog (categories are shop-scoped free text,
/// not a fixed taxonomy — see admin-panels products.category_name).
IconData categoryIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('rice')) return Icons.rice_bowl_rounded;
  if (n.contains('dal') || n.contains('pulse') || n.contains('lentil')) {
    return Icons.grain_rounded;
  }
  if (n.contains('salt')) return Icons.science_rounded;
  if (n.contains('flour') || n.contains('atta')) return Icons.bakery_dining_rounded;
  if (n.contains('oil') || n.contains('ghee')) return Icons.opacity_rounded;
  if (n.contains('dairy') || n.contains('milk') || n.contains('paneer')) {
    return Icons.icecream_rounded;
  }
  if (n.contains('sugar') || n.contains('jaggery') || n.contains('sweet')) return Icons.cookie_rounded;
  if (n.contains('spice') || n.contains('masala')) {
    return Icons.local_fire_department_rounded;
  }
  if (n.contains('dry fruit') || n.contains('nut')) return Icons.scatter_plot_rounded;
  if (n.contains('sauce') || n.contains('ketchup')) return Icons.water_drop_rounded;
  if (n.contains('papad')) return Icons.pie_chart_rounded;
  if (n.contains('plate') || n.contains('glass') || n.contains('dispos')) return Icons.inventory_2_rounded;
  return Icons.category_rounded;
}

/// Fixed catalog taxonomy shown in the UI at all times. Shop owners tag
/// their products with a free-text category_name (see admin-panels
/// products.category_name) — when it matches one of these names the
/// products show up under that tile; the tile itself is always visible
/// even before any shop has stocked that category yet.
const List<ProductCategory> staticCategories = [
  ProductCategory(name: 'Rice'),
  ProductCategory(name: 'Dal'),
  ProductCategory(name: 'Salt'),
  ProductCategory(name: 'Sugar'),
  ProductCategory(name: 'Dairy Grocery Items'),
  ProductCategory(name: 'Spices/Masala items'),
  ProductCategory(name: 'Flours'),
  ProductCategory(name: 'Oil'),
  ProductCategory(name: 'Dry fruits'),
  ProductCategory(name: 'Sweetener'),
  ProductCategory(name: 'Sauces'),
  ProductCategory(name: 'Papad'),
  ProductCategory(name: 'Plates & glasses'),
  ProductCategory(name: 'Other individual items'),
];

class Occasion {
  final String id;
  final String name;
  final IconData icon;

  const Occasion({
    required this.id,
    required this.name,
    required this.icon,
  });
}

/// Fixed occasion taxonomy used to tag bulk orders (orders.occasion is a
/// free-text column, this is just the picker shown in the UI).
const List<Occasion> occasions = [
  Occasion(id: 'wedding', name: 'Wedding', icon: Icons.favorite_rounded),
  Occasion(id: 'birthday', name: 'Birthday', icon: Icons.cake_rounded),
  Occasion(id: 'reception', name: 'Reception', icon: Icons.celebration_rounded),
  Occasion(id: 'temple', name: 'Temple Festival', icon: Icons.temple_hindu_rounded),
  Occasion(id: 'corporate', name: 'Corporate Event', icon: Icons.business_center_rounded),
  Occasion(id: 'hostel', name: 'Hostel', icon: Icons.apartment_rounded),
  Occasion(id: 'hotel', name: 'Hotel', icon: Icons.hotel_rounded),
  Occasion(id: 'restaurant', name: 'Restaurant', icon: Icons.restaurant_rounded),
  Occasion(id: 'catering', name: 'Catering', icon: Icons.soup_kitchen_rounded),
];

/// Occasions grouped as "Celebrations" for the homepage toggle AND as
/// "event" orders for payment-method purposes (advance-online is only
/// offered for these; everything else is treated as a "business" order —
/// cheque/cash on delivery only). Matched by occasion id.
///
/// Mirrored server-side in supabase/functions/_shared/occasions.ts (there
/// is no shared package between the Deno Edge Functions and this Flutter
/// app) — that copy matches by occasion *name* lowercased, since
/// `orders.occasion` stores the name (e.g. "Wedding"), not the id. Keep
/// both in sync if this set ever changes.
const celebrationOccasionIds = {'wedding', 'birthday', 'reception'};

bool isEventOccasionName(String occasion) {
  final normalized = occasion.trim().toLowerCase();
  return occasions.any(
    (o) => celebrationOccasionIds.contains(o.id) && o.name.toLowerCase() == normalized,
  );
}
