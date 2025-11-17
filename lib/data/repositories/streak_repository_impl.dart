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

    // TODO: Later, merge with remote if needed
    // if (shouldSyncWithRemote) {
    //   final remoteStreak = await _remoteDatasource.getStreak();
    //   // Keep the higher streak
    //   if (remoteStreak.currentStreak > streak.currentStreak) {
    //     await saveStreak(remoteStreak);
    //     return remoteStreak;
    //   }
    // }

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
