import 'dart:ui';

import 'package:colo/module/game/page.dart';
import 'package:colo/utils/shader.dart';
import 'package:flame/components.dart';

/// Renders a background
class Background extends RectangleComponent with HasGameRef<ColoGamePage>{
  /// Is the game disabled or not
  late bool _disabled;
  /// Fragment shader
  late FragmentShader _shader;
  /// Shader timer, used for update
  late double _shaderTimer;

  Background({required bool disabled}) {
    _disabled = disabled;
  }

  @override
  Future<void> onLoad() async {
    size = game.size;
    _shader = await loadShader(asset: _disabled ? 'shaders/background_initial.glsl' : 'shaders/background.glsl');
    _shaderTimer = 0.0001;
    _shader.setFloat(0, _shaderTimer);
    _shader.setFloat(1, 100);
    _shader.setFloat(2, 100);
    paint = Paint()..shader = _shader;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _shader.setFloat(1, 100);
    _shader.setFloat(2, 100);
  }

  @override
  void update(double dt) {
    _shaderTimer = _shaderTimer + 0.005;
    _shader.setFloat(0, _shaderTimer);
  }
}