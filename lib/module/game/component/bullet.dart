import 'dart:math';

import 'package:colo/module/game/component/bar.dart';
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
class Bullet extends CircleComponent with HasGameRef<ColoGamePage>, CollisionCallbacks {
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
    play(asset: 'rocket.wav', volume: 0.05);
    final lastBar = game.children.whereType<Bar>().first;
    position = Vector2(lastBar.position.x + lastBar.size.x / 2, game.size.y);
    final bulletRiv = await loadArtboard(
        RiveFile.asset(
            game.manager.getBulletRivAssetBasedOnColor(color: bulletColor)
        )
    );
    final riv = RivAnimationComponent(
        artBoard: bulletRiv,
        size: game.size / 2,
        position: Vector2((game.size.x / 4) * -1, (game.size.y / 3.85) * -1),
        stateMachineKey: 'State Machine 1',
        animationKey: 'All'
    );
    await add(riv);
  }

  @override
  void update(double dt) {
    super.update(dt);
    /// Renders a barrier for the bullet based on the game level
    if (game.manager.getBulletDyLimit() >= position.y) {
      _renderBarrier();
    }
    /// --------------------------------------------------------
    position.y = position.y - (bulletVelocity * dt);
    final random = Random();
    add(
        ParticleSystemComponent(
            particle: Particle.generate(
              count: 10,
              lifespan: 0.5,
              generator: (i) => AcceleratedParticle(
                acceleration: _getRandomVector(),
                speed: _getRandomVector(),
                child: CustomParticle(
                  radius: 1,
                  paint: Paint()
                    ..color = game.manager.gameColors[
                      random.nextInt(
                          game.manager.gameColors.length
                      )
                    ],
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
    if (other is Bar && other.color != bulletColor) {
      /// Not successful bullet to bar
      play(asset: 'mismatch.wav', volume: 0.1);
      game.add(
          ParticleSystemComponent(
              particle: Particle.generate(
                count: 50,
                lifespan: 1,
                generator: (i) => AcceleratedParticle(
                  position: position.clone(),
                  acceleration: _getRandomVector() * 2.0,
                  speed: _getRandomVector() * 2.0,
                  child: CustomParticle(
                    radius: 1,
                    paint: Paint()..color = bulletColor,
                  ),
                ),
              )
          )
      );
      game.manager.onBulletColorMiss();
    }
    super.onCollision(intersectionPoints, other);
  }

  /// Renders a barrier for the bullet
  void _renderBarrier() {
    final random = Random();
    game.add(
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
                  ..color = game.manager.gameColors[
                    random.nextInt(
                        game.manager.gameColors.length
                    )
                  ],
                shadowColor: bulletColor
              ),
            ),
          ),
        )
    );
    game.add(
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
                    ..color = game.manager.gameColors[
                      random.nextInt(
                          game.manager.gameColors.length
                      )
                    ],
                  shadowColor: bulletColor
              ),
            ),
          ),
        )
    );
    game.remove(this);
  }

  /// Gets a random vector
  _getRandomVector() {
    final random = Random();
    return (Vector2.random(random) - Vector2(0.5, -1)) * 100;
  }

  // This method generates a random vector with its angle
  _getBarrierVector({bool right = true}) {
    final random = Random();
    return (Vector2(random.nextDouble(), random.nextInt(1).toDouble())) * (right == true ? 1000 : -1000);
  }
}