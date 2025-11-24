import '../model/quiz_model.dart';
import '../model/word_model.dart';

/// Abstract repository interface for Quiz operations
abstract class QuizRepository {
  /// Generate a quiz question for a word
  Future<QuizQuestion> generateQuestion(
    Word word,
    QuizType type,
    List<Word> allWords,
  );

  /// Record a quiz result
  Future<void> recordQuizResult(QuizResult result);

  /// Get quiz history for a word
  Future<WordQuizHistory?> getQuizHistory(String word);

  /// Update quiz history for a word
  Future<void> updateQuizHistory(WordQuizHistory history);

  /// Get all quiz histories
  Future<List<WordQuizHistory>> getAllQuizHistories();

  /// Get words that should be quizzed (based on history)
  Future<List<Word>> getWordsToQuiz(List<Word> allWords);
}
