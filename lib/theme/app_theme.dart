
import 'package:flutter/material.dart';

class AppTheme {
  // Existing Cyber Energy colors — preserved
  static const Color background = Color(0xFF070B14);
  static const Color surface = Color(0xFF101827);
  static const Color surfaceLight = Color(0xFF182337);

  static const Color electricBlue = Color(0xFF00B7FF);
  static const Color cyberPurple = Color(0xFF8B5CF6);
  static const Color lightningYellow = Color(0xFFFFD60A);

  static const Color primaryText = Color(0xFFF5F7FF);
  static const Color secondaryText = Color(0xFF9AA8BD);

  // Premium Light Theme colors
  static const Color lightBackground = Color(0xFFF4F6FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFE9EEFA);

  static const Color lightBlue = Color(0xFF1769D2);
  static const Color lightPurple = Color(0xFF6741C8);
  static const Color lightYellow = Color(0xFFFFC928);

  static const Color lightPrimaryText = Color(0xFF17213B);
  static const Color lightSecondaryText = Color(0xFF46536B);
  static const Color lightBorder = Color(0xFFB9C5DA);

  // DARK THEME
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: electricBlue,
      secondary: cyberPurple,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: primaryText,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: primaryText),
      bodyMedium: TextStyle(color: primaryText),
      bodySmall: TextStyle(color: secondaryText),
      titleLarge: TextStyle(
        color: primaryText,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(color: primaryText),
      labelLarge: TextStyle(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: primaryText,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: surface,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      labelStyle: const TextStyle(color: secondaryText),
      hintStyle: const TextStyle(color: secondaryText),
      prefixIconColor: electricBlue,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: electricBlue,
          width: 1.5,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: electricBlue,
        foregroundColor: const Color(0xFF07111F),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  // PREMIUM LIGHT THEME — high text contrast
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: lightBlue,
      secondary: lightPurple,
      surface: lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightPrimaryText,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: lightPrimaryText,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: lightPrimaryText,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: lightSecondaryText,
        fontSize: 12,
      ),
      titleLarge: TextStyle(
        color: lightPrimaryText,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: lightPrimaryText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        color: lightPrimaryText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: TextStyle(
        color: lightPrimaryText,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightPrimaryText,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: lightSurface,
      elevation: 2,
      shadowColor: Color(0x180E2855),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      labelStyle: const TextStyle(
        color: lightSecondaryText,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: lightSecondaryText,
      ),
      prefixIconColor: lightBlue,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: lightBorder,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: lightBlue,
          width: 2,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightBlue,
        side: const BorderSide(color: lightBlue),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: lightBorder,
      thickness: 1,
    ),
  );
}