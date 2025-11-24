import 'package:flutter/widgets.dart';
import '../core/model/streak_model.dart';
import '../core/repositories/streak_repository.dart';
import '../core/repositories/word_repository.dart';

/// ViewModel for Streak management
/// Handles streak calculation, display, and risk notifications
class StreakViewModel extends ChangeNotifier {
  final StreakRepository _streakRepository;
  final WordRepository _wordRepository;

  StreakViewModel({
    required StreakRepository streakRepository,
    required WordRepository wordRepository,
  })  : _streakRepository = streakRepository,
        _wordRepository = wordRepository;

  Streak _streak = Streak(currentStreak: 0);
  Streak get streak => _streak;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isStreakAtRisk = false;
  bool get isStreakAtRisk => _isStreakAtRisk;

  String? _error;
  String? get error => _error;

  /// Load current streak data
  /// This also validates and resets the streak if it's broken
  Future<void> loadStreak() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotify();

      // Get streak (this will validate and reset if broken)
      _streak = await _streakRepository.getStreak();
      
      // Also check if streak is at risk (will break if no activity today)
      _isStreakAtRisk = await _streakRepository.isStreakAtRisk();

      _isLoading = false;
      _safeNotify();
    } catch (e) {
      debugPrint('Failed to load streak: $e');
      _error = 'Failed to load streak';
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Update streak based on today's activity
  /// This should be called when a word is added or when checking streak status
  Future<void> updateStreak() async {
    try {
      // Check if user has added words today
      final todaysWords = await _wordRepository.getTodaysWords();
      final hasActivityToday = todaysWords.isNotEmpty;

      // Update streak with today's activity status
      await _streakRepository.updateStreak(hasActivityToday: hasActivityToday);

      // Reload streak data to get updated values
      await loadStreak();
    } catch (e) {
      debugPrint('Failed to update streak: $e');
      _error = 'Failed to update streak';
      _safeNotify();
    }
  }

  /// Validate and update streak on app load
  /// This ensures streak is reset if user missed days
  Future<void> validateStreak() async {
    try {
      // First, check if streak should be reset (no activity for >1 day)
      // This is done automatically in getStreak(), but we also update based on today's activity
      final todaysWords = await _wordRepository.getTodaysWords();
      final hasActivityToday = todaysWords.isNotEmpty;

      // Update streak (will reset if broken, increment if consecutive)
      await _streakRepository.updateStreak(hasActivityToday: hasActivityToday);

      // Reload to get validated streak
      await loadStreak();
    } catch (e) {
      debugPrint('Failed to validate streak: $e');
      _error = 'Failed to validate streak';
      _safeNotify();
    }
  }

  /// Reset streak to zero
  Future<void> resetStreak() async {
    try {
      await _streakRepository.resetStreak();
      await loadStreak();
    } catch (e) {
      debugPrint('Failed to reset streak: $e');
      _error = 'Failed to reset streak';
      _safeNotify();
    }
  }

  /// Check if user should be notified about streak risk
  bool shouldNotifyUser() {
    return _isStreakAtRisk && _streak.currentStreak > 0;
  }

  /// Get streak display text
  String getStreakDisplayText() {
    if (_streak.currentStreak == 0) {
      return 'Start your streak today!';
    } else if (_streak.currentStreak == 1) {
      return '1-day streak 🔥';
    } else {
      return '${_streak.currentStreak}-day streak 🔥';
    }
  }

  /// Get streak progress (for progress bar, 0.0 to 1.0)
  double getStreakProgress() {
    // Show progress towards next milestone (7 days)
    return (_streak.currentStreak % 7) / 7.0;
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
