import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    colorScheme: const ColorScheme.light(
      surface: Color(0xFFFFFFFF),
      surfaceContainerHighest: Color(0xFFFAF8F5),
      onSurface: Color(0xFF000000),
      onSurfaceVariant: Color(0xFF9E9E9E),
      primary: Color(0xFFFF9800),
      error: Colors.red,
    ),
    useMaterial3: true,
  );

  static ThemeData dark = ThemeData(
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF1E1E1E),
      surfaceContainerHighest: Color(0xFF2A2A2A),
      onSurface: Color(0xFFE6E1E5),
      onSurfaceVariant: Color(0xFF999999),
      primary: Color(0xFFFF9800),
      error: Colors.red,
    ),
    useMaterial3: true,
  );
}

class AppColors {
  static const point = Color(0xFFFF9800);
  static const error = Colors.red;

  static const moodAngry = Color(0xFFFF4B4B);
  static const moodSad = Color(0xFFFF8A3D);
  static const moodAnxious = Color(0xFFFFD95C);
  static const moodNormal = Color(0xFFB0BEC5);
  static const moodDepressed = Color(0xFF90A4AE);
  static const moodLucky = Color(0xFF81C784);
  static const moodExcited = Color(0xFF4CAF50);
  static const moodHappy = Color(0xFF008C14);
}
