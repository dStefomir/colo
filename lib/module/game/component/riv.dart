import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';

class RivAnimationComponent extends RiveComponent {
  /// state machine key
  final String stateMachineKey;
  /// Key of the animation
  final String animationKey;

  RivAnimationComponent({
    required Artboard artBoard,
    Vector2? size,
    Vector2? position,
    int priorityIndex = 0,
    this.stateMachineKey = 'State Machine 1',
    this.animationKey = 'Wave'}) : super(
      artboard: artBoard,
      size: size,
      position: position,
      priority: priorityIndex
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