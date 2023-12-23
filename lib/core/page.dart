import 'package:colo/widgets/load.dart';
import 'package:colo/widgets/page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Responsible for wrapping all pages and handling the app bar and the app drawer
class CorePage extends StatelessWidget {
  /// Specifies the page path
  final String pageName;
  /// Should resize when keyboard pops
  final bool resizeToAvoidBottomInset;
  /// Renders the holding page
  final Widget Function(SharedPreferences) render;
  /// What happens if the page is popped
  final void Function(bool)? onPopInvoked;

  const CorePage({
    Key? key,
    required this.pageName,
    required this.render,
    this.onPopInvoked,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  /// Renders the default page widget
  Widget _renderDefaultPage(BuildContext context) => MainScaffold(
    body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.hasData) {
            return PopScope(
                onPopInvoked: onPopInvoked,
                canPop: false,
                child: render(snapshot.data!)
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

  @override
  Widget build(BuildContext context) => _renderDefaultPage(context);
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
