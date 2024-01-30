import 'package:colo/module/game/component/background.dart';
import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/bullet.dart';
import 'package:colo/module/game/component/color_button.dart';
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
  /// Game score
  late Score _score;
  /// Sub managers -------------------------------------------------------------
  late BarManager _barManager;
  /// Bullet manager
  late BulletManager _bulletManager;
  /// Button manager
  late ButtonManager _buttonManager;
  /// --------------------------------------------------------------------------

  GameManager({required SharedPreferences sharedPreferences, required this.disabled, GameLevel? level}) {
    _sharedPreferences = sharedPreferences;
    _selectedLevel = level ?? GameLevel.easy;
    _level = disabled ? GameLevel.easy : level ?? GameLevel.easy;
    _gameColors = List.generate(barColors.length, (index) => barColors[index])..shuffle();
    _destroyedBars = ValueNotifier(0);
  }

  @override
  Future<void> onLoad() async {
    _score = Score(
        gameSize: game.size,
        text: '${_destroyedBars.value}'
    );
    if (!disabled) {
      _barManager = BarManager(
        disabled: disabled,
        level: level
      );
      _bulletManager = BulletManager();
      _buttonManager = ButtonManager();
      await add(_barManager);
      await add(_bulletManager);
      await add(_buttonManager);

      if (_level == GameLevel.hard) {
        game.add(_score);
      }
    }
    await add(Background());
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
  void handleGamePause() {
    if (!game.paused) {
      game.overlays.add('gamePause');
      barManager.pauseBars();
      game.pauseEngine();
    } else {
      game.overlays.remove('gamePause');
      barManager.unPauseBars();
      game.resumeEngine();
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
    _gameColors.shuffle();
    _destroyedBars.value = 0;
    game.overlays.remove('gameOver');
    if (_level == GameLevel.hard) {
      game.remove(_score);
    }
    _level = _selectedLevel;
    game.removeAll(game.children.whereType<Bullet>());
    game.removeAll(game.children.whereType<Bar>());
    game.removeAll(game.children.whereType<ColorfulButton>());
    _buttonManager.restartState();
    _barManager.restartState();
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
  void decreaseScore() {
    _destroyedBars.value = _destroyedBars.value - 1;
    if (_destroyedBars.value < 0) {
      gameOver();
    }
  }

  /// Resets the game score
  void resetScore() => _destroyedBars.value = 0;

  /// Increases the game level
  void _increaseLevel() async {
    /// Sets medium level
    if (_destroyedBars.value == 10 && _level == GameLevel.easy) {
      if (_buttonManager.actionButtons.length == 2) {
        _level = GameLevel.medium;
        await _buttonManager.addExtraActionButton();
      }
    }
    /// Sets hard level
    if (_destroyedBars.value == 20 && _level == GameLevel.medium) {
      if (_buttonManager.actionButtons.length == 3) {
        _level = GameLevel.hard;
        await _buttonManager.addExtraActionButton();
        _destroyedBars.value = 0;
        await game.add(_score);
      }
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
}