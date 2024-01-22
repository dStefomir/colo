import 'package:colo/core/service/admob.dart';
import 'package:colo/core/page.dart';
import 'package:colo/model/account.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:colo/widgets/blur.dart';
import 'package:colo/widgets/button.dart';
import 'package:colo/widgets/shadow.dart';
import 'package:colo/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders the game over overlay
class GameOverDialog extends HookConsumerWidget {
  /// User account
  final Account account;
  /// Adds
  final AdMobService adMob;
  /// What happens when the restart button is pressed
  final void Function() onRestart;
  /// Best game score
  final int bestScore;

  const GameOverDialog({super.key, required this.account, required this.adMob, required this.bestScore, required this.onRestart});

  /// Creates the interstitial ad
  void _createInterstitialAd({required WidgetRef ref}) {
    InterstitialAd.load(
        adUnitId: adMob.interstitialAdUnitId!,
        request: const AdRequest(),
        adLoadCallback: adMob.interstitialListener(
            onAdCreated: (ad) => ref.read(interstitialAdProvider.notifier).onAddCreated(ad),
            onAdFailed: () => ref.read(interstitialAdProvider.notifier).onAddCreated(null)
        )
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InterstitialAd? ad = ref.watch(interstitialAdProvider);
    if (account.noAds != true) {
      _createInterstitialAd(ref: ref);
    }

    return MainScaffold(
        body: Blurrable(
          strength: 5,
          child: Container(
              color: Colors.transparent,
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const StyledText(
                    family: 'RenegadePursuit',
                    text: 'Game Over',
                    fontSize: 40,
                    align: TextAlign.start,
                    letterSpacing: 5,
                    gradientColors: barColors,
                    weight: FontWeight.bold,
                    useShadow: true,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ShadowWidget(
                          shouldHaveBorderRadius: true,
                          child: NormalButton(
                            gradientColors: barColors,
                            color: Colors.cyan,
                            text: const StyledText(
                              family: 'RenegadePursuit',
                              text: 'Try again',
                              fontSize: 20,
                              align: TextAlign.start,
                              color: Colors.white,
                              weight: FontWeight.bold,
                            ),
                            onClick: () {
                              if (account.noAds != true) {
                                if (ad != null) {
                                  ad.fullScreenContentCallback = adMob.interstitialCallback(
                                      createAdd: () => _createInterstitialAd(ref: ref),
                                      onDismissed: onRestart
                                  );
                                  ad.show();
                                  ref.read(interstitialAdProvider.notifier).onAddCreated(null);
                                }
                              } else {
                                onRestart();
                              }
                            }
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
          ),
        )
    );
  }
}