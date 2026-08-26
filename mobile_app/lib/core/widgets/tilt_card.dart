import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Wraps a child in a slow, continuous 3D perspective float — the surface
/// gently leans on two axes like it's catching light, unlike a static flat
/// card. Deliberately gesture-free (no pan/drag capture) so it's safe to use
/// inside a PageView or scrollable without stealing swipe/scroll gestures.
class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final double perspective;
  final Duration duration;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 0.045,
    this.perspective = 0.0018,
    this.duration = const Duration(milliseconds: 7000),
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
      builder: (context, child) {
        final t = _controller.value * 2 * math.pi;
        final rotateX = math.sin(t) * widget.maxTilt;
        final rotateY = math.cos(t * 0.6) * widget.maxTilt;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, widget.perspective)
            ..rotateX(rotateX)
            ..rotateY(rotateY),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
