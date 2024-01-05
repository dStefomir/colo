import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/bullet.dart';
import 'package:colo/module/game/component/color_button.dart';
import 'package:colo/module/game/component/manager/background.dart';
import 'package:colo/module/game/component/manager/bar.dart';
import 'package:colo/module/game/component/manager/bullet.dart';
import 'package:colo/module/game/component/manager/button.dart';
import 'package:colo/module/game/component/score.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/utils/audio.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameLevel {
  easy, medium, hard
}

/// Manger for controlling the game rules
class GameManager extends Component with HasGameRef<ColoGamePage> {
  /// Is the game disabled or not.
  /// Disabled means no touch and rules apply to the game.
  final bool disabled;
  /// Sub managers -------------------------------------------------------------
  late BarManager _barManager;
  /// Bullet manager
  late BulletManager _bulletManager;
  /// Button manager
  late ButtonManager _buttonManager;
  /// Background manager
  late BackgroundManager _backgroundManager;
  /// --------------------------------------------------------------------------
  /// Shared prefs
  late SharedPreferences _sharedPreferences;
  /// Game colors structure
  late List<Color> _gameColors;
  /// Notifier for the current score
  late ValueNotifier<int> _destroyedBars;
  /// Current game level
  late GameLevel _level;
  /// Selected game level
  late GameLevel _selectedLevel;
  /// Multiplier for the falling speed of the bars
  late double _barFallingSpeedMultiplier;
  /// Game score
  late Score _score;

  GameManager({required SharedPreferences sharedPreferences, required this.disabled, GameLevel? level}) {
    _sharedPreferences = sharedPreferences;
    _selectedLevel = level ?? GameLevel.easy;
    _level = disabled ? GameLevel.hard : level ?? GameLevel.easy;
    _gameColors = List.generate(barColors.values.length, (index) => barColors.values.toList()[index]);
    _destroyedBars = ValueNotifier(0);
    _barFallingSpeedMultiplier = 1;
    _score = Score(text: '${_destroyedBars.value}');
  }

  @override
  Future<void> onLoad() async {
    if (!disabled) {
      _barManager = BarManager();
      _bulletManager = BulletManager();
      _buttonManager = ButtonManager();
      _backgroundManager = BackgroundManager();
      await add(_barManager);
      await add(_bulletManager);
      await add(_buttonManager);
      await add(_backgroundManager);

      if (_level == GameLevel.hard) {
        game.add(_score);
      }
    }
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);
    if (!disabled) {
      _increaseLevel();
      /// Updates the text score component
      if (_level == GameLevel.hard) {
        _score.text = '${_destroyedBars.value}';
      }
    }
  }

  /// Pauses the game
  void gameOver() {
    if (!disabled) {
      play(asset: 'game_over.wav', volume: 0.3);
      game.overlays.add('gameOver');
      game.pauseEngine();
    }
  }

  /// Restarts the game
  Future<void> restartGame() async {
    _destroyedBars.value = 0;
    _barFallingSpeedMultiplier = 1;
    game.overlays.remove('gameOver');
    if (_level == GameLevel.hard) {
      game.remove(_score);
    }
    _level = _selectedLevel;
    game.removeAll(game.children.whereType<Bullet>());
    game.removeAll(game.children.whereType<Bar>());
    game.removeAll(game.children.whereType<ColorfulButton>());
    _buttonManager.restartState();
    game.resumeEngine();
    if (_level == GameLevel.hard) {
      game.add(_score);
    }
  }

  /// Gets the number of different colors in the game
  int getGameColors() {
    int colors;
    switch (_level) {
      case GameLevel.easy:
        colors = 2;
        break;
      case GameLevel.medium:
        colors = 3;
        break;
      case GameLevel.hard:
        colors = 4;
        break;
    }

    return colors;
  }

  /// What happens when a bar is hit by a bullet with different color
  void onBulletColorMiss() => _bulletManager.onBulletColorMiss(
      level: level,
      currentScore: _destroyedBars.value,
      onGameOver: gameOver,
      onDecreaseScore: _decreaseScore,
      onResetDestroyedBars: () => _destroyedBars.value = 0
  );

  /// Increase the current score
  void increaseScore() {
    _destroyedBars.value = _destroyedBars.value + 1;
    if (_level == GameLevel.hard) {
      if (_sharedPreferences.getInt('score') == null) {
        _sharedPreferences.setInt('score', _destroyedBars.value);
      } else if (_sharedPreferences.getInt('score') != null && (_sharedPreferences.getInt('score')! < _destroyedBars.value)) {
        _sharedPreferences.setInt('score', _destroyedBars.value);
      }
    }
  }

  /// Decrease the current score
  void _decreaseScore() {
    _destroyedBars.value = _destroyedBars.value - 1;
    if (_destroyedBars.value < 0) {
      gameOver();
    }
  }

  /// Increases the game level
  void _increaseLevel() async {
    /// Sets medium level
    if (_destroyedBars.value == 10 && _level == GameLevel.easy) {
      if (_buttonManager.actionButtons.length == 2) {
        _level = GameLevel.medium;
        await _buttonManager.addExtraActionButton();
        _backgroundManager.removeCurrentBackground(priorityOfCurrent: -1);
      }
    }
    /// Sets hard level
    if (_destroyedBars.value == 30 && _level == GameLevel.medium) {
      if (_buttonManager.actionButtons.length == 3) {
        _level = GameLevel.hard;
        await _buttonManager.addExtraActionButton();
        _destroyedBars.value = 0;
        await game.add(_score);
        _backgroundManager.removeCurrentBackground(priorityOfCurrent: -2);
      }
    }
    /// If its hard level and 20 more bars are destroyed - increase bar falling speed
    if (_level == GameLevel.hard && _destroyedBars.value % 20 == 1 && _barFallingSpeedMultiplier < 1.57) {
      _barFallingSpeedMultiplier = _barFallingSpeedMultiplier + 0.002;
    }
  }

  /// Gets the bar manager
  BarManager get barManager => _barManager;
  /// Gets the bullet manager
  BulletManager get bulletManager => _bulletManager;
  /// Gets the button manager
  ButtonManager get buttonManager => _buttonManager;
  /// Gets the game colors
  List<Color> get gameColors => _gameColors;
  /// Gets the game level
  GameLevel get level => _level;
  /// Gets the current score
  int get score => _destroyedBars.value;
  /// Gets the bar falling speed multiplier
  double get barFallingSpeedMultiplier => _barFallingSpeedMultiplier;
}