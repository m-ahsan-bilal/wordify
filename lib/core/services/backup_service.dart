import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../model/backup_model.dart';
import '../../data/datasources/backup_datasource.dart';

/// Service for handling Google Drive backup and restore
/// Follows the app's service architecture pattern
class BackupService {
  static const String _backupFileName = 'word_master_backup.json';
  static const String _backupFolderName = 'Word Master Backups';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  final BackupDatasource _backupDatasource = BackupDatasource();

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Sign in to Google
  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Sign in cancelled');
      }
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Get current user email
  Future<String?> getCurrentUserEmail() async {
    final account = await _googleSignIn.signInSilently();
    return account?.email;
  }

  /// Get authenticated HTTP client
  Future<AuthClient> _getAuthenticatedClient() async {
    final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
    if (account == null) {
      throw Exception('Not signed in');
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) {
      throw Exception('No access token');
    }

    return authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', accessToken, DateTime.now().add(const Duration(hours: 1))),
        auth.idToken,
        [
          'https://www.googleapis.com/auth/drive.file',
        ],
      ),
    );
  }

  /// Create or get backup folder in Google Drive
  Future<String> _getOrCreateBackupFolder(drive.DriveApi driveApi) async {
    // Search for existing folder
    final response = await driveApi.files.list(
      q: "name='$_backupFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
    );

    if (response.files != null && response.files!.isNotEmpty) {
      return response.files!.first.id!;
    }

    // Create new folder
    final folder = drive.File();
    folder.name = _backupFolderName;
    folder.mimeType = 'application/vnd.google-apps.folder';

    final createdFolder = await driveApi.files.create(folder);
    return createdFolder.id!;
  }

  /// Create backup and upload to Google Drive
  Future<void> createBackup() async {
    try {
      // Check if signed in
      if (!await isSignedIn()) {
        throw Exception('Please sign in to Google first');
      }

      // Export data
      final backupData = await _backupDatasource.exportData();
      final jsonString = backupData.toJson();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File(path.join(tempDir.path, _backupFileName));
      await file.writeAsString(jsonString);

      // Get authenticated client
      final client = await _getAuthenticatedClient();
      final driveApi = drive.DriveApi(client);

      // Get or create backup folder
      final folderId = await _getOrCreateBackupFolder(driveApi);

      // Delete old backup if exists
      final existingFiles = await driveApi.files.list(
        q: "name='$_backupFileName' and parents in '$folderId' and trashed=false",
        spaces: 'drive',
      );

      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        for (final existingFile in existingFiles.files!) {
          await driveApi.files.delete(existingFile.id!);
        }
      }

      // Upload new backup
      final driveFile = drive.File();
      driveFile.name = _backupFileName;
      driveFile.parents = [folderId];

      final media = drive.Media(file.openRead(), file.lengthSync());
      await driveApi.files.create(driveFile, uploadMedia: media);

      // Clean up temp file
      await file.delete();

      debugPrint('Backup created successfully');
    } catch (e) {
      debugPrint('Backup error: $e');
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Download backup from Google Drive and restore
  Future<void> restoreBackup() async {
    try {
      // Check if signed in
      if (!await isSignedIn()) {
        throw Exception('Please sign in to Google first');
      }

      // Get authenticated client
      final client = await _getAuthenticatedClient();
      final driveApi = drive.DriveApi(client);

      // Get backup folder
      final folderResponse = await driveApi.files.list(
        q: "name='$_backupFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        spaces: 'drive',
      );

      if (folderResponse.files == null || folderResponse.files!.isEmpty) {
        throw Exception('No backup folder found');
      }

      final folderId = folderResponse.files!.first.id!;

      // Find backup file
      final fileResponse = await driveApi.files.list(
        q: "name='$_backupFileName' and parents in '$folderId' and trashed=false",
        spaces: 'drive',
      );

      if (fileResponse.files == null || fileResponse.files!.isEmpty) {
        throw Exception('No backup file found');
      }

      final backupFile = fileResponse.files!.first;

      // Download file
      final tempDir = await getTemporaryDirectory();
      final file = File(path.join(tempDir.path, _backupFileName));

      final media = await driveApi.files.get(
        backupFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      await media.stream.pipe(file.openWrite());

      // Read and parse backup data
      final jsonString = await file.readAsString();
      final backupData = BackupData.fromJson(jsonString);

      // Import data
      await _backupDatasource.importData(backupData);

      // Clean up temp file
      await file.delete();

      debugPrint('Backup restored successfully');
    } catch (e) {
      debugPrint('Restore error: $e');
      throw Exception('Failed to restore backup: $e');
    }
  }

  /// Check if backup exists in Google Drive
  Future<bool> backupExists() async {
    try {
      if (!await isSignedIn()) {
        return false;
      }

      final client = await _getAuthenticatedClient();
      final driveApi = drive.DriveApi(client);

      final folderResponse = await driveApi.files.list(
        q: "name='$_backupFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        spaces: 'drive',
      );

      if (folderResponse.files == null || folderResponse.files!.isEmpty) {
        return false;
      }

      final folderId = folderResponse.files!.first.id!;

      final fileResponse = await driveApi.files.list(
        q: "name='$_backupFileName' and parents in '$folderId' and trashed=false",
        spaces: 'drive',
      );

      return fileResponse.files != null && fileResponse.files!.isNotEmpty;
    } catch (e) {
      debugPrint('Check backup error: $e');
      return false;
    }
  }
}

