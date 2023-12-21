import 'dart:math';

import 'package:colo/component/bar.dart';
import 'package:colo/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

/// Renders a bullet
class Bullet extends CircleComponent with HasGameRef<ColoGame>, CollisionCallbacks {
  /// Color of the bullet
  final Color bulletColor;
  /// Bullet radius
  final double bulletSize;

  Bullet({required this.bulletColor, required this.bulletSize}) : super(
    paint: Paint()
      ..color = Colors.transparent
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true,
    radius: bulletSize,
    children: [
      CircleHitbox()
    ],
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    FlameAudio.play('rocket.wav', volume: 0.05);
    position = Vector2(game.size.x / 2, game.size.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final limit = game.manager.getBulletDyLimit();
    if (limit >= position.y) {
      game.remove(this);
    }
    position.y = position.y - (bulletVelocity * dt);
    add(_generateParticles());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    removeFromParent();
    if (other is Bar && other.color != bulletColor) {
      /// Not successful bullet to bar
      game.add(ParticleSystemComponent(
          particle: Particle.generate(
            count: 50,
            lifespan: 1,
            generator: (i) => AcceleratedParticle(
              position: position.clone(),
              acceleration: _getRandomVector() * 2.0,
              speed: _getRandomVector() * 2.0,
              child: CircleParticle(
                radius: 1,
                paint: Paint()..color = bulletColor,
              ),
            ),
          )
      ));
    }
    super.onCollision(intersectionPoints, other);
  }

  /// Generates particles
  _generateParticles() => ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        lifespan: 0.5,
        generator: (i) => AcceleratedParticle(
          acceleration: _getRandomVector(),
          speed: _getRandomVector(),
          child: CircleParticle(
            radius: 1,
            paint: Paint()..color = bulletColor,
          ),
        ),
      )
  );

  /// Gets a random vector
  _getRandomVector() {
    final Random random = Random();
    return (Vector2.random(random) - Vector2(0.5, -1)) * 100;
  }
}