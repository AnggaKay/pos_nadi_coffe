import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF20201D);
  static const cream = Color(0xFFF7F5F0);
  static const coffee = Color(0xFF825B3A);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: coffee,
      brightness: Brightness.light,
      surface: cream,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: cream,
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6E6B64)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
