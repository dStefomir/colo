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
import 'package:url_launcher/url_launcher.dart';

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

  /// Renders the account type
  _renderAccountType({required EdgeInsets padding, required Alignment align}) => (account.difficultySelect == true && account.rocketLimiter == true && account.noAds == true) ? SlideTransitionAnimation(
    getStart: () => const Offset(0, -1),
    getEnd: () => const Offset(0, 0),
    duration: const Duration(milliseconds: 1000),
    child: Align(
      alignment: align,
      child: Padding(
          padding: padding,
          child: StyledText(
            text: account.accountType.capitalize(),
            fontSize: 14,
            align: TextAlign.start,
            letterSpacing: 2,
            gradientColors: barColors,
            weight: FontWeight.bold,
            useShadow: true,
          )
      ),
    ),
  ) : const SizedBox.shrink();

  /// Renders the account Id
  _renderAccountId({required EdgeInsets padding, required Alignment align}) => SlideTransitionAnimation(
    getStart: () => const Offset(0, -1),
    getEnd: () => const Offset(0, 0),
    duration: const Duration(milliseconds: 1000),
    child: Align(
      alignment: align,
      child: Padding(
          padding: padding,
          child: StyledText(
            text: auth.currentUser!.uid,
            fontSize: 14,
            align: TextAlign.start,
            letterSpacing: 2,
            gradientColors: barColors,
            weight: FontWeight.bold,
            useShadow: true,
          )
      ),
    ),
  );

  /// Renders the game title
  _renderGameTitle({required EdgeInsets padding, required Alignment align}) => SlideTransitionAnimation(
    getStart: () => const Offset(0, -1),
    getEnd: () => const Offset(0, 0),
    duration: const Duration(milliseconds: 1000),
    child: Align(
      alignment: align,
      child: Padding(
          padding: padding,
          child: const StyledText(
            family: 'RenegadePursuit',
            text: 'Colost',
            fontSize: 40,
            align: TextAlign.start,
            letterSpacing: 20,
            gradientColors: barColors,
            weight: FontWeight.bold,
            italic: true,
            useShadow: true,
          )
      ),
    ),
  );

  /// Renders the bullet limiter button if available
  _renderBulletLimiterButton({required WidgetRef ref, required bool shouldHaveRocketLimiter, required EdgeInsets padding, required Alignment align}) => account.rocketLimiter ? SlideTransitionAnimation(
    getStart: () => const Offset(0, -1),
    getEnd: () => const Offset(0, 0),
    duration: const Duration(milliseconds: 1000),
    child: Align(
      alignment: align,
      child: Padding(
          padding: padding,
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
                          groupValue: !shouldHaveRocketLimiter,
                          onChanged: (_) {
                            ref.read(rocketLimiterProvider(const Key('rocket_limiter')).notifier).shouldHaveLimiter(!shouldHaveRocketLimiter);
                          },
                        ),
                        const StyledText(
                          family: 'RenegadePursuit',
                          text: 'Rocket limiter',
                          fontSize: 15,
                          padding: EdgeInsets.only(right: 15, top: 15, bottom: 15),
                          gradientColors: barColors,
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
  ) : const SizedBox.shrink();

  /// Renders the store button if available
  _renderStoreButton({required WidgetRef ref, required EdgeInsets padding, required Alignment align}) => (account.difficultySelect != true || account.rocketLimiter != true || account.noAds != true) ? SlideTransitionAnimation(
    getStart: () => const Offset(0, -1),
    getEnd: () => const Offset(0, 0),
    duration: const Duration(milliseconds: 1000),
    child: Align(
      alignment: align,
      child: Padding(
          padding: padding,
          child: ShadowWidget(
            shouldHaveBorderRadius: true,
            child: TextIconButton(
              onClick: () {
                final isGameModeOpened = ref.read(overlayVisibilityProvider(const Key('game_mode')));
                if (isGameModeOpened == null || !isGameModeOpened) {
                  ref.read(overlayVisibilityProvider(const Key('game_store')).notifier).setOverlayVisibility(true);
                }
              },
              gradientColors: barColors,
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
  ) : const SizedBox.shrink();

  /// Renders the start game button
  _renderStartButton({required WidgetRef ref, required EdgeInsets padding, required Alignment align}) => SlideTransitionAnimation(
    getStart: () => const Offset(0, 1),
    getEnd: () => const Offset(0, 0),
    duration: const Duration(milliseconds: 800),
    child: Align(
      alignment: align,
      child: Padding(
        padding: padding,
        child: ShadowWidget(
          shouldHaveBorderRadius: true,
          child: TextIconButton(
            gradientColors: barColors,
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
  );

  /// Renders the game score
  _renderGameScore({required EdgeInsets padding, required Alignment align}) => FadeAnimation(
    start: 0,
    end: 1,
    duration: const Duration(milliseconds: 2000),
    child: Align(
      alignment: align,
      child: Padding(
        padding: padding,
        child: StyledText(
          family: 'RenegadePursuit',
          text: '${sharedPrefs.getInt('score') ?? 0}',
          fontSize: 100,
          align: TextAlign.start,
          gradientColors: barColors,
          weight: FontWeight.bold,
          clip: false,
          useShadow: true,
        ),
      ),
    ),
  );

  /// Renders in game ad
  _renderAd({required Alignment align}) => account.noAds != true ? Align(
    alignment: align,
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
  ) : const SizedBox.shrink();

  /// Renders a policy privacy button
  _renderPrivacyPolicy({required EdgeInsets padding, required Alignment align, required double animationStart}) => SlideTransitionAnimation(
    getStart: () => Offset(0, animationStart),
    getEnd: () => const Offset(0, 0),
    duration: const Duration(milliseconds: 1000),
    child: Align(
      alignment: align,
      child: Padding(
          padding: padding,
          child: ShadowWidget(
              shouldHaveBorderRadius: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  onTap: () async {
                    final url = Uri.parse('https://www.iubenda.com/privacy-policy/39557464');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  child: const StyledText(
                    family: 'RenegadePursuit',
                    text: 'Privacy Policy',
                    fontSize: 15,
                    gradientColors: barColors,
                    align: TextAlign.center,
                  ),
                ),
              )
          )
      ),
    ),
  );

  /// Renders the portrait layout
  List<Widget> _renderPortraitMode({required WidgetRef ref, required Size size, required bool shouldHaveRocketLimiter}) => [
    _renderAccountType(
        padding: EdgeInsets.only(top: size.height / 7),
        align: Alignment.topCenter
    ),
    _renderAccountId(
        padding: EdgeInsets.only(top: size.height / 8.5),
        align: Alignment.topCenter
    ),
    _renderGameTitle(
        padding: EdgeInsets.only(bottom: size.height / 1.25),
        align: Alignment.center
    ),
    _renderBulletLimiterButton(
        ref: ref,
        shouldHaveRocketLimiter: shouldHaveRocketLimiter,
        padding: EdgeInsets.only(bottom: size.height / 1.85),
        align: Alignment.center
    ),
    _renderStoreButton(
        ref: ref,
        padding: EdgeInsets.only(bottom: size.height / 2.8),
        align: Alignment.center
    ),
    _renderStartButton(
        ref: ref,
        padding: EdgeInsets.only(bottom: size.height / 8),
        align: Alignment.bottomCenter
    ),
    _renderGameScore(
        padding: EdgeInsets.only(top: size.height / 9),
        align: Alignment.center
    ),
    _renderPrivacyPolicy(
        padding: EdgeInsets.only(bottom: size.height / 4),
        align: Alignment.bottomCenter,
        animationStart: 1
    ),
    _renderAd(align: Alignment.bottomCenter)
  ];

  /// Renders the landscape layout
  List<Widget> _renderLandscapeMode({required WidgetRef ref, required Size size, required bool shouldHaveRocketLimiter}) => [
    _renderAccountType(
        padding: EdgeInsets.only(top: size.height / 5),
        align: Alignment.topCenter
    ),
    _renderAccountId(
        padding: EdgeInsets.only(top: size.height / 6.5),
        align: Alignment.topCenter
    ),
    _renderGameTitle(
        padding: EdgeInsets.only(bottom: size.height / 1.25),
        align: Alignment.center
    ),
    _renderBulletLimiterButton(
        ref: ref,
        shouldHaveRocketLimiter: shouldHaveRocketLimiter,
        padding: EdgeInsets.only(bottom: size.height / 6, left: size.width / 6),
        align: Alignment.centerLeft
    ),
    _renderPrivacyPolicy(
        padding: EdgeInsets.only(bottom: size.height / 6, right: size.width / 6),
        align: Alignment.centerRight,
        animationStart: -1
    ),
    _renderStoreButton(
        ref: ref,
        padding: EdgeInsets.only(top: size.height / 3, left: size.width / 16),
        align: Alignment.centerLeft
    ),
    _renderStartButton(
        ref: ref,
        padding: EdgeInsets.only(top: size.height / 3, right: size.width / 16),
        align: Alignment.centerRight
    ),
    _renderGameScore(
        padding: EdgeInsets.only(top: size.height / 3),
        align: Alignment.center
    ),
    _renderAd(align: Alignment.bottomCenter)
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