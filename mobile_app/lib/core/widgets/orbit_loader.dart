import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A lightweight, custom-painted loading indicator: a small comet of dots
/// sweeping around a ring, instead of the stock CircularProgressIndicator.
class OrbitLoader extends StatefulWidget {
  final double size;
  final Color color;
  final int dotCount;

  const OrbitLoader({
    super.key,
    this.size = 40,
    this.color = Colors.white,
    this.dotCount = 7,
  });

  @override
  State<OrbitLoader> createState() => _OrbitLoaderState();
}

class _OrbitLoaderState extends State<OrbitLoader>
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
        painter: _OrbitPainter(
          t: _controller.value,
          color: widget.color,
          dotCount: widget.dotCount,
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double t;
  final Color color;
  final int dotCount;

  _OrbitPainter({required this.t, required this.color, required this.dotCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 3;
    final baseAngle = t * 2 * math.pi;
    const spacing = 0.42;

    for (int i = 0; i < dotCount; i++) {
      final angle = baseAngle - i * spacing;
      final progress = 1 - (i / dotCount);
      final dotRadius = 1.4 + 2.6 * progress;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      final paint = Paint()
        ..color = color.withValues(alpha: progress * progress);
      canvas.drawCircle(Offset(dx, dy), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => oldDelegate.t != t;
}
