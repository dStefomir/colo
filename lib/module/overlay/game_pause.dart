import 'dart:async';

import 'package:colo/core/page.dart';
import 'package:colo/core/service/admob.dart';
import 'package:colo/model/account.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:colo/utils/vibration.dart';
import 'package:colo/widgets/blur.dart';
import 'package:colo/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the game pause overlay
class GamePauseDialog extends HookConsumerWidget {
  /// User account
  final Account account;
  /// Ads
  final AdMobService adMob;
  /// Unpauses the game
  final void Function() onUnpause;

  const GamePauseDialog({super.key, required this.onUnpause, required this.account, required this.adMob});

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
              color: Colors.black,
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
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
                  ),
                  if (account.noAds != true) Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 60,
                      child: AdWidget(
                          ad: BannerAd(
                              size: AdSize.fullBanner,
                              adUnitId: adMob.bannerAdUnitId!,
                              request: const AdRequest(),
                              listener: adMob.bannerListener
                          )..load()
                      ),
                    ),
                  ),
                ],
              )
          ),
        ),
      )
  );
}