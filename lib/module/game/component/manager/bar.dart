import 'dart:math';

import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Manger for controlling the bar rules
class BarManager extends Component {
  /// Renders the falling bars
  Bar renderBar() {
    final ColoGamePage game = parent!.parent as ColoGamePage;
    final GameManager manager = parent as GameManager;
    final random = Random();

    return Bar(
      barColor: List.generate(manager.getGameColors(), (index) => manager.gameColors[index])[random.nextInt(manager.getGameColors())],
      barSize: Vector2(225, game.size.y / 15),
    );
  }
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
        lifespan = 1.5 * manager.barFallingSpeedMultiplier;
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
        count = (100 * manager.barFallingSpeedMultiplier).toInt();
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
}