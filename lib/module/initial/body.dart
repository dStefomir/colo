import 'package:colo/core/extension/string.dart';
import 'package:colo/core/service/admob.dart';
import 'package:colo/core/service/auth.dart';
import 'package:colo/model/account.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/module/initial/provider.dart';
import 'package:colo/module/overlay/game_mode.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:colo/module/overlay/store.dart';
import 'package:colo/widgets/animation.dart';
import 'package:colo/widgets/button.dart';
import 'package:colo/widgets/shadow.dart';
import 'package:colo/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the Initial page body content
class InitialPageBody extends HookConsumerWidget {
  /// Shared prefs
  final SharedPreferences sharedPrefs;
  /// Adds
  final AdMobService adMob;
  /// Auth
  final AuthService auth;
  /// User account
  final Account account;

  const InitialPageBody({super.key, required this.sharedPrefs, required this.adMob, required this.auth, required this.account});

  /// Renders the portrait layout
  List<Widget> _renderPortraitMode({required WidgetRef ref, required Size size, required bool shouldHaveRocketLimiter}) => [
    if (account.difficultySelect == true && account.rocketLimiter == true && account.noAds == true) SlideTransitionAnimation(
      getStart: () => const Offset(0, -1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 1000),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
            padding: EdgeInsets.only(top: size.height / 7),
            child: StyledText(
              text: account.accountType.capitalize(),
              fontSize: 14,
              align: TextAlign.start,
              letterSpacing: 2,
              gradientColors: barColors.values.toList(),
              weight: FontWeight.bold,
              useShadow: true,
            )
        ),
      ),
    ),
    SlideTransitionAnimation(
      getStart: () => const Offset(0, -1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 1000),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
            padding: EdgeInsets.only(top: size.height / 8.5),
            child: StyledText(
              text: auth.currentUser!.uid,
              fontSize: 14,
              align: TextAlign.start,
              letterSpacing: 2,
              gradientColors: barColors.values.toList(),
              weight: FontWeight.bold,
              useShadow: true,
            )
        ),
      ),
    ),
    SlideTransitionAnimation(
      getStart: () => const Offset(0, -1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 1000),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
            padding: EdgeInsets.only(bottom: size.height / 1.25),
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
    if (account.rocketLimiter) SlideTransitionAnimation(
      getStart: () => const Offset(0, -1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 1000),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
            padding: EdgeInsets.only(bottom: size.height / 1.85),
            child: ShadowWidget(
              shouldHaveBorderRadius: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  onTap: () => ref.read(rocketLimiterProvider(const Key('rocket_limiter')).notifier).shouldHaveLimiter(!shouldHaveRocketLimiter),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(30))
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<bool>(
                          value: true,
                          toggleable: true,
                          groupValue: shouldHaveRocketLimiter,
                          onChanged: (_) {
                            ref.read(rocketLimiterProvider(const Key('rocket_limiter')).notifier).shouldHaveLimiter(!shouldHaveRocketLimiter);
                          },
                        ),
                        StyledText(
                          family: 'RenegadePursuit',
                          text: 'Rocket limiter',
                          fontSize: 15,
                          padding: const EdgeInsets.only(right: 15, top: 15, bottom: 15),
                          gradientColors: barColors.values.toList(),
                          align: TextAlign.start,
                          weight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            )
        ),
      ),
    ),
    if (account.difficultySelect != true || account.rocketLimiter != true || account.noAds != true) SlideTransitionAnimation(
      getStart: () => const Offset(0, -1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 1000),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
            padding: EdgeInsets.only(bottom: size.height / 2.8),
            child: ShadowWidget(
              shouldHaveBorderRadius: true,
              child: TextIconButton(
                onClick: () {
                  final isGameModeOpened = ref.read(overlayVisibilityProvider(const Key('game_mode')));
                  if (isGameModeOpened == null || !isGameModeOpened) {
                    ref.read(overlayVisibilityProvider(const Key('game_store')).notifier).setOverlayVisibility(true);
                  }
                },
                gradientColors: barColors.values.toList(),
                text: const StyledText(
                  family: 'RenegadePursuit',
                  text: 'Store',
                  fontSize: 15,
                  align: TextAlign.start,
                  color: Colors.white,
                  weight: FontWeight.bold,
                ),
                asset: 'assets/svgs/store.svg',
                assetPaddingBottom: 5,
              ),
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
          padding: EdgeInsets.only(bottom: size.height / 8),
          child: ShadowWidget(
            shouldHaveBorderRadius: true,
            child: TextIconButton(
              gradientColors: barColors.values.toList(),
              text: const StyledText(
                family: 'RenegadePursuit',
                text: 'Start',
                fontSize: 15,
                align: TextAlign.start,
                color: Colors.white,
                weight: FontWeight.bold,
              ),
              asset: 'assets/svgs/game.svg',
              assetPaddingBottom: 10,
              onClick: () {
                if (account.premium == true || account.difficultySelect == true) {
                  final isGameStoreOpened = ref.read(overlayVisibilityProvider(const Key('game_store')));
                  if (isGameStoreOpened == null || !isGameStoreOpened) {
                    ref.read(overlayVisibilityProvider(const Key('game_mode')).notifier).setOverlayVisibility(true);
                  }
                } else {
                  Modular.to.popAndPushNamed('/game?level=easy');
                }
              },
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
        child: Padding(
          padding: EdgeInsets.only(top: size.height / 9),
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
  ];

  /// Renders the landscape layout
  List<Widget> _renderLandscapeMode({required WidgetRef ref, required Size size, required bool shouldHaveRocketLimiter}) => [
    if (account.difficultySelect == true && account.rocketLimiter == true && account.noAds == true) SlideTransitionAnimation(
      getStart: () => const Offset(0, -1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 1000),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
            padding: EdgeInsets.only(top: size.height / 5),
            child: StyledText(
              text: account.accountType.capitalize(),
              fontSize: 14,
              align: TextAlign.start,
              letterSpacing: 2,
              gradientColors: barColors.values.toList(),
              weight: FontWeight.bold,
              useShadow: true,
            )
        ),
      ),
    ),
    SlideTransitionAnimation(
      getStart: () => const Offset(0, -1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 1000),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
            padding: EdgeInsets.only(top: size.height / 6.5),
            child: StyledText(
              text: auth.currentUser!.uid,
              fontSize: 14,
              align: TextAlign.start,
              letterSpacing: 2,
              gradientColors: barColors.values.toList(),
              weight: FontWeight.bold,
              useShadow: true,
            )
        ),
      ),
    ),
    SlideTransitionAnimation(
      getStart: () => const Offset(0, -1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 1000),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
            padding: EdgeInsets.only(bottom: size.height / 1.25),
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
    if (account.rocketLimiter) SlideTransitionAnimation(
      getStart: () => const Offset(0, -1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 1000),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
            padding: EdgeInsets.only(bottom: size.height / 6),
            child: ShadowWidget(
                shouldHaveBorderRadius: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    onTap: () => ref.read(rocketLimiterProvider(const Key('rocket_limiter')).notifier).shouldHaveLimiter(!shouldHaveRocketLimiter),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(30))
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<bool>(
                            value: true,
                            toggleable: true,
                            groupValue: shouldHaveRocketLimiter,
                            onChanged: (_) {
                              ref.read(rocketLimiterProvider(const Key('rocket_limiter')).notifier).shouldHaveLimiter(!shouldHaveRocketLimiter);
                            },
                          ),
                          StyledText(
                            family: 'RenegadePursuit',
                            text: 'Rocket limiter',
                            fontSize: 15,
                            padding: const EdgeInsets.only(right: 15, top: 15, bottom: 15),
                            gradientColors: barColors.values.toList(),
                            align: TextAlign.start,
                            weight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            )
        ),
      ),
    ),
    if (account.difficultySelect != true || account.rocketLimiter != true || account.noAds != true) SlideTransitionAnimation(
      getStart: () => const Offset(0, -1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 1000),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
            padding: EdgeInsets.only(top: size.height / 3, left: size.width / 16),
            child: ShadowWidget(
              shouldHaveBorderRadius: true,
              child: TextIconButton(
                onClick: () {
                  final isGameModeOpened = ref.read(overlayVisibilityProvider(const Key('game_mode')));
                  if (isGameModeOpened == null || !isGameModeOpened) {
                    ref.read(overlayVisibilityProvider(const Key('game_store')).notifier).setOverlayVisibility(true);
                  }
                },
                gradientColors: barColors.values.toList(),
                text: const StyledText(
                  family: 'RenegadePursuit',
                  text: 'Store',
                  fontSize: 15,
                  align: TextAlign.start,
                  color: Colors.white,
                  weight: FontWeight.bold,
                ),
                asset: 'assets/svgs/store.svg',
                assetPaddingBottom: 5,
              ),
            )
        ),
      ),
    ),
    SlideTransitionAnimation(
      getStart: () => const Offset(0, 1),
      getEnd: () => const Offset(0, 0),
      duration: const Duration(milliseconds: 800),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(top: size.height / 3, right: size.width / 16),
          child: ShadowWidget(
            shouldHaveBorderRadius: true,
            child: TextIconButton(
              gradientColors: barColors.values.toList(),
              text: const StyledText(
                family: 'RenegadePursuit',
                text: 'Start',
                fontSize: 15,
                align: TextAlign.start,
                color: Colors.white,
                weight: FontWeight.bold,
              ),
              asset: 'assets/svgs/game.svg',
              assetPaddingBottom: 10,
              onClick: () {
                if (account.premium == true || account.difficultySelect == true) {
                  final isGameStoreOpened = ref.read(overlayVisibilityProvider(const Key('game_store')));
                  if (isGameStoreOpened == null || !isGameStoreOpened) {
                    ref.read(overlayVisibilityProvider(const Key('game_mode')).notifier).setOverlayVisibility(true);
                  }
                } else {
                  Modular.to.popAndPushNamed('/game?level=easy');
                }
              },
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
        child: Padding(
          padding: EdgeInsets.only(top: size.height / 3),
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
    ),
    if (account.premium != true || account.noAds != true) Align(
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
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final bool? shouldShowGameModeDialog = ref.watch(overlayVisibilityProvider(const Key('game_mode')));
    final bool? shouldShowGameStoreDialog = ref.watch(overlayVisibilityProvider(const Key('game_store')));
    final bool shouldHaveRocketLimiter = ref.watch(rocketLimiterProvider(const Key('rocket_limiter')));

    return Stack(
      fit: StackFit.expand,
      children: [
        if (mediaQuery.orientation == Orientation.portrait) ..._renderPortraitMode(ref: ref, size: mediaQuery.size, shouldHaveRocketLimiter: shouldHaveRocketLimiter)
        else ..._renderLandscapeMode(ref: ref, size: mediaQuery.size, shouldHaveRocketLimiter: shouldHaveRocketLimiter),
        if (shouldShowGameStoreDialog != null) Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransitionAnimation(
              duration: const Duration(milliseconds: 1000),
              getStart: () => shouldShowGameStoreDialog == true ? const Offset(0, 1) : const Offset(0, 0),
              getEnd: () => shouldShowGameStoreDialog == true ? const Offset(0, 0) : const Offset(0, 10),
              whenTo: (controller) {
                useValueChanged(shouldShowGameStoreDialog, (_, __) async {
                  controller.reset();
                  controller.forward();
                });
              },
              child: GameStoreDialog(account: account)
          ),
        ),
        if (shouldShowGameModeDialog != null) Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransitionAnimation(
              duration: const Duration(milliseconds: 1000),
              getStart: () => shouldShowGameModeDialog == true ? const Offset(0, 1) : const Offset(0, 0),
              getEnd: () => shouldShowGameModeDialog == true ? const Offset(0, 0) : const Offset(0, 10),
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