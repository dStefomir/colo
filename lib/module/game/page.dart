import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/bullet.dart';
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
const List<Color> barColors = [
  Colors.deepPurpleAccent,
  Colors.pink,
  Colors.blue,
  Colors.greenAccent,
];
/// Game bullet colors
const Map<String, Color> bulletColors = {
  'assets/bullet_purple.riv' : Colors.deepPurpleAccent,
  'assets/bullet_red.riv': Colors.pink,
  'assets/bullet_blue.riv': Colors.blue,
  'assets/bullet_green.riv': Colors.greenAccent,
};
/// Game bullet aim colors
const Map<String, Color> aimColors = {
  'assets/aim_purple.riv' : Colors.deepPurpleAccent,
  'assets/aim_red.riv': Colors.pink,
  'assets/aim_blue.riv': Colors.blue,
  'assets/aim_green.riv': Colors.greenAccent,
};
/// Represents the game itself
class ColoGamePage extends FlameGame with TapDetector, HasCollisionDetection {
  /// Shared prefs
  late SharedPreferences _sharedPreferences;
  /// Is the game disabled or not.
  /// Disabled means no touch and rules apply to the game.
  late bool _disabled;
  /// Gama manager component
  late GameManager manager;
  /// Should remove bullet limiter or not
  late bool _shouldRemoveLimiter;
  /// Selected game level
  GameLevel? _level;

  ColoGamePage({
    required SharedPreferences sharedPrefs,
    required bool limiter,
    String? level, bool disabled = false
  }) {
    _sharedPreferences = sharedPrefs;
    _shouldRemoveLimiter = limiter;
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
          add(
              Bullet(
                  gameSize: size,
                  getBars: () => children.whereType<Bar>().toList(),
                  gameColors: manager.gameColors,
                  onGameAdd: (component) => add(component),
                  onGameRemove: (component) => remove(component),
                  bulletManager: manager.bulletManager,
                  bulletColor: actionButton.buttonColor,
                  bulletSize: bulletSize,
                  shouldRemoveLimiter: _shouldRemoveLimiter
              )
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