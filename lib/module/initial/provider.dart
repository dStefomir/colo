import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the rocket limiter
final rocketLimiterProvider = StateNotifierProvider.family<RocketLimiterNotifier, bool, Key>((ref, value) => RocketLimiterNotifier(ref: ref));
/// Notifier for the rocket limiter
class RocketLimiterNotifier extends StateNotifier<bool> {
  /// Reference
  final Ref ref;

  RocketLimiterNotifier({required this.ref}) : super(false);

  /// Sets the rocket limiter
  shouldHaveLimiter(bool limiter) => state = limiter;
}