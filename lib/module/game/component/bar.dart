import 'dart:math';

import 'package:colo/module/game/component/bullet.dart';
import 'package:colo/module/game/component/manager/bar.dart';
import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/component/riv.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/utils/audio.dart';
import 'package:colo/module/game/component/particle.dart';
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
  /// Glow controller
  late EffectController _glowController;
  /// Move controller
  MoveEffect? _effect;

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
      position = Vector2((gameSize.x / 2) - barSize.x / 1.4, 0);
    } else {
      position = Vector2(_generateRandomDx(), 0);
    }
    debugMode = true;
    _effect = _initMoveEffect();
    if (level == GameLevel.hard) {
      final random = Random();
      paint.color = barManager.generateShade(baseColor: barColor, factor: random.nextDouble());
      add(
          ColorEffect(
            barColors.values.toList()[random.nextInt(barColors.values.length)],
            EffectController(duration: 2.5),
            opacityFrom: 1,
            opacityTo: 0,
          )
      );
    }
    if (!disabled) {
      final waveRiv = await loadArtboard(
          RiveFile.asset(
              barManager.getBarRivAssetBasedOnColor(color: barColor)
          )
      );

      final riv = RivAnimationComponent(artBoard: waveRiv, size: size);
      _glowController = EffectController(
          duration: 0.01,
          reverseDuration: 0.5,
          curve: Curves.decelerate,
          onMin: () async {
            await add(riv);
          }
      );
      add(
          GlowEffect(20, _glowController)
      );
    }
  }

  @override
  void render(Canvas canvas) {
    if (_glowController.completed) {
      final Rect rect = Rect.fromPoints(
          Offset(size.x + 2, size.y + 2), const Offset(5, 5));
      canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.black
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
      );
    }
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += (barVelocity * dt) * barManager.barFallingSpeedMultiplier;
    if (position.y > gameSize.y) {
      barManager.removeBar(bar: this);
      onGameOver();
    }
    if (_effect != null) {
      add(_effect!);
    } else {
      _effect = _initMoveEffect();
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
    final double dx;
    final double dy;
    final double duration;
    if (level == GameLevel.easy || level == GameLevel.medium) {
      dx = 0;
      dy = 5;
      duration = 0.3;
    } else {
      dx = 100;
      dy = 20;
      duration = 1;
    }
    return MoveByEffect(
        Vector2(dx, dy),
        EffectController(
          duration: duration,
          curve: Curves.decelerate,
        ),
        onComplete: () =>
            add(
                MoveByEffect(
                    Vector2(-dx , -dy),
                    EffectController(
                      duration: duration,
                      curve: Curves.decelerate,
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
        position: Vector2(size.x, position.y),
        child: CustomParticle(
            radius: 3,
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
