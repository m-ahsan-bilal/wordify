import '../model/word_model.dart';

/// Abstract repository interface for Word operations
/// This defines the contract that repository implementations must follow
/// Allows easy switching between local (Hive) and remote (Firestore) data sources
abstract class WordRepository {
  /// Add a new word to the repository
  Future<void> addWord(Word word);

  /// Update an existing word at the given index
  Future<void> updateWord(int index, Word word);

  /// Delete a word at the given index
  Future<void> deleteWord(int index);

  /// Get all words (reversed chronologically)
  Future<List<Map<String, dynamic>>> getAllWords();

  /// Get words for a specific date
  Future<List<Map<String, dynamic>>> getWordsByDate({DateTime? date});

  /// Get today's words
  Future<List<Map<String, dynamic>>> getTodaysWords();

  /// Get today's words as text strings
  Future<List<String>> getTodaysWordTexts();

  /// Get total count of words
  Future<int> getWordsCount();

  /// Get a single word by index
  Future<Map<String, dynamic>?> getWord(int index);
}
