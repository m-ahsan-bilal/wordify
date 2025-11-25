import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/utils/app_colors.dart';
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
    final allWords = wordsBox.values.toList().cast<Map>();
    allWords.shuffle();
    questions = allWords.take(min(10, allWords.length)).toList();
  }

  void checkAnswer(String answer) {
    if (answered) return;

    final correctAnswer = questions[currentQuestion]['meaning'];
    setState(() {
      answered = true;
      correct =
          answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
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
        title: Text(AppLocalizations.of(context)!.quizCompleted),
        content: Text('${AppLocalizations.of(context)!.youScored} $score ${AppLocalizations.of(context)!.outOf} ${questions.length}'),
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
        body: Center(child: Text(AppLocalizations.of(context)!.noWordsAvailableForQuiz)),
      );
    }

    final q = questions[currentQuestion];
    final options = _generateOptions(q['meaning']);

    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeColors.getBackgroundColor(context),
        title: Text(
          AppLocalizations.of(context)!.quizTitle(currentQuestion + 1, questions.length),
          style: TextStyle(color: ThemeColors.getTextColor(context)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.getTextColor(context)),
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
                Text('$timeLeft ${AppLocalizations.of(context)!.seconds}', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: Center(
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
                  AppLocalizations.of(context)!.whatIsTheMeaningOf(q['word']),
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
                            ? (opt == q['meaning']
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
                      child: Text(opt, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _selectedOption;

  List<String> _generateOptions(dynamic correct) {
    final correctStr = correct?.toString() ?? AppLocalizations.of(context)!.noMeaningAvailable;
    final allWords = wordsBox.values.toList().cast<Map>();
    final options = <String>[correctStr];

    while (options.length < 4 && allWords.isNotEmpty) {
      final randomWord =
          allWords[Random().nextInt(allWords.length)]['meaning']?.toString() ??
          '';
      if (randomWord.isNotEmpty && !options.contains(randomWord)) {
        options.add(randomWord);
      }
    }

    options.shuffle();
    return options;
  }
}
