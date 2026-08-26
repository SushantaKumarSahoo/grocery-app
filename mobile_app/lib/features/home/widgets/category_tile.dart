import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/category.dart';

class CategoryTile extends StatelessWidget {
  final ProductCategory category;
  final VoidCallback? onTap;

  const CategoryTile({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final imageUrl = category.imageUrl;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 46,
              height: 46,
              color: colors.isDark
                  ? AppColors.secondary.withValues(alpha: 0.22)
                  : AppColors.secondaryLight,
              child: imageUrl == null
                  ? Icon(category.icon,
                      color: colors.isDark
                          ? const Color(0xFF93C5FD)
                          : AppColors.secondary,
                      size: 22)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      cacheWidth:
                          (46 * MediaQuery.of(context).devicePixelRatio)
                              .round(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox.shrink();
                      },
                      errorBuilder: (context, error, stack) => Icon(
                        category.icon,
                        color: colors.isDark
                            ? const Color(0xFF93C5FD)
                            : AppColors.secondary,
                        size: 22,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
