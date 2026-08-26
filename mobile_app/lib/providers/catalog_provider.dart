import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

class CatalogProvider extends ChangeNotifier {
  final ProductRepository _repo = ProductRepository();

  bool loading = false;
  String? error;
  List<Product> featuredProducts = [];

  /// Products per home-shortcut category, for the swipeable category deck.
  /// Keyed by category name (matches [ProductCategory.name]).
  Map<String, List<Product>> categoryPreviews = {};
  bool categoryPreviewsLoading = false;

  Future<void> loadHome() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      featuredProducts = await _repo.fetchFeaturedProducts(limit: 10);
    } catch (e) {
      error = 'Could not load the catalog. Pull down to retry.';
    }
    loading = false;
    notifyListeners();
  }

  /// Fetches products for each of [categoryNames] in parallel so the home
  /// category deck can show a preview inside every card without a round
  /// trip per swipe.
  Future<void> loadCategoryPreviews(List<String> categoryNames) async {
    categoryPreviewsLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait(
        categoryNames.map((name) => _repo.fetchProducts(categoryName: name)),
      );
      categoryPreviews = {
        for (var i = 0; i < categoryNames.length; i++)
          categoryNames[i]: results[i],
      };
    } catch (_) {
      // Leave whatever was already cached — each card falls back to its
      // own empty state rather than blocking the whole deck on one error.
    }
    categoryPreviewsLoading = false;
    notifyListeners();
  }

  Future<List<Product>> productsForCategory(String categoryName) {
    return _repo.fetchProducts(categoryName: categoryName);
  }

  Future<List<Product>> search(String query) {
    return _repo.searchProducts(query);
  }

  Future<Product?> productById(String id) {
    return _repo.fetchProductById(id);
  }
}
