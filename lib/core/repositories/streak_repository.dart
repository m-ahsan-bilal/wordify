import '../model/streak_model.dart';

/// Abstract repository interface for Streak operations
/// This defines the contract that repository implementations must follow
/// Allows easy switching between local (Hive) and remote (Firestore) data sources
abstract class StreakRepository {
  /// Get current streak data
  Future<Streak> getStreak();

  /// Get current streak count
  Future<int> getStreakCount();

  /// Get last activity date
  Future<DateTime?> getLastActivityDate();

  /// Update streak based on current activity
  /// Should be called after adding a word
  Future<void> updateStreak({required bool hasActivityToday});

  /// Check if streak is at risk (no activity today)
  Future<bool> isStreakAtRisk();

  /// Reset streak to zero (for testing or user request)
  Future<void> resetStreak();

  /// Save streak data
  Future<void> saveStreak(Streak streak);
}
