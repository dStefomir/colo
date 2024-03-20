import 'dart:math';

import 'package:colo/module/game/component/manager/bar.dart';
import 'package:colo/module/game/component/particle.dart';
import 'package:colo/utils/vibration.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

enum ButtonType {
  color, bomb
}

/// Renders a colorful button
class ColorfulButton extends RiveComponent {
  /// Bar manager
  final BarManager barManager;
  /// Color of the button
  final Color buttonColor;
  /// Art board for the riv component
  final Artboard artBoard;
  /// Game size
  final Vector2 gameSize;
  /// Adds a component to the game
  final void Function(Component) onGameAdd;
  /// Position of the button
  final Vector2 Function() buttonPosition;
  /// Height of the button
  final double buttonSize;
  /// What type the button should be
  final ButtonType type;
  /// Effect of the button
  MoveEffect? _effect;

  ColorfulButton({
    required this.barManager,
    required this.buttonColor,
    required this.artBoard,
    required this.gameSize,
    required this.buttonSize,
    required this.buttonPosition,
    required this.onGameAdd,
    required this.type
  }) : super(
    artboard: artBoard,
    size: Vector2(buttonSize, buttonSize),
    position: buttonPosition()
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    priority = 1;
    add(
        MoveByEffect(
            Vector2(0, -80),
            EffectController(
              duration: 0.5,
              curve: Curves.linear,
            ),
        )
    );
    _effect = _initEffect();
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );
    if (controller != null) {
      artboard.addController(controller);
      final levelInput = controller.findInput<double>('Idle');
      levelInput?.value = 0;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = buttonPosition();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(buttonSize / 2, buttonSize / 2), buttonSize / 2.2, Paint()
      ..color = Colors.black
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));
    super.render(canvas);
  }


  @override
  Future<void> update(double dt) async {
    super.update(dt);
    if (_effect != null) {
      await add(_effect!);
    } else {
      _effect = _initEffect();
    }
  }

  /// What happens when the button is clicked and not released
  void handleClick() async {
    if (type == ButtonType.color) {
      add(
          MoveByEffect(
              Vector2(0, 10),
              EffectController(
                duration: 0.2,
                curve: Curves.decelerate,
              ),
              onComplete: () =>
                  add(
                      MoveByEffect(
                        Vector2(0, -10),
                        EffectController(
                          duration: 0.2,
                          curve: Curves.decelerate,
                        ),
                      )
                  )
          )
      );
    } else {
      onGameAdd(
          ParticleSystemComponent(
            particle: Particle.generate(
              count: barManager.getBarExplosionParticles(),
              lifespan: barManager.getBarExplosionLifespan(),
              generator: (i) => AcceleratedParticle(
                acceleration: _getRandomVector() * 3.0,
                speed: _getRandomVector() * 8.0,
                position: Vector2((gameSize / 2).x, position.y),
                child: CustomParticle(
                    radius: 3,
                    shadowColor: Colors.black87,
                    paint: Paint()
                      ..color = Colors.black
                ),
              ),
            ),
          )
      );
      removeFromParent();
    }
    vibrate();
  }

  /// Initializes the moving effect of the buttons
  MoveEffect _initEffect() => MoveByEffect(
      Vector2(0, -6),
      EffectController(
        duration: 1.5,
        curve: Curves.linear,
      ),
      onComplete: () => add(MoveByEffect(
          Vector2(0, 6),
          EffectController(
            duration: 1.5,
            curve: Curves.linear,
          ),
          onComplete: () => _effect = null
      )
      )
  );

  // This method generates a random vector with its angle
  // between from 0 and 360 degrees.
  _getRandomVector() {
    final random = Random();
    return (Vector2.random(random) - Vector2.random(random)) * 500;
  }
}