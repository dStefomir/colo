import 'package:colo/model/account.dart';
import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/bullet.dart';
import 'package:colo/module/game/component/cannon.dart';
import 'package:colo/module/game/component/color_button.dart';
import 'package:colo/module/game/component/manager/manager.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Size of the action buttons
const colorfulBtnSize = 75.0;
/// Size of the bullet
const bulletSize = 15.0;
/// Bar speed easy mode
const barVelocity = 100.0;
/// Interval for the timer of the falling bars
const barInterval = 1;
/// Velocity of the bullet
const bulletVelocity = 500;
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
class ColoGamePage extends FlameGame with TapDetector, HasCollisionDetection {
  /// Shared prefs
  late SharedPreferences _sharedPreferences;
  /// User account
  late Account _account;
  /// Is the game disabled or not.
  /// Disabled means no touch and rules apply to the game.
  late bool _disabled;
  /// Gama manager component
  late GameManager manager;
  /// Selected game level
  GameLevel? _level;

  ColoGamePage({
    required SharedPreferences sharedPrefs,
    required Account account,
    String? level, bool disabled = false
  }) {
    _sharedPreferences = sharedPrefs;
    _account = account;
    if (level == 'easy') {
      _level = GameLevel.easy;
    } else if (level == 'medium') {
      _level = GameLevel.medium;
    } else if (level == 'hard') {
      _level = GameLevel.hard;
    }
    _disabled = disabled;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    manager = GameManager(sharedPreferences: _sharedPreferences, level: _level, disabled: _disabled);
    await add(manager);
  }

  @override
  void onTapUp(TapUpInfo info) {
    super.onTapUp(info);
    if (!_disabled) {
      try {
        /// An colorful button has been pressed
        final ColorfulButton actionButton = children.whereType<ColorfulButton>().firstWhere((element) => element.containsPoint(info.eventPosition.global));
        if (actionButton.type == ButtonType.color) {
          final Color buttonColor = manager.gameColors[manager.buttonManager.actionButtons.indexOf(actionButton)];
          final cannon = children.whereType<Cannon>().first;
          cannon.moveToTargetAndShoot(
              bulletColor: buttonColor,
              shouldRemoveBulletLimiter: _account.rocketLimiter
          );
        } else {
          /// A Bomb button has been pressed
          children.whereType<Bar>().forEach((element) => element.destroyBar());
        }
        actionButton.handleClick();
      } catch (e) {
        /// The pressed anywhere else in screen where there are no buttons
        manager.handleGamePause();
      }
    }
  }
}