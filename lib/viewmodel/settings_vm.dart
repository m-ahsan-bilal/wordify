import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

/// ViewModel for Settings and User Preferences
/// Handles onboarding, notification preferences, etc.
class SettingsViewModel extends ChangeNotifier {
  Box? _settingsBox;

  /// Get settings box (lazy initialization)
  Box get _box {
    _settingsBox ??= Hive.box('settings');
    return _settingsBox!;
  }

  // ---------------- ONBOARDING ----------------

  /// Check if user has seen onboarding
  bool hasSeenOnboarding() {
    try {
      return _box.get('onboarding', defaultValue: false);
    } catch (e) {
      debugPrint('Error checking onboarding: $e');
      return false;
    }
  }

  /// Mark onboarding as seen
  Future<void> setOnboardingSeen() async {
    try {
      await _box.put('onboarding', true);
      _safeNotify();
    } catch (e) {
      debugPrint('Error setting onboarding: $e');
    }
  }

  // ---------------- NOTIFICATION SETTINGS ----------------

  /// Get notification time (hour)
  int getNotificationHour() {
    try {
      return _box.get('notificationHour', defaultValue: 20);
    } catch (e) {
      debugPrint('Error getting notification hour: $e');
      return 20;
    }
  }

  /// Get notification time (minute)
  int getNotificationMinute() {
    try {
      return _box.get('notificationMinute', defaultValue: 0);
    } catch (e) {
      debugPrint('Error getting notification minute: $e');
      return 0;
    }
  }

  /// Set notification time
  Future<void> setNotificationTime(int hour, int minute) async {
    try {
      await _box.put('notificationHour', hour);
      await _box.put('notificationMinute', minute);
      _safeNotify();
    } catch (e) {
      debugPrint('Error setting notification time: $e');
    }
  }

  /// Check if notifications are enabled
  bool areNotificationsEnabled() {
    try {
      return _box.get('notificationsEnabled', defaultValue: true);
    } catch (e) {
      debugPrint('Error checking notifications enabled: $e');
      return true;
    }
  }

  /// Toggle notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await _box.put('notificationsEnabled', enabled);
      _safeNotify();
    } catch (e) {
      debugPrint('Error setting notifications enabled: $e');
    }
  }

  // ---------------- GENERAL SETTINGS ----------------

  /// Set any key-value pair
  Future<void> setValue(String key, dynamic value) async {
    try {
      await _box.put(key, value);
      _safeNotify();
    } catch (e) {
      debugPrint('Error setting value for $key: $e');
    }
  }

  /// Get any value by key
  dynamic getValue(String key, {dynamic defaultValue}) {
    try {
      return _box.get(key, defaultValue: defaultValue);
    } catch (e) {
      debugPrint('Error getting value for $key: $e');
      return defaultValue;
    }
  }

  /// Clear all settings (for testing or reset)
  Future<void> clearAllSettings() async {
    try {
      await _box.clear();
      _safeNotify();
    } catch (e) {
      debugPrint('Error clearing settings: $e');
    }
  }

  /// Safely notify listeners (avoids build-phase issues)
  void _safeNotify() {
    if (!hasListeners) return;

    // Use addPostFrameCallback to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }
}
