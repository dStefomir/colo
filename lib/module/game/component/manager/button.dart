import 'dart:math';

import 'package:colo/module/game/component/color_button.dart';
import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/page.dart';
import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

/// Manger for controlling the button rules
class ButtonManager extends Component {
  /// Action buttons structure
  late List<ColorfulButton> _actionButtons;
  /// Timer for adding an new bomb to the game
  Timer? _bombInterval;

  @override
  Future<void> onLoad() async {
    _actionButtons = await _addActionButtons();
    await (parent!.parent as ColoGamePage).addAll(_actionButtons);
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);
    final GameManager manager = parent as GameManager;
    // If its hard level add a bomb button if there is none already
    if (manager.level == GameLevel.hard) {
      _bombInterval ??= Timer(0.1, repeat: true, onTick: () {
        final random = Random();
        if (_bombInterval!.progress > 0.01) {
          _orAddBomb();
        }
        _bombInterval!.limit = random.nextInt(10).toDouble();
      });
      _bombInterval?.update(dt);
    } else {
      _bombInterval?.stop();
      _bombInterval = null;
    }
  }

  /// Adds a bomb to the game
  void _orAddBomb() async {
    final GameManager manager = parent as GameManager;

    final bombs = manager.game.children.whereType<ColorfulButton>().where((element) => element.type == ButtonType.bomb);
    if (bombs.isEmpty && manager.level == GameLevel.hard) {
      await manager.game.add(await _addActionButtonBomb());
    }
  }

  /// Renders the action buttons
  Future<List<ColorfulButton>> _addActionButtons() async {
    final GameManager manager = parent as GameManager;
    final List<Color> spawnButtonColors = manager.game.children.whereType<ColorfulButton>().map((e) => e.buttonColor).toList();
    final List<Color> gameColors = List.generate(manager.getGameColors(), (index) => manager.gameColors[index]);
    final List<MapEntry<Artboard, Color>> rivBoards = [];

    for (final color in (parent as GameManager).gameColors) {
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

    return gameColors.map((e) =>
        ColorfulButton(
            gameSize: manager.game.size,
            onGameAdd: (component) => manager.game.add(component),
            barManager: manager.barManager,
            buttonColor: e,
            artBoard: rivBoards.firstWhere((element) => element.value == e).key,
            type: ButtonType.color,
            buttonSize: colorfulBtnSize,
            buttonPosition: () {
              const double padding = 5;
              const double dX = colorfulBtnSize + (padding * 2);
              final double dY = manager.game.size.y;

              /// Game has two colors
              if (manager.level == GameLevel.easy) {
                if (gameColors.indexOf(e) == 0) {

                  return Vector2(padding, dY);
                } else {

                  return Vector2(
                      manager.game.size.x - (dX - padding),
                      dY
                  );
                }

                /// Game has three colors
              } else if (manager.level == GameLevel.medium) {
                if (gameColors.indexOf(e) == 0) {

                  return Vector2(padding, dY);
                } else if (gameColors.indexOf(e) == 2) {

                  return Vector2(
                      dX - padding,
                      dY - colorfulBtnSize / 2
                  );
                } else {

                  return Vector2(
                      manager.game.size.x - (dX - padding),
                      dY
                  );
                }
                /// Game has four colors
              } else {
                if (gameColors.indexOf(e) == 0) {

                  return Vector2(padding, dY);
                } else if (gameColors.indexOf(e) == 2) {

                  return Vector2(
                      dX - padding,
                      dY - colorfulBtnSize / 2
                  );
                } else if (gameColors.indexOf(e) == 3) {

                  return Vector2(
                      manager.game.size.x - ((dX - padding) * 1.95),
                      dY - colorfulBtnSize / 2
                  );
                } else {

                  return Vector2(
                      manager.game.size.x - (dX - padding),
                      dY
                  );
                }
              }
            })
    ).where((element) => !spawnButtonColors.contains(element.buttonColor)).toList();
  }

  /// Adds a bomb button to the game
  Future<ColorfulButton> _addActionButtonBomb() async {
    final GameManager gameManager = parent as GameManager;
    final bomb = await loadArtboard(RiveFile.asset('assets/button_bomb.riv'));

    return ColorfulButton(
        gameSize: gameManager.game.size,
        onGameAdd: (component) => gameManager.game.add(component),
        barManager: gameManager.barManager,
        buttonColor: Colors.transparent,
        artBoard: bomb,
        type: ButtonType.bomb,
        buttonSize: colorfulBtnSize,
        buttonPosition: () {
          final double dY = gameManager.game.size.y;
          return Vector2(
              (gameManager.game.size.x / 2) - (colorfulBtnSize / 2),
              dY - colorfulBtnSize * 1.2
          );
        }
    );
  }

  /// Adds a button to the game
  Future<void> addExtraActionButton() async {
    final ColoGamePage game = parent!.parent as ColoGamePage;
    _actionButtons = await _addActionButtons();
    game.addAll(_actionButtons);
  }

  /// Gets a riv file button color based on the game level
  String getButtonRivAssetBasedOnColor({required Color color}) => buttonColors.entries.firstWhere((element) => element.value == color).key;

  /// Restart the state of the game buttons
  void restartState() async {
    final GameManager manager = parent as GameManager;
    manager.game.removeAll(manager.game.children.whereType<ColorfulButton>());
    Future.delayed(const Duration(milliseconds: 100), () async {
      _actionButtons = await _addActionButtons();
      await manager.game.addAll(_actionButtons);
    });
  }

  /// Getter for the colorful buttons
  List<ColorfulButton> get actionButtons => _actionButtons;
}