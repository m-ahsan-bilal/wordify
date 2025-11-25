import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/model/quiz_model.dart';

/// Local data source for Quiz operations using Hive
class QuizLocalDatasource {
  static final QuizLocalDatasource _instance = QuizLocalDatasource._internal();
  factory QuizLocalDatasource() => _instance;
  QuizLocalDatasource._internal();

  late Box _quizHistoryBox;
  late Box _quizResultsBox;

  /// Initialize Hive boxes for quiz data
  Future<void> init() async {
    _quizHistoryBox = await Hive.openBox('quiz_history');
    _quizResultsBox = await Hive.openBox('quiz_results');
  }

  /// Save quiz history for a word
  Future<void> saveQuizHistory(WordQuizHistory history) async {
    await _quizHistoryBox.put(history.word, history.toMap());
  }

  /// Get quiz history for a word
  Future<WordQuizHistory?> getQuizHistory(String word) async {
    final data = _quizHistoryBox.get(word);
    if (data == null) return null;
    return WordQuizHistory.fromMap(Map<String, dynamic>.from(data));
  }

  /// Get all quiz histories
  Future<List<WordQuizHistory>> getAllQuizHistories() async {
    return _quizHistoryBox.values
        .map((e) => WordQuizHistory.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Save quiz result
  Future<void> saveQuizResult(QuizResult result) async {
    await _quizResultsBox.add(result.toMap());
  }

  /// Get all quiz results
  Future<List<QuizResult>> getAllQuizResults() async {
    return _quizResultsBox.values
        .map((e) => QuizResult.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Clear all quiz data (for testing/reset)
  Future<void> clearAllData() async {
    await _quizHistoryBox.clear();
    await _quizResultsBox.clear();
  }
}
