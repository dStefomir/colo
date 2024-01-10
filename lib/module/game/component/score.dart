import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

/// Renders a text score
class Score extends TextComponent with HasGameRef<ColoGamePage> {
  @override
  final String text;

  Score({required this.text}) : super(
      anchor: Anchor.topCenter,
  );

  @override
  Future<void> onLoad() async {
    /// Determine the biggest side of the display
    final biggestSide = game.size.y > game.size.x ? game.size.y : game.size.x;
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
          fontSize: biggestSide / 25,
          fontFamily: 'RenegadePursuit',
          fontWeight: FontWeight.bold
      ),
    );
    priority = 1;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(game.size.x / 2, game.size.y / 18);
  }
}