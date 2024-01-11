import 'package:colo/module/game/component/background.dart';
import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// Manger for controlling the background rules
class BackgroundManager extends Component {

  @override
  Future<void> onLoad() async {
    final ColoGamePage game = parent!.parent as ColoGamePage;
    game.addAll(availableBackgrounds());
  }

  /// Removes the current background layer
  void removeCurrentBackground({required int priorityOfCurrent}) {
    final ColoGamePage game = parent!.parent as ColoGamePage;
    final background = game.children.whereType<Background>().where((element) => element.priority == priorityOfCurrent).toList().first;
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

  /// Gets all available backgrounds
  List<Background> availableBackgrounds() {
    final GameManager manager = parent as GameManager;

    return [
      if (!manager.disabled) Background(
          disabled: manager.disabled,
          asset: 'background_hard.png',
          priority: -3
      ),
      if (!manager.disabled && (manager.level != GameLevel.hard)) Background(
          disabled: manager.disabled,
          asset: 'background_medium.png',
          priority: -2
      ),
      if (manager.disabled || manager.level == GameLevel.easy) Background(
          disabled: manager.disabled,
          asset: 'background_easy.png',
          priority: -1
      ),
    ];
  }
}