import 'package:flutter/material.dart';

class CardBuilder extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? color;
  final ShapeBorder? shape;

  const CardBuilder({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.color,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    // Default values
    EdgeInsetsGeometry defaultPadding = const EdgeInsets.all(16.0);
    double defaultElevation = 16.0; // Increased elevation for more shadow
    Color defaultColor = Theme.of(context).cardColor;
    ShapeBorder defaultShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0), // Increased border radius
    );

    // Merged values
    EdgeInsetsGeometry mergedPadding = padding ?? defaultPadding;
    double mergedElevation = elevation ?? defaultElevation;
    Color mergedColor = color ?? defaultColor;
    ShapeBorder mergedShape = shape ?? defaultShape;

    return Card(
      color: mergedColor,
      elevation: mergedElevation,
      shape: mergedShape,
      child: Padding(
        padding: mergedPadding,
        child: child,
      ),
    );
  }
}
