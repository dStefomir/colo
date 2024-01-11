import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colo/core/service/admob.dart';
import 'package:colo/core/page.dart';
import 'package:colo/core/service/auth.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/initial/page.dart';
import 'package:colo/module/overlay/game_over.dart';
import 'package:colo/module/overlay/game_pause.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:colo/widgets/animation.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

const String _initialPageRoute = '/';
const String _gamePageRoute = '/game';

/// Represents the main module of the app
class MainModule extends Module {
  /// Adds
  final AdMobService adMob;
  /// Auth
  final AuthService auth;

  MainModule({required this.adMob, required this.auth});

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
            userId: auth.currentUser!.uid,
            onPopInvoked: (_, ref) {
              final bool? isOverlayVisible = ref.read(overlayVisibilityProvider(const Key('game_mode')));
              if (isOverlayVisible != null && isOverlayVisible == true) {
                ref.read(overlayVisibilityProvider(const Key('game_mode')).notifier).setOverlayVisibility(false);
              } else {
                exit(0);
              }
            },
            render: (sharedPrefs, account) => InitialPage(
                sharedPrefs: sharedPrefs,
                adMob: adMob,
                auth: auth,
                account: account
            )
        )
    );
    r.child(
        _gamePageRoute,
        transition: TransitionType.scale,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            pageName: 'Game',
            userId: auth.currentUser!.uid,
            onPopInvoked: (_, __) => Modular.to.popAndPushNamed(_initialPageRoute),
            render: (sharedPrefs, account) => GameWidget(
              overlayBuilderMap: {
                'gameOver': (BuildContext context, ColoGamePage game) => SlideTransitionAnimation(
                  duration: const Duration(milliseconds: 1000),
                  getStart: () => const Offset(0, 1),
                  getEnd: () => const Offset(0, 0),
                  child: GameOverDialog(
                      onRestart: () async => game.manager.restartGame(),
                      bestScore: sharedPrefs.getInt('score') ?? game.manager.score,
                      account: account,
                      adMob: adMob
                  ),
                ),
                'gamePause': (BuildContext context, ColoGamePage game) => FadeAnimation(
                    start: 0,
                    end: 1,
                    duration: const Duration(milliseconds: 1000),
                    child: GamePauseDialog(
                        adMob: adMob,
                        account: account,
                        onUnpause: () => game.manager.handleGamePause()
                    )
                )
              },
              game: ColoGamePage(
                    sharedPrefs: sharedPrefs,
                    account: account,
                    level: r.args.queryParams['level'],
                    disabled: false
                ),
            )
        )
    );
  }
}
