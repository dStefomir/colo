import 'dart:math';

import 'package:colo/component/bullet.dart';
import 'package:colo/component/riv.dart';
import 'package:colo/game.dart';
import 'package:colo/utils/audio.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

/// Renders a bar
class Bar extends RectangleComponent with HasGameRef<ColoGame>, CollisionCallbacks {
  /// Color of the bar
  final Color color;
  /// Bar size
  final Vector2 barSize;
  /// Riv animation component
  late RivAnimationComponent riv;

  Bar({required this.color, required this.barSize}) : super(
      size: barSize,
      paint: Paint()
        ..color = color
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
    // position = Vector2(30, 0);
    final waveRiv = await loadArtboard(RiveFile.asset(game.manager.getRivAssetBasedOnColor(color: color)));
    riv = RivAnimationComponent(artBoard: waveRiv, size: barSize);
    await add(riv);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += barVelocity * dt;

    if (position.y > game.size.y) {
      game.remove(this);
      game.pauseEngine();
      /// TODO: Show game over dialog
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      if (other.bulletColor == color) {
        _destroyBar();
      } else {
        _destroyBullet();
      }
    }
  }

  /// Destroys a bar
  _destroyBar() {
    play(asset: 'blow.wav');
    game.manager.increaseScore();
    game.remove(this);
    game.add(_generateParticle());
  }

  /// When the bullet is destroyed because of a wrong
  /// color, also decrease the current score
  _destroyBullet() {
    play(asset: 'mismatch.wav', volume: 0.5);
    game.manager.decreaseScore();
  }

  /// Generates a particle
  _generateParticle() => ParticleSystemComponent(
    particle: Particle.generate(
      count: 50,
      lifespan: 0.3,
      generator: (i) => AcceleratedParticle(
        acceleration: _getRandomVector() * 3.0,
        speed: _getRandomVector() * 8.0,
        position: Vector2((game.size / 2).x, position.y),
        child: CircleParticle(
            radius: 3,
            paint: Paint()
              ..color = color.withOpacity(0.7)
              ..filterQuality = FilterQuality.high
              ..isAntiAlias = true
        ),
      ),
    ),
  );

  /// Generates a random dx for the bar
  _generateRandomDx({int min = 30}) {
    final random = Random();

    return min + random.nextInt(((game.size.x / 2) - min + 1).toInt()).toDouble();
  }

  // This method generates a random vector with its angle
  // between from 0 and 360 degrees.
  _getRandomVector() {
    final random = Random();
    return (Vector2.random(random) - Vector2.random(random)) * 500;
  }
}
