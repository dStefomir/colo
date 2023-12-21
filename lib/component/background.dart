import 'dart:ui';

import 'package:colo/game.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/parallax.dart';
import 'package:flame/rendering.dart';

/// Renders a background
class Background extends ParallaxComponent<ColoGame> {
  /// Asset for the background
  final String asset;

  Background({required this.asset});

  @override
  Future<void> onLoad() async {
    final background = await Flame.images.load(asset);
    decorator.addLast(PaintDecorator.blur(5.5));
    parallax = Parallax(
        [
          ParallaxLayer(
            ParallaxImage(
                background,
                fill: LayerFill.none,
                filterQuality: FilterQuality.high
            )
          )
        ]
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    parallax?.baseVelocity.x = barVelocity;
  }
}