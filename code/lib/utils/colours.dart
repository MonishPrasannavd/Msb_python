import 'package:flutter/material.dart';

class AppColors {
  static const Color scaffoldBackgroundColor = Color(0xFFF5F4F4);
  // misc
  static const Color transparent = Colors.transparent;

  // Primary Colors
  static const Color primary = Color(0xFF540D96); // Deep Purple
  static const Color primaryVariant = Color(0xFF4A148C); // Darker Purple
  static const Color secondary = Color(0xFF4CAF50); // Green
  static const Color secondaryVariant = Color(0xFF388E3C); // Darker Green

  // Background Colors
  static const Color background = Color(0xFFF5F5F5); // Light Grey
  static const Color surface = Color(0xFFFFFFFF); // White

  // Text and Icon Colors
  static const Color onPrimary = Color(0xFFFFFFFF); // White
  static const Color onSecondary = Color(0xFFFFFFFF); // White
  static const Color onBackground = Color(0xFF000000); // Black
  static const Color onSurface = Color(0xFF000000); // Black
  static const Color onError = Color(0xFFFFFFFF); // White

  // Error Colors
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color errorLight = Color(0xFFE57373); // Light Red
  static const Color errorDark = Color(0xFFB71C1C); // Dark Red

  // Shades of White
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF); // White with 70% opacity
  static const Color white30 = Color(0x4DFFFFFF); // White with 30% opacity

  // Shades of Grey
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Black and shades of black
  static const Color black = Color(0xFF000000);
  static const Color black87 = Color(0xDD000000); // Black with 87% opacity
  static const Color black54 = Color(0x8A000000); // Black with 54% opacity
  static const Color black38 = Color(0x61000000); // Black with 38% opacity
  static const Color black12 = Color(0x1F000000); // Black with 12% opacity

  // Additional Colors
  static const Color blue = Color(0xFF2196F3); // Blue
  static const Color blueLight = Color(0xFF64B5F6); // Light Blue
  static const Color blueDark = Color(0xFF1976D2); // Dark Blue

  static const Color yellow = Color(0xFFFFEB3B); // Yellow
  static const Color yellowLight = Color(0xFFFFF176); // Light Yellow
  static const Color yellowDark = Color(0xFFFBC02D); // Dark Yellow

  static const Color orange = Color(0xFFFF9800); // Orange
  static const Color orangeLight = Color(0xFFFFB74D); // Light Orange
  static const Color orangeDark = Color(0xFFF57C00); // Dark Orange

  static const Color purple = Color(0xFF9C27B0); // Purple
  static const Color purpleLight = Color(0xFFBA68C8); // Light Purple
  static const Color purpleDark = Color(0xFF7B1FA2); // Dark Purple

  static const Color teal = Color(0xFF009688); // Teal
  static const Color tealLight = Color(0xFF4DB6AC); // Light Teal
  static const Color tealDark = Color(0xFF00796B); // Dark Teal

  static const Color pink = Color(0xFFE91E63); // Pink
  static const Color pinkLight = Color(0xFFF48FB1); // Light Pink
  static const Color pinkDark = Color(0xFFC2185B); // Dark Pink

  // Peach Colors
  static const Color peach = Color(0xFFFFE5B4); // Peach
  static const Color peachLight = Color(0xFFFFF8E1); // Light Peach
  static const Color peachDark = Color(0xFFFFC107); // Dark Peach
  static const Color fontHint = Color(0xFF938A8A); // Dark Peach

  // Peach Badge Color
  static const Color peachBadge = Color(0xFFFF6E4A); // Peach Badge

  // Colors for moods
  static const Color terrible = Color(0xFFD32F2F); // Red
  static const Color bad = Color(0xFFE57373); // Light Red
  static const Color moderate = Color(0xFFFF8C00); // Dark Amber
  static const Color good = Color(0xFF8BC34A); // Light Green
  static const Color excellent = Color(0xFF388E3C); // Green

  // msb Main Colors
  static const Color msbMain100 = Color(0xFFEDE9FA);
  static const Color msbMain200 = Color(0xFFE1DBF6);
  static const Color msbMain300 = Color(0xFFD4CCF3);
  static const Color msbMain400 = Color(0xFFB4A7EB);
  static const Color msbMain500 = Color(0xFF8F7BE0);
  static const Color msbMain600 = Color(0xFF694FD6);
  static const Color msbMain700 = Color(0xFF5438C8);
  static const Color msbMain800 = Color(0xFF482BBD);
  static const Color msbMain900 = Color(0xFF3B1EB1);
  static const Color msbMain1000 = Color(0xFF371DA8);
  static const Color msbMain1200 = Color(0xFF321A97);
  static const Color msbMain1300 = Color(0xFF2C1685);
  static const Color msbMain1400 = Color(0xFF201163);
  static const Color msbMain1500 = Color(0xFF1C0F58);
  static const Color msbMain1600 = Color(0xFF160C48);

  // msb Neutral Colors
  static const Color msbNeutral50 = Color(0xFFFAFAFA);
  static const Color msbNeutral100 = Color(0xFFF5F5F5);
  static const Color msbNeutral200 = Color(0xFFEEEEEE);
  static const Color msbNeutral300 = Color(0xFFE0E0E0);
  static const Color msbNeutral400 = Color(0xFFBDBDBD);
  static const Color msbNeutral500 = Color(0xFF9E9E9E);
  static const Color msbNeutral600 = Color(0xFF757575);
  static const Color msbNeutral700 = Color(0xFF616161);
  static const Color msbNeutral800 = Color(0xFF424242);
  static const Color msbNeutral900 = Color(0xFF212121);

  // msb major colors
  static const Color msbWhite = Color(0xFFFFFFFF);
  static const Color msbColor1 = Color(0xFF0447AB); // #0447AB
  static const Color msbColor2 = Color(0xFF0498AF); // #0498AF
  static const Color msbColor3 = Color(0xFF847DB0); // #847DB0
  static const Color msbColor4 =
      Color(0x59000000); // #00000059 (Semi-transparent black)
  static const Color msbColor5 = Color(0xFF000000); // #000000
  static const Color msbColor6 = Color(0xFF525252); // #525252
  static const Color msbColor7 =
      Color(0x60000000); // #00000059 (Semi-transparent black)

  // msb misc colors
  static const Color msbGold = Color(0xFFFFDC64);
  static const Color msbBrightRed = Color(0xFFFA0000);
}
