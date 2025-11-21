/// XP Model - Tracks user's experience points and level progression
/// Compatible with both Hive and Firestore serialization
class XP {
  final int totalXP;
  final int currentLevel;
  final DateTime? lastUpdated;

  XP({
    required this.totalXP,
    required this.currentLevel,
    this.lastUpdated,
  });

  /// Create XP from Map (for Hive/Firestore)
  factory XP.fromMap(Map<String, dynamic> map) {
    return XP(
      totalXP: map['totalXP'] ?? 0,
      currentLevel: map['currentLevel'] ?? 1,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
    );
  }

  /// Convert XP to Map (for Hive/Firestore)
  Map<String, dynamic> toMap() {
    return {
      'totalXP': totalXP,
      'currentLevel': currentLevel,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Calculate level based on total XP
  /// Level progression: Level 1 = 0-99 XP, Level 2 = 100-299 XP, etc.
  static int calculateLevelFromXP(int xp) {
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    if (xp < 2100) return 6;
    if (xp < 2800) return 7;
    if (xp < 3600) return 8;
    if (xp < 4500) return 9;
    if (xp < 5500) return 10;
    
    // For levels above 10, each level requires 1000 more XP
    return 10 + ((xp - 5500) ~/ 1000);
  }

  /// Get XP required for next level
  int get xpForNextLevel {
    final nextLevel = currentLevel + 1;
    return _getXPRequiredForLevel(nextLevel);
  }

  /// Get XP required for current level
  int get xpForCurrentLevel {
    return _getXPRequiredForLevel(currentLevel);
  }

  /// Get progress to next level (0.0 to 1.0)
  double get progressToNextLevel {
    final currentLevelXP = xpForCurrentLevel;
    final nextLevelXP = xpForNextLevel;
    final progressXP = totalXP - currentLevelXP;
    final levelRange = nextLevelXP - currentLevelXP;
    
    if (levelRange <= 0) return 1.0;
    return (progressXP / levelRange).clamp(0.0, 1.0);
  }

  /// Get XP remaining to next level
  int get xpToNextLevel {
    return (xpForNextLevel - totalXP).clamp(0, double.infinity).toInt();
  }

  /// Helper method to get XP required for a specific level
  static int _getXPRequiredForLevel(int level) {
    if (level <= 1) return 0;
    if (level == 2) return 100;
    if (level == 3) return 300;
    if (level == 4) return 600;
    if (level == 5) return 1000;
    if (level == 6) return 1500;
    if (level == 7) return 2100;
    if (level == 8) return 2800;
    if (level == 9) return 3600;
    if (level == 10) return 4500;
    if (level == 11) return 5500;
    
    // For levels above 11, each level requires 1000 more XP than the previous
    return 5500 + ((level - 11) * 1000);
  }

  /// Add XP and return new XP object with updated level
  XP addXP(int xpToAdd) {
    final newTotalXP = totalXP + xpToAdd;
    final newLevel = calculateLevelFromXP(newTotalXP);
    
    return XP(
      totalXP: newTotalXP,
      currentLevel: newLevel,
      lastUpdated: DateTime.now(),
    );
  }

  /// Check if user leveled up compared to previous XP object
  bool didLevelUp(XP previousXP) {
    return currentLevel > previousXP.currentLevel;
  }

  /// Get level title/name
  String get levelTitle {
    if (currentLevel <= 2) return 'Beginner';
    if (currentLevel <= 5) return 'Learner';
    if (currentLevel <= 8) return 'Scholar';
    if (currentLevel <= 12) return 'Expert';
    if (currentLevel <= 16) return 'Master';
    if (currentLevel <= 20) return 'Grandmaster';
    return 'Legend';
  }

  /// Copy with method for immutability
  XP copyWith({
    int? totalXP,
    int? currentLevel,
    DateTime? lastUpdated,
  }) {
    return XP(
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'XP(totalXP: $totalXP, currentLevel: $currentLevel, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XP &&
        other.totalXP == totalXP &&
        other.currentLevel == currentLevel &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return totalXP.hashCode ^ currentLevel.hashCode ^ lastUpdated.hashCode;
  }
}
