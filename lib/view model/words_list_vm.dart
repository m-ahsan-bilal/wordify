import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:word_master/core/local_db/words_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/widgets.dart';

class WordsListViewModel extends ChangeNotifier {
  final _service = WordsService();

  List<Map<String, dynamic>> todaysWords = [];
  List<Map<String, dynamic>> yesterdaysWords = [];
  Map<String, List<Map<String, dynamic>>> olderWords = {};

  Future<void> loadWords() async {
    // Ensure the Hive box is open
    if (!Hive.isBoxOpen('words')) {
      await Hive.openBox('words');
    }
    final box = Hive.box('words');
    final formatter = DateFormat('yyyy-MM-dd');

    // Helper to attach Hive index to each word
    List<Map<String, dynamic>> attachIndex(List<Map<String, dynamic>>? words) {
      if (words == null || words.isEmpty) return [];
      return words.asMap().entries.map((entry) {
        final word = entry.value;
        if (word.isEmpty) return {"index": 0};
        final index = box.values.toList().indexWhere((w) => mapEquals(w, word));
        return {"index": index >= 0 ? index : 0, ...word};
      }).toList();
    }

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    // Get today's and yesterday's words safely
    todaysWords = attachIndex(_service.getWordsByDate(date: today));
    yesterdaysWords = attachIndex(_service.getWordsByDate(date: yesterday));

    // Clear and populate older words
    olderWords.clear();
    final allWords = _service.getAllWords();

    for (var i = 0; i < allWords.length; i++) {
      final word = allWords[i];
      if (word.isEmpty) continue;

      final dateStrRaw = word['dateAdded']?.toString();
      if (dateStrRaw == null) continue;

      DateTime dateAdded;
      try {
        dateAdded = DateTime.parse(dateStrRaw);
      } catch (_) {
        continue; // skip invalid date
      }

      final dateStr = formatter.format(dateAdded);

      // Skip today's and yesterday's words
      if (dateStr == formatter.format(today) ||
          dateStr == formatter.format(yesterday)) {
        continue;
      }

      olderWords.putIfAbsent(dateStr, () => []);
      olderWords[dateStr]!.add({"index": i, ...word});
    }

    // Notify listeners safely after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }
}
