import 'package:flutter/foundation.dart';
import '../core/model/xp_model.dart';
import '../core/repositories/xp_repository.dart';

/// ViewModel for XP management
/// Handles XP-related business logic and state management
class XPViewModel extends ChangeNotifier {
  final XPRepository _xpRepository;

  XPViewModel({required XPRepository xpRepository})
      : _xpRepository = xpRepository;

  XP _xp = XP(totalXP: 0, currentLevel: 1);
  XP get xp => _xp;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Load current XP data
  Future<void> loadXP() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _xp = await _xpRepository.getXP();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading XP: $e');
      _error = 'Failed to load XP data';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add XP and handle level up notifications
  Future<bool> addXP(int xpToAdd) async {
    try {
      _error = null;

      final result = await _xpRepository.addXP(xpToAdd);
      _xp = result.newXP;
      
      notifyListeners();
      
      // Return true if user leveled up (for UI notifications)
      return result.leveledUp;
    } catch (e) {
      debugPrint('Error adding XP: $e');
      _error = 'Failed to add XP';
      notifyListeners();
      return false;
    }
  }

  /// Get formatted XP display text
  String getXPDisplayText() {
    if (_xp.totalXP >= 1000) {
      return '${(_xp.totalXP / 1000).toStringAsFixed(1)}k XP';
    }
    return '${_xp.totalXP} XP';
  }

  /// Get level display text
  String getLevelDisplayText() {
    return 'Level ${_xp.currentLevel}';
  }

  /// Get level title
  String getLevelTitle() {
    return _xp.levelTitle;
  }

  /// Get progress to next level (0.0 to 1.0)
  double getProgressToNextLevel() {
    return _xp.progressToNextLevel;
  }

  /// Get XP remaining to next level
  int getXPToNextLevel() {
    return _xp.xpToNextLevel;
  }

  /// Get progress text for UI
  String getProgressText() {
    final current = _xp.totalXP - _xp.xpForCurrentLevel;
    final needed = _xp.xpForNextLevel - _xp.xpForCurrentLevel;
    return '$current / $needed XP';
  }

  /// Reset XP (for testing or user request)
  Future<void> resetXP() async {
    try {
      _error = null;
      await _xpRepository.resetXP();
      _xp = XP(totalXP: 0, currentLevel: 1);
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting XP: $e');
      _error = 'Failed to reset XP';
      notifyListeners();
    }
  }

  /// Award XP for specific actions
  Future<bool> awardXPForAction(XPAction action, {int? customAmount}) async {
    int xpAmount;
    
    switch (action) {
      case XPAction.addWord:
        xpAmount = customAmount ?? 0; // XP calculated by Word model
        break;
      case XPAction.completeQuiz:
        xpAmount = 20;
        break;
      case XPAction.perfectQuiz:
        xpAmount = 35; // 20 + 15 bonus
        break;
      case XPAction.dailyStreak:
        xpAmount = 5;
        break;
      case XPAction.weeklyChallenge:
        xpAmount = 50;
        break;
      case XPAction.masterWord:
        xpAmount = 25;
        break;
      case XPAction.monthlyGoal:
        xpAmount = 100;
        break;
      case XPAction.custom:
        xpAmount = customAmount ?? 0;
        break;
    }

    if (xpAmount > 0) {
      return await addXP(xpAmount);
    }
    return false;
  }

  /// Check if user can level up with current XP
  bool canLevelUp() {
    return _xp.totalXP >= _xp.xpForNextLevel;
  }

  /// Get next level preview
  int getNextLevel() {
    return _xp.currentLevel + 1;
  }
}

/// Enum for different XP-earning actions
enum XPAction {
  addWord,
  completeQuiz,
  perfectQuiz,
  dailyStreak,
  weeklyChallenge,
  masterWord,
  monthlyGoal,
  custom,
}
