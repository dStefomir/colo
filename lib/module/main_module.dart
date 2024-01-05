import 'dart:io';

import 'package:colo/core/page.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/initial/page.dart';
import 'package:colo/module/overlay/game_over.dart';
import 'package:colo/widgets/animation.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';

const String _initialPageRoute = '/';
const String _gamePageRoute = '/game';

/// Represents the main module of the app
class MainModule extends Module {
  // Provide a list of dependencies to inject into the project
  @override
  void binds(i) {}
  // Provide all the routes for the module
  @override
  void routes(r) {
    r.child(
        _initialPageRoute,
        transition: TransitionType.fadeIn,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            pageName: 'Initial',
            onPopInvoked: (canPop) => exit(0),
            render: (sharedPrefs) => InitialPage(
                sharedPrefs: sharedPrefs
            )
        )
    );
    r.child(
        _gamePageRoute,
        transition: TransitionType.scale,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            pageName: 'Game',
            onPopInvoked: (canPop) => Modular.to.popAndPushNamed(_initialPageRoute),
            render: (sharedPrefs) => GameWidget(
              overlayBuilderMap: {
                'gameOver': (BuildContext context, ColoGamePage game) => SlideTransitionAnimation(
                  duration: const Duration(milliseconds: 1000),
                  getStart: () => const Offset(0, 1),
                  getEnd: () => const Offset(0, 0),
                  child: GameOverDialog(
                      onRestart: () async => game.manager.restartGame(),
                      bestScore: sharedPrefs.getInt('score') ?? game.manager.score
                  ),
                )
              },
              game: ColoGamePage(
                    sharedPrefs: sharedPrefs,
                    level: r.args.queryParams['level'],
                    disabled: false
                ),
            )
        )
    );
  }
}
