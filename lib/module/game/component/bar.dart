import 'dart:math';
import 'dart:ui';

import 'package:colo/module/game/component/bullet.dart';
import 'package:colo/module/game/component/manager/bar.dart';
import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/component/riv.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/utils/audio.dart';
import 'package:colo/module/game/component/particle.dart';
import 'package:colo/utils/shader.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

/// Renders a bar
class Bar extends RectangleComponent with CollisionCallbacks {
  /// Is the game disabled or not
  final bool disabled;
  /// Current game level
  final GameLevel level;
  /// Bar manager
  final BarManager barManager;
  /// Stops the game
  final void Function() onGameOver;
  /// Increases the current score
  final void Function() onIncreaseScore;
  /// Game size
  final Vector2 gameSize;
  /// Color of the bar
  final Color barColor;
  /// Bar size
  final Vector2 barSize;
  /// Fragment shader
  late FragmentShader _shader;
  /// Shader timer, used for update
  late double _shaderTimer;
  /// Move controller
  MoveEffect? _effect;
  /// Aim riv
  Artboard? _aimRiv;

  Bar({
    required this.disabled,
    required this.level,
    required this.barManager,
    required this.onGameOver,
    required this.onIncreaseScore,
    required this.gameSize,
    required this.barColor,
    required this.barSize}) : super(
      size: barSize,
      paint: Paint()
        ..color = barColor
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true,
      children: [
        RectangleHitbox(
          size: barSize,
        )
      ]
  );

  @override
  Future<void> onLoad() async {
    if (level == GameLevel.hard) {
      position = Vector2((gameSize.x / 2) - barSize.x / 1.4, -15);
      _effect = _initMoveEffect();
    } else {
      position = Vector2(_generateRandomDx(), -15);
    }
    _shader = await loadShader(asset: 'shaders/glow.glsl');
    _shaderTimer = 0.1;
    if (!disabled) {
      _shader.setFloat(0, _shaderTimer);
      _shader.setFloat(1, 100);
      _shader.setFloat(2, 100);
      _shader.setFloat(3, barColor.red.toDouble() / 110);
      _shader.setFloat(4, barColor.green.toDouble() / 110);
      _shader.setFloat(5, barColor.blue.toDouble() / 110);
      paint.shader = _shader;
    }
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);
    if (barManager.getAvailableBars().first == this && _aimRiv == null) {
      _aimRiv = await loadArtboard(
          RiveFile.asset(
              barManager.getBulletAimRivAsset(color: barColor)
          )
      );
      final barAim = RivAnimationComponent(
          artBoard: _aimRiv!,
          size: Vector2.all(bulletSize) * 2,
          position: Vector2(36, 35),
          stateMachineKey: 'State Machine 1',
          animationKey: 'Target',
      );
      add(barAim);
    }
    position.y += (barVelocity * dt) * barManager.barFallingSpeedMultiplier;
    _shaderTimer = _shaderTimer + 0.015;
    _shader.setFloat(0, _shaderTimer);
    if (position.y > gameSize.y) {
      barManager.removeBar(bar: this);
      onGameOver();
    }
    if (level == GameLevel.hard) {
      if (_effect != null) {
        add(_effect!);
      } else {
        _effect = _initMoveEffect();
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      if (other.bulletColor == barColor) {
        destroyBar();
      }
    }
  }

  /// Destroys a bar
  destroyBar() {
    final ColoGamePage game = (parent as ColoGamePage);
    play(asset: 'blow.wav');
    onIncreaseScore();
    barManager.removeBar(bar: this);
    game.add(_generateParticle());
  }

  /// Creates a moving effect
  MoveEffect _initMoveEffect() {
    const double dx = 100;
    const double dy = 20;
    final double duration = 1 / barManager.barFallingSpeedMultiplier;

    return MoveByEffect(
        Vector2(dx, dy),
        EffectController(
          duration: duration,
          curve: Curves.easeInOut,
        ),
        onComplete: () =>
            add(
                MoveByEffect(
                    Vector2(-dx , -dy),
                    EffectController(
                      duration: duration,
                      curve: Curves.easeInOut,
                    ),
                    onComplete: () => _effect = null
                )
            )
    );
  }

  /// Generates a particle
  _generateParticle() => ParticleSystemComponent(
    particle: Particle.generate(
      count: barManager.getBarExplosionParticles(),
      lifespan: barManager.getBarExplosionLifespan(),
      generator: (i) => AcceleratedParticle(
        acceleration: _getRandomVector() * 3.0,
        speed: _getRandomVector() * 8.0,
        position: Vector2(position.x + size.x / 2, position.y),
        child: CustomParticle(
            radius: 1,
            isCircle: false,
            shadowColor: barManager.generateShade(baseColor: barColor, factor: Random().nextDouble()),
            paint: Paint()
              ..color = barColor
        ),
      ),
    ),
  );

  /// Generates a random dx for the bar
  _generateRandomDx({int min = 30}) {
    final random = Random();
    return min + random.nextInt(((gameSize.x - size.x) - min).toInt()).toDouble();
  }

  // This method generates a random vector with its angle
  // between from 0 and 360 degrees.
  _getRandomVector() {
    final random = Random();
    return (Vector2.random(random) - Vector2.random(random)) * 500;
  }
}