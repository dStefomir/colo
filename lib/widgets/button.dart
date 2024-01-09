import 'package:colo/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders a normal button
class TextIconButton extends HookConsumerWidget {
  /// What happens when you click the button
  final void Function() onClick;
  /// Gradient colors
  final List<Color>? gradientColors;
  /// Button color
  final Color? color;
  /// button text
  final StyledText text;
  /// Asset for the icon
  final String asset;
  /// Extra padding to the bottom of the asset
  final double? assetPaddingBottom;
  /// Extra padding to the top of the asset
  final double? assetPaddingTop;

  const TextIconButton({super.key, required this.onClick, required this.text, required this.asset, this.color, this.gradientColors, this.assetPaddingBottom, this.assetPaddingTop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final button = TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll<Color>(color ?? Colors.black),
      ),
      onPressed: () => onClick(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15, bottom: assetPaddingBottom ?? 0, top: assetPaddingTop ?? 0),
            child: SvgPicture.asset(asset, height: 45,),
          ),
          text
        ],
      ),
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
          backgroundColor: MaterialStatePropertyAll<Color>(color ?? Colors.black),
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

/// Renders a rounded button widget
class DefaultButton extends StatelessWidget {
  /// What happens when the widget is clicked
  final Function() onClick;
  /// Color of the button
  final Color color;
  /// Color of the button border
  final Color borderColor;
  /// Icon asset
  final String icon;
  /// Shape of the button
  final BoxShape shape;
  /// Width of the border
  final double borderWidth;
  /// Icon height
  final double height;
  /// Padding of the button
  final double padding;
  /// Svg color
  final Color? svgColor;
  /// Fit for the svg icon
  final BoxFit iconFit;

  const DefaultButton({
    required this.onClick,
    required this.borderColor,
    required this.icon,
    this.color = Colors.white,
    this.shape = BoxShape.circle,
    this.borderWidth = 1,
    this.height = 35,
    this.padding = 10,
    this.svgColor,
    this.iconFit = BoxFit.scaleDown,
    super.key
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(padding),
    child: Container(
      decoration: BoxDecoration(
          color: color,
          shape: shape,
          border: borderWidth == 0 ? null : Border.all(color: borderColor, width: borderWidth)
      ),
      child: InkWell(
          onTap: onClick,
          child: SvgPicture.asset(icon, fit: iconFit, color: svgColor, height: height,)
      ),
    ),
  );
}