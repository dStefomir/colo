import 'dart:math';

import 'package:colo/component/background.dart';
import 'package:colo/component/bar.dart';
import 'package:colo/component/bullet.dart';
import 'package:colo/component/color_button.dart';
import 'package:colo/component/manager.dart';
import 'package:colo/component/score.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Size of the action buttons
const colorfulBtnSize = 30.0;
/// Size of the bullet
const bulletSize = 15.0;
/// Bar speed easy mode
const barVelocity = 100.0;
/// Interval for the timer of the falling bars
const barInterval = 0.8;
/// Velocity of the bullet
const bulletVelocity = 500;
/// Game colors
const colors = [
  Colors.deepPurpleAccent,
  Colors.deepOrangeAccent,
  Colors.blue,
  Colors.greenAccent,
  Colors.yellowAccent
];

/// Represents the game itself
class ColoGame extends FlameGame with TapDetector, HasCollisionDetection {

  /// Timer for updating the falling bars
  late Timer _barInterval;
  /// Gama manager component
  late GameManager manager;
  /// Game score
  late Score _score;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    /// Loads the background music of the game
    FlameAudio.loopLongAudio('background.mp3', volume: 0.1);

    manager = GameManager(onChange: _onLevelChange);
    _score = Score(text: '${manager.score}');
    /// ---------------- Adds components to the game ---------------------------
    await addAll(
        [
          manager,
          Background(),
          _renderBar(),
          _score
        ]
    );
    /// ------------------------------------------------------------------------
    _barInterval = Timer(manager.getBarInterval(), repeat: true);
    /// What happens when timer updates the game
    _barInterval.onTick = () async {
      await add(_renderBar());
      await add(_score);
    };
  }

  @override
  void update(double dt) {
    super.update(dt);
    _barInterval.update(dt);
    _score.text = '${manager.score}';
  }

  @override
  void onTapUp(TapUpInfo info) {
    super.onTapUp(info);
    try {
      final ColorfulButton actionButton = manager.actionButtons.firstWhere((element) => element.containsPoint(info.eventPosition.global));
      final Color buttonColor = manager.gameColors[manager.actionButtons.indexOf(actionButton)];
      FlameAudio.play('rocket.wav', volume: 0.1);
      actionButton.handleClick();
      add(Bullet(bulletColor: buttonColor, bulletSize: bulletSize));
    } catch (e) {
      if (kDebugMode) {
        print("No button was clicked");
      }
    }
  }

  /// Renders the falling bars
  _renderBar() {
    final Random random = Random();

    return Bar(
        color: manager.gameColors[random.nextInt(manager.gameColors.length)],
        barSize: Vector2(size.x / 1.5, 50),
    );
  }

  /// What happens when the game level is changed
  void _onLevelChange(GameLevel level) {
    _barInterval.limit = manager.getBarInterval();
    _barInterval.start();
  }
}