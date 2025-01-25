import 'package:flutter/material.dart';
import 'package:msb_app/components/text_builder.dart';

class ButtonBuilder extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final TextStyle? textStyle;

  const ButtonBuilder({
    super.key,
    required this.text,
    required this.onPressed,
    this.style,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Get the default style from the theme
    final ButtonStyle defaultStyle = Theme.of(context).elevatedButtonTheme.style ?? ElevatedButton.styleFrom();
    // Merge custom style with default style
    final ButtonStyle mergedStyle = _mergeButtonStyles(defaultStyle, style);

    return ElevatedButton(
      onPressed: onPressed,
      style: mergedStyle,
      child: TextBuilder(
        text: text,
        style: textStyle ?? _resolveTextStyle(defaultStyle),
      ),
    );
  }

  ButtonStyle _mergeButtonStyles(ButtonStyle base, ButtonStyle? override) {
    if (override == null) return base;

    return base.copyWith(
      backgroundColor: override.backgroundColor ?? base.backgroundColor,
      foregroundColor: override.foregroundColor ?? base.foregroundColor,
      overlayColor: override.overlayColor ?? base.overlayColor,
      shadowColor: override.shadowColor ?? base.shadowColor,
      surfaceTintColor: override.surfaceTintColor ?? base.surfaceTintColor,
      elevation: override.elevation ?? base.elevation,
      padding: override.padding ?? base.padding,
      minimumSize: override.minimumSize ?? base.minimumSize,
      fixedSize: override.fixedSize ?? base.fixedSize,
      maximumSize: override.maximumSize ?? base.maximumSize,
      side: override.side ?? base.side,
      shape: override.shape ?? base.shape,
      mouseCursor: override.mouseCursor ?? base.mouseCursor,
      visualDensity: override.visualDensity ?? base.visualDensity,
      tapTargetSize: override.tapTargetSize ?? base.tapTargetSize,
      animationDuration: override.animationDuration ?? base.animationDuration,
      enableFeedback: override.enableFeedback ?? base.enableFeedback,
      alignment: override.alignment ?? base.alignment,
      splashFactory: override.splashFactory ?? base.splashFactory,
    );
  }

  TextStyle? _resolveTextStyle(ButtonStyle style) {
    final TextStyle resolvedStyle = style.textStyle?.resolve({}) ?? const TextStyle();
    return resolvedStyle;
  }
}
