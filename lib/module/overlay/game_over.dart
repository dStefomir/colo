import 'package:colo/core/page.dart';
import 'package:colo/module/game/page.dart';
import 'package:colo/widgets/blur.dart';
import 'package:colo/widgets/button.dart';
import 'package:colo/widgets/text.dart';
import 'package:flutter/material.dart';


class GameOverDialog extends StatelessWidget {
  /// What happens when the restart button is pressed
  final void Function() onRestart;
  /// Best game score
  final int bestScore;

  const GameOverDialog({super.key, required this.bestScore, required this.onRestart});

  @override
  Widget build(BuildContext context) => MainScaffold(
      body: Blurrable(
        strength: 5,
        child: Container(
            color: Colors.black.withOpacity(0.5),
            height: double.infinity,
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StyledText(
                  family: 'RenegadePursuit',
                  text: 'Game Over',
                  fontSize: 40,
                  align: TextAlign.start,
                  letterSpacing: 5,
                  gradientColors: barColors.values.toList(),
                  weight: FontWeight.bold,
                  useShadow: true,
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: NormalButton(
                        gradientColors: barColors.values.toList(),
                        text: const StyledText(
                          family: 'RenegadePursuit',
                          text: 'Try again',
                          fontSize: 20,
                          align: TextAlign.start,
                          color: Colors.white,
                          weight: FontWeight.bold,
                        ),
                        onClick: () => onRestart(),
                      ),
                    ),
                  ],
                ),
              ],
            )
        ),
      )
  );
}