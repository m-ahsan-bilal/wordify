import 'package:flutter/material.dart';

/// Shared color constants for the app
/// All colors used throughout the app are defined here
class AppColors {
  // Light Theme Colors (from splash/onboarding)
  static const Color lightLavender = Color(0xFFF5F0FF); // Background
  static const Color lightPurple = Color(0xFFE8D5FF); // Buttons, accents
  static const Color lightBlue = Color(0xFFE0F2FE); // Accent shapes
  static const Color purple = Color(0xFFD4A5FF); // Secondary accent
  static const Color darkPurple = Color(0xFF9D6FD9); // Primary accent
  static const Color darkGray = Color(0xFF2D2D2D); // Text
  static const Color lightGray = Color(0xFF9E9E9E); // Secondary text
  static const Color lightGreen = Color(0xFF4ADE80); // Progress, success
  static const Color progressGray = Color(0xFFE5E5E5); // Borders, dividers
  static const Color fireOrange = Color(0xFFFF6B35); // Fire color for streak
  static const Color inputFieldBackground = Colors.white; // Input field background (for contrast with lightLavender)

  // Dark Theme Colors (black shades)
  static const Color darkBackground = Color(0xFF121212); // Main background
  static const Color darkSurface = Color(0xFF1E1E1E); // Cards, surfaces
  static const Color darkCard = Color(0xFF2D2D2D); // Card background
  static const Color darkPrimary = Color(0xFF9D6FD9); // Primary accent
  static const Color darkSecondary = Color(0xFFE8D5FF); // Secondary accent
  static const Color darkOnSurface = Color(0xFFE0E0E0); // Text on dark
  static const Color darkDivider = Color(0xFF404040); // Dividers, borders
  static const Color darkStatCard = Color(0xFF2D1F3D); // Stat cards
  static const Color darkStatCardLight = Color(0xFF3D2F5A); // Stat cards light
}

/// Theme helper class to get colors based on current theme
/// Uses clean architecture - all color logic centralized here
class ThemeColors {
  /// Get background color based on theme
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  /// Get card/surface color based on theme
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Get secondary text color based on theme
  static Color getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.lightGray : AppColors.lightGray;
  }

  /// Get border/divider color based on theme
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  /// Get primary color based on theme
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Get secondary color based on theme
  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  /// Get button color (0xFFE8D5FF) for all app buttons
  static Color getButtonColor(BuildContext context) {
    return AppColors.lightPurple;
  }

  /// Get stat card background color
  static Color getStatCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkStatCard : AppColors.lightPurple;
  }

  /// Get stat card icon/text color
  static Color getStatCardIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkSecondary : AppColors.darkGray;
  }
}
