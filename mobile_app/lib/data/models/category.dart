import 'package:flutter/material.dart';

class ProductCategory {
  final String name;
  final int productCount;

  const ProductCategory({required this.name, this.productCount = 0});

  IconData get icon => categoryIcon(name);
}

/// Best-effort icon lookup for a free-text category name coming from the
/// shop owner's product catalog (categories are shop-scoped free text,
/// not a fixed taxonomy — see admin-panels products.category_name).
IconData categoryIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('rice')) return Icons.rice_bowl_rounded;
  if (n.contains('dal') || n.contains('pulse') || n.contains('lentil')) {
    return Icons.grain_rounded;
  }
  if (n.contains('flour') || n.contains('atta')) return Icons.bakery_dining_rounded;
  if (n.contains('oil') || n.contains('ghee')) return Icons.opacity_rounded;
  if (n.contains('veg')) return Icons.eco_rounded;
  if (n.contains('fruit')) return Icons.apple_rounded;
  if (n.contains('dairy') || n.contains('milk') || n.contains('paneer')) {
    return Icons.icecream_rounded;
  }
  if (n.contains('sugar') || n.contains('jaggery')) return Icons.cookie_rounded;
  if (n.contains('spice') || n.contains('masala')) {
    return Icons.local_fire_department_rounded;
  }
  if (n.contains('dry fruit') || n.contains('nut')) return Icons.scatter_plot_rounded;
  if (n.contains('dispos')) return Icons.inventory_2_rounded;
  if (n.contains('water')) return Icons.water_drop_rounded;
  if (n.contains('beverage') || n.contains('drink') || n.contains('juice')) {
    return Icons.local_cafe_rounded;
  }
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
  ProductCategory(name: 'Flour'),
  ProductCategory(name: 'Oil'),
  ProductCategory(name: 'Vegetables'),
  ProductCategory(name: 'Fruits'),
  ProductCategory(name: 'Dairy'),
  ProductCategory(name: 'Sugar'),
  ProductCategory(name: 'Spices'),
  ProductCategory(name: 'Dry Fruits'),
  ProductCategory(name: 'Disposable Items'),
  ProductCategory(name: 'Water Bottles'),
  ProductCategory(name: 'Beverages'),
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
