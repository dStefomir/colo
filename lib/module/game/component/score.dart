import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

/// Renders a text score
class Score extends TextComponent with HasGameRef<ColoGamePage> {

  @override
  final String text;

  Score({required this.text}) : super(
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontFamily: 'RenegadePursuit',
            fontWeight: FontWeight.bold
        ),
      )
  );

  @override
  Future<void> onLoad() async {
    decorator.addLast(
        Shadow3DDecorator(
          angle: -0.5,
          xShift: 1.2,
          yScale: 1.2,
          opacity: 0.5,
          blur: 1.5,
        )
    );
    position = Vector2(game.size.x / 2, 70);
  }
}