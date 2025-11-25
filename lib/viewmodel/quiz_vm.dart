import 'package:flutter/foundation.dart';
import '../core/model/quiz_model.dart';
import '../core/model/word_model.dart';
import '../core/repositories/quiz_repository.dart';
import '../core/repositories/xp_repository.dart';

/// ViewModel for Quiz management
class QuizViewModel extends ChangeNotifier {
  final QuizRepository _quizRepository;
  final XPRepository _xpRepository;

  QuizViewModel({
    required QuizRepository quizRepository,
    required XPRepository xpRepository,
  })  : _quizRepository = quizRepository,
        _xpRepository = xpRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  QuizQuestion? _currentQuestion;
  QuizQuestion? get currentQuestion => _currentQuestion;

  /// Generate a quiz question
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

  /// Submit an answer and award XP if correct
  Future<({bool isCorrect, int xpEarned, bool leveledUp})> submitAnswer(
    String selectedAnswer,
  ) async {
    if (_currentQuestion == null) {
      return (isCorrect: false, xpEarned: 0, leveledUp: false);
    }

    final isCorrect = _currentQuestion!.isCorrect(selectedAnswer);
    int xpEarned = 0;
    bool leveledUp = false;

    // Award XP only for correct answers
    if (isCorrect) {
      // Base XP for correct answer
      xpEarned = 5;

      // Bonus XP based on quiz type difficulty
      switch (_currentQuestion!.type) {
        case QuizType.meaning:
          xpEarned += 2; // Meaning is easier
          break;
        case QuizType.synonym:
          xpEarned += 3; // Synonym is medium difficulty
          break;
        case QuizType.antonym:
          xpEarned += 4; // Antonym is harder
          break;
      }

      // Award XP
      final result = await _xpRepository.addXP(xpEarned);
      leveledUp = result.leveledUp;
    }

    // Record quiz result
    final quizResult = QuizResult(
      isCorrect: isCorrect,
      selectedAnswer: selectedAnswer,
      correctAnswer: _currentQuestion!.correctAnswer,
      xpEarned: xpEarned,
    );

    await _quizRepository.recordQuizResult(quizResult);

    // Update quiz history
    final history = await _quizRepository.getQuizHistory(_currentQuestion!.word);
    final updatedHistory = (history ?? WordQuizHistory(word: _currentQuestion!.word))
        .recordQuiz(_currentQuestion!.type, isCorrect);
    await _quizRepository.updateQuizHistory(updatedHistory);

    // Clear current question
    _currentQuestion = null;
    notifyListeners();

    return (isCorrect: isCorrect, xpEarned: xpEarned, leveledUp: leveledUp);
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

