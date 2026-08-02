import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QtyStepper extends StatelessWidget {
  final double value;
  final double step;
  final double min;
  final ValueChanged<double> onChanged;

  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.min = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(Icons.remove_rounded, () {
            final next = value - step;
            onChanged(next < min ? min : next);
          }),
          Container(
            constraints: const BoxConstraints(minWidth: 44),
            alignment: Alignment.center,
            child: Text(
              value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
                fontSize: 15,
              ),
            ),
          ),
          _button(Icons.add_rounded, () => onChanged(value + step)),
        ],
      ),
    );
  }

  Widget _button(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 18, color: AppColors.primaryDark),
      ),
    );
  }
}
