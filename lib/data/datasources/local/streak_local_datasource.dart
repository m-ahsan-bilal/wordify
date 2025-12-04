import 'package:flutter/foundation.dart';
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
    try {
      // Check if box is already open
      if (Hive.isBoxOpen('settings')) {
        _settingsBox = Hive.box('settings');
      } else {
        _settingsBox = await Hive.openBox('settings').timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            // Try to get existing box if timeout
            try {
              return Hive.box('settings');
            } catch (_) {
              rethrow;
            }
          },
        );
      }
    } catch (e) {
      debugPrint('Error initializing StreakLocalDatasource: $e');
      // Retry after delay
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        _settingsBox = await Hive.openBox('settings');
      } catch (e2) {
        debugPrint('StreakLocalDatasource retry failed: $e2');
        rethrow;
      }
    }
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
