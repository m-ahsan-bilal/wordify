import 'package:flutter/widgets.dart';
import '../core/model/word_model.dart';
import '../core/repositories/word_repository.dart';
import '../core/repositories/streak_repository.dart';

/// ViewModel for Add Word screen
/// Handles adding, updating, and deleting words
/// Updates streak after successful word addition
class AddWordViewModel extends ChangeNotifier {
  final WordRepository _wordRepository;
  final StreakRepository _streakRepository;

  AddWordViewModel({
    required WordRepository wordRepository,
    required StreakRepository streakRepository,
  })  : _wordRepository = wordRepository,
        _streakRepository = streakRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Add a new word
  Future<bool> addWord(Word word) async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotify();

      await _wordRepository.addWord(word);

      // Update streak after adding word
      await _streakRepository.updateStreak(hasActivityToday: true);

      _isLoading = false;
      _safeNotify();
      return true;
    } catch (e) {
      debugPrint('Error adding word: $e');
      _error = 'Failed to add word: $e';
      _isLoading = false;
      _safeNotify();
      return false;
    }
  }

  /// Update an existing word
  Future<bool> updateWord(int index, Word word) async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotify();

      await _wordRepository.updateWord(index, word);

      _isLoading = false;
      _safeNotify();
      return true;
    } catch (e) {
      debugPrint('Error updating word: $e');
      _error = 'Failed to update word: $e';
      _isLoading = false;
      _safeNotify();
      return false;
    }
  }

  /// Delete a word
  Future<bool> deleteWord(int index) async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotify();

      await _wordRepository.deleteWord(index);

      _isLoading = false;
      _safeNotify();
      return true;
    } catch (e) {
      debugPrint('Error deleting word: $e');
      _error = 'Failed to delete word: $e';
      _isLoading = false;
      _safeNotify();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    _safeNotify();
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
