import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/widgets/tappable.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import '../../../providers/locale_provider.dart';

/// How many products from each category's preview list get a tile inside
/// the card — the rest are only reachable via the "View all" button, per
/// the home screen's "don't dump everything on one page" rule.
const _kPreviewTileCount = 3;

/// Swipeable deck of category cards for the homepage: one category (with a
/// peek of its products) per page, instead of a separate categories row and
/// a separate products row. Swiping horizontally moves to the next
/// category; each card links out to the full category listing rather than
/// showing every product inline.
class CategoryShowcaseDeck extends StatefulWidget {
  final List<ProductCategory> categories;
  final Map<String, List<Product>> previews;
  final bool loading;
  final AppLanguage lang;
  final ValueChanged<ProductCategory> onSeeAll;
  final ValueChanged<Product> onProductTap;

  const CategoryShowcaseDeck({
    super.key,
    required this.categories,
    required this.previews,
    required this.loading,
    required this.lang,
    required this.onSeeAll,
    required this.onProductTap,
  });

  @override
  State<CategoryShowcaseDeck> createState() => _CategoryShowcaseDeckState();
}

class _CategoryShowcaseDeckState extends State<CategoryShowcaseDeck> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.87);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _currentPage() {
    if (_controller.hasClients && _controller.position.haveDimensions) {
      return _controller.page ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 336,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.categories.length,
            itemBuilder: (context, i) {
              final category = widget.categories[i];
              final products = widget.previews[category.name];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final delta = (_currentPage() - i).clamp(-1.0, 1.0).abs();
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Transform.scale(
                      scale: 1 - (delta * 0.08),
                      child: Opacity(
                        opacity: 1 - (delta * 0.45),
                        child: child,
                      ),
                    ),
                  );
                },
                child: _CategoryDeckCard(
                  category: category,
                  products: products,
                  loading: widget.loading && products == null,
                  lang: widget.lang,
                  onSeeAll: () => widget.onSeeAll(category),
                  onProductTap: widget.onProductTap,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final active = _currentPage().round();
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.categories.length, (i) {
                final isActive = i == active;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : colors.border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryDeckCard extends StatelessWidget {
  final ProductCategory category;
  final List<Product>? products;
  final bool loading;
  final AppLanguage lang;
  final VoidCallback onSeeAll;
  final ValueChanged<Product> onProductTap;

  const _CategoryDeckCard({
    required this.category,
    required this.products,
    required this.loading,
    required this.lang,
    required this.onSeeAll,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final imageUrl = category.imageUrl;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border, width: colors.isDark ? 1 : 0),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 50,
                  height: 50,
                  color: colors.isDark
                      ? AppColors.secondary.withValues(alpha: 0.22)
                      : AppColors.secondaryLight,
                  child: imageUrl == null
                      ? Icon(category.icon, color: AppColors.secondary, size: 24)
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          cacheWidth:
                              (50 * MediaQuery.of(context).devicePixelRatio).round(),
                          errorBuilder: (context, error, stack) =>
                              Icon(category.icon, color: AppColors.secondary, size: 24),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.display(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      products == null
                          ? ' '
                          : '${products!.length} ${products!.length == 1 ? 'product' : 'products'}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => _buildBody(colors, constraints.maxWidth),
            ),
          ),
          const SizedBox(height: 14),
          Tappable(
            onTap: onSeeAll,
            pressedScale: 0.97,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${t(lang, 'view_all')} · ${category.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tiles always reserve a fixed 3-column width (regardless of how many
  // preview products actually exist) so a category with only 1-2 products
  // doesn't stretch a single tile's square image across the whole card —
  // that's what caused the RenderFlex overflow when Expanded was used here.
  double _tileWidth(double maxWidth) {
    const gaps = (_kPreviewTileCount - 1) * 10;
    return (maxWidth - gaps) / _kPreviewTileCount;
  }

  Widget _buildBody(SemanticColors colors, double maxWidth) {
    final tileWidth = _tileWidth(maxWidth);

    if (loading) {
      return Shimmer.fromColors(
        baseColor: colors.border,
        highlightColor: colors.bg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_kPreviewTileCount, (i) {
            return Padding(
              padding: EdgeInsets.only(right: i == _kPreviewTileCount - 1 ? 0 : 10),
              child: SizedBox(
                width: tileWidth,
                height: tileWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }

    final items = products;
    if (items == null || items.isEmpty) {
      return Center(
        child: Text(
          t(lang, 'no_products_yet'),
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
      );
    }

    final preview = items.take(_kPreviewTileCount).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < preview.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          SizedBox(
            width: tileWidth,
            child: _MiniProductTile(
              product: preview[i],
              onTap: () => onProductTap(preview[i]),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact product tile for inside a category deck card — image, name and
/// price only, sized to sit three-across without any nested scrolling
/// (which would fight the deck's own horizontal swipe gesture).
class _MiniProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _MiniProductTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tappable(
      onTap: onTap,
      pressedScale: 0.96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: product.imageUrl.isEmpty
                  ? Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 20),
                    )
                  : Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      cacheWidth: (120 * MediaQuery.of(context).devicePixelRatio).round(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(color: colors.border);
                      },
                      errorBuilder: (context, error, stack) => Container(
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.image_not_supported_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹${product.price.toStringAsFixed(0)}/${product.unit}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
