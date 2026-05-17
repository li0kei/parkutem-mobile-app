import 'package:flutter/material.dart';

// =====================================================
// APP THEME
// =====================================================

class AppTheme {
  static const Color primaryCyan = Color(0xFF16D9FF);
  static const Color primaryBlue = Color(0xFF0D8DFF);
  static const Color darkBackground = Color(0xFF020817);
  static const Color darkCard = Color(0xFF0F172A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: primaryBlue,
        surface: darkCard,
      ),
      fontFamily: 'Roboto',
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryCyan,
        surface: Colors.white,
      ),
      fontFamily: 'Roboto',
    );
  }
}