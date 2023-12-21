import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';

/// Renders a colorful button
class ColorfulButton extends SpriteComponent {

  /// Color of the button
  final Color color;
  /// Position of the button
  final Vector2 Function() btnPosition;
  /// Height of the button
  @override
  final double height;

  ColorfulButton({
    required this.height,
    required this.color,
    required this.btnPosition
  }) : super(
      children: [
        CircleComponent(
          paint: Paint()
            ..color = color
            ..filterQuality = FilterQuality.high
            ..isAntiAlias = true,
          radius: height - 7.5,
          position: Vector2(height / 4.8, height / 4.8),
        )
      ]
  );

  @override
  Future<void> onLoad() async{
    super.onLoad();
    final button = await Flame.images.load('round_button.png');
    decorator.addLast(
        Shadow3DDecorator(
          angle: -0.5,
          xShift: 1.2,
          yScale: 1.2,
          opacity: 0.5,
          blur: 1.5,
        )
    );
    position = btnPosition();
    size = Vector2(height * 2, height * 2);
    priority = 1;
    sprite = Sprite(button);
  }

  /// What happens when the button is clicked and not released
  void handleClick() async => await add(
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
}