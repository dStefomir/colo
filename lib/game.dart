import 'dart:math';

import 'package:colo/component/background.dart';
import 'package:colo/component/bar.dart';
import 'package:colo/component/bullet.dart';
import 'package:colo/component/color_button.dart';
import 'package:colo/component/manager.dart';
import 'package:colo/component/score.dart';
import 'package:colo/utils/audio.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Size of the action buttons
const colorfulBtnSize = 75.0;
/// Size of the bullet
const bulletSize = 15.0;
/// Bar speed easy mode
const barVelocity = 100.0;
/// Interval for the timer of the falling bars
const barInterval = 0.8;
/// Velocity of the bullet
const bulletVelocity = 500;
/// Speed of the background parallax effect
const backgroundParallax = 25.0;
/// Game button colors
const Map<String, Color> buttonColors = {
  'assets/button_purple.riv' : Colors.deepPurpleAccent,
  'assets/button_red.riv': Colors.pink,
  'assets/button_blue.riv': Colors.blue,
  'assets/button_green.riv': Colors.greenAccent,
};
/// Game bar colors
const Map<String, Color> barColors = {
  'assets/wave_purple.riv' : Colors.deepPurpleAccent,
  'assets/wave_red.riv': Colors.pink,
  'assets/wave_blue.riv': Colors.blue,
  'assets/wave_green.riv': Colors.greenAccent,
};
/// Game bullet colors
const Map<String, Color> bulletColors = {
  'assets/bullet_purple.riv' : Colors.deepPurpleAccent,
  'assets/bullet_red.riv': Colors.pink,
  'assets/bullet_blue.riv': Colors.blue,
  'assets/bullet_green.riv': Colors.greenAccent,
};
/// Represents the game itself
class ColoGame extends FlameGame with TapDetector, HasCollisionDetection {
  /// Timer for updating the falling bars
  late Timer _barInterval;
  /// Gama manager component
  late GameManager manager;
  /// Game score
  late Score _score;

  @override
  void onMount() {
    super.onMount();
    /// Loads the background music of the game
    playLooped(asset: 'background.mp3', volume: 0.05);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    manager = GameManager();
    _score = Score(text: '${manager.score}');
    /// ---------------- Adds components to the game ---------------------------
    await addAll(
        [
          manager,
          Background(asset: 'background.jpg'),
          _renderBar(),
          _score,
        ]
    );
    /// ------------------------------------------------------------------------

    /// Game looper
    _barInterval = Timer(barInterval, repeat: true);
    _barInterval.onTick = () async {
      await add(_renderBar());
      await add(_score);
    };
  }

  @override
  void update(double dt) {
    super.update(dt);
    _barInterval.update(dt);
    /// Updates the text score component
    _score.text = '${manager.score}';
  }

  @override
  void onTapUp(TapUpInfo info) {
    super.onTapUp(info);
    try {
      final ColorfulButton actionButton = manager.actionButtons.firstWhere((element) => element.containsPoint(info.eventPosition.global));
      final Color buttonColor = manager.gameColors[manager.actionButtons.indexOf(actionButton)];
      actionButton.handleClick();
      add(
          Bullet(
              bulletColor: buttonColor,
              bulletSize: bulletSize
          )
      );
    } catch (e) {
      if (kDebugMode) {
        print("No button was clicked");
      }
    }
  }

  /// Renders the falling bars
  _renderBar() {
    final random = Random();

    return Bar(
        color: manager.gameColors[random.nextInt(manager.gameColors.length)],
        barSize: Vector2(size.x / 2, 50),
    );
  }
}