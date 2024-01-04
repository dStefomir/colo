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
    _actionButtons = await _renderActionButtons();
    await (parent!.parent as ColoGamePage).addAll(_actionButtons);
  }


  @override
  Future<void> update(double dt) async {
    super.update(dt);
    final ColoGamePage game = parent!.parent as ColoGamePage;
    final GameManager manager = parent as GameManager;
    // If its hard level add a bomb button if there is none already
    if (manager.level == GameLevel.hard) {
      _bombInterval ??= Timer(35, repeat: true, onTick: () async {
        final bombs = game.children.whereType<ColorfulButton>().where((element) => element.type == ButtonType.bomb).toList();
        if (bombs.isEmpty) {
          game.add(await addActionButtonBomb());
      }
      });
      _bombInterval?.update(dt);
    }
  }

  /// Renders the action buttons
  Future<List<ColorfulButton>> _renderActionButtons() async {
    final ColoGamePage game = parent!.parent as ColoGamePage;
    final GameManager manager = parent as GameManager;
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
            artBoard: rivBoards.firstWhere((element) => element.value == e).key,
            type: ButtonType.color,
            buttonSize: game.size.y / 10,
            btnPosition: () {
              const double padding = 5;
              final double dX = game.size.y / 10;
              final double dY = game.size.y - (game.size.y / 10 + padding);

              /// Game has two colors
              if (gameColors.length == 2) {
                if (gameColors.indexOf(e) == 0) {

                  return Vector2(padding, dY);
                } else {

                  return Vector2(
                      game.size.x - (dX + padding),
                      dY
                  );
                }

                /// Game has three colors
              } else if (gameColors.length == 3) {
                if (gameColors.indexOf(e) == 0) {

                  return Vector2(padding, dY);
                } else if (gameColors.indexOf(e) == 2) {

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
                if (gameColors.indexOf(e) == 0) {

                  return Vector2(padding, dY);
                } else if (gameColors.indexOf(e) == 2) {

                  return Vector2(
                      dX,
                      dY - colorfulBtnSize / 2
                  );
                } else if (gameColors.indexOf(e) == 3) {

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
  /// Adds a bomb button to the game
  Future<ColorfulButton> addActionButtonBomb() async {
    final ColoGamePage game = parent!.parent as ColoGamePage;
    final bomb = await loadArtboard(RiveFile.asset('assets/button_bomb.riv'));

    return ColorfulButton(
        artBoard: bomb,
        type: ButtonType.bomb,
        buttonSize: game.size.y / 10,
        btnPosition: () {
          const double padding = 5;
          final double dY = game.size.y - (game.size.y / 10 + padding);

          return Vector2(
              (game.size.x / 2.5) - (padding / 2),
              dY - colorfulBtnSize * 1.2
          );
        }
    );
  }
  /// Adds a button to the game
  Future<void> addExtraActionButton() async {
    final ColoGamePage game = parent!.parent as ColoGamePage;

    game.removeAll(game.children.whereType<ColorfulButton>());
    _actionButtons = await _renderActionButtons();
    game.addAll(_actionButtons);
  }
  /// Gets a riv file button color based on the game level
  String getButtonRivAssetBasedOnColor({required Color color}) => buttonColors.entries.firstWhere((element) => element.value == color).key;
  /// Restart the state of the game buttons
  void restartState() async {
    final ColoGamePage game = parent!.parent as ColoGamePage;
    _actionButtons = await _renderActionButtons();
    game.addAll(_actionButtons);
  }
  /// Getter for the colorful buttons
  List<ColorfulButton> get actionButtons => _actionButtons;
}