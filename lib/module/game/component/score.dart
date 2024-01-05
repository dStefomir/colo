import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
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
          shadows: const <Shadow>[
            Shadow(
              offset: Offset(1.0, 1.0),
              blurRadius: 3.0,
              color: Colors.black,
            ),
          ],
          fontSize: game.size.y / 25,
          fontFamily: 'RenegadePursuit',
          fontWeight: FontWeight.bold
      ),
    );
    position = Vector2(game.size.x / 2, 70);
    priority = 1;
  }
}