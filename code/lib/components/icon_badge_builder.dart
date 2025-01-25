import 'package:flutter/material.dart';

class IconBadgeBuilder extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;
  final double? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? tiltAngle;

  const IconBadgeBuilder({
    super.key,
    required this.icon,
    this.color,
    this.size,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.tiltAngle,
  });

  @override
  Widget build(BuildContext context) {
    // Default values
    final double defaultPadding = padding ?? 8.0;
    final double defaultSize = size ?? 24.0;
    final Color defaultColor = color ?? Colors.white;
    final Color defaultBackgroundColor = backgroundColor ?? Colors.red;
    final double defaultBorderRadius = borderRadius ?? 50.0;
    final double defaultTiltAngle = tiltAngle ?? 0.0;

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      child: Transform.rotate(
        angle: defaultTiltAngle,
        child: Icon(
          icon,
          color: defaultColor,
          size: defaultSize,
        ),
      ),
    );
  }
}
