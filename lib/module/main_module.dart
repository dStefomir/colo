import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colo/core/service/admob.dart';
import 'package:colo/core/page.dart';
import 'package:colo/core/service/auth.dart';
import 'package:colo/model/account.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/initial/page.dart';
import 'package:colo/module/overlay/game_over.dart';
import 'package:colo/module/overlay/game_pause.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:colo/widgets/animation.dart';
import 'package:colo/widgets/load.dart';
import 'package:colo/widgets/page.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
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
            onPopInvoked: (_, ref) {
              final bool? isOverlayVisible = ref.read(overlayVisibilityProvider(const Key('game_mode')));
              if (isOverlayVisible != null && isOverlayVisible == true) {
                ref.read(overlayVisibilityProvider(const Key('game_mode')).notifier).setOverlayVisibility(false);
              } else {
                exit(0);
              }
            },
            /// Creates a stream build to listen for events in the fire store.
            /// If there are any new events - it will reload the InitialPage with new data.
            render: (sharedPrefs) => StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").doc(auth.currentUser?.uid).snapshots(),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    final account = Account.fromSnapshot(snapshot.data);

                    return InitialPage(
                        sharedPrefs: sharedPrefs,
                        adMob: adMob,
                        auth: auth,
                        account: account
                    );
                  }

                  return const BackgroundPage(
                      child: Center(
                        child: LoadingIndicator(color: Colors.purple)
                      )
                  );
                }
            )
        )
    );
    r.child(
        _gamePageRoute,
        transition: TransitionType.scale,
        duration: const Duration(milliseconds: 800),
        child: (_) => CorePage(
            pageName: 'Game',
            onPopInvoked: (_, __) => Modular.to.popAndPushNamed(_initialPageRoute),
            render: (sharedPrefs) => GameWidget(
              overlayBuilderMap: {
                'gameOver': (BuildContext context, ColoGamePage game) => SlideTransitionAnimation(
                  duration: const Duration(milliseconds: 1000),
                  getStart: () => const Offset(0, 1),
                  getEnd: () => const Offset(0, 0),
                  child: GameOverDialog(
                      onRestart: () async => game.manager.restartGame(),
                      bestScore: sharedPrefs.getInt('score') ?? game.manager.score,
                      adMob: adMob
                  ),
                ),
                'gamePause': (BuildContext context, ColoGamePage game) => FadeAnimation(
                    start: 0,
                    end: 1,
                    duration: const Duration(milliseconds: 1000),
                    child: GamePauseDialog(onUnpause: () => game.manager.handleGamePause())
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
