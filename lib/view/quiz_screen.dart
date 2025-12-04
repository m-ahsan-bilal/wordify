import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/utils/app_colors.dart';
import 'widgets/ad_banner_widget.dart';
import '../l10n/app_localizations.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Box wordsBox;
  List<Map> questions = [];
  int currentQuestion = 0;
  int score = 0;
  bool answered = false;
  bool correct = false;
  Timer? timer;
  int timeLeft = 15; // Optional timer per question
  String? _selectedOption; // Track selected option for answer feedback

  @override
  void initState() {
    super.initState();
    wordsBox = Hive.box('words');
    generateQuiz();
    startTimer();
  }

  void startTimer() {
    timeLeft = 15;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft == 0) {
        t.cancel();
        nextQuestion();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void generateQuiz() {
    try {
      final allWords = wordsBox.values.toList().cast<Map>();
      // Filter out words without meaning
      final validWords = allWords.where((word) {
        final meaning = word['meaning']?.toString() ?? '';
        return meaning.trim().isNotEmpty;
      }).toList();
      
      if (validWords.isEmpty) {
        questions = [];
        return;
      }
      
      validWords.shuffle();
      questions = validWords.take(min(10, validWords.length)).toList();
    } catch (e) {
      debugPrint('Error generating quiz: $e');
      questions = [];
    }
  }

  void checkAnswer(String answer) {
    if (answered) return;

    final question = questions[currentQuestion];
    final correctAnswer = question['meaning']?.toString() ?? '';
    final isCorrect = answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    
    setState(() {
      answered = true;
      correct = isCorrect;
      _selectedOption = answer;
      if (correct) score++;
    });

    // short delay before moving to next question
    Future.delayed(const Duration(seconds: 1), nextQuestion);
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        answered = false;
        correct = false;
        _selectedOption = null; // Reset selected option
      });
      startTimer();
    } else {
      timer?.cancel();
      showResults();
    }
  }

  void showResults() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: null,
        titlePadding: EdgeInsets.zero,
        content: Text(
          '${AppLocalizations.of(context)!.youScored} $score ${AppLocalizations.of(context)!.outOf} ${questions.length}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.done),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.noWordsAvailableForQuiz),
        ),
      );
    }

    final q = questions[currentQuestion];
    final wordText = q['word']?.toString() ?? '';
    final meaning = q['meaning']?.toString() ?? '';
    final options = _generateOptions(meaning);

    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeColors.getBackgroundColor(context),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ThemeColors.getTextColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: timeLeft / 15,
                    color: Colors.indigo,
                    strokeWidth: 4,
                  ),
                ),
                Text(
                  '$timeLeft ${AppLocalizations.of(context)!.seconds}',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.whatIsTheMeaningOf(wordText),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ...options.map(
                        (opt) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: answered
                                  ? (opt == meaning
                                        ? Colors.green
                                        : (opt == _selectedOption
                                              ? Colors.red
                                              : null))
                                  : null,
                            ),
                            onPressed: () {
                              setState(() => _selectedOption = opt);
                              checkAnswer(opt);
                            },
                            child: Text(
                              opt,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Ad Banner at bottom
          const AdBannerWidget(margin: EdgeInsets.symmetric(vertical: 8)),
        ],
      ),
    );
  }

  List<String> _generateOptions(String correct) {
    final correctStr = correct.trim().isNotEmpty
        ? correct
        : AppLocalizations.of(context)!.noMeaningAvailable;
    final options = <String>[correctStr];

    try {
      final allWords = wordsBox.values.toList().cast<Map>();
      final validMeanings = allWords
          .map((w) => w['meaning']?.toString() ?? '')
          .where((m) => m.trim().isNotEmpty && m != correct)
          .toList();

      while (options.length < 4 && validMeanings.isNotEmpty) {
        final randomMeaning = validMeanings[Random().nextInt(validMeanings.length)];
        if (!options.contains(randomMeaning)) {
          options.add(randomMeaning);
        }
        // Prevent infinite loop if we run out of unique meanings
        if (options.length >= validMeanings.length + 1) break;
      }

      options.shuffle();
      return options;
    } catch (e) {
      debugPrint('Error generating options: $e');
      // Return at least the correct answer
      return [correctStr];
    }
  }
}
