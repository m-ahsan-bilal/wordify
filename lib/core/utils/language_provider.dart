import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Language Provider - Manages app language selection
/// Supports English, Urdu, Hindi, and Arabic
class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'appLanguage';
  late Box _settingsBox;
  Locale _locale = const Locale('en'); // Default to English

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      _settingsBox = await Hive.openBox('settings');
      final languageCode = _settingsBox.get(_languageKey, defaultValue: 'en');
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language: $e');
      _locale = const Locale('en');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    
    _locale = Locale(languageCode);
    await _settingsBox.put(_languageKey, languageCode);
    notifyListeners();
  }

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ur'), // Urdu
    Locale('hi'), // Hindi
    Locale('ar'), // Arabic
  ];

  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ur':
        return 'اردو'; // Urdu
      case 'hi':
        return 'हिंदी'; // Hindi
      case 'ar':
        return 'العربية'; // Arabic
      default:
        return 'English';
    }
  }
}

