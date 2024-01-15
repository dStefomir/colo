import 'dart:math';

import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/bullet.dart';
import 'package:colo/module/game/component/manager/bullet.dart';
import 'package:colo/module/game/component/particle.dart';
import 'package:colo/module/game/component/riv.dart';
import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

/// Renders a cannot that shoots bullets
class Cannon extends RivAnimationComponent {
  /// Game size
  final Vector2 gameSize;
  /// Falling bars
  final List<Bar> Function() getBars;
  /// Game colors
  final List<Color> gameColors;
  /// Adds component to the game
  final void Function(Component) onGameAdd;
  /// Removes component to the game
  final void Function(Component) onGameRemove;
  /// Bullet manager
  final BulletManager bulletManager;
  /// Art board for the riv component
  final Artboard artBoard;
  /// Dy effect of the cannon
  MoveEffect? _dYEffect;

  Cannon({
    required this.gameSize,
    required this.getBars,
    required this.gameColors,
    required this.onGameAdd,
    required this.onGameRemove,
    required this.bulletManager,
    required this.artBoard,
    Vector2? size,
    Vector2? position,
  }) : super(
      artBoard: artBoard,
      size: size,
      position: position,
      stateMachineKey: '',
      animationKey: ''
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    priority = 3;
    size = Vector2.all(200);
    position = Vector2(gameSize.x / 2 - size.x / 2, gameSize.y / 1.17);
    _dYEffect = _initDyEffect();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    size = Vector2.all(200);
    position = Vector2(gameSize.x / 2 - size.x / 2, gameSize.y / 1.17);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
        Offset(gameSize.x / 4, gameSize.y / 4),
        size.x / 14,
        Paint()
          ..color = Colors.black54
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
    );
    super.render(canvas);
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);
    if (_dYEffect != null) {
      await add(_dYEffect!);
    } else {
      _dYEffect = _initDyEffect();
    }
    add(
        ParticleSystemComponent(
            particle: Particle.generate(
              count: 10,
              lifespan: 0.5,
              generator: (i) => AcceleratedParticle(
                position: Vector2(100, 120),
                acceleration: bulletManager.getRandomVector(),
                speed: bulletManager.getRandomVector(),
                child: CustomParticle(
                    radius: 1,
                    paint: Paint()
                      ..color = Colors.red,
                    shadowColor: Colors.amber
                ),
              ),
            )
        )
    );
  }

  /// Moves the cannon to target
  void moveToTargetAndShoot({
    required Color bulletColor,
    required bool shouldRemoveBulletLimiter}) {
    final lastFallingBar = getBars().first;

    final Vector2 position = Vector2((lastFallingBar.position.x - this.position.x) + bulletSize, 0);
    add(
        MoveByEffect(
            position,
            EffectController(
              duration: 0.2,
              curve: Curves.decelerate,
            ),
            onComplete: () async {
              onGameAdd(
                  Bullet(
                      gameSize: gameSize,
                      getBars: getBars,
                      gameColors: gameColors,
                      onGameAdd: onGameAdd,
                      onGameRemove: onGameRemove,
                      bulletManager: bulletManager,
                      bulletColor: bulletColor,
                      bulletSize: bulletSize,
                      shouldRemoveLimiter: shouldRemoveBulletLimiter
                  )
              );
              add(
                  MoveByEffect(
                      -position,
                      EffectController(
                        duration: 0.8,
                        curve: Curves.decelerate,
                      ),
                  )
              );
            }
        )
    );
  }

  /// Initializes the moving effect of the cannon
  MoveEffect _initDyEffect() => MoveByEffect(
      Vector2(0, -20),
      EffectController(
        duration: 1.5,
        curve: Curves.linear,
      ),
      onComplete: () => add(
          MoveByEffect(
              Vector2(0, 20),
              EffectController(
                duration: 1.5,
                curve: Curves.linear,
              ),
              onComplete: () => _dYEffect = null
          )
      )
  );
}