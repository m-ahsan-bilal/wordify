import 'dart:math';
import '../../core/model/quiz_model.dart';
import '../../core/model/word_model.dart';
import '../../core/repositories/quiz_repository.dart';
import '../datasources/local/quiz_local_datasource.dart';

/// Implementation of QuizRepository
class QuizRepositoryImpl implements QuizRepository {
  final QuizLocalDatasource _localDatasource;
  final Random _random = Random();

  QuizRepositoryImpl({QuizLocalDatasource? localDatasource})
      : _localDatasource = localDatasource ?? QuizLocalDatasource();

  // Static word bank for fallback options when database has few words
  static const List<String> _staticWordBank = [
    // Common words for meaning quiz options
    'a feeling of great happiness',
    'to make something better',
    'a person who is admired',
    'to understand something',
    'very important',
    'to continue doing something',
    'a difficult situation',
    'to show or express',
    'happening quickly',
    'to make a decision',
    'full of energy',
    'to remember something',
    'to help someone',
    'a strong feeling',
    'to create something new',
    'very large in size',
    'to discover something',
    'a person who creates art',
    'to explain something clearly',
    'to achieve a goal',
    'full of life',
    'to protect something',
    'a difficult problem',
    'to improve something',
    'a person who leads',
    'to understand deeply',
    'very beautiful',
    'to make progress',
    'a person who teaches',
    'to solve a problem',
  ];

  // Static word list for synonym/antonym quiz options
  static const List<String> _staticWordList = [
    'happy', 'sad', 'big', 'small', 'fast', 'slow', 'good', 'bad',
    'beautiful', 'ugly', 'smart', 'dumb', 'strong', 'weak', 'rich', 'poor',
    'hot', 'cold', 'new', 'old', 'young', 'ancient', 'bright', 'dark',
    'loud', 'quiet', 'brave', 'afraid', 'kind', 'cruel', 'honest', 'dishonest',
    'calm', 'anxious', 'confident', 'shy', 'generous', 'selfish', 'patient', 'impatient',
    'active', 'lazy', 'creative', 'boring', 'friendly', 'hostile', 'polite', 'rude',
    'clean', 'dirty', 'fresh', 'stale', 'smooth', 'rough', 'soft', 'hard',
    'light', 'heavy', 'thick', 'thin', 'wide', 'narrow', 'high', 'low',
    'deep', 'shallow', 'full', 'empty', 'open', 'closed', 'free', 'trapped',
  ];

  @override
  Future<QuizQuestion> generateQuestion(
    Word word,
    QuizType type,
    List<Word> allWords,
  ) async {
    String question;
    String correctAnswer;
    List<String> options;

    switch (type) {
      case QuizType.meaning:
        question = "What is the meaning of '${word.word}'?";
        correctAnswer = word.meaning;
        options = _generateMeaningOptions(word, allWords);
        break;
      case QuizType.synonym:
        if (word.synonyms.isEmpty) {
          throw Exception('Word has no synonyms');
        }
        final synonymsList = word.synonyms
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        correctAnswer = synonymsList[_random.nextInt(synonymsList.length)];
        question = "Which word is a synonym of '${word.word}'?";
        options = _generateSynonymOptions(word, correctAnswer, allWords);
        break;
      case QuizType.antonym:
        if (word.antonyms.isEmpty) {
          throw Exception('Word has no antonyms');
        }
        final antonymsList = word.antonyms
            .split(',')
            .map((a) => a.trim())
            .where((a) => a.isNotEmpty)
            .toList();
        correctAnswer = antonymsList[_random.nextInt(antonymsList.length)];
        question = "Which word is an antonym of '${word.word}'?";
        options = _generateAntonymOptions(word, correctAnswer, allWords);
        break;
    }

    // Shuffle options
    options.shuffle(_random);

    return QuizQuestion(
      word: word.word,
      question: question,
      correctAnswer: correctAnswer,
      options: options,
      type: type,
    );
  }

  /// Generate options for meaning quiz
  List<String> _generateMeaningOptions(Word word, List<Word> allWords) {
    final options = <String>[word.meaning];
    final usedMeanings = <String>{word.meaning};
    final usedWords = <String>{word.word};

    // Get 3 random meanings from other words in database
    int attempts = 0;
    while (options.length < 4 && allWords.length > 1 && attempts < 50) {
      attempts++;
      final randomWord = allWords[_random.nextInt(allWords.length)];
      if (randomWord.meaning.isNotEmpty &&
          !usedWords.contains(randomWord.word) &&
          !usedMeanings.contains(randomWord.meaning) &&
          randomWord.meaning != word.meaning) {
        options.add(randomWord.meaning);
        usedMeanings.add(randomWord.meaning);
        usedWords.add(randomWord.word);
      }
    }

    // Fill remaining slots with static word bank if needed
    final availableStatic = List<String>.from(_staticWordBank);
    availableStatic.shuffle(_random);
    
    while (options.length < 4 && availableStatic.isNotEmpty) {
      final staticOption = availableStatic.removeAt(0);
      if (!usedMeanings.contains(staticOption)) {
        options.add(staticOption);
        usedMeanings.add(staticOption);
      }
    }

    // Final fallback if still not enough
    while (options.length < 4) {
      options.add('A definition');
    }

    return options.take(4).toList();
  }

