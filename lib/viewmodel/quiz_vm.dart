import 'package:flutter/foundation.dart';
import '../core/model/quiz_model.dart';
import '../core/model/word_model.dart';
import '../core/repositories/quiz_repository.dart';

// ViewModel for Quiz management
class QuizViewModel extends ChangeNotifier {
  final QuizRepository _quizRepository;

  QuizViewModel({
    required QuizRepository quizRepository,
  }) : _quizRepository = quizRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  QuizQuestion? _currentQuestion;
  QuizQuestion? get currentQuestion => _currentQuestion;

  // Generate a quiz question
  Future<QuizQuestion?> generateQuestion(
    Word word,
    QuizType type,
    List<Word> allWords,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Note: Since meaning, synonyms, and antonyms are now required fields,
      // we don't need to check for empty values here

      _currentQuestion = await _quizRepository.generateQuestion(
        word,
        type,
        allWords,
      );

      _isLoading = false;
      notifyListeners();
      return _currentQuestion;
    } catch (e) {
      debugPrint('Error generating quiz question: $e');
      _error = 'Failed to generate quiz question';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Submit an answer
  Future<bool> submitAnswer(
    String selectedAnswer,
  ) async {
    if (_currentQuestion == null) {
      return false;
    }

    final isCorrect = _currentQuestion!.isCorrect(selectedAnswer);

    // Record quiz result
    final quizResult = QuizResult(
      isCorrect: isCorrect,
      selectedAnswer: selectedAnswer,
      correctAnswer: _currentQuestion!.correctAnswer,
    );

    await _quizRepository.recordQuizResult(quizResult);

    // Update quiz history
    final history = await _quizRepository.getQuizHistory(
      _currentQuestion!.word,
    );
    final updatedHistory =
        (history ?? WordQuizHistory(word: _currentQuestion!.word)).recordQuiz(
          _currentQuestion!.type,
          isCorrect,
        );
    await _quizRepository.updateQuizHistory(updatedHistory);

    // Clear current question
    _currentQuestion = null;
    notifyListeners();

    return isCorrect;
  }

  /// Clear current question
  void clearQuestion() {
    _currentQuestion = null;
    _error = null;
    notifyListeners();
  }

  /// Get quiz history for a word
  Future<WordQuizHistory?> getQuizHistory(String word) async {
    return await _quizRepository.getQuizHistory(word);
  }
}
