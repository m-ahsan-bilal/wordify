import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/widgets.dart';
import '../core/repositories/word_repository.dart';
import '../core/model/word_model.dart';

/// ViewModel for Words List screen
/// Handles loading and displaying words sorted by date
class WordsListViewModel extends ChangeNotifier {
  final WordRepository _wordRepository;

  WordsListViewModel({required WordRepository wordRepository})
    : _wordRepository = wordRepository;

  // Store all words with indices attached
  List<Map<String, dynamic>> _allWords = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Load all words with indices attached
  Future<void> loadWords() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotify();

      // Ensure the Hive box is open
      if (!Hive.isBoxOpen('words')) {
        await Hive.openBox('words');
      }

      // Get all words and attach Hive index to each
      final allWords = await _wordRepository.getAllWords();
      _allWords = [];

      for (var i = 0; i < allWords.length; i++) {
        final word = allWords[i];
        if (word.isEmpty) continue;
        _allWords.add({"index": i, ...word});
      }

      _isLoading = false;
      _safeNotify();
    } catch (e) {
      debugPrint('Error loading words: $e');
      _error = 'Failed to load words';
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Delete a word and reload the list
  Future<void> deleteWord(int index) async {
    try {
      await _wordRepository.deleteWord(index);
      await loadWords();
    } catch (e) {
      debugPrint('Error deleting word: $e');
      _error = 'Failed to delete word';
      _safeNotify();
    }
  }

  /// Get total words count
  Future<int> getWordsCount() async {
    try {
      return await _wordRepository.getWordsCount();
    } catch (e) {
      debugPrint('Error getting words count: $e');
      return 0;
    }
  }

  /// Check if a word is new
  bool isWordNew(Map<String, dynamic> wordMap) {
    final word = Word.fromMap(wordMap);
    return word.isNew;
  }

  /// Check if a word is mastered
  bool isWordMastered(Map<String, dynamic> wordMap) {
    final word = Word.fromMap(wordMap);
    return word.isMastered;
  }

  /// Get all words sorted by time (most recent first)
  List<Map<String, dynamic>> getAllWordsSortedByTime() {
    // Create a copy to avoid modifying the original list
    final allWords = List<Map<String, dynamic>>.from(_allWords);

    // Sort by dateAdded (most recent first)
    allWords.sort((a, b) {
      final dateA = a['dateAdded']?.toString();
      final dateB = b['dateAdded']?.toString();

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      try {
        final parsedDateA = DateTime.parse(dateA);
        final parsedDateB = DateTime.parse(dateB);
        // Sort in descending order (most recent first)
        return parsedDateB.compareTo(parsedDateA);
      } catch (e) {
        return 0;
      }
    });

    return allWords;
  }

  /// Get today's words
  List<Map<String, dynamic>> getTodaysWords() {
    final today = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final todayStr = formatter.format(today);

    return _allWords.where((word) {
      final dateStr = word['dateAdded']?.toString();
      if (dateStr == null) return false;
      try {
        final date = DateTime.parse(dateStr);
        return formatter.format(date) == todayStr;
      } catch (e) {
        return false;
      }
    }).toList();
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
