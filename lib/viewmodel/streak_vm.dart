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
  Future<void> loadStreak() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotify();

      _streak = await _streakRepository.getStreak();
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
  Future<void> updateStreak() async {
    try {
      // Check if user has added words today
      final todaysWords = await _wordRepository.getTodaysWords();
      final hasActivityToday = todaysWords.isNotEmpty;

      await _streakRepository.updateStreak(hasActivityToday: hasActivityToday);

      // Reload streak data
      await loadStreak();
    } catch (e) {
      debugPrint('Failed to update streak: $e');
      _error = 'Failed to update streak';
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
