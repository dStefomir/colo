import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Manger for controlling the bullet rules
class BulletManager extends Component {

  /// Gets a riv file bullet color based on the game level
  String getBulletRivAssetBasedOnColor({required Color color}) => bulletColors.entries.firstWhere((element) => element.value == color).key;
  /// Gets a dy limit for the bullet based on the game level
  double getBulletDyLimit() {
    double dy;
    final GameManager manager = parent as GameManager;

    switch (manager.level) {
      case GameLevel.easy:
        dy = 0;
        break;
      case GameLevel.medium:
        dy = ((parent?.parent) as ColoGamePage).size.y / 2;
        break;
      case GameLevel.hard:
        dy = ((parent?.parent) as ColoGamePage).size.y / 1.5;
        break;
    }

    return dy;
  }
  /// What happens when a bullet color hit a falling bar
  /// with a different color
  void onBulletColorMiss({
    required GameLevel level,
    required int currentScore,
    required void Function() onGameOver,
    required void Function() onDecreaseScore,
    required void Function() onResetDestroyedBars}) {
    if (level == GameLevel.easy) {
      onDecreaseScore();
    } else if (level == GameLevel.medium) {
      if (currentScore > 0) {
        onResetDestroyedBars();
      } else {
        onDecreaseScore();
      }
    } else if (level == GameLevel.hard) {
      onGameOver();
    }
  }
}