  /// Generate options for synonym quiz
  List<String> _generateSynonymOptions(
    Word word,
    String correctSynonym,
    List<Word> allWords,
  ) {
    final options = <String>[correctSynonym];
    final usedWords = <String>{word.word, correctSynonym};

    // Get random words/synonyms from database as distractors
    int attempts = 0;
    while (options.length < 4 && allWords.length > 1 && attempts < 50) {
      attempts++;
      final randomWord = allWords[_random.nextInt(allWords.length)];
      if (!usedWords.contains(randomWord.word)) {
        // Use word itself or a synonym from another word
        if (randomWord.synonyms.isNotEmpty) {
          final synonyms = randomWord.synonyms
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty && !usedWords.contains(s))
              .toList();
          if (synonyms.isNotEmpty) {
            final synonym = synonyms[_random.nextInt(synonyms.length)];
            options.add(synonym);
            usedWords.add(synonym);
          } else {
            options.add(randomWord.word);
            usedWords.add(randomWord.word);
          }
        } else {
          options.add(randomWord.word);
          usedWords.add(randomWord.word);
        }
      }
    }

    // Fill remaining slots with static word bank if needed
    final availableStatic = List<String>.from(_staticWordList);
    availableStatic.shuffle(_random);
    
    while (options.length < 4 && availableStatic.isNotEmpty) {
      final staticWord = availableStatic.removeAt(0);
      if (!usedWords.contains(staticWord) && staticWord != correctSynonym) {
        options.add(staticWord);
        usedWords.add(staticWord);
      }
    }

    // Final fallback if still not enough
    while (options.length < 4) {
      options.add('word');
    }

    return options.take(4).toList();
  }

  /// Generate options for antonym quiz
  List<String> _generateAntonymOptions(
    Word word,
    String correctAntonym,
    List<Word> allWords,
  ) {
    final options = <String>[correctAntonym];
    final usedWords = <String>{word.word, correctAntonym};

    // Get random words/antonyms from database as distractors
    int attempts = 0;
    while (options.length < 4 && allWords.length > 1 && attempts < 50) {
      attempts++;
      final randomWord = allWords[_random.nextInt(allWords.length)];
      if (!usedWords.contains(randomWord.word)) {
        // Use word itself or an antonym from another word
        if (randomWord.antonyms.isNotEmpty) {
          final antonyms = randomWord.antonyms
              .split(',')
              .map((a) => a.trim())
              .where((a) => a.isNotEmpty && !usedWords.contains(a))
              .toList();
          if (antonyms.isNotEmpty) {
            final antonym = antonyms[_random.nextInt(antonyms.length)];
            options.add(antonym);
            usedWords.add(antonym);
          } else {
            options.add(randomWord.word);
            usedWords.add(randomWord.word);
          }
        } else {
          options.add(randomWord.word);
          usedWords.add(randomWord.word);
        }
      }
    }

    // Fill remaining slots with static word bank if needed
    final availableStatic = List<String>.from(_staticWordList);
    availableStatic.shuffle(_random);
    
    while (options.length < 4 && availableStatic.isNotEmpty) {
      final staticWord = availableStatic.removeAt(0);
      if (!usedWords.contains(staticWord) && staticWord != correctAntonym) {
        options.add(staticWord);
        usedWords.add(staticWord);
      }
    }

    // Final fallback if still not enough
    while (options.length < 4) {
      options.add('word');
    }

    return options.take(4).toList();
  }

  @override
  Future<void> recordQuizResult(QuizResult result) async {
    await _localDatasource.saveQuizResult(result);
  }

  @override
  Future<WordQuizHistory?> getQuizHistory(String word) async {
    return await _localDatasource.getQuizHistory(word);
  }

  @override
  Future<void> updateQuizHistory(WordQuizHistory history) async {
    await _localDatasource.saveQuizHistory(history);
  }

  @override
  Future<List<WordQuizHistory>> getAllQuizHistories() async {
    return await _localDatasource.getAllQuizHistories();
  }

  @override
  Future<List<Word>> getWordsToQuiz(List<Word> allWords) async {
    if (allWords.isEmpty) return [];

    final histories = await getAllQuizHistories();
    final historyMap = {
      for (var h in histories) h.word: h,
    };

    // Filter words that should be quizzed
    final wordsToQuiz = <Word>[];
    for (final word in allWords) {
      final history = historyMap[word.word];
      if (history == null || history.shouldQuizAgain()) {
        wordsToQuiz.add(word);
      }
    }

    // If all words have been quizzed recently, return all words
    if (wordsToQuiz.isEmpty) {
      return allWords;
    }

    // Shuffle and return
    wordsToQuiz.shuffle(_random);
    return wordsToQuiz;
  }
}

