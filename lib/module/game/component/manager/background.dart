import 'package:colo/module/game/component/background.dart';
import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// Manger for controlling the background rules
class BackgroundManager extends Component {

  @override
  Future<void> onLoad() async => await addAll(_availableBackgrounds());

  /// Restart the state of the manager
  void restartState() {
    removeAll(children);
    addAll(_availableBackgrounds());
  }

  /// Removes the current background layer
  void removeCurrentBackground() {
    final ColoGamePage game = parent!.parent as ColoGamePage;
    final backgrounds = children;
    final background = backgrounds.last;
    background.add(
        MoveByEffect(
            Vector2(0, game.size.y * - 1),
            EffectController(
              duration: 0.5,
              curve: Curves.fastOutSlowIn,
            ),
            onComplete: () => remove(background)
        )
    );
  }

  /// Gets all available backgrounds
  List<Background> _availableBackgrounds() {
    final GameManager manager = parent as GameManager;

    return [
      if (!manager.disabled) Background(
          disabled: manager.disabled,
          asset: 'background_hard.png',
          priority: -1
      ),
      if (!manager.disabled) Background(
          disabled: manager.disabled,
          asset: 'background_medium.png',
          priority: -1
      ),
      Background(
          disabled: manager.disabled,
          asset: 'background_easy.png',
          priority: -1
      ),
    ]..shuffle();
  }
}