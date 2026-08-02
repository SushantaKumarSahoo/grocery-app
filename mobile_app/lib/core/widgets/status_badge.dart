import 'package:flutter/material.dart';
import '../../data/models/order.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.textSecondary;
      case OrderStatus.quotationSent:
        return AppColors.secondary;
      case OrderStatus.accepted:
        return AppColors.primary;
      case OrderStatus.preparing:
        return AppColors.accent;
      case OrderStatus.ready:
        return const Color(0xFF0EA5E9);
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
      ),
    );
  }
}
