import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/model/word_model.dart';

/// Local data source for Word operations using Hive
/// Handles all local database operations for words
class WordsLocalDatasource {
  static final WordsLocalDatasource _instance =
      WordsLocalDatasource._internal();
  factory WordsLocalDatasource() => _instance;
  WordsLocalDatasource._internal();

  late Box _wordsBox;

  /// Initialize Hive box for words
  Future<void> init() async {
    _wordsBox = await Hive.openBox('words');
  }

  /// Add a new word to local storage
  Future<void> addWord(Word word) async {
    await _wordsBox.add(word.toMap());
  }

  /// Update an existing word at the given index
  Future<void> updateWord(int index, Word word) async {
    if (index < 0 || index >= _wordsBox.length) return;
    await _wordsBox.putAt(index, word.toMap());
  }

  /// Delete a word at the given index
  Future<void> deleteWord(int index) async {
    if (index < 0 || index >= _wordsBox.length) return;
    await _wordsBox.deleteAt(index);
  }

  /// Get all words from local storage (reversed chronologically)
  Future<List<Map<String, dynamic>>> getAllWords() async {
    return _wordsBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
        .reversed
        .toList();
  }

  /// Get words for a specific date
  /// Uses timezone-aware date comparison (compares only year, month, day)
  Future<List<Map<String, dynamic>>> getWordsByDate({DateTime? date}) async {
    date ??= DateTime.now();
    // Normalize to local timezone and extract date components only
    final targetDate = DateTime(date.year, date.month, date.day);
    final formatter = DateFormat('yyyy-MM-dd');
    final targetDateStr = formatter.format(targetDate);

    return _wordsBox.values.map((e) => Map<String, dynamic>.from(e)).where((
      word,
    ) {
      final dateStr = word['dateAdded'];
      if (dateStr == null) return false;
      
      // Parse the stored date and normalize to date-only for comparison
      final wordDate = DateTime.parse(dateStr);
      final wordDateOnly = DateTime(wordDate.year, wordDate.month, wordDate.day);
      final wordDateStr = formatter.format(wordDateOnly);
      
      return wordDateStr == targetDateStr;
    }).toList();
  }

  /// Get today's words
  /// Uses current local timezone to determine "today"
  Future<List<Map<String, dynamic>>> getTodaysWords() async {
    // Use DateTime.now() which is already in local timezone
    return getWordsByDate(date: DateTime.now());
  }

  /// Get today's words as text strings only
  Future<List<String>> getTodaysWordTexts() async {
    final todaysWords = await getTodaysWords();
    return todaysWords
        .map((w) => w['word']?.toString() ?? '')
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Get total count of words
  Future<int> getWordsCount() async => _wordsBox.length;

  /// Get a single word by index
  Future<Map<String, dynamic>?> getWord(int index) async {
    if (index < 0 || index >= _wordsBox.length) return null;
    return Map<String, dynamic>.from(_wordsBox.getAt(index)!);
  }
}
