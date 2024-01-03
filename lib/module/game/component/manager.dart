import 'dart:math';

import 'package:colo/module/game/component/background.dart';
import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/bullet.dart';
import 'package:colo/module/game/component/color_button.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/utils/audio.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_rive/flame_rive.dart';
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
  /// Action buttons structure
  late List<ColorfulButton> _actionButtons;
  /// Notifier for the current score
  late ValueNotifier<int> _destroyedBars;
  /// Current game level
  late GameLevel _level;
  /// Multiplier for the falling speed of the bars
  late double _barFallingSpeedMultiplier;

  GameManager({required SharedPreferences sharedPreferences, required this.disabled}) {
    _sharedPreferences = sharedPreferences;
    _level = disabled ? GameLevel.hard : GameLevel.easy;
    _gameColors = List.generate(_getGameColors(), (index) => barColors.values.toList()[index]);
    _destroyedBars = ValueNotifier(0);
    _barFallingSpeedMultiplier = 1;
  }

  @override
  Future<void> onLoad() async {
    if (!disabled) {
      _actionButtons = await _renderActionButtons();
      await game.addAll(_actionButtons);
    }
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);
    if (!disabled) {
      _increaseLevel();
    }
  }

  /// Reset the state of the manager
  void _resetState() {
    _level = GameLevel.easy;
    _gameColors = List.generate(_getGameColors(), (index) => barColors.values.toList()[index]);
    _destroyedBars.value = 0;
    _barFallingSpeedMultiplier = 1;
  }

  /// Renders the action buttons
  Future<List<ColorfulButton>> _renderActionButtons() async {
    final List<MapEntry<Artboard, Color>> rivBoards = [];

    for (final color in _gameColors) {
      rivBoards.add(
          MapEntry(
              await loadArtboard(
                  RiveFile.asset(
                      getButtonRivAssetBasedOnColor(color: color)
                  )
              ),
              color
          )
      );
    }
    return _gameColors.map((e) =>
        ColorfulButton(
            artBoard: rivBoards.firstWhere((element) => element.value == e).key,
            buttonSize: game.size.y / 10,
            color: e,
            btnPosition: () {
              const double padding = 5;
              final double dX = game.size.y / 10;
              final double dY = game.size.y - (game.size.y / 10 + padding);

              /// Game has two colors
              if (_gameColors.length == 2) {
                if (_gameColors.indexOf(e) == 0) {

                  return Vector2(padding, dY);
                } else {

                  return Vector2(
                      game.size.x - (dX + padding),
                      dY
                  );
                }

                /// Game has three colors
              } else if (_gameColors.length == 3) {
                if (_gameColors.indexOf(e) == 0) {

                  return Vector2(padding, dY);
                } else if (_gameColors.indexOf(e) == 2) {

                  return Vector2(
                      (padding + dX) * 0.99,
                      dY - colorfulBtnSize / 2
                  );
                } else {

                  return Vector2(
                      game.size.x - (dX + padding),
                      dY
                  );
                }

                /// Game has four colors
              } else {
                if (_gameColors.indexOf(e) == 0) {

                  return Vector2(padding, dY);
                } else if (_gameColors.indexOf(e) == 2) {

                  return Vector2(
                      dX,
                      dY - colorfulBtnSize / 2
                  );
                } else if (_gameColors.indexOf(e) == 3) {

                  return Vector2(
                      game.size.x - ((padding + dX) * 1.89),
                      dY - colorfulBtnSize / 2
                  );
                } else {

                  return Vector2(
                      game.size.x - (dX + padding),
                      dY
                  );
                }
              }
            })
    ).toList();
  }

  /// Gets the number of different colors in the game
  int _getGameColors() {
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

  /// Adds a button to the game
  Future<void> _addExtraActionButton() async {
    game.removeAll(_actionButtons);
    _gameColors = [..._gameColors, barColors.values.toList()[_getGameColors()]];
    _actionButtons = await _renderActionButtons();
    game.addAll(_actionButtons);
  }

  /// Increases the game level
  void _increaseLevel() async {
    /// Sets medium level
    if (_destroyedBars.value == 10) {
      if (_actionButtons.length == 2) {
        _addExtraActionButton();
        _level = GameLevel.medium;
        final background = game.children.whereType<Background>().where((element) => element.priority == -1).toList().first;
        background.add(
            MoveByEffect(
                Vector2(0, game.size.y * - 1),
                EffectController(
                  duration: 0.5,
                  curve: Curves.fastOutSlowIn,
                ),
                onComplete: () => game.remove(background)
            )
        );
      }
    }
    /// Sets hard level
    if (_destroyedBars.value == 30) {
      if (_actionButtons.length == 3) {
        _addExtraActionButton();
        _level = GameLevel.hard;
        final background = game.children.whereType<Background>().where((element) => element.priority == -2).toList().first;
        background.add(
            MoveByEffect(
                Vector2(0, game.size.y * - 1),
                EffectController(
                  duration: 0.5,
                  curve: Curves.fastOutSlowIn,
                ),
                onComplete: () => game.remove(background)
            )
        );
      }
    }
    /// If its hard level and 20 more bars are destroyed - increase bar falling speed
    if (_level == GameLevel.hard && _destroyedBars.value % 20 == 1 && _barFallingSpeedMultiplier < 1.57) {
      _barFallingSpeedMultiplier = _barFallingSpeedMultiplier + 0.002;
    }
  }

  /// Decrease the current score
  void _decreaseScore() {
    _destroyedBars.value = _destroyedBars.value - 1;
    if (_destroyedBars.value < 0) {
      gameOver();
    }
  }

  /// Gets a background asset based on the game level
  String getBackgroundAsset() {
    String asset;

    switch(_level) {
      case GameLevel.easy:
        asset = 'background_easy.jpg';
        break;
      case GameLevel.medium:
        asset = 'background_medium.jpg';
        break;
      case GameLevel.hard:
        asset = 'background_hard.jpg';
        break;
    }

    return asset;
  }

  /// Removes a bar from the game
  void removeBar({required Bar bar}) => game.remove(bar);

  /// Gets bar explosion lifespan for particles
  double getBarExplosionLifespan() {
    double lifespan;

    switch (_level) {
      case GameLevel.easy:
        lifespan = 0.3;
        break;
      case GameLevel.medium:
        lifespan = 1.5;
        break;
      case GameLevel.hard:
        lifespan = 1.5 * _barFallingSpeedMultiplier;
        break;
    }

    return lifespan;
  }

  /// Gets bar explosion count for particles
  int getBarExplosionParticles() {
    int count;

    switch (_level) {
      case GameLevel.easy:
        count = 50;
        break;
      case GameLevel.medium:
        count = 100;
        break;
      case GameLevel.hard:
        count = (100 * _barFallingSpeedMultiplier).toInt();
        break;
    }

    return count;
  }

  /// Gets a riv file bar color based on the game level
  String getBarRivAssetBasedOnColor({required Color color}) {
    if (_level == GameLevel.easy || _level == GameLevel.medium) {

      return barColors.entries.firstWhere((element) => element.value == color).key;
    }
    final random = Random();

    return barColors.keys.toList()[random.nextInt(barColors.length)];
  }

  /// Gets a riv file bullet color based on the game level
  String getBulletRivAssetBasedOnColor({required Color color}) => bulletColors.entries.firstWhere((element) => element.value == color).key;

  /// Gets a riv file button color based on the game level
  String getButtonRivAssetBasedOnColor({required Color color}) => buttonColors.entries.firstWhere((element) => element.value == color).key;

  /// Gets a dy limit for the bullet based on the game level
  double getBulletDyLimit() {
    double dy;

    switch (_level) {
      case GameLevel.easy:
        dy = 0;
        break;
      case GameLevel.medium:
        dy = game.size.y / 2;
        break;
      case GameLevel.hard:
        dy = game.size.y / 1.5;
        break;
    }

    return dy;
  }

  /// What happens when a bullet color hit a falling bar
  /// with a different color
  void onBulletColorMiss() {
    if (_level == GameLevel.easy) {
      _decreaseScore();
    } else if (_level == GameLevel.medium) {
      if (_destroyedBars.value > 0) {
        _destroyedBars.value = 0;
      } else {
        _decreaseScore();
      }
    } else if (_level == GameLevel.hard) {
      gameOver();
    }
  }

  /// Increase the current score
  void increaseScore() {
    _destroyedBars.value = _destroyedBars.value + 1;
    if (_sharedPreferences.getInt('score') == null) {
      _sharedPreferences.setInt('score', _destroyedBars.value);
    } else if (_sharedPreferences.getInt('score') != null && (_sharedPreferences.getInt('score')! < _destroyedBars.value)) {
      _sharedPreferences.setInt('score', _destroyedBars.value);
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
    _resetState();
    game.overlays.remove('gameOver');
    game.removeAll(game.children.whereType<Bullet>());
    game.removeAll(game.children.whereType<Bar>());
    game.removeAll(game.children.whereType<ColorfulButton>());

    _actionButtons = await _renderActionButtons();
    await game.addAll(_actionButtons);

    game.resumeEngine();
  }

  /// Gets the game colors
  List<Color> get gameColors => _gameColors;

  /// Gets the action buttons
  List<ColorfulButton> get actionButtons => _actionButtons;

  /// Gets the current score
  int get score => _destroyedBars.value;

  /// Gets the bar falling speed multiplier
  double get barFallingSpeedMultiplier => _barFallingSpeedMultiplier;
}