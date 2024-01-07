import 'package:colo/module/game/page.dart';
import 'package:colo/module/overlay/game_mode.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:colo/widgets/animation.dart';
import 'package:colo/widgets/button.dart';
import 'package:colo/widgets/shadow.dart';
import 'package:colo/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the Initial page body content
class InitialPageBody extends HookConsumerWidget {
  /// Shared prefs
  final SharedPreferences sharedPrefs;

  const InitialPageBody({super.key, required this.sharedPrefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final bool? shouldShowGameModeDialog = ref.watch(overlayVisibilityProvider(const Key('game_mode')));

    return Stack(
      fit: StackFit.expand,
      children: [
        SlideTransitionAnimation(
          getStart: () => const Offset(0, -1),
          getEnd: () => const Offset(0, 0),
          duration: const Duration(milliseconds: 1000),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
                padding: EdgeInsets.only(bottom: size.height / 1.5),
                child: StyledText(
                  family: 'RenegadePursuit',
                  text: 'Colost',
                  fontSize: 40,
                  align: TextAlign.start,
                  letterSpacing: 20,
                  gradientColors: barColors.values.toList(),
                  weight: FontWeight.bold,
                  italic: true,
                  useShadow: true,
                )
            ),
          ),
        ),
        SlideTransitionAnimation(
          getStart: () => const Offset(0, 1),
          getEnd: () => const Offset(0, 0),
          duration: const Duration(milliseconds: 800),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: size.height / 12),
              child: ShadowWidget(
                shouldHaveBorderRadius: true,
                child: NormalButton(
                  gradientColors: barColors.values.toList(),
                  text: const StyledText(
                    family: 'RenegadePursuit',
                    text: 'Start',
                    fontSize: 20,
                    align: TextAlign.start,
                    color: Colors.white,
                    weight: FontWeight.bold,
                  ),
                  onClick: () => ref.read(overlayVisibilityProvider(const Key('game_mode')).notifier).setOverlayVisibility(true),
                ),
              ),
            ),
          ),
        ),
        FadeAnimation(
          start: 0,
          end: 1,
          duration: const Duration(milliseconds: 2000),
          child: Align(
            alignment: Alignment.center,
            child: StyledText(
              family: 'RenegadePursuit',
              text: '${sharedPrefs.getInt('score') ?? 0}',
              fontSize: 100,
              align: TextAlign.start,
              gradientColors: barColors.values.toList(),
              weight: FontWeight.bold,
              clip: false,
              useShadow: true,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransitionAnimation(
              duration: const Duration(milliseconds: 1000),
              getStart: () => shouldShowGameModeDialog != null && shouldShowGameModeDialog == true ? const Offset(0, 1) : const Offset(0, 0),
              getEnd: () => shouldShowGameModeDialog != null && shouldShowGameModeDialog == true ? const Offset(0, 0) : const Offset(0, 10),
              whenTo: (controller) {
                useValueChanged(shouldShowGameModeDialog, (_, __) async {
                  controller.reset();
                  controller.forward();
                });
              },
              child: const GameModeDialog()
          ),
        ),
      ],
    );
  }
}