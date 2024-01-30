import 'dart:math';

import 'package:colo/module/game/component/bar.dart';
import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Manger for controlling the bar rules
class BarManager extends Component {
  /// Color used for the same bars
  late Color _colorForSameBar;
  /// Numbers of same bars rendered
  late int _numberOfSameBars;
  /// Multiplier for the falling speed of the bars
  late double _barFallingSpeedMultiplier;
  /// Timer for increasing the bar falling speed
  Timer? _barFallingSpeedInterval;
  /// Timer for updating the falling bars
  Timer? _barInterval;

  BarManager({required bool disabled, required GameLevel level}) {
    _colorForSameBar = Colors.white;
    _numberOfSameBars = 0;
    _barFallingSpeedMultiplier = 1;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final ColoGamePage game = parent!.parent as ColoGamePage;
    final GameManager manager = parent as GameManager;

    _barFallingSpeedInterval ??= Timer(30, repeat: true, onTick: () {
      /// If its hard level and 20 more bars are destroyed - increase bar falling speed
      if (manager.level == GameLevel.hard) {
        _barFallingSpeedMultiplier = _barFallingSpeedMultiplier + 0.2;
      }
    });
    _barInterval = Timer(barInterval / manager.barManager.barFallingSpeedMultiplier, repeat: true);
    _barInterval!.onTick = () async {
      await game.add(manager.barManager.renderBar());
    };
  }

  @override
  void update(double dt) {
    super.update(dt);
    final GameManager manager = parent as GameManager;
    _barInterval?.limit = barInterval / manager.barManager.barFallingSpeedMultiplier;
    _barInterval?.update(dt);
    _barFallingSpeedInterval?.update(dt);
  }

  /// Pauses the falling bars
  void pauseBars() {
    _barInterval?.pause();
    _barFallingSpeedInterval?.pause();
  }

  /// Resumes the falling bars
  void unPauseBars() {
    _barInterval?.resume();
    _barFallingSpeedInterval?.resume();
  }

  /// Reset the state of the manager
  void restartState() => _barFallingSpeedMultiplier = 1;

  /// Renders a falling bar
  renderBar() => Bar(
    barManager: this,
    disabled: (parent as GameManager).disabled,
    level: (parent as GameManager).level,
    onGameOver: (parent as GameManager).gameOver,
    onIncreaseScore: (parent as GameManager).increaseScore,
    gameSize: (parent!.parent as ColoGamePage).size,
    barColor: _getBarColor(),
    // barSize: Vector2(255, 64),
    barSize: Vector2(100, 100),
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
        lifespan = 3.5;
        break;
      case GameLevel.medium:
        lifespan = 3.5;
        break;
      case GameLevel.hard:
        lifespan = 3.5 * _barFallingSpeedMultiplier;
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
        count = 150;
        break;
      case GameLevel.medium:
        count = 150;
        break;
      case GameLevel.hard:
        count = (150 * _barFallingSpeedMultiplier).toInt();
        break;
    }

    return count;
  }

  /// Gets a color for a bar
  Color _getBarColor() {
    final GameManager manager = parent as GameManager;
    final random = Random();

    if (_numberOfSameBars > 0) {
      _numberOfSameBars--;

      return _colorForSameBar;
    } else if (manager.level == GameLevel.hard && manager.score % random.nextDouble() == 1) {
      _colorForSameBar = List.generate(manager.getGameColors(), (index) => manager.gameColors[index])[random.nextInt(manager.getGameColors())];
      _numberOfSameBars = 8;
    }

    return List.generate(manager.getGameColors(), (index) => manager.gameColors[index])[random.nextInt(manager.getGameColors())];
  }

  /// Gets the bar falling speed multiplier
  double get barFallingSpeedMultiplier => _barFallingSpeedMultiplier;
}