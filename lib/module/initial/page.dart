import 'package:colo/module/game/page.dart';
import 'package:colo/widgets/animation.dart';
import 'package:colo/widgets/button.dart';
import 'package:colo/widgets/text.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialPage extends StatelessWidget {
  /// Shared prefs
  final SharedPreferences sharedPrefs;

  const InitialPage({super.key, required this.sharedPrefs});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        GameWidget(
            game: ColoGamePage(sharedPrefs: sharedPrefs, disabled: true)
        ),
        SlideTransitionAnimation(
          getStart: () => const Offset(0, -1),
          getEnd: () => const Offset(0, 0),
          duration: const Duration(milliseconds: 1000),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: size.height / 1.5),
              child: StyledText(
                family: 'RenegadePursuit',
                text: 'Colost',
                fontSize: 40,
                align: TextAlign.start,
                letterSpacing: 20,
                gradientColors: barColors.values.toList(),
                weight: FontWeight.bold,
                italic: true,
                useShadow: true,
              )
            ),
          ),
        ),
        SlideTransitionAnimation(
          getStart: () => const Offset(0, 1),
          getEnd: () => const Offset(0, 0),
          duration: const Duration(milliseconds: 1000),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: size.height / 12),
              child: NormalButton(
                gradientColors: barColors.values.toList(),
                text: const StyledText(
                  family: 'RenegadePursuit',
                  text: 'Start',
                  fontSize: 20,
                  align: TextAlign.start,
                  color: Colors.white,
                  weight: FontWeight.bold,
                ),
                onClick: () => Modular.to.popAndPushNamed('/game'),
              ),
            ),
          ),
        ),
        FadeAnimation(
          start: 0,
          end: 1,
          duration: const Duration(milliseconds: 2000),
          child: Align(
            alignment: Alignment.center,
            child: StyledText(
              family: 'RenegadePursuit',
              text: '${sharedPrefs.getInt('score') ?? 0}',
              fontSize: 100,
              align: TextAlign.start,
              gradientColors: barColors.values.toList(),
              weight: FontWeight.bold,
              clip: false,
              useShadow: true,
            ),
          ),
        ),
      ],
    );
  }
}