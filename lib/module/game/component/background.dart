import 'dart:ui';

import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/parallax.dart';
import 'package:flame/rendering.dart';

/// Renders a background
class Background extends ParallaxComponent<ColoGamePage> {
  /// is the game disabled or not
  final bool disabled;
  /// Asset for the background
  final String asset;
  /// Priority for the background component
  @override
  final int priority;

  Background({required this.disabled, required this.asset, required this.priority});

  @override
  Future<void> onLoad() async {
    final background = await Flame.images.load(disabled ? 'background_disabled.png' : asset);
    decorator = PaintDecorator.blur(5.0);
    parallax = Parallax(
        [
          ParallaxLayer(
              ParallaxImage(
                background,
                fill: LayerFill.height,
                filterQuality: FilterQuality.high,
              )
          )
        ]
    );
    parallax?.baseVelocity.x = backgroundParallax;
  }
}