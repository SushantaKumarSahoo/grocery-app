import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_ext.dart';

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });
}

/// A pill-shaped bottom nav bar that floats above the content by default and
/// smoothly docks into a full-width bar flush with the screen edge while the
/// active page is scrolled down, undocking again once scrolling stops or
/// reverses.
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItemData> items;
  final bool docked;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.docked = false,
  });

  static const _animDuration = Duration(milliseconds: 320);
  static const _animCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      bottom: !docked,
      child: AnimatedPadding(
        duration: _animDuration,
        curve: _animCurve,
        padding: docked
            ? EdgeInsets.zero
            : const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: AnimatedContainer(
          duration: _animDuration,
          curve: _animCurve,
          height: docked ? 62 : 68,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: docked
                ? BorderRadius.zero
                : BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colors.isDark
                    ? Colors.transparent
                    : Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slotWidth = constraints.maxWidth / items.length;
              final pillSize = docked ? 46.0 : 52.0;
              // Side length of the (unrotated) square so that once rotated
              // 45° into a diamond, its footprint roughly matches pillSize.
              final diamondSize = pillSize * 0.72;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedPositioned(
                    duration: _animDuration,
                    curve: _animCurve,
                    left: slotWidth * currentIndex + (slotWidth - diamondSize) / 2,
                    top: (constraints.maxHeight - diamondSize) / 2,
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: AnimatedContainer(
                        duration: _animDuration,
                        curve: _animCurve,
                        width: diamondSize,
                        height: diamondSize,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(docked ? 10 : 12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(items.length, (i) {
                      final selected = i == currentIndex;
                      final item = items[i];
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onTap(i),
                          child: SizedBox(
                            height: docked ? 62 : 68,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  selected ? item.activeIcon : item.icon,
                                  color: selected ? Colors.white : colors.textMuted,
                                  size: docked ? 22 : 24,
                                ),
                                if (item.badgeCount > 0)
                                  Positioned(
                                    top: 6,
                                    right: (constraints.maxWidth / items.length) / 2 - 20,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${item.badgeCount}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
