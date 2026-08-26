import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../data/models/product.dart';
import '../../providers/catalog_provider.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  const CategoryProductsScreen({super.key, required this.categoryId});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late Future<List<Product>> _future;
  final _searchController = TextEditingController();
  String _query = '';

  String get _categoryName => widget.categoryId;

  @override
  void initState() {
    super.initState();
    _future = context.read<CatalogProvider>().productsForCategory(
      _categoryName,
    );
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = context.read<CatalogProvider>().productsForCategory(
        _categoryName,
      );
    });
  }

  List<Product> _filter(List<Product> products) {
    if (_query.isEmpty) return products;
    return products
        .where((p) => p.name.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: Text(_categoryName)),
      body: ScreenBackdrop(
        themed: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15.5),
                  decoration: InputDecoration(
                    hintText: 'Search in $_categoryName',
                    hintStyle: TextStyle(
                      color: colors.textMuted,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colors.textMuted,
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: colors.textMuted,
                            ),
                            onPressed: () => _searchController.clear(),
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (snapshot.hasError) {
                    return EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Something went wrong',
                      message: 'Could not load products in this category.',
                      action: OutlinedButton(
                        onPressed: _reload,
                        child: const Text('Retry'),
                      ),
                    );
                  }
                  final products = snapshot.data ?? [];
                  if (products.isEmpty) {
                    return const EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No products yet',
                      message: 'We are adding products to this category soon.',
                    );
                  }
                  final filtered = _filter(products);
                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matches',
                      message: 'No products match "${_searchController.text}".',
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, i) {
                      final p = filtered[i];
                      return ProductCard(
                            product: p,
                            onTap: () => context.push('/product/${p.id}', extra: p),
                          )
                          .animate()
                          .fadeIn(delay: (40 * i).ms, duration: 300.ms)
                          .slideY(
                            begin: 0.08,
                            end: 0,
                            delay: (40 * i).ms,
                            duration: 300.ms,
                          );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
