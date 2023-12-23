import 'dart:io';

import 'package:colo/core/page.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/initial/page.dart';
import 'package:flame/game.dart';
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
                game: ColoGamePage(
                    sharedPrefs: sharedPrefs,
                    disabled: false
                )
            )
        )
    );
  }
}
