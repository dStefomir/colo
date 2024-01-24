import 'dart:ui';

import 'package:colo/module/game/page.dart';
import 'package:colo/utils/shader.dart';
import 'package:flame/components.dart';

/// Renders a background
class Background extends RectangleComponent with HasGameRef<ColoGamePage>{
  /// Fragment shader
  late FragmentShader _shader;
  /// Shader timer, used for update
  late double _shaderTimer;

  @override
  Future<void> onLoad() async {
    size = game.size;
    _shader = await loadShader(asset: 'shaders/background.glsl');
    _shaderTimer = 0.01;
    _shader.setFloat(0, _shaderTimer);
    _shader.setFloat(1, game.size.x);
    _shader.setFloat(2, game.size.y);
    _shader.setFloat(3, 0.5);
    paint = Paint()..shader = _shader;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _shader.setFloat(1, size.x);
    _shader.setFloat(2, size.y);
  }

  @override
  void update(double dt) {
    _shaderTimer = _shaderTimer + 0.005;
    _shader.setFloat(0, _shaderTimer);
  }
}