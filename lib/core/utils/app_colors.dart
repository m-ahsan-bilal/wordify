import 'package:flutter/material.dart';

/// Shared color constants for the app
class AppColors {
  // Light Theme Colors
  static const Color lightLavender = Color(0xFFF5F0FF);
  static const Color lightPurple = Color(0xFFE8D5FF);
  static const Color lightBlue = Color(0xFFE0F2FE);
  static const Color purple = Color(0xFFD4A5FF);
  static const Color darkPurple = Color(0xFF9D6FD9);
  static const Color darkGray = Color(0xFF2D2D2D);
  static const Color lightGray = Color(0xFF9E9E9E);
  static const Color lightGreen = Color(0xFF4ADE80);
  static const Color progressGray = Color(0xFFE5E5E5);
  static const Color white = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkPrimary = Color(0xFF9D6FD9);
  static const Color darkSecondary = Color(0xFFE8D5FF);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkDivider = Color(0xFF404040);
  static const Color darkBorder = Color(0xFF404040);
  
  // Dark theme stat card color (darker purple with black shades)
  // Smooth dark purple-black that matches splash screen aesthetic
  static const Color darkStatCard = Color(0xFF2D1F3D); // Smooth dark purple-black
  static const Color darkStatCardLight = Color(0xFF3D2F5A); // Lighter variant for contrast
}

/// Theme helper class to get colors based on current theme
class ThemeColors {
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF9E9E9E)
            : const Color(0xFF9E9E9E));
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getOnPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getOnSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSecondary;
  }

  /// Get stat card background color (matches splash screen logo container)
  static Color getStatCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkStatCard : AppColors.lightPurple;
  }

  /// Get stat card icon/text color (matches splash screen)
  static Color getStatCardIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkSecondary : AppColors.darkGray;
  }
}
