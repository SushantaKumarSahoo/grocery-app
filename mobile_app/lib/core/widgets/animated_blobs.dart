import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Soft, slowly-drifting translucent blobs used behind hero surfaces
/// (splash screen, home banner) for a premium, "alive" background instead
/// of a flat gradient fill.
class AnimatedBlobs extends StatefulWidget {
  final List<Color> colors;
  final double opacity;

  const AnimatedBlobs({
    super.key,
    required this.colors,
    this.opacity = 0.22,
  });

  @override
  State<AnimatedBlobs> createState() => _AnimatedBlobsState();
}

class _AnimatedBlobsState extends State<AnimatedBlobs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _BlobPainter(
              t: _controller.value,
              colors: widget.colors,
              opacity: widget.opacity,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  final double opacity;

  _BlobPainter({required this.t, required this.colors, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final blobs = [
      (dx: 0.10, dy: 0.10, r: 0.75, speed: 1.0, colorIndex: 0),
      (dx: 0.90, dy: 0.08, r: 0.62, speed: -0.7, colorIndex: 1 % colors.length),
      (dx: 0.85, dy: 0.55, r: 0.68, speed: 0.6, colorIndex: 2 % colors.length),
      (dx: 0.12, dy: 0.55, r: 0.6, speed: -0.9, colorIndex: 1 % colors.length),
      (dx: 0.5, dy: 0.92, r: 0.7, speed: 0.5, colorIndex: 0),
      (dx: 0.55, dy: 0.3, r: 0.5, speed: -0.5, colorIndex: 2 % colors.length),
    ];

    for (final b in blobs) {
      final angle = t * 2 * math.pi * b.speed;
      final dx = b.dx * size.width + math.cos(angle) * size.width * 0.08;
      final dy = b.dy * size.height + math.sin(angle) * size.height * 0.08;
      final radius = b.r * size.shortestSide;
      final color = colors[b.colorIndex];

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.55),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) => oldDelegate.t != t;
}
