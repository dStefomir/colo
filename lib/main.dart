import 'dart:async';

import 'package:colo/core/service/admob.dart';
import 'package:colo/core/service/auth.dart';
import 'package:colo/core/service/firestore.dart';
import 'package:colo/core/service/purchase.dart';
import 'package:colo/utils/audio.dart';
import 'package:colo/module/main_module.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /// Initializes firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  /// Initializes admob service
  await MobileAds.instance.initialize();
  /// Initializes auth service
  final authService = AuthService();
  await authService.getOrCreateUser();
  /// Initializes admob service
  final adMobService = AdMobService();
  /// Initializes fire store service
  final fireStoreService = FireStoreService(userId: authService.currentUser!.uid);
  /// Initializes in app purchases service
  final inAppPurchasesService = InAppPurchaseService(fireStoreService: fireStoreService);
  /// Plays the game background music
  playLooped(asset: 'background.mp3', volume: 0.05);

  runApp(
      ModularApp(
          module: MainModule(adMob: adMobService, auth: authService),
          child: ProviderScope(
              child: _MyApp(inAppPurchaseService: inAppPurchasesService)
          )
      )
  );
}

/// Application itself holding the theming and the app`s delegates
class _MyApp extends StatefulWidget {

  /// In app purchase service
  final InAppPurchaseService inAppPurchaseService;

  const _MyApp({required this.inAppPurchaseService});

  @override
  State<_MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  /// Stream subscription for handling the bought items from the game
  late StreamSubscription<List<PurchaseDetails>> _inAppPurchaseSubscription;

  @override
  void initState() {
    super.initState();

    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _inAppPurchaseSubscription = purchaseUpdated.listen((purchaseDetailsList) {
      widget.inAppPurchaseService.listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _inAppPurchaseSubscription.cancel();
    }, onError: (error) {
      _inAppPurchaseSubscription.cancel();
    }) as StreamSubscription<List<PurchaseDetails>>;
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Colost",
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
  );
}