import 'dart:math';

import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Manger for controlling the bar rules
class BarManager extends Component {
  /// Color used for the same bars
  late Color colorForSameBar;
  /// Numbers of same bars rendered
  late int _numberOfSameBars;
  /// Multiplier for the falling speed of the bars
  late double _barFallingSpeedMultiplier;
  /// Timer for increasing the bar falling speed
  Timer? _barFallingSpeedInterval;

  BarManager() {
    colorForSameBar = Colors.white;
    _numberOfSameBars = 0;
    _barFallingSpeedMultiplier = 1;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final GameManager manager = parent as GameManager;
    _barFallingSpeedInterval ??= Timer(30, repeat: true, onTick: () {
      /// If its hard level and 20 more bars are destroyed - increase bar falling speed
      if (manager.level == GameLevel.hard) {
        _barFallingSpeedMultiplier = _barFallingSpeedMultiplier + 0.2;
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _barFallingSpeedInterval?.update(dt);
  }

  @override
  Future<void> onGameResize(Vector2 size) async {
    super.onGameResize(size);
    final ColoGamePage game = parent!.parent as ColoGamePage;

    game.removeAll(game.children.whereType<Bar>());
  }

  /// Reset the state of the manager
  void restartState() => _barFallingSpeedMultiplier = 1;

  /// Renders a falling bar
  renderBar() => Bar(
    barColor: _getBarColor(),
    barSize: Vector2(255, 64),
  );
  /// Removes a bar from the game
  void removeBar({required Bar bar}) => parent?.parent?.remove(bar);
  /// Generate a different shades of color
  Color generateShade({required Color baseColor, required double factor}) {
    factor = factor.clamp(-1.0, 0.3);
    final int red = (baseColor.red * (1 + factor)).round().clamp(0, 255);
    final int green = (baseColor.green * (1 + factor)).round().clamp(0, 255);
    final int blue = (baseColor.blue * (1 + factor)).round().clamp(0, 255);

    return Color.fromARGB(
      baseColor.alpha,
      red,
      green,
      blue,
    );
  }
  /// Gets bar explosion lifespan for particles
  double getBarExplosionLifespan() {
    double lifespan;
    final GameManager manager = parent as GameManager;

    switch (manager.level) {
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
    final GameManager manager = parent as GameManager;

    switch (manager.level) {
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
    final GameManager manager = parent as GameManager;
    if (manager.level == GameLevel.easy || manager.level == GameLevel.medium) {

      return barColors.entries.firstWhere((element) => element.value == color).key;
    }
    final random = Random();

    return barColors.keys.toList()[random.nextInt(barColors.length)];
  }

  /// Gets a color for a bar
  Color _getBarColor() {
    final GameManager manager = parent as GameManager;
    final random = Random();

    if (_numberOfSameBars > 0) {
      _numberOfSameBars--;

      return colorForSameBar;
    } else if (manager.level == GameLevel.hard && manager.score % random.nextDouble() == 1) {
      colorForSameBar = List.generate(manager.getGameColors(), (index) => manager.gameColors[index])[random.nextInt(manager.getGameColors())];
      _numberOfSameBars = 8;
    }

    return List.generate(manager.getGameColors(), (index) => manager.gameColors[index])[random.nextInt(manager.getGameColors())];
  }

  /// Gets the bar falling speed multiplier
  double get barFallingSpeedMultiplier => _barFallingSpeedMultiplier;
}