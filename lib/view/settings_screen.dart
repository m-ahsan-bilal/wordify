import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/utils/app_colors.dart';
import '../core/utils/theme_provider.dart';
import '../core/utils/language_provider.dart';
import 'widgets/ad_banner_widget.dart';
import '../l10n/app_localizations.dart';

/// Settings Screen - Centralized settings for the app
/// Includes theme toggle, language selection, about, and backup options
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          l10n.settings,
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Theme Section
                _buildSectionHeader(context, l10n.theme),
                const SizedBox(height: 8),
                _buildThemeCard(context),

                const SizedBox(height: 24),

                // Language Section
                _buildSectionHeader(context, l10n.language),
                const SizedBox(height: 8),
                _buildLanguageCard(context),

                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader(context, l10n.about),
                const SizedBox(height: 8),
                _buildAboutCard(context, l10n),

                const SizedBox(height: 24),

                // Backup Section
                // _buildSectionHeader(context, l10n.backupRestore),
                // const SizedBox(height: 8),
                // _buildBackupCard(context, l10n),
              ],
            ),
          ),
          // Ad Banner at bottom
          const AdBannerWidget(margin: EdgeInsets.symmetric(vertical: 8)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ThemeColors.getTextColor(context),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          decoration: BoxDecoration(
            color: ThemeColors.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            title: Text(
              themeProvider.isDarkMode
                  ? AppLocalizations.of(context)!.darkMode
                  : AppLocalizations.of(context)!.lightMode,
              style: TextStyle(
                color: ThemeColors.getTextColor(context),
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              themeProvider.isDarkMode
                  ? AppLocalizations.of(context)!.darkMode
                  : AppLocalizations.of(context)!.lightMode,
              style: TextStyle(
                color: ThemeColors.getSecondaryTextColor(context),
                fontSize: 14,
              ),
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: ThemeColors.getPrimaryColor(context),
            ),
            activeThumbColor: ThemeColors.getPrimaryColor(context),
          ),
        );
      },
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final l10n = AppLocalizations.of(context)!;
        final currentLocale = languageProvider.locale.languageCode;

        return Container(
          decoration: BoxDecoration(
            color: ThemeColors.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.language,
                  color: ThemeColors.getPrimaryColor(context),
                ),
                title: Text(
                  l10n.language,
                  style: TextStyle(
                    color: ThemeColors.getTextColor(context),
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  languageProvider.getLanguageName(currentLocale),
                  style: TextStyle(
                    color: ThemeColors.getSecondaryTextColor(context),
                    fontSize: 14,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: ThemeColors.getSecondaryTextColor(context),
                ),
                onTap: () {
                  _showLanguageDialog(context, languageProvider, l10n);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          Icons.info_outline,
          color: ThemeColors.getPrimaryColor(context),
        ),
        title: Text(
          l10n.about,
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Word Master',
          style: TextStyle(
            color: ThemeColors.getSecondaryTextColor(context),
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: ThemeColors.getSecondaryTextColor(context),
        ),
        onTap: () {
          context.push('/about');
        },
      ),
    );
  }

  Widget _buildBackupCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          Icons.cloud_upload,
          color: ThemeColors.getPrimaryColor(context),
        ),
        title: Text(
          l10n.backupRestore,
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          l10n.googleDriveBackup,
          style: TextStyle(
            color: ThemeColors.getSecondaryTextColor(context),
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: ThemeColors.getSecondaryTextColor(context),
        ),
        onTap: () {
          context.push('/backup');
        },
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LanguageProvider languageProvider,
    AppLocalizations l10n,
  ) {
    final currentLocale = languageProvider.locale.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColors.getCardColor(context),
        title: Text(
          l10n.language,
          style: TextStyle(color: ThemeColors.getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageProvider.supportedLocales.map((locale) {
            return RadioListTile<String>(
              title: Text(
                languageProvider.getLanguageName(locale.languageCode),
                style: TextStyle(color: ThemeColors.getTextColor(context)),
              ),
              value: locale.languageCode,
              groupValue: currentLocale,
              onChanged: (value) {
                if (value != null) {
                  languageProvider.setLanguage(value);
                  Navigator.pop(context);
                }
              },
              activeColor: ThemeColors.getPrimaryColor(context),
            );
          }).toList(),
        ),
      ),
    );
  }
}
