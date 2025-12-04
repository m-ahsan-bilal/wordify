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
    // Wait for Hive to be initialized (with retries)
    for (int i = 0; i < 10; i++) {
      try {
        // Check if Hive is initialized
        if (!Hive.isBoxOpen('settings')) {
          _settingsBox = await Hive.openBox('settings').timeout(
            const Duration(milliseconds: 500),
            onTimeout: () {
              // Try to get existing box if timeout
              try {
                return Hive.box('settings');
              } catch (_) {
                rethrow;
              }
            },
          );
        } else {
          _settingsBox = Hive.box('settings');
        }
        
        final languageCode = _settingsBox.get(_languageKey, defaultValue: 'en');
        _locale = Locale(languageCode);
        notifyListeners();
        return; // Success, exit
      } catch (e) {
        // Hive not ready yet, wait and retry
        if (i < 9) {
          await Future.delayed(const Duration(milliseconds: 100));
          continue;
        }
        // Last attempt failed, use default
        debugPrint('Error loading language (Hive not ready): $e');
        _locale = const Locale('en'); // Default to English
        notifyListeners();
        return;
      }
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    _locale = Locale(languageCode);
    try {
      // Ensure box is available
      if (!Hive.isBoxOpen('settings')) {
        _settingsBox = await Hive.openBox('settings');
      } else {
        _settingsBox = Hive.box('settings');
      }
      await _settingsBox.put(_languageKey, languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving language: $e');
      // Still update UI even if save fails
      notifyListeners();
    }
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
