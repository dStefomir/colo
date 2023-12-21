import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Renders a custom particle with shadow
class CustomParticle extends CircleParticle {

  /// Shadow color
  final Color shadowColor;

  CustomParticle({required super.paint, required super.radius, this.shadowColor = Colors.black54});

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(
        Offset.zero,
        radius + 1,
        Paint()
          ..color = shadowColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
    );
  }
}