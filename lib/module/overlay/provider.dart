import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Provider for the overlay visibility
final overlayVisibilityProvider = StateNotifierProvider.family<OverlayVisibilityNotifier, bool?, Key>((ref, value) => OverlayVisibilityNotifier(ref: ref));
/// Notifier for the overlay visibility
class OverlayVisibilityNotifier extends StateNotifier<bool?> {
  /// Reference
  final Ref ref;

  OverlayVisibilityNotifier({required this.ref}) : super(null);

  /// Changes the overlay visibility
  setOverlayVisibility(bool? visibility) => state = visibility;
}

/// Provider for the overlay visibility
final secondsToUnpauseProvider = StateNotifierProvider<SecondsToUnpauseNotifier, int?>((ref) => SecondsToUnpauseNotifier(ref: ref));
/// Notifier for the overlay visibility
class SecondsToUnpauseNotifier extends StateNotifier<int?> {
  /// Reference
  final Ref ref;

  SecondsToUnpauseNotifier({required this.ref}) : super(null);

  /// Sets the remaining seconds
  onSecondsChanged(int? seconds) => state = seconds;
}

/// Provider for an interstitial ad
final interstitialAdProvider = StateNotifierProvider<InterstitialAdNotifier, InterstitialAd?>((ref) => InterstitialAdNotifier(ref: ref));

/// Notifier for an interstitial ad
class InterstitialAdNotifier extends StateNotifier<InterstitialAd?> {
  /// Reference
  final Ref ref;

  InterstitialAdNotifier({required this.ref}) : super(null);

  /// Sets an add
  onAddCreated(InterstitialAd? add) => state = add;
}