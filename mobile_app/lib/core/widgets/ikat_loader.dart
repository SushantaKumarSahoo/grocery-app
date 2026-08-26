import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A comet of shrinking diamonds sweeping around a ring — the loading
/// indicator's shape echoes the app's diamond-weave motif instead of a
/// stock circular spinner.
class IkatLoader extends StatefulWidget {
  final double size;
  final Color color;
  final int dotCount;

  const IkatLoader({
    super.key,
    this.size = 40,
    this.color = Colors.white,
    this.dotCount = 7,
  });

  @override
  State<IkatLoader> createState() => _IkatLoaderState();
}

class _IkatLoaderState extends State<IkatLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: _IkatLoaderPainter(
          t: _controller.value,
          color: widget.color,
          dotCount: widget.dotCount,
        ),
      ),
    );
  }
}

class _IkatLoaderPainter extends CustomPainter {
  final double t;
  final Color color;
  final int dotCount;

  _IkatLoaderPainter({required this.t, required this.color, required this.dotCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    final baseAngle = t * 2 * math.pi;
    const spacing = 0.42;

    for (int i = 0; i < dotCount; i++) {
      final angle = baseAngle - i * spacing;
      final progress = 1 - (i / dotCount);
      final half = 1.6 + 2.8 * progress;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      final paint = Paint()..color = color.withValues(alpha: progress * progress);

      final path = Path()
        ..moveTo(dx, dy - half)
        ..lineTo(dx + half, dy)
        ..lineTo(dx, dy + half)
        ..lineTo(dx - half, dy)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IkatLoaderPainter oldDelegate) => oldDelegate.t != t;
}
