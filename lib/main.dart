import 'package:colo/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Opens the app in fullscreen mode
  await Flame.device.fullScreen();
  /// Sets the device orientation
  await Flame.device.setOrientation(DeviceOrientation.portraitUp);
  runApp(
    GameWidget(game: ColoGame())
  );
}