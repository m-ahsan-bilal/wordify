import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/model/backup_model.dart';
import '../../core/model/streak_model.dart';
import '../../core/model/xp_model.dart';
import '../../core/model/quiz_model.dart';
import 'local/words_local_datasource.dart';
import 'local/streak_local_datasource.dart';
import 'local/xp_local_datasource.dart';
import 'local/quiz_local_datasource.dart';

/// Handles export and import of backup data
/// Follows the app's datasource architecture pattern
class BackupDatasource {
  final WordsLocalDatasource _wordsDatasource = WordsLocalDatasource();
  final StreakLocalDatasource _streakDatasource = StreakLocalDatasource();
  final XPLocalDatasource _xpDatasource = XPLocalDatasource();
  final QuizLocalDatasource _quizDatasource = QuizLocalDatasource();

  /// Export all data to BackupData
  Future<BackupData> exportData() async {
    // Export words
    final wordsData = await _wordsDatasource.getAllWords();

    // Export streak
    final streak = await _streakDatasource.getStreak();
    final streakData = {
      'currentStreak': streak.currentStreak,
      'lastActivityDate': streak.lastActivityDate?.toIso8601String(),
    };

    // Export XP
    final xp = await _xpDatasource.getXP();
    final xpData = {
      'totalXP': xp.totalXP,
      'currentLevel': xp.currentLevel,
      'lastUpdated': xp.lastUpdated?.toIso8601String(),
    };

    // Export quiz history
    final quizHistories = await _quizDatasource.getAllQuizHistories();
    final quizHistoryData = quizHistories.map((h) => h.toMap()).toList();

    // Export quiz results
    final quizResults = await _quizDatasource.getAllQuizResults();
    final quizResultsData = quizResults.map((r) => r.toMap()).toList();

    // Get app version
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    return BackupData(
      words: wordsData,
      streak: streakData,
      xp: xpData,
      quizHistory: quizHistoryData,
      quizResults: quizResultsData,
      backupDate: DateTime.now().toIso8601String(),
      appVersion: appVersion,
    );
  }

  /// Import data from BackupData
  Future<void> importData(BackupData backupData) async {
    // Import words
    final wordsBox = await Hive.openBox('words');
    await wordsBox.clear();
    for (final wordData in backupData.words) {
      await wordsBox.add(wordData);
    }

    // Import streak
    if (backupData.streak.isNotEmpty) {
      final streak = Streak(
        currentStreak: backupData.streak['currentStreak'] ?? 0,
        lastActivityDate: backupData.streak['lastActivityDate'] != null
            ? DateTime.parse(backupData.streak['lastActivityDate'])
            : null,
      );
      await _streakDatasource.saveStreak(streak);
    }

    // Import XP
    if (backupData.xp.isNotEmpty) {
      final xp = XP(
        totalXP: backupData.xp['totalXP'] ?? 0,
        currentLevel: backupData.xp['currentLevel'] ?? 1,
        lastUpdated: backupData.xp['lastUpdated'] != null
            ? DateTime.parse(backupData.xp['lastUpdated'])
            : null,
      );
      await _xpDatasource.saveXP(xp);
    }

    // Import quiz history
    final quizHistoryBox = await Hive.openBox('quiz_history');
    await quizHistoryBox.clear();
    for (final historyData in backupData.quizHistory) {
      final history = WordQuizHistory.fromMap(historyData);
      await quizHistoryBox.put(history.word, history.toMap());
    }

    // Import quiz results
    final quizResultsBox = await Hive.openBox('quiz_results');
    await quizResultsBox.clear();
    for (final resultData in backupData.quizResults) {
      final result = QuizResult.fromMap(resultData);
      await quizResultsBox.add(result.toMap());
    }
  }
}

