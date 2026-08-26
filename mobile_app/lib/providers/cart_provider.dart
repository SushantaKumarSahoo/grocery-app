import 'package:flutter/material.dart';
import '../data/models/cart_item.dart';
import '../data/models/product.dart';
import '../data/models/event_details.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  EventDetails eventDetails = EventDetails();

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  double get subtotal => _items.fold(0, (sum, i) => sum + i.subtotal);

  /// Sets the shopping occasion and notifies listeners — used instead of
  /// mutating `eventDetails.occasion` directly so themed screens (see
  /// ScreenBackdrop's `themed` flag) pick up the change immediately even
  /// if they were already on screen when it was picked.
  void setOccasion(String occasionName) {
    eventDetails.occasion = occasionName;
    notifyListeners();
  }

  void addItem(Product product, double quantity, {String? packaging, String? notes}) {
    final existingIndex = _items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity = quantity;
      _items[existingIndex].packaging = packaging;
      _items[existingIndex].notes = notes;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        packaging: packaging,
        notes: notes,
      ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, double quantity) {
    final item = _items.firstWhere((i) => i.product.id == productId);
    item.quantity = quantity;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    eventDetails = EventDetails();
    notifyListeners();
  }
}
