import 'dart:math';

import 'package:colo/module/game/component/particle.dart';
import 'package:colo/module/game/page.dart';
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
class ColorfulButton extends RiveComponent with HasGameRef<ColoGamePage> {
  /// Art board for the riv component
  final Artboard artBoard;
  /// Position of the button
  final Vector2 Function() btnPosition;
  /// Height of the button
  final double buttonSize;
  /// What type the button should be
  final ButtonType type;

  ColorfulButton({
    required this.artBoard,
    required this.buttonSize,
    required this.btnPosition,
    required this.type
  }) : super(
    artboard: artBoard,
    size: Vector2(buttonSize, buttonSize),
    position: btnPosition()
  );

  @override
  Future<void> onLoad() async{
    super.onLoad();
    await add(
        MoveByEffect(
            Vector2(0, -10),
            EffectController(
              duration: 1.5,
              curve: Curves.decelerate,
            ),
        )
    );
    priority = 1;
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
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(buttonSize / 2, buttonSize / 2), buttonSize / 2.2, Paint()
      ..color = Colors.black
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));
    super.render(canvas);
  }

  /// What happens when the button is clicked and not released
  void handleClick() async {
    if (type == ButtonType.color) {
      await add(
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
      await game.add(
          ParticleSystemComponent(
            particle: Particle.generate(
              count: game.manager.getBarExplosionParticles(),
              lifespan: game.manager.getBarExplosionLifespan(),
              generator: (i) => AcceleratedParticle(
                acceleration: _getRandomVector() * 3.0,
                speed: _getRandomVector() * 8.0,
                position: Vector2((game.size / 2).x, position.y),
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

  // This method generates a random vector with its angle
  // between from 0 and 360 degrees.
  _getRandomVector() {
    final random = Random();
    return (Vector2.random(random) - Vector2.random(random)) * 500;
  }
}