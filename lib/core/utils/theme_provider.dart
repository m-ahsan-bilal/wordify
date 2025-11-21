import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  late Box _settingsBox;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Expose theme colors directly from provider
  Color get backgroundColor =>
      _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F0FF);
  Color get cardColor => _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get textColor =>
      _isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF2D2D2D);
  Color get secondaryTextColor => const Color(0xFF9E9E9E);
  Color get borderColor =>
      _isDarkMode ? const Color(0xFF404040) : const Color(0xFFE5E5E5);
  Color get primaryColor =>
      _isDarkMode ? const Color(0xFF9D6FD9) : const Color(0xFF6C63FF);

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

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: const Color(0xFFF5F0FF),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFFE8D5FF),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF2D2D2D),
        onSurface: Color(0xFF2D2D2D),
        outline: Color(0xFFE5E5E5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F0FF),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF2D2D2D)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2D2D2D),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2D2D2D),
          side: const BorderSide(color: Color(0xFFE5E5E5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F0FF).withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFF2D2D2D)),
        displayMedium: TextStyle(color: Color(0xFF2D2D2D)),
        displaySmall: TextStyle(color: Color(0xFF2D2D2D)),
        headlineLarge: TextStyle(color: Color(0xFF2D2D2D)),
        headlineMedium: TextStyle(color: Color(0xFF2D2D2D)),
        headlineSmall: TextStyle(color: Color(0xFF2D2D2D)),
        titleLarge: TextStyle(color: Color(0xFF2D2D2D)),
        titleMedium: TextStyle(color: Color(0xFF2D2D2D)),
        titleSmall: TextStyle(color: Color(0xFF2D2D2D)),
        bodyLarge: TextStyle(color: Color(0xFF2D2D2D)),
        bodyMedium: TextStyle(color: Color(0xFF2D2D2D)),
        bodySmall: TextStyle(color: Color(0xFF9E9E9E)),
        labelLarge: TextStyle(color: Color(0xFF2D2D2D)),
        labelMedium: TextStyle(color: Color(0xFF2D2D2D)),
        labelSmall: TextStyle(color: Color(0xFF9E9E9E)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F0FF),
        selectedColor: const Color(0xFFE8D5FF),
        labelStyle: const TextStyle(color: Color(0xFF2D2D2D)),
        side: const BorderSide(color: Color(0xFFE5E5E5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: const Color(0xFFE5E5E5),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color.fromARGB(255, 154, 116, 205),
        secondary: Color(0xFF6B4C93),
        surface: Color(0xFF2D2D2D),
        onPrimary: Colors.white,
        onSecondary: Color(0xFFE0E0E0),
        onSurface: Color(0xFFE0E0E0),
        outline: Color(0xFF404040),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFE0E0E0)),
        titleTextStyle: TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9D6FD9),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE0E0E0),
          side: const BorderSide(color: Color(0xFF404040)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFFE0E0E0)),
        displayMedium: TextStyle(color: Color(0xFFE0E0E0)),
        displaySmall: TextStyle(color: Color(0xFFE0E0E0)),
        headlineLarge: TextStyle(color: Color(0xFFE0E0E0)),
        headlineMedium: TextStyle(color: Color(0xFFE0E0E0)),
        headlineSmall: TextStyle(color: Color(0xFFE0E0E0)),
        titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
        titleMedium: TextStyle(color: Color(0xFFE0E0E0)),
        titleSmall: TextStyle(color: Color(0xFFE0E0E0)),
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
        bodySmall: TextStyle(color: Color(0xFF9E9E9E)),
        labelLarge: TextStyle(color: Color(0xFFE0E0E0)),
        labelMedium: TextStyle(color: Color(0xFFE0E0E0)),
        labelSmall: TextStyle(color: Color(0xFF9E9E9E)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: const Color(0xFF6B4C93),
        labelStyle: const TextStyle(color: Color(0xFFE0E0E0)),
        side: const BorderSide(color: Color(0xFF404040)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: const Color(0xFF404040),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF2D2D2D),
        textStyle: const TextStyle(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
