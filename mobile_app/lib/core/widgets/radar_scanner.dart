import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A sonar-style radar animation — pulsing rings plus a rotating sweep
/// wedge — used behind a status icon while we're actively looking for
/// something (e.g. checking delivery availability for the user's area).
///
/// When [scanning] is false the rings/sweep fade out and [child] is left
/// sitting on a plain static backdrop, signalling "search finished".
class RadarScanner extends StatefulWidget {
  final Widget child;
  final Color color;
  final bool scanning;
  final double size;

  const RadarScanner({
    super.key,
    required this.child,
    required this.color,
    this.scanning = true,
    this.size = 168,
  });

  @override
  State<RadarScanner> createState() => _RadarScannerState();
}

class _RadarScannerState extends State<RadarScanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    if (widget.scanning) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant RadarScanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scanning == oldWidget.scanning) return;
    if (widget.scanning) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: widget.scanning ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  size: Size.square(widget.size),
                  painter: _RadarPainter(
                    t: _controller.value,
                    color: widget.color,
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double t;
  final Color color;

  const _RadarPainter({required this.t, required this.color});

  static const _pingPhases = [0.0, 0.34, 0.67];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final innerRadius = maxRadius * 0.42;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(t * 2 * math.pi);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi / 2.2,
        colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.28)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: maxRadius));
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: maxRadius),
      0,
      math.pi / 2.2,
      true,
      sweepPaint,
    );
    canvas.restore();

    for (final phase in _pingPhases) {
      final localT = (t + phase) % 1.0;
      final radius = innerRadius + (maxRadius - innerRadius) * localT;
      final opacity = (1 - localT) * 0.38;
      final ringPaint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawCircle(center, radius, ringPaint);
    }

    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, maxRadius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      t != oldDelegate.t || color != oldDelegate.color;
}
