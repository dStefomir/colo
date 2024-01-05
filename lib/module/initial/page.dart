import 'package:colo/module/game/page.dart';
import 'package:colo/module/initial/body.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the Initial page
class InitialPage extends HookConsumerWidget {
  /// Shared prefs
  final SharedPreferences sharedPrefs;

  const InitialPage({super.key, required this.sharedPrefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return GestureDetector(
      onTap: () => ref.read(overlayVisibilityProvider(const Key('game_mode')).notifier).setOverlayVisibility(false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AbsorbPointer(
            absorbing: true,
            child: GameWidget(
                game: ColoGamePage(sharedPrefs: sharedPrefs, disabled: true)
            ),
          ),
          InitialPageBody(sharedPrefs: sharedPrefs)
        ],
      ),
    );
  }
}