import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

/// Renders a text score
class Score extends TextComponent {
  /// Game size
  final Vector2 gameSize;
  /// Text of the score
  @override
  final String text;

  Score({required this.gameSize, required this.text}) : super(
      anchor: Anchor.topCenter,
  );

  @override
  Future<void> onLoad() async {
    /// Determine the biggest side of the display
    final biggestSide = gameSize.y > gameSize.x ? gameSize.y : gameSize.x;
    textRenderer = TextPaint(
      style: TextStyle(
          foreground: Paint()..shader = const LinearGradient(
            colors: barColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            tileMode: TileMode.clamp,
          ).createShader(Rect.fromPoints(const Offset(50, 0), Offset(size.x, size.y))),
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
    position = Vector2(gameSize.x / 2, gameSize.y / 18);
  }
}