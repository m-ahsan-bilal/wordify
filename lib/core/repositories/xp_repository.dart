import '../model/xp_model.dart';

/// Abstract repository interface for XP operations
/// This defines the contract that repository implementations must follow
/// Allows easy switching between local (Hive) and remote (Firestore) data sources
abstract class XPRepository {
  /// Get current XP data
  Future<XP> getXP();

  /// Get current total XP
  Future<int> getTotalXP();

  /// Get current level
  Future<int> getCurrentLevel();

  /// Add XP and update level automatically
  /// Returns the updated XP object and whether user leveled up
  Future<({XP newXP, bool leveledUp})> addXP(int xpToAdd);

  /// Save XP data
  Future<void> saveXP(XP xp);

  /// Reset XP to zero (for testing or user request)
  Future<void> resetXP();

  /// Get XP progress to next level (0.0 to 1.0)
  Future<double> getProgressToNextLevel();

  /// Get XP remaining to reach next level
  Future<int> getXPToNextLevel();
}
