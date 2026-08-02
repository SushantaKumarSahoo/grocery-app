import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/widgets/tappable.dart';
import '../../../data/models/category.dart';

const List<LinearGradient> _occasionGradients = [
  AppColors.primaryGradient,
  AppColors.oceanGradient,
  AppColors.sunsetGradient,
  AppColors.auroraGradient,
];

class OccasionCard extends StatelessWidget {
  final Occasion occasion;
  final int index;
  final bool selected;
  final VoidCallback? onTap;

  const OccasionCard({
    super.key,
    required this.occasion,
    this.index = 0,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradient = _occasionGradients[index % _occasionGradients.length];
    final glowColor = gradient.colors.first;

    return Tappable(
      onTap: onTap,
      pressedScale: 0.92,
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.glow(glowColor),
                border: selected ? Border.all(color: Colors.white, width: 2.5) : null,
              ),
              child: Icon(occasion.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                occasion.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppColors.primary : colors.textPrimary,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
