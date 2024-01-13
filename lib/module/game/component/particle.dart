import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Renders a custom particle with shadow
class CustomParticle extends CircleParticle {
  /// Shadow color
  final Color shadowColor;
  /// Should be particle be circle or rect
  final bool isCircle;

  CustomParticle({required super.paint, required super.radius, this.shadowColor = Colors.black54, this.isCircle = true});

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = shadowColor;
    if (isCircle) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawCircle(
          Offset.zero,
          radius + 1,
          paint
      );
    } else {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
      canvas.drawRect(Rect.fromCircle(center: const Offset(0, 0), radius: radius + 1), paint);
    }
  }
}