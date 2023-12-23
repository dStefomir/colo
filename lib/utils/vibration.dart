import 'package:flutter/services.dart';

/// Vibrates the device
void vibrate() {
  HapticFeedback.lightImpact();
}