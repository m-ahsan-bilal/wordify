import '../../core/model/xp_model.dart';
import '../../core/repositories/xp_repository.dart';
import '../datasources/local/xp_local_datasource.dart';
import '../datasources/remote/xp_remote_datasource.dart';

/// Implementation of XP Repository
/// Handles data operations using local and remote data sources
/// Follows the same pattern as other repository implementations
class XPRepositoryImpl implements XPRepository {
  final XPLocalDatasource _localDatasource;
  final XPRemoteDatasource _remoteDatasource;

  XPRepositoryImpl({
    required XPLocalDatasource localDatasource,
    required XPRemoteDatasource remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource;

  @override
  Future<XP> getXP() async {
    // Primary: Get from local storage
    final localXP = await _localDatasource.getXP();

    // TODO: Later, sync with remote if needed
    // if (shouldSyncWithRemote) {
    //   final userId = await getCurrentUserId();
    //   final syncedXP = await _remoteDatasource.syncXP(userId, localXP);
    //   if (syncedXP != localXP) {
    //     await _localDatasource.saveXP(syncedXP);
    //     return syncedXP;
    //   }
    // }

    return localXP;
  }

  @override
  Future<int> getTotalXP() async {
    return await _localDatasource.getTotalXP();
  }

  @override
  Future<int> getCurrentLevel() async {
    return await _localDatasource.getCurrentLevel();
  }

  @override
  Future<({XP newXP, bool leveledUp})> addXP(int xpToAdd) async {
    // Add XP locally
    final result = await _localDatasource.addXP(xpToAdd);

    // TODO: Later, also update remote
    // if (shouldSyncWithRemote) {
    //   final userId = await getCurrentUserId();
    //   await _remoteDatasource.addXP(userId, xpToAdd);
    // }

    return result;
  }

  @override
  Future<void> saveXP(XP xp) async {
    await _localDatasource.saveXP(xp);

    // TODO: Later, also save to remote
    // if (shouldSyncWithRemote) {
    //   final userId = await getCurrentUserId();
    //   await _remoteDatasource.saveXP(userId, xp);
    // }
  }

  @override
  Future<void> resetXP() async {
    await _localDatasource.resetXP();

    // TODO: Later, also reset remote
    // if (shouldSyncWithRemote) {
    //   final userId = await getCurrentUserId();
    //   await _remoteDatasource.resetXP(userId);
    // }
  }

  @override
  Future<double> getProgressToNextLevel() async {
    final xp = await getXP();
    return xp.progressToNextLevel;
  }

  @override
  Future<int> getXPToNextLevel() async {
    final xp = await getXP();
    return xp.xpToNextLevel;
  }

  /// Future method: Sync local XP to Firestore
  Future<void> syncToRemote() async {
    // TODO: Implement sync logic
    // final userId = await getCurrentUserId();
    // final localXP = await getXP();
    // await _remoteDatasource.saveXP(userId, localXP);
  }

  /// Future method: Get current user ID for Firebase operations
  Future<String> getCurrentUserId() async {
    // TODO: Implement when authentication is added
    // return FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    return 'local_user'; // Placeholder
  }
}
