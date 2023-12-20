import 'package:colo/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // This opens the app in fullscreen mode.
  await Flame.device.fullScreen();
  runApp(
    GameWidget(game: ColoGame())
  );
}