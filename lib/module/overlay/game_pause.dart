import 'dart:async';

import 'package:colo/core/page.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:colo/utils/vibration.dart';
import 'package:colo/widgets/blur.dart';
import 'package:colo/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the game pause overlay
class GamePauseDialog extends HookConsumerWidget {
  /// Unpauses the game
  final void Function() onUnpause;

  const GamePauseDialog({super.key, required this.onUnpause});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MainScaffold(
      body: Blurrable(
        strength: 5,
        child: GestureDetector(
          onTap: () {
            if (ref.read(secondsToUnpauseProvider) == null) {
              vibrate();
              ref.read(secondsToUnpauseProvider.notifier).onSecondsChanged(4);
              Timer.periodic(const Duration(milliseconds: 650), (timer) {
                final secondsToUnpause = ref.watch(secondsToUnpauseProvider);
                ref.read(secondsToUnpauseProvider.notifier).onSecondsChanged(
                    ref.read(secondsToUnpauseProvider)! - 1);
                if (secondsToUnpause == 1) {
                  timer.cancel();
                  ref.read(secondsToUnpauseProvider.notifier).onSecondsChanged(
                      null);
                  onUnpause();
                }
              });
            }
          },
          child: Container(
              color: Colors.transparent,
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StyledText(
                    family: 'RenegadePursuit',
                    text: '${ref.read(secondsToUnpauseProvider) ?? 'Paused'}',
                    fontSize: 40,
                    align: TextAlign.start,
                    letterSpacing: 5,
                    gradientColors: barColors.values.toList(),
                    weight: FontWeight.bold,
                    useShadow: true,
                  ),
                ],
              )
          ),
        ),
      )
  );
}