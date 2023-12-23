import 'dart:ui';

import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/parallax.dart';

/// Renders a background
class Background extends ParallaxComponent<ColoGamePage> {
  /// Asset for the background
  final String asset;
  /// Fit for the background
  final LayerFill fill;

  Background({required this.asset, this.fill = LayerFill.height});

  @override
  Future<void> onLoad() async {
    final background = await Flame.images.load(asset);
    parallax = Parallax(
        [
          ParallaxLayer(
            ParallaxImage(
                background,
                fill: fill,
                filterQuality: FilterQuality.high,
            )
          )
        ]
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    parallax?.baseVelocity.x = backgroundParallax;
  }
}