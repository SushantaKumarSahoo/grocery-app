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

  String get _categoryName => widget.categoryId;

  @override
  void initState() {
    super.initState();
    _future = context.read<CatalogProvider>().productsForCategory(
      _categoryName,
    );
  }

  void _reload() {
    setState(() {
      _future = context.read<CatalogProvider>().productsForCategory(
        _categoryName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: Text(_categoryName)),
      body: ScreenBackdrop(
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
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, i) {
                final p = products[i];
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
    );
  }
}
