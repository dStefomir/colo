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
    position = Vector2(_generateRandomDx(), 0);
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
          duration: 0.5,
          reverseDuration: 0.5,
          curve: Curves.decelerate,
          onMin: () async {
            await add(riv);
          }
      );
      add(GlowEffect(30, _glowController));
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

  /// Generates a random dx for the bar
  _generateRandomDx({int min = 30}) {
    final random = Random();
    return min + random.nextInt(((game.size.x - size.x) - min).toInt()).toDouble();
  }

  // This method generates a random vector with its angle
  // between from 0 and 360 degrees.
  _getRandomVector() {
    final random = Random();
    return (Vector2.random(random) - Vector2.random(random)) * 500;
  }
}
