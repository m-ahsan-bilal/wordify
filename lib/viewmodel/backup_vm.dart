import 'package:flutter/material.dart';
import '../core/services/backup_service.dart';

/// ViewModel for Backup and Restore functionality
/// Follows the app's MVVM architecture pattern
class BackupViewModel extends ChangeNotifier {
  final BackupService _backupService = BackupService();

  bool _isLoading = false;
  bool _isSignedIn = false;
  bool _backupExists = false;
  String? _error;
  String? _successMessage;
  String? _userEmail;

  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;
  bool get backupExists => _backupExists;
  String? get error => _error;
  String? get successMessage => _successMessage;
  String? get userEmail => _userEmail;

  /// Check sign-in status and backup existence
  Future<void> checkSignInStatus() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _isSignedIn = await _backupService.isSignedIn();
      if (_isSignedIn) {
        _userEmail = await _backupService.getCurrentUserEmail();
        _backupExists = await _backupService.backupExists();
      } else {
        _userEmail = null;
        _backupExists = false;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to check sign-in status: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in to Google
  Future<void> signIn() async {
    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      await _backupService.signIn();
      _isSignedIn = true;
      _userEmail = await _backupService.getCurrentUserEmail();
      _backupExists = await _backupService.backupExists();
      _successMessage = 'Signed in successfully';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sign in: ${e.toString().replaceAll('Exception: ', '')}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      await _backupService.signOut();
      _isSignedIn = false;
      _userEmail = null;
      _backupExists = false;
      _successMessage = 'Signed out successfully';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sign out: ${e.toString().replaceAll('Exception: ', '')}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create backup
  Future<void> createBackup() async {
    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      await _backupService.createBackup();
      _backupExists = true;
      _successMessage = 'Backup created successfully!';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create backup: ${e.toString().replaceAll('Exception: ', '')}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restore backup
  Future<void> restoreBackup() async {
    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      await _backupService.restoreBackup();
      _successMessage = 'Backup restored successfully!';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to restore backup: ${e.toString().replaceAll('Exception: ', '')}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error and success messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}

