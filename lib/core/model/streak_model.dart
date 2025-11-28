/// Streak Model - Tracks user's daily learning streak
/// Compatible with both Hive and Firestore serialization
class Streak {
  final int currentStreak;
  final DateTime? lastActivityDate;

  Streak({required this.currentStreak, this.lastActivityDate});

  /// Create Streak from Map (for Hive/Firestore)
  factory Streak.fromMap(Map<String, dynamic> map) {
    return Streak(
      currentStreak: map['currentStreak'] ?? 0,
      lastActivityDate: map['lastActivityDate'] != null
          ? DateTime.parse(map['lastActivityDate'])
          : null,
    );
  }

  /// Convert Streak to Map (for Hive/Firestore)
  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
    };
  }

  /// Calculate if streak should continue, reset, or increment
  /// Returns a new Streak object with updated values
  /// Handles timezone-aware date comparisons
  Streak calculateStreak({required bool hasActivityToday}) {
    // Use local timezone for "today" calculation
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    // If no previous activity
    if (lastActivityDate == null) {
      if (hasActivityToday) {
        // Start new streak - use current time, not just date
        return Streak(currentStreak: 1, lastActivityDate: now);
      } else {
        // No activity and no previous activity, keep at 0
        return this;
      }
    }

    // Calculate days difference using date-only comparison (timezone-aware)
    final lastDate = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    
    // Calculate difference in days (ignoring time component)
    final daysDifference = todayDate.difference(lastDate).inDays;

    if (hasActivityToday) {
      // User has activity today
      if (daysDifference == 0) {
        // Same day - update lastActivityDate to current time but keep streak
        // This ensures if user adds word multiple times today, streak persists
        return Streak(currentStreak: currentStreak, lastActivityDate: now);
      } else if (daysDifference == 1) {
        // Consecutive day (yesterday -> today), increment streak
        return Streak(currentStreak: currentStreak + 1, lastActivityDate: now);
      } else if (daysDifference > 1) {
        // Streak broken (missed days), start new streak at 1
        return Streak(currentStreak: 1, lastActivityDate: now);
      } else {
        // Negative difference shouldn't happen, but handle gracefully
        // This could happen if system time changed backwards
        return Streak(currentStreak: currentStreak, lastActivityDate: now);
      }
    } else {
      // No activity today - check if streak should be reset
      if (daysDifference == 0) {
        // Same day but no activity yet, keep current streak
        // Don't reset until tomorrow if still no activity
        return this;
      } else if (daysDifference == 1) {
        // Yesterday was last activity, today no activity yet
        // Keep streak for now - will reset tomorrow if still no activity
        // This allows user to add word later today and maintain streak
        return this;
      } else if (daysDifference > 1) {
        // Missed multiple days, reset streak to 0
        return Streak(currentStreak: 0, lastActivityDate: null);
      } else {
        // Negative difference (shouldn't happen), keep current streak
        return this;
      }
    }
  }

  /// Check if streak will break if no activity today
  /// Returns true if streak is at risk (yesterday was last activity, today no activity yet)
  bool isStreakAtRisk() {
    if (lastActivityDate == null) return false;
    if (currentStreak == 0) return false;

    final today = DateTime.now();
    final lastDate = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysDifference = todayDate.difference(lastDate).inDays;

    // Streak is at risk if yesterday was the last activity (1 day difference)
    // and user hasn't added word today yet
    // If 0 days difference, user already has activity today, so not at risk
    // If >1 days difference, streak is already broken, so not "at risk"
    return daysDifference == 1;
  }

  /// Copy with method for immutability
  Streak copyWith({int? currentStreak, DateTime? lastActivityDate}) {
    return Streak(
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}
