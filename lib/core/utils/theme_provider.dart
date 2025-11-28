import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'app_colors.dart';

/// Theme provider - manages light and dark themes
/// Uses colors from AppColors for consistency
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  late Box _settingsBox;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _settingsBox = await Hive.openBox('settings');
    _isDarkMode = _settingsBox.get(_themeKey, defaultValue: false);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _settingsBox.put(_themeKey, _isDarkMode);
    notifyListeners();
  }

  /// Light theme - uses colors from splash/onboarding
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightLavender,
      colorScheme: const ColorScheme.light(
        primary: AppColors.darkPurple,
        secondary: AppColors.lightPurple,
        surface: AppColors.lightLavender, // Replaces white
        onPrimary: Colors.white,
        onSecondary: AppColors.darkGray,
        onSurface: AppColors.darkGray,
        outline: AppColors.progressGray,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightLavender,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkGray),
        titleTextStyle: TextStyle(
          color: AppColors.darkGray,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightLavender,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPurple,
          foregroundColor: AppColors.darkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGray,
          side: const BorderSide(color: AppColors.progressGray),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColors.lightGray),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.darkGray),
        displayMedium: TextStyle(color: AppColors.darkGray),
        displaySmall: TextStyle(color: AppColors.darkGray),
        headlineLarge: TextStyle(color: AppColors.darkGray),
        headlineMedium: TextStyle(color: AppColors.darkGray),
        headlineSmall: TextStyle(color: AppColors.darkGray),
        titleLarge: TextStyle(color: AppColors.darkGray),
        titleMedium: TextStyle(color: AppColors.darkGray),
        titleSmall: TextStyle(color: AppColors.darkGray),
        bodyLarge: TextStyle(color: AppColors.darkGray),
        bodyMedium: TextStyle(color: AppColors.darkGray),
        bodySmall: TextStyle(color: AppColors.lightGray),
        labelLarge: TextStyle(color: AppColors.darkGray),
        labelMedium: TextStyle(color: AppColors.darkGray),
        labelSmall: TextStyle(color: AppColors.lightGray),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightLavender,
        selectedColor: AppColors.lightPurple,
        labelStyle: const TextStyle(color: AppColors.darkGray),
        side: const BorderSide(color: AppColors.progressGray),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: AppColors.progressGray,
    );
  }

  /// Dark theme - uses black shades
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSecondary: AppColors.darkOnSurface,
        onSurface: AppColors.darkOnSurface,
        outline: AppColors.darkDivider,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkOnSurface),
        titleTextStyle: TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPurple,
          foregroundColor: AppColors.darkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkOnSurface,
          side: const BorderSide(color: AppColors.darkDivider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColors.lightGray),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.darkOnSurface),
        displayMedium: TextStyle(color: AppColors.darkOnSurface),
        displaySmall: TextStyle(color: AppColors.darkOnSurface),
        headlineLarge: TextStyle(color: AppColors.darkOnSurface),
        headlineMedium: TextStyle(color: AppColors.darkOnSurface),
        headlineSmall: TextStyle(color: AppColors.darkOnSurface),
        titleLarge: TextStyle(color: AppColors.darkOnSurface),
        titleMedium: TextStyle(color: AppColors.darkOnSurface),
        titleSmall: TextStyle(color: AppColors.darkOnSurface),
        bodyLarge: TextStyle(color: AppColors.darkOnSurface),
        bodyMedium: TextStyle(color: AppColors.darkOnSurface),
        bodySmall: TextStyle(color: AppColors.lightGray),
        labelLarge: TextStyle(color: AppColors.darkOnSurface),
        labelMedium: TextStyle(color: AppColors.darkOnSurface),
        labelSmall: TextStyle(color: AppColors.lightGray),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.darkPrimary,
        labelStyle: const TextStyle(color: AppColors.darkOnSurface),
        side: const BorderSide(color: AppColors.darkDivider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: AppColors.darkDivider,
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkCard,
        textStyle: const TextStyle(color: AppColors.darkOnSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
