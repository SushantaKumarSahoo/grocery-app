import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Occasion-specific decorative motifs layered on top of [ScreenBackdrop]'s
/// default ikat texture when a shopper has picked a celebration occasion
/// (see core/theme/occasion_themes.dart). Procedural only, matching the
/// rest of the app's backdrop art (no photo/image assets) — drawn from
/// recognisable Indian festival/wedding iconography rather than a generic
/// "party" look.

/// A hanging toran/bandhanwar: a sagging string strung with alternating
/// mango leaves and marigold flowers, the garland traditionally hung across
/// doorways for weddings, receptions and birthdays.
class ToranGarlandBackdrop extends StatelessWidget {
  final Color color;
  final double opacity;
  final double spacing;

  const ToranGarlandBackdrop({
    super.key,
    required this.color,
    this.opacity = 0.16,
    this.spacing = 44,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ToranGarlandPainter(color: color, opacity: opacity, spacing: spacing),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ToranGarlandPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double spacing;

  _ToranGarlandPainter({required this.color, required this.opacity, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final strand = Paint()
      ..color = color.withValues(alpha: opacity * 1.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final leafFill = Paint()..color = color.withValues(alpha: opacity);
    final petalFill = Paint()..color = color.withValues(alpha: opacity * 1.3);
    final coreFill = Paint()..color = color.withValues(alpha: opacity * 2);

    const stringY = 5.0;
    final segments = (size.width / spacing).ceil() + 1;

    final strandPath = Path()..moveTo(0, stringY);
    for (int i = 0; i < segments; i++) {
      final x1 = (i + 1) * spacing;
      strandPath.quadraticBezierTo(i * spacing + spacing / 2, stringY + 9, x1, stringY);
    }
    canvas.drawPath(strandPath, strand);

    for (int i = 0; i < segments; i++) {
      final x = i * spacing + spacing / 2;
      final dropStart = stringY + 8;
      final dropEnd = dropStart + 16;
      canvas.drawLine(Offset(x, dropStart), Offset(x, dropEnd), strand);

      if (i.isEven) {
        _drawMangoLeaf(canvas, Offset(x, dropEnd + 9), leafFill);
      } else {
        _drawMarigold(canvas, Offset(x, dropEnd + 7), petalFill, coreFill);
      }
    }
  }

  void _drawMangoLeaf(Canvas canvas, Offset tip, Paint fill) {
    final path = Path()
      ..moveTo(tip.dx, tip.dy - 15)
      ..quadraticBezierTo(tip.dx + 8, tip.dy - 7, tip.dx, tip.dy + 5)
      ..quadraticBezierTo(tip.dx - 8, tip.dy - 7, tip.dx, tip.dy - 15)
      ..close();
    canvas.drawPath(path, fill);
  }

  void _drawMarigold(Canvas canvas, Offset center, Paint petals, Paint core) {
    const petalCount = 8;
    for (int i = 0; i < petalCount; i++) {
      final a = 2 * math.pi * i / petalCount;
      final px = center.dx + math.cos(a) * 5.5;
      final py = center.dy + math.sin(a) * 5.5;
      canvas.drawCircle(Offset(px, py), 3, petals);
    }
    canvas.drawCircle(center, 2.6, core);
  }

  @override
  bool shouldRepaint(covariant _ToranGarlandPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity || oldDelegate.spacing != spacing;
}

/// A row of lit diyas (clay oil lamps) — the classic marker of an Indian
/// temple festival, lined up along the bottom edge of the screen.
class DiyaRowBackdrop extends StatelessWidget {
  final Color color;
  final double opacity;
  final double spacing;

  const DiyaRowBackdrop({
    super.key,
    required this.color,
    this.opacity = 0.15,
    this.spacing = 50,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _DiyaRowPainter(color: color, opacity: opacity, spacing: spacing),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _DiyaRowPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double spacing;

  _DiyaRowPainter({required this.color, required this.opacity, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final bowl = Paint()..color = color.withValues(alpha: opacity);
    final rim = Paint()
      ..color = color.withValues(alpha: opacity * 1.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final flame = Paint()..color = color.withValues(alpha: opacity * 2.3);

    final baseline = size.height - 6;
    final count = (size.width / spacing).ceil() + 1;
    for (int i = 0; i < count; i++) {
      final cx = i * spacing + spacing / 2;
      _drawDiya(canvas, Offset(cx, baseline), bowl, rim, flame);
    }
  }

  void _drawDiya(Canvas canvas, Offset base, Paint bowl, Paint rim, Paint flame) {
    final bowlPath = Path()
      ..moveTo(base.dx - 11, base.dy - 4)
      ..quadraticBezierTo(base.dx, base.dy + 6, base.dx + 11, base.dy - 4)
      ..close();
    canvas.drawPath(bowlPath, bowl);
    canvas.drawPath(bowlPath, rim);

    final flamePath = Path()
      ..moveTo(base.dx, base.dy - 22)
      ..quadraticBezierTo(base.dx + 4, base.dy - 13, base.dx, base.dy - 6)
      ..quadraticBezierTo(base.dx - 4, base.dy - 13, base.dx, base.dy - 22)
      ..close();
    canvas.drawPath(flamePath, flame);
  }

  @override
  bool shouldRepaint(covariant _DiyaRowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity || oldDelegate.spacing != spacing;
}

/// A string of triangular pennant flags — the bunting used to dress up
/// Indian corporate events, hostels, hotels, restaurants and catering
/// setups. Festive without reading as wedding-specific like [ToranGarlandBackdrop].
class BuntingBackdrop extends StatelessWidget {
  final Color color;
  final double opacity;
  final double spacing;

  const BuntingBackdrop({
    super.key,
    required this.color,
    this.opacity = 0.16,
    this.spacing = 34,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _BuntingPainter(color: color, opacity: opacity, spacing: spacing),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BuntingPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double spacing;

  _BuntingPainter({required this.color, required this.opacity, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final strand = Paint()
      ..color = color.withValues(alpha: opacity * 1.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final flagA = Paint()..color = color.withValues(alpha: opacity * 1.5);
    final flagB = Paint()..color = color.withValues(alpha: opacity * 0.9);

    const stringY = 5.0;
    final segments = (size.width / spacing).ceil() + 1;

    final strandPath = Path()..moveTo(0, stringY);
    for (int i = 0; i < segments; i++) {
      final x1 = (i + 1) * spacing;
      strandPath.quadraticBezierTo(i * spacing + spacing / 2, stringY + 6, x1, stringY);
    }
    canvas.drawPath(strandPath, strand);

    for (int i = 0; i < segments; i++) {
      final x = i * spacing + spacing / 2;
      final dipY = stringY + 5;
      final path = Path()
        ..moveTo(x - 7, dipY)
        ..lineTo(x + 7, dipY)
        ..lineTo(x, dipY + 16)
        ..close();
      canvas.drawPath(path, i.isEven ? flagA : flagB);
    }
  }

  @override
  bool shouldRepaint(covariant _BuntingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity || oldDelegate.spacing != spacing;
}
