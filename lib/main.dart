import 'package:colo/core/service/admob.dart';
import 'package:colo/core/service/auth.dart';
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
  /// Initializes firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  /// Initializes auth service
  final authService = AuthService();
  await authService.getOrCreateUser();
  /// Initializes admob service
  await MobileAds.instance.initialize();
  final adMobService = AdMobService();
  /// Plays the game background music
  playLooped(asset: 'background.mp3', volume: 0.05);

  runApp(
      ModularApp(
          module: MainModule(adMob: adMobService, auth: authService),
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