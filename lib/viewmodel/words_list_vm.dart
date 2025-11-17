import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/widgets.dart';
import '../core/repositories/word_repository.dart';

/// ViewModel for Words List screen
/// Handles loading, grouping, and displaying words by date
class WordsListViewModel extends ChangeNotifier {
  final WordRepository _wordRepository;

  WordsListViewModel({required WordRepository wordRepository})
    : _wordRepository = wordRepository;

  List<Map<String, dynamic>> todaysWords = [];
  List<Map<String, dynamic>> yesterdaysWords = [];
  Map<String, List<Map<String, dynamic>>> olderWords = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Load all words grouped by date
  Future<void> loadWords() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotify();

      // Ensure the Hive box is open
      if (!Hive.isBoxOpen('words')) {
        await Hive.openBox('words');
      }
      final box = Hive.box('words');
      final formatter = DateFormat('yyyy-MM-dd');

      // Helper to attach Hive index to each word
      List<Map<String, dynamic>> attachIndex(
        List<Map<String, dynamic>>? words,
      ) {
        if (words == null || words.isEmpty) return [];
        return words.asMap().entries.map((entry) {
          final word = entry.value;
          if (word.isEmpty) return {"index": 0};
          final index = box.values.toList().indexWhere(
            (w) => mapEquals(w, word),
          );
          return {"index": index >= 0 ? index : 0, ...word};
        }).toList();
      }

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // Get today's and yesterday's words safely
      todaysWords = attachIndex(
        await _wordRepository.getWordsByDate(date: today),
      );
      yesterdaysWords = attachIndex(
        await _wordRepository.getWordsByDate(date: yesterday),
      );

      // Clear and populate older words
      olderWords.clear();
      final allWords = await _wordRepository.getAllWords();

      for (var i = 0; i < allWords.length; i++) {
        final word = allWords[i];
        if (word.isEmpty) continue;

        final dateStrRaw = word['dateAdded']?.toString();
        if (dateStrRaw == null) continue;

        DateTime dateAdded;
        try {
          dateAdded = DateTime.parse(dateStrRaw);
        } catch (_) {
          continue; // skip invalid date
        }

        final dateStr = formatter.format(dateAdded);

        // Skip today's and yesterday's words
        if (dateStr == formatter.format(today) ||
            dateStr == formatter.format(yesterday)) {
          continue;
        }

        olderWords.putIfAbsent(dateStr, () => []);
        olderWords[dateStr]!.add({"index": i, ...word});
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
      await loadWords(); // Reload after deletion
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
