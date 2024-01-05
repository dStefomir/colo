import 'package:colo/module/game/component/background.dart';
import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/bullet.dart';
import 'package:colo/module/game/component/color_button.dart';
import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/component/score.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
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
/// Speed of the background parallax effect
const backgroundParallax = 45.0;
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
  /// Is the game disabled or not.
  /// Disabled means no touch and rules apply to the game.
  late bool _disabled;
  /// Gama manager component
  late GameManager manager;
  /// Game score
  late Score _score;
  /// Timer for updating the falling bars
  Timer? _barInterval;

  ColoGamePage({required SharedPreferences sharedPrefs, bool disabled = false}) {
    _sharedPreferences = sharedPrefs;
    _disabled = disabled;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    manager = GameManager(sharedPreferences: _sharedPreferences, disabled: _disabled);
    _score = Score(text: '${manager.score}');
    /// ---------------- Adds components to the game ---------------------------
    await addAll(
        [
          manager,
          if (!_disabled) Background(
              disabled: _disabled,
              asset: 'background_hard.jpg',
              priority: -3
          ),
          if (!_disabled) Background(
              disabled: _disabled,
              asset: 'background_medium.jpg',
              priority: -2
          ),
          Background(
              disabled: _disabled,
              asset: 'background_easy.jpg',
              priority: -1
          ),
          if (!_disabled) _score,
        ]
    );
    /// ------------------------------------------------------------------------

    if (!_disabled) {
      _barInterval = Timer(barInterval / manager.barFallingSpeedMultiplier, repeat: true);
      _barInterval!.onTick = () async {
        await add(_renderBar());
      };
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _barInterval?.limit = barInterval / manager.barFallingSpeedMultiplier;
    _barInterval?.update(dt);
    /// Updates the text score component
    _score.text = '${manager.score}';
  }

  @override
  void onTapUp(TapUpInfo info) {
    super.onTapUp(info);
    try {
      final ColorfulButton actionButton = children.whereType<ColorfulButton>().firstWhere((element) => element.containsPoint(info.eventPosition.global));
      if (actionButton.type == ButtonType.color) {
        final Color buttonColor = manager.gameColors[manager.buttonManager.actionButtons.indexOf(actionButton)];
        add(
            Bullet(
                bulletColor: buttonColor,
                bulletSize: bulletSize
            )
        );
      } else {
        children.whereType<Bar>().forEach((element) => element.destroyBar());
      }
      actionButton.handleClick();
    } catch (e) {
      if (kDebugMode) {
        print("No button was clicked");
      }
    }
  }

  /// Renders the falling bars
  _renderBar() => Bar(
    barColor: manager.barManager.getBarColor(),
    barSize: Vector2(255, 64),
  );
}