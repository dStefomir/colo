import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

class RivAnimationComponent extends RiveComponent {
  /// state machine key
  final String stateMachineKey;
  /// Key of the animation
  final String animationKey;

  RivAnimationComponent({
    required Artboard artBoard,
    required Vector2 size,
    this.stateMachineKey = 'State Machine 1',
    this.animationKey = 'Wave'}) : super(
      artboard: artBoard,
      size: size,
      alignment: Alignment.center
  );

  @override
  void onLoad() {
    final controller = StateMachineController.fromArtboard(
      artboard,
      stateMachineKey,
    );
    if (controller != null) {
      artboard.addController(controller);
      final levelInput = controller.findInput<double>(animationKey);
      levelInput?.value = 0;
    }
  }
}