import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../theme/app_colors.dart';
import '../theme/theme_ext.dart';
import 'app_card.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool useHero;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.useHero = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final image = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: AspectRatio(
        aspectRatio: 1.3,
        child: product.imageUrl.isEmpty
            ? Container(
                color: AppColors.primaryLight,
                child: const Icon(Icons.inventory_2_rounded,
                    color: AppColors.primary),
              )
            : Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                // Decode at display size, not source size — an
                // un-downsampled multi-megapixel upload decoded per grid
                // tile is a common cause of scroll jank/OOM on low-end
                // devices.
                cacheWidth: (280 * MediaQuery.of(context).devicePixelRatio).round(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: colors.border);
                },
                errorBuilder: (context, error, stack) => Container(
                  color: AppColors.primaryLight,
                  child: const Icon(Icons.image_not_supported_rounded,
                      color: AppColors.primary),
                ),
              ),
      ),
    );

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          useHero
              ? Hero(tag: 'product-image-${product.id}', child: image)
              : image,
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MOQ ${product.minOrderQty.toStringAsFixed(0)} ${product.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.5,
                            ),
                          ),
                          TextSpan(
                            text: '/${product.unit}',
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
