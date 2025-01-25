import 'package:flutter/material.dart';


class TextBuilder extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const TextBuilder({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = Theme.of(context).textTheme.bodyMedium!;
    TextStyle mergedStyle = _overrideDefaultStyle(defaultStyle, style);

    return Text(
      text,
      style: mergedStyle,
      textAlign: textAlign,
    );
  }

  // write method to override the default style
  TextStyle _overrideDefaultStyle(TextStyle defaultStyle, TextStyle? style) {
    if (style == null) return defaultStyle;

    return defaultStyle.copyWith(
      color: style.color ?? defaultStyle.color,
      fontSize: style.fontSize ?? defaultStyle.fontSize,
      fontWeight: style.fontWeight ?? defaultStyle.fontWeight,
      letterSpacing: style.letterSpacing ?? defaultStyle.letterSpacing,
      wordSpacing: style.wordSpacing ?? defaultStyle.wordSpacing,
      height: style.height ?? defaultStyle.height,
      decoration: style.decoration ?? defaultStyle.decoration,
      decorationColor: style.decorationColor ?? defaultStyle.decorationColor,
      decorationStyle: style.decorationStyle ?? defaultStyle.decorationStyle,
      decorationThickness: style.decorationThickness ?? defaultStyle.decorationThickness,
      shadows: style.shadows ?? defaultStyle.shadows,
      fontFeatures: style.fontFeatures ?? defaultStyle.fontFeatures,
      fontFamily: style.fontFamily ?? defaultStyle.fontFamily,
      fontFamilyFallback: style.fontFamilyFallback ?? defaultStyle.fontFamilyFallback
    );
  }

}
