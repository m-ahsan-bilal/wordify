import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/app_colors.dart';
import '../viewmodel/backup_vm.dart';
import '../l10n/app_localizations.dart';

/// Backup Screen - Handles Google Drive backup and restore
/// Follows the app's UI architecture and theme
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BackupViewModel>().checkSignInStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeColors.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ThemeColors.getTextColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.backupRestore,
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<BackupViewModel>(
        builder: (context, backupVm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                _buildInfoCard(context),

                const SizedBox(height: 24),

                // Status Messages
                if (backupVm.error != null)
                  _buildErrorCard(context, backupVm.error!),
                if (backupVm.successMessage != null)
                  _buildSuccessCard(context, backupVm.successMessage!),

                const SizedBox(height: 24),

                // Sign In Section
                if (!backupVm.isSignedIn)
                  _buildSignInSection(context, backupVm),

                // Signed In Section
                if (backupVm.isSignedIn)
                  _buildSignedInSection(context, backupVm),

                const SizedBox(height: 24),

                // Loading Indicator
                if (backupVm.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_upload,
                color: ThemeColors.getPrimaryColor(context),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.backupRestore,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Backup your vocabulary data to Google Drive and restore it on any device. Your words, progress, streaks, and quiz history will be safely stored in the cloud.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeColors.getPrimaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: ThemeColors.getPrimaryColor(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.dataStoredSecurely,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.getTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInSection(BuildContext context, BackupViewModel backupVm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.signInToGoogle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.signInDescription,
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: backupVm.isLoading
                ? null
                : () async {
                    backupVm.clearMessages();
                    await backupVm.signIn();
                  },
            icon: const Icon(Icons.login),
            label: Text(AppLocalizations.of(context)!.signInWithGoogle),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getPrimaryColor(context),
              foregroundColor: ThemeColors.getOnPrimaryColor(context),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignedInSection(BuildContext context, BackupViewModel backupVm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Account Info Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeColors.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    color: ThemeColors.getPrimaryColor(context),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.signedIn,
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeColors.getSecondaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          backupVm.userEmail ?? 'Google Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: backupVm.isLoading
                        ? null
                        : () async {
                            backupVm.clearMessages();
                            await backupVm.signOut();
                          },
                    child: Text(
                      AppLocalizations.of(context)!.signOut,
                      style: TextStyle(
                        color: ThemeColors.getPrimaryColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Backup Status
        if (backupVm.backupExists)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.lightGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.backupFound,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.getTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),

        // Create Backup Button
        ElevatedButton.icon(
          onPressed: backupVm.isLoading
              ? null
              : () async {
                  backupVm.clearMessages();
                  await backupVm.createBackup();
                  if (backupVm.successMessage != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(backupVm.successMessage!),
                        backgroundColor: AppColors.lightGreen,
                      ),
                    );
                  }
                },
          icon: const Icon(Icons.backup),
          label: Text(AppLocalizations.of(context)!.createBackup),
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.getPrimaryColor(context),
            foregroundColor: ThemeColors.getOnPrimaryColor(context),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Restore Backup Button
        if (backupVm.backupExists)
          OutlinedButton.icon(
            onPressed: backupVm.isLoading
                ? null
                : () async {
                    // Show confirmation dialog
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: ThemeColors.getCardColor(context),
                        title: Text(
                          AppLocalizations.of(context)!.restoreBackup,
                          style: TextStyle(
                            color: ThemeColors.getTextColor(context),
                          ),
                        ),
                        content: Text(
                          AppLocalizations.of(context)!.restoreConfirm,
                          style: TextStyle(
                            color: ThemeColors.getTextColor(context),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: ThemeColors.getSecondaryTextColor(
                                  context,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              AppLocalizations.of(context)!.restore,
                              style: TextStyle(
                                color: ThemeColors.getPrimaryColor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      backupVm.clearMessages();
                      await backupVm.restoreBackup();
                      if (backupVm.successMessage != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(backupVm.successMessage!),
                            backgroundColor: AppColors.lightGreen,
                          ),
                        );
                        // Refresh app data after restore
                        Navigator.pop(context);
                      }
                    }
                  },
            icon: const Icon(Icons.restore),
            label: Text(AppLocalizations.of(context)!.backupRestore),
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeColors.getPrimaryColor(context),
              side: BorderSide(color: ThemeColors.getPrimaryColor(context)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.getTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.lightGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.getTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
