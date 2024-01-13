import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/bullet.dart';
import 'package:colo/module/game/component/riv.dart';
import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

/// Renders a cannot that shoots bullets
class Cannon extends RivAnimationComponent with HasGameRef<ColoGamePage> {
  /// Art board for the riv component
  final Artboard artBoard;
  /// Dy effect of the cannon
  MoveEffect? _dYEffect;

  Cannon({
    required this.artBoard,
    Vector2? size,
    Vector2? position,
  }) : super(
      artBoard: artBoard,
      size: size,
      position: position,
      stateMachineKey: 'State Machine 1',
      animationKey: 'Background Travel'
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    priority = 3;
    size = game.size / 2;
    position = Vector2((game.size.x / 4), (game.size.y / 1.35));
    _dYEffect = _initDyEffect();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size / 2;
    position = Vector2((size.x / 4), (size.y / 1.35));
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
        Offset(game.size.x / 4, game.size.y / 4),
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
  }

  /// Moves the cannon to target
  void moveToTargetAndShoot({
    required Color bulletColor,
    required bool shouldRemoveBulletLimiter}) {
    final firstFallingBar = game.children.whereType<Bar>().first;
    final double currentDXPosition = this.position.x;
    final Vector2 position = Vector2((firstFallingBar.position.x - currentDXPosition) + bulletSize, 0);
    add(
        MoveByEffect(
          position,
          EffectController(
            duration: 0.2,
            curve: Curves.decelerate,
          ),
          onComplete: () async {
            await game.add(
                Bullet(
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
                    )
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