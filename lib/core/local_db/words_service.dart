import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class WordsService {
  static final WordsService _instance = WordsService._internal();
  factory WordsService() => _instance;
  WordsService._internal();

  late Box _wordsBox;

  Future<void> init() async {
    _wordsBox = await Hive.openBox('words');
  }

  Future<void> addWord(Map<String, dynamic> wordData) async {
    final now = DateTime.now();
    wordData['dateAdded'] = now.toIso8601String();
    await _wordsBox.add(wordData);
  }

  Future<void> updateWord(int index, Map<String, dynamic> wordData) async {
    if (index < 0 || index >= _wordsBox.length) return;
    // Keep the original dateAdded if it exists
    wordData['dateAdded'] =
        wordData['dateAdded'] ?? DateTime.now().toIso8601String();
    await _wordsBox.putAt(index, wordData);
  }

  Future<void> deleteWord(int index) async {
    if (index < 0 || index >= _wordsBox.length) return;
    await _wordsBox.deleteAt(index);
  }

  List<Map<String, dynamic>> getAllWords() {
    return _wordsBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
        .reversed
        .toList();
  }

  List<Map<String, dynamic>> getWordsByDate({DateTime? date}) {
    date ??= DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final targetDateStr = formatter.format(date);

    return _wordsBox.values.map((e) => Map<String, dynamic>.from(e)).where((
      word,
    ) {
      final dateStr = word['dateAdded'];
      if (dateStr == null) return false;
      return formatter.format(DateTime.parse(dateStr)) == targetDateStr;
    }).toList();
  }

  List<Map<String, dynamic>> getTodaysWords() =>
      getWordsByDate(date: DateTime.now());

  List<String> getTodaysWordTexts() {
    return getTodaysWords()
        .map((w) => w['word']?.toString() ?? '')
        .where((w) => w.isNotEmpty)
        .toList();
  }

  int getWordsCount() => _wordsBox.length;

  Map<String, dynamic>? getWord(int index) {
    if (index < 0 || index >= _wordsBox.length) return null;
    return Map<String, dynamic>.from(_wordsBox.getAt(index)!);
  }
}
