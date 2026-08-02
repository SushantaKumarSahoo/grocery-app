import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

class CatalogProvider extends ChangeNotifier {
  final ProductRepository _repo = ProductRepository();

  bool loading = false;
  String? error;
  List<Product> featuredProducts = [];

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
