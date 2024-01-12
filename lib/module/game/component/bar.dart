import 'dart:math';

import 'package:colo/module/game/component/bullet.dart';
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
class Bar extends RectangleComponent with HasGameRef<ColoGamePage>, CollisionCallbacks {
  /// Color of the bar
  final Color barColor;
  /// Bar size
  final Vector2 barSize;
  /// Glow controller
  late EffectController _glowController;
  /// Move controller
  MoveEffect? _effect;

  Bar({required this.barColor, required this.barSize}) : super(
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
    if (game.manager.level == GameLevel.hard) {
      position = Vector2((game.size.x / 2) - barSize.x / 1.4, 0);
    } else {
      position = Vector2((game.size.x / 2) - (size.x / 2), 0);
    }
    _effect = _initMoveEffect();
    if (game.manager.level == GameLevel.hard) {
      final random = Random();
      paint.color = game.manager.barManager.generateShade(baseColor: barColor, factor: random.nextDouble());
      add(
          ColorEffect(
            barColors.values.toList()[random.nextInt(barColors.values.length)],
            EffectController(duration: 2.5),
            opacityFrom: 1,
            opacityTo: 0,
          )
      );
    }
    if (!game.manager.disabled) {
      final waveRiv = await loadArtboard(
          RiveFile.asset(
              game.manager.barManager.getBarRivAssetBasedOnColor(color: barColor)
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

    position.y += (barVelocity * dt) * game.manager.barManager.barFallingSpeedMultiplier;
    if (position.y > game.size.y) {
      game.manager.barManager.removeBar(bar: this);
      game.manager.gameOver();
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
    play(asset: 'blow.wav');
    game.manager.increaseScore();
    game.manager.barManager.removeBar(bar: this);
    game.add(_generateParticle());
  }

  /// Creates a moving effect
  MoveEffect _initMoveEffect() {
    final GameManager manager = game.manager;
    final double dx;
    final double dy;
    final double duration;
    if (manager.level == GameLevel.easy || manager.level == GameLevel.medium) {
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
          curve: Curves.linear,
        ),
        onComplete: () =>
            add(
                MoveByEffect(
                    Vector2(-dx , -dy),
                    EffectController(
                      duration: duration,
                      curve: Curves.linear,
                    ),
                    onComplete: () => _effect = null
                )
            )
    );
  }

  /// Generates a particle
  _generateParticle() => ParticleSystemComponent(
    particle: Particle.generate(
      count: game.manager.barManager.getBarExplosionParticles(),
      lifespan: game.manager.barManager.getBarExplosionLifespan(),
      generator: (i) => AcceleratedParticle(
        acceleration: _getRandomVector() * 3.0,
        speed: _getRandomVector() * 8.0,
        position: Vector2(size.x, position.y),
        child: CustomParticle(
            radius: 3,
            paint: Paint()
              ..color = barColor
        ),
      ),
    ),
  );

  // This method generates a random vector with its angle
  // between from 0 and 360 degrees.
  _getRandomVector() {
    final random = Random();
    return (Vector2.random(random) - Vector2.random(random)) * 500;
  }
}
