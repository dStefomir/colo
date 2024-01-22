import 'package:colo/module/game/component/manager/manager.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/initial/provider.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:colo/widgets/blur.dart';
import 'package:colo/widgets/button.dart';
import 'package:colo/widgets/shadow.dart';
import 'package:colo/widgets/text.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the mode selector overlay
class GameModeDialog extends StatefulHookConsumerWidget {

  const GameModeDialog({super.key});

  @override
  ConsumerState createState() => _GameModeDialogState();
}

class _GameModeDialogState extends ConsumerState<GameModeDialog> {

  /// Controller for the riv components
  late RiveAnimationController _rivController;

  @override
  void initState() {
    super.initState();
    _rivController = SimpleAnimation('Idle', mix: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _rivController.dispose();
  }

  /// Renders an riv animation
  Widget _renderRiv({required String asset, required double width}) => SizedBox(
    height: width / 5,
    width: width / 5,
    child: RiveAnimation.asset(
      asset,
      controllers: [_rivController],
      stateMachines: const ['State Machine 1'],
    ),
  );

  /// Renders the game level selector
  Widget _renderGameLevelSelector({required GameLevel level, required double size}) {
    Widget selector;
    switch (level) {
      case GameLevel.easy:
        selector = ShadowWidget(
          child: Card(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 15),
                  child: Row(
                    children: [
                      _renderRiv(asset: 'assets/button_purple.riv', width: size),
                      const SizedBox(width: 10,),
                      _renderRiv(asset: 'assets/button_red.riv', width: size),
                    ],
                  ),
                ),
                const StyledText(
                  family: 'RenegadePursuit',
                  text: 'Easy',
                  fontSize: 30,
                  align: TextAlign.start,
                  letterSpacing: 20,
                  gradientColors: barColors,
                  weight: FontWeight.bold,
                  padding: EdgeInsets.only(left: 5, bottom: 15),
                  italic: true,
                  useShadow: true,
                )
              ],
            ),
          ),
        );
      case GameLevel.medium:
        selector = ShadowWidget(
          child: Card(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 15),
                  child: Row(
                    children: [
                      _renderRiv(asset: 'assets/button_purple.riv', width: size),
                      const SizedBox(width: 10,),
                      _renderRiv(asset: 'assets/button_red.riv', width: size),
                      const SizedBox(width: 10,),
                      _renderRiv(asset: 'assets/button_blue.riv', width: size),
                    ],
                  ),
                ),
                const StyledText(
                  family: 'RenegadePursuit',
                  text: 'Medium',
                  fontSize: 30,
                  align: TextAlign.start,
                  letterSpacing: 20,
                  gradientColors: barColors,
                  weight: FontWeight.bold,
                  padding: EdgeInsets.only(left: 5, bottom: 15),
                  italic: true,
                  useShadow: true,
                )
              ],
            ),
          ),
        );
      case GameLevel.hard:
        selector = ShadowWidget(
          child: Card(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 15),
                  child: Row(
                    children: [
                      _renderRiv(asset: 'assets/button_purple.riv', width: size),
                      const SizedBox(width: 10,),
                      _renderRiv(asset: 'assets/button_red.riv', width: size),
                      const SizedBox(width: 10,),
                      _renderRiv(asset: 'assets/button_blue.riv', width: size),
                      const SizedBox(width: 10,),
                      _renderRiv(asset: 'assets/button_green.riv', width: size),
                    ],
                  ),
                ),
                const StyledText(
                  family: 'RenegadePursuit',
                  text: 'Hard',
                  fontSize: 30,
                  align: TextAlign.start,
                  letterSpacing: 20,
                  gradientColors: barColors,
                  weight: FontWeight.bold,
                  padding: EdgeInsets.only(left: 5, bottom: 15),
                  italic: true,
                  useShadow: true,
                )
              ],
            ),
          ),
        );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(overlayVisibilityProvider(const Key('game_mode')).notifier).setOverlayVisibility(false);
          final shouldRemoveLimiter = ref.read(rocketLimiterProvider(const Key('rocket_limiter')));

          switch (level) {
            case GameLevel.easy:
              Modular.to.popAndPushNamed('/game?level=easy&limiter=$shouldRemoveLimiter');
              break;
            case GameLevel.medium:
              Modular.to.popAndPushNamed('/game?level=medium&limiter=$shouldRemoveLimiter');
              break;
            case GameLevel.hard:
              Modular.to.popAndPushNamed('/game?level=hard&limiter=$shouldRemoveLimiter');
              break;
          }
        },
        child: selector,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidget = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(),
              DefaultButton(
                  onClick: () => ref.read(overlayVisibilityProvider(const Key('game_mode')).notifier).setOverlayVisibility(false),
                  color: Colors.black,
                  svgColor: Colors.pink.withOpacity(0.5),
                  borderColor: Colors.black,
                  icon: 'assets/svgs/close.svg'
              ),
            ],
          ),
          _renderGameLevelSelector(level: GameLevel.easy, size: size.width < size.height ? size.width : size.height),
          _renderGameLevelSelector(level: GameLevel.medium, size: size.width < size.height ? size.width : size.height),
          _renderGameLevelSelector(level: GameLevel.hard, size: size.width < size.height ? size.width : size.height),
        ],
      ),
    );
    final bool? shouldShowGameModeDialog = ref.watch(overlayVisibilityProvider(const Key('game_mode')));
    return shouldShowGameModeDialog != null && shouldShowGameModeDialog ? Blurrable(
      strength: 5,
      child: dialogWidget,
    ) : dialogWidget;
  }
}