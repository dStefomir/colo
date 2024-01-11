import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colo/model/account.dart';
import 'package:colo/widgets/load.dart';
import 'package:colo/widgets/page.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Responsible for wrapping all pages and handling the app bar and the app drawer
class CorePage extends HookConsumerWidget {
  /// Specifies the page path
  final String pageName;
  /// Current userId
  final String userId;
  /// Should resize when keyboard pops
  final bool resizeToAvoidBottomInset;
  /// Renders the holding page
  final Widget Function(SharedPreferences, Account) render;
  /// What happens if the page is popped
  final void Function(bool, WidgetRef)? onPopInvoked;

  const CorePage({
    Key? key,
    required this.pageName,
    required this.userId,
    required this.render,
    this.onPopInvoked,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  /// Renders the default page widget
  Widget _renderDefaultPage(BuildContext context, WidgetRef ref) {
    final page = MainScaffold(
      body: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
            if (snapshot.hasData) {
              final sharedPrefs = snapshot.data;
              /// Creates a stream build to listen for events in the fire store.
              /// If there are any new events - it will reload the InitialPage with new data.
              return StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("users").doc(userId).snapshots(),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      final account = Account.fromSnapshot(snapshot.data);

                      return PopScope(
                          onPopInvoked: (shouldPop) {
                            if (onPopInvoked != null) {
                              onPopInvoked!(shouldPop, ref);
                            }
                          },
                          canPop: false,
                          child: render(sharedPrefs!, account)
                      );
                    }

                    return const BackgroundPage(
                        child: Center(
                            child: LoadingIndicator(color: Colors.purple)
                        )
                    );
                  }
              );
            }

            return const BackgroundPage(
                color: Colors.black,
                child: Center(
                    child: LoadingIndicator(
                        color: Colors.purple
                    )
                )
            );
          }),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );

    /// If game is started then allow only portrait orientation.
    /// If its the initial screen then allow all orientations.
    return pageName == 'Game'
        ? FutureBuilder(
        future: Flame.device.setOrientation(DeviceOrientation.portraitUp),
        builder: (_, __) => page)
        : FutureBuilder(
        future: Flame.device.setOrientations(
            [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight
            ]
        ), builder: (_, __) => page);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => _renderDefaultPage(context, ref);
}

/// Scaffold wrapper for each page
class MainScaffold extends StatelessWidget {
  /// Represent each page`s content
  final Widget body;
  /// Should resize when keyboard pops
  final bool resizeToAvoidBottomInset;

  const MainScaffold(
      {Key? key, required this.body, this.resizeToAvoidBottomInset = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: body,
    );
  }
}
