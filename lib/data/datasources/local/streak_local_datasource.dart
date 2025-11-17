import 'package:hive/hive.dart';
import '../../../core/model/streak_model.dart';

/// Local data source for Streak operations using Hive
/// Handles all local database operations for streak tracking
class StreakLocalDatasource {
  static final StreakLocalDatasource _instance =
      StreakLocalDatasource._internal();
  factory StreakLocalDatasource() => _instance;
  StreakLocalDatasource._internal();

  late Box _settingsBox;

  /// Initialize Hive box for settings/streak
  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
  }

  /// Get streak data from local storage
  Future<Streak> getStreak() async {
    final currentStreak = _settingsBox.get('streak', defaultValue: 0);
    final dateStr = _settingsBox.get('lastActivityDate');

    return Streak(
      currentStreak: currentStreak,
      lastActivityDate: dateStr != null ? DateTime.parse(dateStr) : null,
    );
  }

  /// Get just the streak count
  Future<int> getStreakCount() async {
    return _settingsBox.get('streak', defaultValue: 0);
  }

  /// Get last activity date
  Future<DateTime?> getLastActivityDate() async {
    final dateStr = _settingsBox.get('lastActivityDate');
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }

  /// Save streak data to local storage
  Future<void> saveStreak(Streak streak) async {
    await _settingsBox.put('streak', streak.currentStreak);
    if (streak.lastActivityDate != null) {
      await _settingsBox.put(
        'lastActivityDate',
        streak.lastActivityDate!.toIso8601String(),
      );
    }
  }

  /// Reset streak to zero
  Future<void> resetStreak() async {
    await _settingsBox.put('streak', 0);
    await _settingsBox.delete('lastActivityDate');
  }
}
