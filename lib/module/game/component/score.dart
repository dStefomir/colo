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
  );

  @override
  Future<void> onLoad() async {
    textRenderer = TextPaint(
      style: TextStyle(
          color: Colors.white,
          fontSize: game.size.y / 25,
          fontFamily: 'RenegadePursuit',
          fontWeight: FontWeight.bold
      ),
    );
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