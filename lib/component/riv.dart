import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

class RivAnimationComponent extends RiveComponent {
  /// state machine key
  final String stateMachineKey;
  /// Key of the animation
  final String animationKey;
  /// Should have shadow or not
  final bool useShadow;

  RivAnimationComponent({
    required Artboard artBoard,
    Vector2? size,
    Vector2? position,
    this.useShadow = false,
    this.stateMachineKey = 'State Machine 1',
    this.animationKey = 'Wave'}) : super(
      artboard: artBoard,
      size: size,
      position: position,
      alignment: Alignment.center
  );

  @override
  void onLoad() {
    if (useShadow) {
      decorator.addLast(
          Shadow3DDecorator(
            angle: - 0.5,
            xShift: 1.2,
            yScale: 1.2,
            opacity: 0.5,
            blur: 1.5,
          )
      );
    }
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