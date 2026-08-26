import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Direct numeric entry for bulk order quantities — typing a value beats
/// tapping +/- one unit at a time when orders run into the hundreds/kgs.
class QtyStepper extends StatefulWidget {
  final double value;
  final double min;
  final ValueChanged<double> onChanged;

  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
  });

  @override
  State<QtyStepper> createState() => _QtyStepperState();
}

class _QtyStepperState extends State<QtyStepper> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  String _format(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(covariant QtyStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commit() {
    final parsed = double.tryParse(_controller.text.trim());
    final next = parsed == null || parsed < widget.min ? widget.min : parsed;
    _controller.text = _format(next);
    if (next != widget.value) widget.onChanged(next);
  }

  void _onTyped(String text) {
    final parsed = double.tryParse(text.trim());
    if (parsed != null && parsed != widget.value) widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(minWidth: 76),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
          fontSize: 15,
        ),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        onChanged: _onTyped,
        onSubmitted: (_) => _commit(),
        ),
      ),
    );
  }
}
