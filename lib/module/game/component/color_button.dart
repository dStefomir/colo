import 'package:colo/utils/vibration.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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