import 'package:colo/module/game/utils/vibration.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/rendering.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

/// Renders a colorful button
class ColorfulButton extends RiveComponent {
  /// Art board for the riv component
  final Artboard artBoard;
  /// Color of the button
  final Color color;
  /// Position of the button
  final Vector2 Function() btnPosition;
  /// Height of the button
  final double buttonSize;

  ColorfulButton({
    required this.artBoard,
    required this.buttonSize,
    required this.color,
    required this.btnPosition
  }) : super(
    artboard: artBoard,
    size: Vector2(buttonSize, buttonSize),
    position: btnPosition()
  );

  @override
  Future<void> onLoad() async{
    super.onLoad();
    priority = 1;
    decorator.addLast(
        Shadow3DDecorator(
          angle: - 0.5,
          xShift: 1.2,
          yScale: 1.2,
          opacity: 0.5,
          blur: 1.5,
        )
    );
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

  /// What happens when the button is clicked and not released
  void handleClick() async {
    await add(
        MoveByEffect(
            Vector2(0, 10),
            EffectController(
              duration: 0.2,
              curve: Curves.decelerate,
            ),
            onComplete: () => add(
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
    vibrate();
  }
}