import 'package:flutter/material.dart';

/// Central color palette. Referenced by [AppTheme] to build the light and dark
/// [ThemeData]. Widgets should prefer `Theme.of(context).colorScheme` over
/// reaching into these directly, but semantic finance colors (income/expense)
/// live here since Material's scheme has no slot for them.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF2E7D6B); // teal-green
  static const Color primaryDark = Color(0xFF1B5E52);
  static const Color secondary = Color(0xFFF2A44E); // warm accent

  // Semantic finance colors
  static const Color income = Color(0xFF2E9E5B);
  static const Color expense = Color(0xFFE0533D);
  static const Color warning = Color(0xFFF2A44E);

  // Light surfaces
  static const Color lightBackground = Color(0xFFF6F8F7);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Dark surfaces
  static const Color darkBackground = Color(0xFF121514);
  static const Color darkSurface = Color(0xFF1D2321);

  // Neutrals
  static const Color error = Color(0xFFD32F2F);
}
