import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Watermark skyline of Odisha's iconic Kalinga-architecture landmarks —
/// the Jagannath Temple's rekha deul (with its crowning Nilachakra wheel
/// and dhvaja flag), the Konark Sun Temple's carved stone chariot wheel,
/// and its stepped pidha-deul jagamohana hall. Proportions and details
/// (24-spoke beaded wheel rim, fluted amalaka, tiered pyramidal roof) are
/// modeled on real temple photographs rather than a generic pointed-tower
/// cliché. Shapes are filled with a light/dark gradient of the given base
/// color to read as bas-relief carved stone instead of a flat silhouette.
///
/// Two presentations:
///  * Default — a low-opacity single-tone watermark layered behind screen
///    content, matching [IkatWeaveBackdrop]'s treatment.
///  * `rich: true` — a higher-opacity hero graphic (e.g. splash screen)
///    using a warm gold/stone gradient so it reads as a genuine landmark
///    illustration rather than background texture.
class OdishaSkylineBackdrop extends StatelessWidget {
  final Color color;
  final double opacity;
  final bool rich;
  final List<Color>? richColors;

  const OdishaSkylineBackdrop({
    super.key,
    required this.color,
    this.opacity = 0.08,
    this.rich = false,
    this.richColors,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _OdishaSkylinePainter(
            color: color,
            opacity: opacity,
            rich: rich,
            richColors: richColors,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _OdishaSkylinePainter extends CustomPainter {
  final Color color;
  final double opacity;
  final bool rich;
  final List<Color>? richColors;

  _OdishaSkylinePainter({
    required this.color,
    required this.opacity,
    required this.rich,
    required this.richColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hsl = HSLColor.fromColor(color);
    final lightBase =
        richColors != null ? richColors![0] : hsl.withLightness((hsl.lightness + 0.24).clamp(0.0, 1.0)).toColor();
    final darkBase =
        richColors != null ? richColors![1] : hsl.withLightness((hsl.lightness - 0.20).clamp(0.0, 1.0)).toColor();

    final baseline = size.height - 4;
    final unit = size.height;

    _drawRekhaDeul(canvas, Offset(size.width * 0.17, baseline), unit, lightBase, darkBase);
    _drawSunWheel(canvas, Offset(size.width * 0.52, baseline), unit, lightBase, darkBase);
    _drawJagamohana(canvas, Offset(size.width * 0.85, baseline), unit, lightBase, darkBase);
  }

  Paint _gradientFill(Rect rect, Color light, Color dark) {
    return Paint()
      ..shader = LinearGradient(
        colors: [
          light.withValues(alpha: opacity),
          dark.withValues(alpha: opacity),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
  }

  /// Jagannath-style rekha deul: a mostly-vertical fluted tower (unlike a
  /// generic tapering cone, real rekha deuls stay near-vertical for most
  /// of their height and only curve inward sharply near the top, into the
  /// beki neck) topped with a tiered fluted amalaka, kalasha finial, the
  /// temple's signature Nilachakra wheel, and a dhvaja flag.
  void _drawRekhaDeul(Canvas canvas, Offset base, double unit, Color light, Color dark) {
    final width = unit * 0.5;
    final h = unit * 1.05;
    final rect = Rect.fromLTWH(base.dx - width, base.dy - h, width * 2, h);
    final fill = _gradientFill(rect, light, dark);
    final edge = Paint()
      ..color = dark.withValues(alpha: opacity * 1.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Plinth (bada).
    final plinth = Rect.fromLTWH(base.dx - width * 0.62, base.dy - h * 0.06, width * 1.24, h * 0.06);
    canvas.drawRect(plinth, fill);

    // Tower (gandi): near-vertical body curving inward only in the top
    // quarter, into the beki neck.
    final tower = Path()
      ..moveTo(base.dx - width * 0.5, base.dy - h * 0.06)
      ..lineTo(base.dx - width * 0.5, base.dy - h * 0.66)
      ..cubicTo(
        base.dx - width * 0.5, base.dy - h * 0.82,
        base.dx - width * 0.13, base.dy - h * 0.88,
        base.dx - width * 0.11, base.dy - h * 0.90,
      )
      ..lineTo(base.dx - width * 0.11, base.dy - h * 0.92)
      ..lineTo(base.dx + width * 0.11, base.dy - h * 0.92)
      ..lineTo(base.dx + width * 0.11, base.dy - h * 0.90)
      ..cubicTo(
        base.dx + width * 0.13, base.dy - h * 0.88,
        base.dx + width * 0.5, base.dy - h * 0.82,
        base.dx + width * 0.5, base.dy - h * 0.66,
      )
      ..lineTo(base.dx + width * 0.5, base.dy - h * 0.06)
      ..close();
    canvas.drawPath(tower, fill);
    canvas.drawPath(tower, edge);

    // Vertical paga ridges — the raised fluting bands on a rekha deul face.
    for (final t in [-0.26, 0.0, 0.26]) {
      canvas.drawLine(
        Offset(base.dx + width * t, base.dy - h * 0.08),
        Offset(base.dx + width * t * 0.32, base.dy - h * 0.80),
        edge..strokeWidth = 0.8,
      );
    }

    // Amalaka: tiered fluted disc, drawn as three stacked flattened ovals.
    final discY = base.dy - h * 0.92;
    for (int i = 0; i < 3; i++) {
      final w = width * (0.42 - i * 0.07);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(base.dx, discY - i * width * 0.045), width: w, height: width * 0.09),
        fill,
      );
    }

    // Kalasha finial.
    final kalashaY = discY - width * 0.18;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, kalashaY), width: width * 0.14, height: width * 0.20),
      fill,
    );

    // Nilachakra — Puri's signature crowning wheel — and dhvaja flag.
    final wheelCenter = Offset(base.dx, kalashaY - width * 0.20);
    final wheelR = width * 0.14;
    canvas.drawCircle(wheelCenter, wheelR, edge..strokeWidth = 1.2);
    canvas.drawCircle(wheelCenter, wheelR * 0.22, fill);
    for (int i = 0; i < 8; i++) {
      final a = 2 * math.pi * i / 8;
      canvas.drawLine(
        wheelCenter,
        Offset(wheelCenter.dx + wheelR * math.cos(a), wheelCenter.dy + wheelR * math.sin(a)),
        edge..strokeWidth = 0.8,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, wheelCenter.dy - wheelR * 0.4)
        ..lineTo(base.dx + width * 0.24, wheelCenter.dy - wheelR * 0.9)
        ..lineTo(base.dx, wheelCenter.dy - wheelR * 1.4)
        ..close(),
      fill,
    );
  }

  /// The Konark Sun Temple's carved stone chariot wheel: a double rim with
  /// beaded border, 24 spokes, and a decorative hub — grounded on a short
  /// axle plinth rather than floating.
  void _drawSunWheel(Canvas canvas, Offset base, double unit, Color light, Color dark) {
    final radius = unit * 0.36;
    final center = Offset(base.dx, base.dy - radius * 1.02);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final rim = Paint()
      ..shader = LinearGradient(
        colors: [light.withValues(alpha: opacity * 1.5), dark.withValues(alpha: opacity * 1.5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.11;
    final innerRim = Paint()
      ..color = dark.withValues(alpha: opacity * 1.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03;
    final hub = _gradientFill(rect, light, dark);

    // Axle plinth grounding the wheel to the platform.
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, base.dy - unit * 0.02), width: radius * 0.5, height: unit * 0.05),
      hub,
    );

    canvas.drawCircle(center, radius, rim);
    canvas.drawCircle(center, radius * 0.86, innerRim);
    canvas.drawCircle(center, radius * 0.16, hub);

    const spokes = 24;
    for (int i = 0; i < spokes; i++) {
      final a = 2 * math.pi * i / spokes;
      final inner = Offset(center.dx + radius * 0.16 * math.cos(a), center.dy + radius * 0.16 * math.sin(a));
      final outer = Offset(center.dx + radius * 0.86 * math.cos(a), center.dy + radius * 0.86 * math.sin(a));
      canvas.drawLine(inner, outer, innerRim);
      if (i.isEven) {
        // Beaded studs along the outer rim, echoing Konark's carved border.
        canvas.drawCircle(
          Offset(center.dx + radius * 1.0 * math.cos(a), center.dy + radius * 1.0 * math.sin(a)),
          radius * 0.045,
          hub,
        );
      }
    }
  }

  /// Konark's surviving jagamohana: a stepped pidha-deul pyramidal roof
  /// over a plain hall body, each tier stepping back with a shadow ledge.
  void _drawJagamohana(Canvas canvas, Offset base, double unit, Color light, Color dark) {
    final width = unit * 0.66;
    final hallH = unit * 0.32;
    final roofH = unit * 0.5;
    final rect = Rect.fromLTWH(base.dx - width, base.dy - hallH - roofH, width * 2, hallH + roofH);
    final fill = _gradientFill(rect, light, dark);
    final ledge = Paint()..color = dark.withValues(alpha: opacity * 1.7);

    // Hall body with corner pilaster lines.
    final hallRect = Rect.fromLTWH(base.dx - width / 2, base.dy - hallH, width, hallH);
    canvas.drawRect(hallRect, fill);
    for (final t in [-0.44, 0.44]) {
      canvas.drawLine(
        Offset(base.dx + width * t, base.dy),
        Offset(base.dx + width * t, base.dy - hallH),
        Paint()
          ..color = dark.withValues(alpha: opacity * 1.4)
          ..strokeWidth = 1,
      );
    }

    // Stepped pyramidal roof (pidha), five diminishing tiers.
    const tiers = 5;
    final tierH = roofH / tiers;
    for (int i = 0; i < tiers; i++) {
      final t = i / tiers;
      final tierW = width * (1 - t * 0.72);
      final y = base.dy - hallH - i * tierH;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(base.dx, y - tierH * 0.42), width: tierW, height: tierH * 0.72),
        fill,
      );
      // Shadow ledge under each tier for a stepped, three-dimensional read.
      canvas.drawRect(
        Rect.fromCenter(center: Offset(base.dx, y), width: tierW, height: tierH * 0.10),
        ledge,
      );
    }

    // Kalasha finial capping the roof.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy - hallH - roofH - width * 0.05), width: width * 0.09, height: width * 0.14),
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _OdishaSkylinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.rich != rich ||
      oldDelegate.richColors != richColors;
}
