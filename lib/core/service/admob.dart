import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wrapper for the admob
class AdMobService {
  /// Listener for the banner add
  late BannerAdListener _bannerListener;

  AdMobService() {
    _bannerListener = BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('Banner ad loaded');

          }},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (kDebugMode) {
            print('Banner ad failed to load: $error');
          }
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('Banner ad opened');
          }},
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('Banner ad closed');
          }
        }
    );
  }

  /// Getter for the banner add listener
  BannerAdListener get bannerListener => _bannerListener;

  /// Get an banner add id
  String? get bannerAdUnitId {
    return "ca-app-pub-3940256099942544/6300978111";
    if (kReleaseMode) {
      if (Platform.isIOS) {
        return "ca-app-pub-2745355777679464/2009413172";
      } else {
        return "ca-app-pub-2745355777679464/6222375956";
      }
    } else {
      return "ca-app-pub-3940256099942544/6300978111";
    }
  }

  /// Gets a listener for the interstitial ad
  InterstitialAdLoadCallback interstitialListener({
    required void Function(InterstitialAd) onAdCreated,
    required void Function() onAdFailed}) => InterstitialAdLoadCallback(
      onAdLoaded: (ad) => onAdCreated(ad),
      onAdFailedToLoad: (error) => onAdFailed()
  );

  /// Gets a callback for the interstitial ad
  FullScreenContentCallback<InterstitialAd> interstitialCallback({
    required void Function() createAdd,
    required void Function() onDismissed}) => FullScreenContentCallback(
    onAdDismissedFullScreenContent: (ad) {
      ad.dispose();
      createAdd();
      onDismissed();
    },
    onAdFailedToShowFullScreenContent: (ad, error) {
      ad.dispose();
      createAdd();
    }
  );

  /// Get an interstitial add id
  String? get interstitialAdUnitId {
    return "ca-app-pub-3940256099942544/1033173712";
    if (kReleaseMode) {
      if (Platform.isIOS) {
        return "ca-app-pub-2745355777679464/2123348840";
      } else {
        return "ca-app-pub-2745355777679464/5822349880";
      }
    } else {
      return "ca-app-pub-3940256099942544/1033173712";
    }
  }
}