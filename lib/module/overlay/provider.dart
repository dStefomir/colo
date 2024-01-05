import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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