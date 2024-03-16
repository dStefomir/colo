import 'dart:math';

import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/manager/bullet.dart';
import 'package:colo/module/game/component/riv.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/utils/audio.dart';
import 'package:colo/module/game/component/particle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

/// Renders a bullet
class Bullet extends CircleComponent with CollisionCallbacks {
  /// Game size
  final Vector2 gameSize;
  /// Falling bars
  final List<Bar> Function() getBars;
  /// Game colors
  final List<Color> gameColors;
  /// Adds a bullet to the game
  final void Function(Component) onGameAdd;
  /// Removes a bullet from the game
  final void Function(Component) onGameRemove;
  /// Bullet manager
  final BulletManager bulletManager;
  /// Color of the bullet
  final Color bulletColor;
  /// Bullet radius
  final double bulletSize;
  /// Should have a bullet limiter or not
  final bool shouldRemoveLimiter;

  Bullet({
    required this.gameSize,
    required this.getBars,
    required this.gameColors,
    required this.onGameAdd,
    required this.onGameRemove,
    required this.bulletManager,
    required this.bulletColor,
    required this.bulletSize,
    required this.shouldRemoveLimiter}) : super(
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
    play(asset: 'rocket.wav', volume: 0.05);
    if (getBars().isEmpty) {
      position = Vector2((gameSize.x / 2) - (bulletSize / 2), gameSize.y);
    } else {
      final lastBar = getBars().first;
      position = Vector2(lastBar.position.x + lastBar.size.x / 2, gameSize.y);
    }
    final bulletRiv = await loadArtboard(
        RiveFile.asset(
            bulletManager.getBulletRivAssetBasedOnColor(color: bulletColor)
        )
    );
    final riv = RivAnimationComponent(
        artBoard: bulletRiv,
        size: Vector2.all(bulletSize) * 8,
        position: Vector2(-60, -65),
        stateMachineKey: 'State Machine 1',
        animationKey: 'All'
    );
    await add(riv);
  }

  @override
  void render(Canvas canvas) {
    final Rect rect = Rect.fromPoints(
        Offset((bulletSize / 8) * -1 , (size.y / 3.3) * -1),
        Offset(bulletSize / 4 , size.y)
    );
    canvas.drawRRect(RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(35),
        topRight: const Radius.circular(35),
        bottomLeft: const Radius.circular(35),
        bottomRight: const Radius.circular(35)
    ), Paint()
      ..color = Colors.black54
      );
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    /// Renders a barrier for the bullet based on the game level
    if (!shouldRemoveLimiter && bulletManager.getBulletDyLimit() >= position.y) {
      _renderBarrier();
    }
    /// --------------------------------------------------------
    position.y = position.y - (bulletVelocity * dt);
    add(
        ParticleSystemComponent(
            particle: Particle.generate(
              count: 10,
              lifespan: 0.5,
              generator: (i) => AcceleratedParticle(
                acceleration: bulletManager.getRandomVector(),
                speed: bulletManager.getRandomVector(),
                child: CustomParticle(
                  radius: 1,
                  paint: Paint()
                    ..color = Colors.black,
                  shadowColor: bulletColor
                ),
              ),
            )
        )
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    removeFromParent();
    if (other is Bar && other.barColor != bulletColor) {
      /// Not successful bullet to bar
      play(asset: 'mismatch.wav', volume: 0.1);
      onGameAdd(
          ParticleSystemComponent(
              particle: Particle.generate(
                count: 50,
                lifespan: 1,
                generator: (i) => AcceleratedParticle(
                  position: position.clone(),
                  acceleration: bulletManager.getRandomVector() * 2.0,
                  speed: bulletManager.getRandomVector() * 2.0,
                  child: CustomParticle(
                    radius: 1,
                    paint: Paint()..color = bulletColor,
                  ),
                ),
              )
          )
      );
      bulletManager.onBulletColorMiss();
    }
    super.onCollision(intersectionPoints, other);
  }

  /// Renders a barrier for the bullet
  void _renderBarrier() {
    final random = Random();
    onGameAdd(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 10,
            lifespan: 0.3,
            generator: (i) => AcceleratedParticle(
              acceleration: _getBarrierVector(),
              speed: _getBarrierVector(),
              position: Vector2(position.x, position.y),
              child: CustomParticle(
                radius: 2,
                paint: Paint()
                  ..color = gameColors[
                    random.nextInt(gameColors.length)
                  ],
                shadowColor: bulletColor
              ),
            ),
          ),
        )
    );
    onGameAdd(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 10,
            lifespan: 0.3,
            generator: (i) => AcceleratedParticle(
              acceleration: _getBarrierVector(right: false),
              speed: _getBarrierVector(right: false),
              position: Vector2(position.x, position.y),
              child: CustomParticle(
                  radius: 2,
                  paint: Paint()
                    ..color = gameColors[
                      random.nextInt(gameColors.length)
                    ],
                  shadowColor: bulletColor
              ),
            ),
          ),
        )
    );
    onGameRemove(this);
  }

  // This method generates a random vector with its angle
  _getBarrierVector({bool right = true}) {
    final random = Random();
    return (Vector2(random.nextDouble(), random.nextInt(1).toDouble())) * (right == true ? 1000 : -1000);
  }
}