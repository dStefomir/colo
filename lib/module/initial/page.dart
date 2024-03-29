import 'package:colo/core/service/admob.dart';
import 'package:colo/core/service/auth.dart';
import 'package:colo/model/account.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/initial/body.dart';
import 'package:colo/module/initial/provider.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the Initial page
class InitialPage extends HookConsumerWidget {
  /// Shared prefs
  final SharedPreferences sharedPrefs;
  /// Adds
  final AdMobService adMob;
  /// Auth
  final AuthService auth;
  /// User account
  final Account account;

  const InitialPage({
    super.key,
    required this.sharedPrefs,
    required this.adMob,
    required this.auth,
    required this.account
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
      future: Future(() => ref.read(rocketLimiterProvider(const Key('rocket_limiter')).notifier).shouldHaveLimiter(account.rocketLimiter)),
      builder: (_, __) => GestureDetector(
        onTap: () {
          if (ref.read(overlayVisibilityProvider(const Key('game_mode'))) != null) {
            ref.read(overlayVisibilityProvider(const Key('game_mode')).notifier).setOverlayVisibility(false);
          }
          if (ref.read(overlayVisibilityProvider(const Key('game_store'))) != null) {
            ref.read(overlayVisibilityProvider(const Key('game_store')).notifier).setOverlayVisibility(false);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AbsorbPointer(
              absorbing: true,
              child: GameWidget(
                  game: ColoGamePage(
                      sharedPrefs: sharedPrefs,
                      limiter: true,
                      disabled: true
                  )
              ),
            ),
            InitialPageBody(
                sharedPrefs: sharedPrefs,
                adMob: adMob,
                auth: auth,
                account: account
            )
          ],
        ),
      )
  );
}