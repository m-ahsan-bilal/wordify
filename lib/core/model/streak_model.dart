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
  Streak calculateStreak({required bool hasActivityToday}) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // If no previous activity
    if (lastActivityDate == null) {
      if (hasActivityToday) {
        // Start new streak
        return Streak(currentStreak: 1, lastActivityDate: today);
      } else {
        // No activity and no previous activity, keep at 0
        return this;
      }
    }

    // Calculate days difference
    final lastDate = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    final daysDifference = todayDate.difference(lastDate).inDays;

    if (hasActivityToday) {
      // User has activity today
      if (daysDifference == 0) {
        // Same day, no change
        return this;
      } else if (daysDifference == 1) {
        // Consecutive day, increment streak
        return Streak(currentStreak: currentStreak + 1, lastActivityDate: today);
      } else {
        // Streak broken (missed days), reset to 1
        return Streak(currentStreak: 1, lastActivityDate: today);
      }
    } else {
      // No activity today - check if streak should be reset
      if (daysDifference == 0) {
        // Same day but no activity yet, keep current streak
        return this;
      } else if (daysDifference >= 1) {
        // Missed a day or more, reset streak to 0
        return Streak(currentStreak: 0, lastActivityDate: null);
      } else {
        // This shouldn't happen, but keep current streak
        return this;
      }
    }
  }

  /// Check if streak will break if no activity today
  bool isStreakAtRisk() {
    if (lastActivityDate == null) return false;

    final today = DateTime.now();
    final lastDate = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysDifference = todayDate.difference(lastDate).inDays;

    // Streak is at risk if more than 1 day has passed
    return daysDifference >= 1;
  }

  /// Copy with method for immutability
  Streak copyWith({int? currentStreak, DateTime? lastActivityDate}) {
    return Streak(
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}
