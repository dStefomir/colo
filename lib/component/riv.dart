import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

class RivAnimationComponent extends RiveComponent {

  RivAnimationComponent({required Artboard artBoard, required Vector2 size}) : super(
      artboard: artBoard,
      size: size,
      alignment: Alignment.center
  );

  @override
  void onLoad() {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );
    if (controller != null) {
      artboard.addController(controller);
      final levelInput = controller.findInput<double>("Wave");
      levelInput?.value = 0;
    }
  }
}