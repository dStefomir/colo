import 'package:colo/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders a normal button
class NormalButton extends HookConsumerWidget {
  /// What happens when you click the button
  final Function onClick;
  /// Gradient colors
  final List<Color>? gradientColors;
  /// Button color
  final Color? color;
  /// button text
  final StyledText text;

  const NormalButton({super.key, required this.onClick, required this.text, this.color, this.gradientColors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final button = TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(color ?? Colors.black87),
      ),
      onPressed: () => onClick(),
      child: text,
    );

    return gradientColors != null ? ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(colors: gradientColors!).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
        child: button
    ) : button;
  }
}