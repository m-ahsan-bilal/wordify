/// Quiz Model - Represents a quiz question with options
class QuizQuestion {
  final String word;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final QuizType type;
  final DateTime createdAt;

  QuizQuestion({
    required this.word,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create QuizQuestion from Map (for storage)
  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
    word: map['word'] ?? '',
    question: map['question'] ?? '',
    correctAnswer: map['correctAnswer'] ?? '',
    options: List<String>.from(map['options'] ?? []),
    type: QuizType.values.firstWhere(
      (e) => e.toString() == map['type'],
      orElse: () => QuizType.meaning,
    ),
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : DateTime.now(),
  );

  /// Convert QuizQuestion to Map (for storage)
  Map<String, dynamic> toMap() => {
    'word': word,
    'question': question,
    'correctAnswer': correctAnswer,
    'options': options,
    'type': type.toString(),
    'createdAt': createdAt.toIso8601String(),
  };

  /// Check if the selected answer is correct
  bool isCorrect(String selectedAnswer) {
    return selectedAnswer.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase();
  }
}

/// Quiz Type Enum
enum QuizType {
  meaning, // Swipe Up
  synonym, // Swipe Left
  antonym, // Swipe Right
}

/// Quiz Result Model
class QuizResult {
  final bool isCorrect;
  final String selectedAnswer;
  final String correctAnswer;
  final int xpEarned;
  final DateTime answeredAt;

  QuizResult({
    required this.isCorrect,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.xpEarned,
    DateTime? answeredAt,
  }) : answeredAt = answeredAt ?? DateTime.now();

  /// Create QuizResult from Map
  factory QuizResult.fromMap(Map<String, dynamic> map) => QuizResult(
    isCorrect: map['isCorrect'] ?? false,
    selectedAnswer: map['selectedAnswer'] ?? '',
    correctAnswer: map['correctAnswer'] ?? '',
    xpEarned: map['xpEarned'] ?? 0,
    answeredAt: map['answeredAt'] != null
        ? DateTime.parse(map['answeredAt'])
        : DateTime.now(),
  );

  /// Convert QuizResult to Map
  Map<String, dynamic> toMap() => {
    'isCorrect': isCorrect,
    'selectedAnswer': selectedAnswer,
    'correctAnswer': correctAnswer,
    'xpEarned': xpEarned,
    'answeredAt': answeredAt.toIso8601String(),
  };
}

/// Word Quiz History - Tracks which words have been quizzed
class WordQuizHistory {
  final String word;
  final List<DateTime> quizDates;
  final Map<QuizType, int> correctCounts;
  final Map<QuizType, int> totalCounts;
  final DateTime lastQuizzed;

  WordQuizHistory({
    required this.word,
    List<DateTime>? quizDates,
    Map<QuizType, int>? correctCounts,
    Map<QuizType, int>? totalCounts,
    DateTime? lastQuizzed,
  }) : quizDates = quizDates ?? [],
       correctCounts = correctCounts ?? {},
       totalCounts = totalCounts ?? {},
       lastQuizzed = lastQuizzed ?? DateTime.now();

  /// Create WordQuizHistory from Map
  factory WordQuizHistory.fromMap(Map<String, dynamic> map) {
    final correctCountsMap = <QuizType, int>{};
    final totalCountsMap = <QuizType, int>{};

    if (map['correctCounts'] != null) {
      (map['correctCounts'] as Map).forEach((key, value) {
        final type = QuizType.values.firstWhere(
          (e) => e.toString() == key,
          orElse: () => QuizType.meaning,
        );
        correctCountsMap[type] = value as int;
      });
    }

    if (map['totalCounts'] != null) {
      (map['totalCounts'] as Map).forEach((key, value) {
        final type = QuizType.values.firstWhere(
          (e) => e.toString() == key,
          orElse: () => QuizType.meaning,
        );
        totalCountsMap[type] = value as int;
      });
    }

    return WordQuizHistory(
      word: map['word'] ?? '',
      quizDates:
          (map['quizDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      correctCounts: correctCountsMap,
      totalCounts: totalCountsMap,
      lastQuizzed: map['lastQuizzed'] != null
          ? DateTime.parse(map['lastQuizzed'])
          : DateTime.now(),
    );
  }

  /// Convert WordQuizHistory to Map
  Map<String, dynamic> toMap() {
    final correctCountsMap = <String, int>{};
    final totalCountsMap = <String, int>{};

    correctCounts.forEach((key, value) {
      correctCountsMap[key.toString()] = value;
    });

    totalCounts.forEach((key, value) {
      totalCountsMap[key.toString()] = value;
    });

    return {
      'word': word,
      'quizDates': quizDates.map((e) => e.toIso8601String()).toList(),
      'correctCounts': correctCountsMap,
      'totalCounts': totalCountsMap,
      'lastQuizzed': lastQuizzed.toIso8601String(),
    };
  }

  /// Record a quiz attempt
  WordQuizHistory recordQuiz(QuizType type, bool isCorrect) {
    final newQuizDates = List<DateTime>.from(quizDates)..add(DateTime.now());
    final newCorrectCounts = Map<QuizType, int>.from(correctCounts);
    final newTotalCounts = Map<QuizType, int>.from(totalCounts);

    newTotalCounts[type] = (newTotalCounts[type] ?? 0) + 1;
    if (isCorrect) {
      newCorrectCounts[type] = (newCorrectCounts[type] ?? 0) + 1;
    }

    return WordQuizHistory(
      word: word,
      quizDates: newQuizDates,
      correctCounts: newCorrectCounts,
      totalCounts: newTotalCounts,
      lastQuizzed: DateTime.now(),
    );
  }

  /// Get accuracy for a specific quiz type
  double getAccuracy(QuizType type) {
    final total = totalCounts[type] ?? 0;
    if (total == 0) return 0.0;
    final correct = correctCounts[type] ?? 0;
    return correct / total;
  }

  /// Check if word should be quizzed again (after a cycle of other words)
  bool shouldQuizAgain({int minWordsBetween = 5}) {
    if (quizDates.isEmpty) return true;
    final daysSinceLastQuiz = DateTime.now().difference(lastQuizzed).inDays;
    // Allow quiz again after 1 day or if enough words have been quizzed
    return daysSinceLastQuiz >= 1;
  }
}
