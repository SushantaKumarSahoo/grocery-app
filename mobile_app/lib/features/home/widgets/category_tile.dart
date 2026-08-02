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
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.isDark
                  ? AppColors.secondary.withValues(alpha: 0.22)
                  : AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(category.icon,
                color: colors.isDark ? const Color(0xFF93C5FD) : AppColors.secondary,
                size: 20),
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
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
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
