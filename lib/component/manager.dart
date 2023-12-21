import 'dart:math';

import 'package:colo/component/color_button.dart';
import 'package:colo/game.dart';
import 'package:colo/utils/vibration.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum GameLevel {
  easy, medium, hard
}

/// Manger for controlling the game rules
class GameManager extends Component with HasGameRef<ColoGame> {

  final void Function(GameLevel) onChange;
  /// Game colors structure
  late List<Color> _gameColors;
  /// Action buttons structure
  late List<ColorfulButton> _actionButtons;
  /// Notifier for the current score
  late ValueNotifier<int> _destroyedBars;
  /// Current game level
  late GameLevel _level;

  GameManager({required this.onChange}) {
    _level = GameLevel.easy;
    _gameColors = List.generate(_getGameColors(), (index) => colors.values.toList()[index]);
    _destroyedBars = ValueNotifier(0);
  }

  @override
  Future<void> onLoad() async {
    _actionButtons = _renderActionButtons();
    await game.addAll(_actionButtons);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_destroyedBars.value == 10) {
      if (_actionButtons.length == 2) {
        _addExtraActionButton();
        _level = GameLevel.medium;
        onChange(_level);
      }
    }
    if (_destroyedBars.value == 30) {
      if (_actionButtons.length == 3) {
        _addExtraActionButton();
        _level = GameLevel.hard;
        onChange(_level);
      }
    }
  }

  /// Renders the action buttons
  _renderActionButtons() => _gameColors.map(
          (e) => ColorfulButton(
          height: colorfulBtnSize,
          color: e,
          btnPosition: () {
            const double horizontalSpace = colorfulBtnSize * 3;
            final double verticalSpace = game.size.y - (colorfulBtnSize * 2.2);

            /// Game has two colors
            if (_gameColors.length == 2) {
              if (_gameColors.indexOf(e) == 0) {
                return Vector2(15, verticalSpace);
              } else {
                return Vector2(game.size.x - (colorfulBtnSize * 2) - 15, verticalSpace);
              }
              /// Game has three colors
            } else if (_gameColors.length == 3) {
              if (_gameColors.indexOf(e) == 0) {
                return Vector2(15, verticalSpace);
              } else if (_gameColors.indexOf(e) == 2) {
                return Vector2(15 + horizontalSpace / 1.5, verticalSpace - colorfulBtnSize);
              } else {
                return Vector2(game.size.x - (colorfulBtnSize * 2) - 15, verticalSpace);
              }
              /// Game has four colors
            } else {
              if (_gameColors.indexOf(e) == 0) {
                return Vector2(15, verticalSpace);
              } else if (_gameColors.indexOf(e) == 2) {
                return Vector2(15 + horizontalSpace / 1.5, verticalSpace - colorfulBtnSize);
              } else if (_gameColors.indexOf(e) == 3) {
                return Vector2(game.size.x - (colorfulBtnSize * 2) - 15 - horizontalSpace / 1.5, verticalSpace - colorfulBtnSize);
              } else {
                return Vector2(game.size.x - (colorfulBtnSize * 2) - 15, verticalSpace);
              }
            }
          }
      )
  ).toList();

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
  void _addExtraActionButton() {
    game.removeAll(_actionButtons);
    _gameColors = [..._gameColors, colors.values.toList()[_getGameColors()]];
    _actionButtons = _renderActionButtons();
    game.addAll(_actionButtons);
  }

  /// Gets the game colors
  List<Color> get gameColors => _gameColors;
  /// Gets the action buttons
  List<ColorfulButton> get actionButtons => _actionButtons;
  /// Gets the current score
  int get score => _destroyedBars.value;

  /// Gets the game bar interval based on the level
  double getBarInterval() {
    double interval;

    switch (_level) {
      case GameLevel.easy:
        interval = barInterval;
        break;
      case GameLevel.medium:
        interval = barInterval - 0.1;
        break;
      case GameLevel.hard:
        interval = barInterval - 0.1;
        break;
    }

    return interval;
  }

  /// Gets a riv file based on the color based on the game level
  String getRivAssetBasedOnColor({required Color color}) {
    if (_level == GameLevel.easy || _level == GameLevel.medium) {

      return colors.entries.firstWhere((element) => element.value == color).key;
    }
    final random = Random();

    return colors.keys.toList()[random.nextInt(colors.length)];
  }

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

  /// Increase the current score
  void increaseScore() => _destroyedBars.value = _destroyedBars.value + 1;
  /// Decrease the current score
  void decreaseScore() {
    _destroyedBars.value = _destroyedBars.value - 1;
    if (_destroyedBars.value < 0) {
      gameOver();
    }
    vibrate();
  }
  /// Pauses the game
  void gameOver() => game.pauseEngine();
  /// Restarts the game
  void restartGame() => game.resumeEngine();
}