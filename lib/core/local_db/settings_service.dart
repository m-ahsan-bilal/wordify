import 'package:hive/hive.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late Box _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
  }

  // ---------------- STREAK ----------------
  int getStreak() {
    return _settingsBox.get('streak', defaultValue: 0);
  }

  DateTime? getLastActivityDate() {
    final dateStr = _settingsBox.get('lastActivityDate');
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }

  Future<void> updateStreak() async {
    final today = DateTime.now();
    final lastDate = getLastActivityDate();

    int streak = getStreak();

    if (lastDate != null) {
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        streak += 1;
      } else if (difference > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    await _settingsBox.put('streak', streak);
    await _settingsBox.put('lastActivityDate', today.toIso8601String());
  }

  Future<void> setStreak(int value) async {
    await _settingsBox.put('streak', value);
  }

  // ---------------- ONBOARDING ----------------
  bool hasSeenOnboarding() {
    return _settingsBox.get('onboarding', defaultValue: false);
  }

  Future<void> setOnboardingSeen() async {
    await _settingsBox.put('onboarding', true);
  }
}
