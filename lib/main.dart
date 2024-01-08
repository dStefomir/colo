import 'package:colo/core/admob.dart';
import 'package:colo/utils/audio.dart';
import 'package:colo/module/main_module.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Opens the app in fullscreen mode
  await Flame.device.fullScreen();
  /// Sets the device orientation
  await Flame.device.setOrientation(DeviceOrientation.portraitUp);
  /// Initializes firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  /// Initializes admob
  await MobileAds.instance.initialize();
  final adMob = AdMob();
  /// Plays the game background music
  playLooped(asset: 'background.mp3', volume: 0.05);

  runApp(
      ModularApp(
          module: MainModule(adMob: adMob),
          child: ProviderScope(
              child: _MyApp()
          )
      )
  );
}

/// Application itself holding the theming and the app`s delegates
class _MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) => MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Colo",
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
  );
}