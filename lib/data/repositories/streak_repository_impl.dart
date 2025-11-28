import '../../core/model/streak_model.dart';
import '../../core/repositories/streak_repository.dart';
import '../datasources/local/streak_local_datasource.dart';
import '../datasources/remote/streak_remote_datasource.dart';

/// Implementation of StreakRepository
/// Uses local datasource (Hive) as primary, with remote (Firestore) for future sync
class StreakRepositoryImpl implements StreakRepository {
  final StreakLocalDatasource _localDatasource;
  // ignore: unused_field
  final StreakRemoteDatasource _remoteDatasource;

  StreakRepositoryImpl({
    StreakLocalDatasource? localDatasource,
    StreakRemoteDatasource? remoteDatasource,
  }) : _localDatasource = localDatasource ?? StreakLocalDatasource(),
       _remoteDatasource = remoteDatasource ?? StreakRemoteDatasource();

  @override
  Future<Streak> getStreak() async {
    // Primary: Get from local storage
    final streak = await _localDatasource.getStreak();

    // Validate and reset streak if needed (check if streak is broken)
    // This ensures streak is always accurate when loaded
    final validatedStreak = _validateStreak(streak);
    
    // If streak was reset, save it
    if (validatedStreak.currentStreak != streak.currentStreak ||
        validatedStreak.lastActivityDate != streak.lastActivityDate) {
      await saveStreak(validatedStreak);
    }

    // TODO: Later, merge with remote if needed
    // if (shouldSyncWithRemote) {
    //   final remoteStreak = await _remoteDatasource.getStreak();
    //   // Keep the higher streak
    //   if (remoteStreak.currentStreak > streak.currentStreak) {
    //     await saveStreak(remoteStreak);
    //     return remoteStreak;
    //   }
    // }

    return validatedStreak;
  }

  /// Validate streak and reset if broken (no activity for more than 1 day)
  /// IMPORTANT: This only validates based on dates, not current activity
  /// Always call updateStreak() after validation to account for today's activity
  Streak _validateStreak(Streak streak) {
    if (streak.lastActivityDate == null) {
      // No previous activity, ensure streak is 0
      if (streak.currentStreak > 0) {
        return Streak(currentStreak: 0, lastActivityDate: null);
      }
      return streak;
    }

    final today = DateTime.now();
    final lastDate = DateTime(
      streak.lastActivityDate!.year,
      streak.lastActivityDate!.month,
      streak.lastActivityDate!.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysDifference = todayDate.difference(lastDate).inDays;

    // Only reset if more than 1 day has passed (2+ days)
    // If exactly 1 day has passed, the streak might still be valid if user adds word today
    // The updateStreak() method will handle the actual update based on today's activity
    if (daysDifference > 1) {
      // More than 1 day passed = streak is definitely broken
      return Streak(currentStreak: 0, lastActivityDate: null);
    }

    // Streak is still valid (same day or 1 day difference)
    // Note: If 1 day difference, updateStreak() will handle incrementing or resetting
    return streak;
  }

  @override
  Future<int> getStreakCount() async {
    return await _localDatasource.getStreakCount();
  }

  @override
  Future<DateTime?> getLastActivityDate() async {
    return await _localDatasource.getLastActivityDate();
  }

  @override
  Future<void> updateStreak({required bool hasActivityToday}) async {
    // Get current streak
    final currentStreak = await getStreak();

    // Calculate new streak
    final newStreak = currentStreak.calculateStreak(
      hasActivityToday: hasActivityToday,
    );

    // Save updated streak
    await saveStreak(newStreak);
  }

  @override
  Future<bool> isStreakAtRisk() async {
    final streak = await getStreak();
    return streak.isStreakAtRisk();
  }

  @override
  Future<void> resetStreak() async {
    await _localDatasource.resetStreak();

    // TODO: Later, sync to Firestore
    // await _remoteDatasource.resetStreak();
  }

  @override
  Future<void> saveStreak(Streak streak) async {
    await _localDatasource.saveStreak(streak);

    // TODO: Later, sync to Firestore in background
    // try {
    //   await _remoteDatasource.saveStreak(streak);
    // } catch (e) {
    //   // Log error but don't fail - local is primary
    //   debugPrint('Failed to sync streak to Firestore: $e');
    // }
  }

  /// Future method: Sync local streak to Firestore
  Future<void> syncToRemote() async {
    // TODO: Implement sync logic
    // final localStreak = await getStreak();
    // await _remoteDatasource.syncStreak(localStreak);
  }
}
