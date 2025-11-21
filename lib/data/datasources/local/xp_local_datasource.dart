import 'package:hive/hive.dart';
import '../../../core/model/xp_model.dart';

/// Local data source for XP operations using Hive
/// Handles all local database operations for XP tracking
class XPLocalDatasource {
  static final XPLocalDatasource _instance = XPLocalDatasource._internal();
  factory XPLocalDatasource() => _instance;
  XPLocalDatasource._internal();

  late Box _settingsBox;

  /// Initialize Hive box for settings/XP
  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
  }

  /// Get XP data from local storage
  Future<XP> getXP() async {
    final totalXP = _settingsBox.get('totalXP', defaultValue: 0);
    final currentLevel = _settingsBox.get('currentLevel', defaultValue: 1);
    final lastUpdatedStr = _settingsBox.get('xpLastUpdated');

    return XP(
      totalXP: totalXP,
      currentLevel: currentLevel,
      lastUpdated: lastUpdatedStr != null ? DateTime.parse(lastUpdatedStr) : null,
    );
  }

  /// Get just the total XP
  Future<int> getTotalXP() async {
    return _settingsBox.get('totalXP', defaultValue: 0);
  }

  /// Get current level
  Future<int> getCurrentLevel() async {
    return _settingsBox.get('currentLevel', defaultValue: 1);
  }

  /// Save XP data to local storage
  Future<void> saveXP(XP xp) async {
    await _settingsBox.put('totalXP', xp.totalXP);
    await _settingsBox.put('currentLevel', xp.currentLevel);
    if (xp.lastUpdated != null) {
      await _settingsBox.put(
        'xpLastUpdated',
        xp.lastUpdated!.toIso8601String(),
      );
    }
  }

  /// Add XP and return updated XP object with level calculation
  Future<({XP newXP, bool leveledUp})> addXP(int xpToAdd) async {
    final currentXP = await getXP();
    final newXP = currentXP.addXP(xpToAdd);
    final leveledUp = newXP.didLevelUp(currentXP);
    
    await saveXP(newXP);
    
    return (newXP: newXP, leveledUp: leveledUp);
  }

  /// Reset XP to zero
  Future<void> resetXP() async {
    final resetXP = XP(
      totalXP: 0,
      currentLevel: 1,
      lastUpdated: DateTime.now(),
    );
    await saveXP(resetXP);
  }
}
