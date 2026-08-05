import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFFF7F7F5);
  static const Color surfaceColor = Colors.white;
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color textColor = Color(0xFF222222);
  static const Color secondaryTextColor = Color(0xFF666666);
  static const Color borderColor = Color(0xFFD9D9D9);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: backgroundColor,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
    ),

    cardTheme: const CardThemeData(
      color: surfaceColor,
      elevation: 1,
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: borderColor),
      ),
    ),

    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: textColor),
      bodyMedium: TextStyle(fontSize: 14, color: secondaryTextColor),
    ),
  );
}
