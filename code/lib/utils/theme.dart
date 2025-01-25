import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colours.dart';

ThemeData getTheme() {
  return ThemeData(
      colorScheme: getColourScheme(),
      textTheme: getTextTheme(),
      useMaterial3: true,
      cardColor: AppColors.surface,
      cardTheme: getCardTheme(),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: getAppBarTheme(),
      elevatedButtonTheme: getElevatedButtonTheme(),
      fontFamily: GoogleFonts.raleway().fontFamily,
      inputDecorationTheme: getInputDecorationTheme(),
      textSelectionTheme: getTextSelectionTheme());
}

TextSelectionThemeData getTextSelectionTheme() {
  return const TextSelectionThemeData(cursorColor: AppColors.msbNeutral600);
}

InputDecorationTheme getInputDecorationTheme() {
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.white,
    hintStyle: const TextStyle(color: AppColors.msbNeutral400),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.msbNeutral400),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.msbNeutral400),
      borderRadius: BorderRadius.circular(10.0),
    ),
  );
}

ElevatedButtonThemeData getElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 8),
      textStyle: GoogleFonts.rubik(fontSize: 24.0, fontWeight: FontWeight.w500, color: AppColors.msbWhite),
      backgroundColor: AppColors.msbColor1,
      // Dark background color for buttons
      foregroundColor: AppColors.white,
      // White text color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
    ),
  );
}

AppBarTheme getAppBarTheme() {
  return AppBarTheme(
    surfaceTintColor: AppColors.msbMain100,
    backgroundColor: AppColors.msbMain100,
    foregroundColor: AppColors.msbMain100,
    titleTextStyle: TextStyle(color: AppColors.msbMain600, fontFamily: GoogleFonts.aclonica().fontFamily),
    iconTheme: const IconThemeData(color: AppColors.msbMain600),
  );
}

CardTheme getCardTheme() {
  return CardTheme(
    elevation: 16.0,
    surfaceTintColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  );
}

ColorScheme getColourScheme() {
  return const ColorScheme(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onSurface: AppColors.onSurface,
    onError: AppColors.onError,
    brightness: Brightness.light, background: AppColors.white, onBackground: AppColors.white,
  );
}

TextTheme getTextTheme() {
  return const TextTheme(
    bodySmall: TextStyle(color: AppColors.msbMain600),
    bodyMedium: TextStyle(color: AppColors.msbWhite),
    bodyLarge: TextStyle(color: AppColors.msbMain600),
    headlineSmall: TextStyle(color: AppColors.msbMain600),
    headlineMedium: TextStyle(color: AppColors.msbMain600),
    headlineLarge: TextStyle(color: AppColors.msbMain600),
  );
}
