import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Procedural motifs drawn from Sambalpuri ikat weave geometry — a diamond
/// lattice texture for surfaces, and a small radiating rosette used as a
/// recurring brand mark. Both are static (no per-frame animation cost) so
/// they're cheap to layer under real content.

/// Low-opacity diamond-lattice texture, evoking the resist-dye diamond
/// grid found in Sambalpuri ikat borders. Meant to sit behind content at
/// ~0.05–0.12 opacity — a texture, not a foreground pattern.
class IkatWeaveBackdrop extends StatelessWidget {
  final Color color;
  final double opacity;
  final double spacing;

  const IkatWeaveBackdrop({
    super.key,
    required this.color,
    this.opacity = 0.08,
    this.spacing = 34,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _IkatWeavePainter(
            color: color,
            opacity: opacity,
            spacing: spacing,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _IkatWeavePainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double spacing;

  _IkatWeavePainter({
    required this.color,
    required this.opacity,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final dot = Paint()..color = color.withValues(alpha: opacity * 1.4);

    final cell = spacing;
    final cols = (size.width / cell).ceil() + 2;
    final rows = (size.height / cell).ceil() + 2;

    for (int r = -1; r < rows; r++) {
      final rowOffset = (r.isOdd) ? cell / 2 : 0.0;
      for (int c = -1; c < cols; c++) {
        final cx = c * cell + rowOffset;
        final cy = r * cell * 0.72;
        final half = cell * 0.34;

        final path = Path()
          ..moveTo(cx, cy - half)
          ..lineTo(cx + half, cy)
          ..lineTo(cx, cy + half)
          ..lineTo(cx - half, cy)
          ..close();
        canvas.drawPath(path, line);
        canvas.drawCircle(Offset(cx, cy), 1.4, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IkatWeavePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.spacing != spacing;
}

/// A small radiating diamond rosette — the app's recurring brand glyph.
/// Used on the splash emblem and as a decorative flourish in place of
/// generic stock icons.
class IkatRosette extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final int petals;

  const IkatRosette({
    super.key,
    this.size = 48,
    required this.color,
    this.strokeWidth = 2,
    this.petals = 8,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _IkatRosettePainter(
        color: color,
        strokeWidth: strokeWidth,
        petals: petals,
      ),
    );
  }
}

class _IkatRosettePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int petals;

  _IkatRosettePainter({
    required this.color,
    required this.strokeWidth,
    required this.petals,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final inner = outer * 0.42;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final fillDot = Paint()..color = color;

    for (int i = 0; i < petals; i++) {
      final angle = (2 * math.pi * i / petals) - math.pi / 2;
      final tip = Offset(
        center.dx + outer * math.cos(angle),
        center.dy + outer * math.sin(angle),
      );
      final leftAngle = angle - (math.pi / petals);
      final rightAngle = angle + (math.pi / petals);
      final left = Offset(
        center.dx + inner * math.cos(leftAngle),
        center.dy + inner * math.sin(leftAngle),
      );
      final right = Offset(
        center.dx + inner * math.cos(rightAngle),
        center.dy + inner * math.sin(rightAngle),
      );

      final petal = Path()
        ..moveTo(left.dx, left.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(right.dx, right.dy);
      canvas.drawPath(petal, stroke);
    }

    canvas.drawCircle(center, inner * 0.4, fillDot);
    canvas.drawCircle(center, inner * 0.4, stroke..strokeWidth = strokeWidth * 0.8);
  }

  @override
  bool shouldRepaint(covariant _IkatRosettePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.petals != petals;
}
