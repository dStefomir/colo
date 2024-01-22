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
    _shaderTimer = 0.1;
    _shader.setFloat(0, _shaderTimer);
    _shader.setFloat(1, size.x * 4);
    _shader.setFloat(2, size.y * 4);
    _shader.setFloat(3, 0.5);
    _shader.setFloat(4, 1.8);
    paint = Paint()..shader = _shader;
  }

  @override
  void update(double dt) {
    _shaderTimer = _shaderTimer + 0.011;
    _shader.setFloat(0, _shaderTimer);
  }
}