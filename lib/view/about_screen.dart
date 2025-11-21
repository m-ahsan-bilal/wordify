import 'package:flutter/material.dart';
import '../core/utils/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About Word Master',
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: ThemeColors.getPrimaryColor(context),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Word Master',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeColors.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About Section
            _buildSection(
              context,
              'About the App',
              'Word Master is your ultimate vocabulary companion designed to help you expand your word knowledge effortlessly. Whether you\'re a student preparing for exams, a professional looking to enhance your communication skills, or simply someone who loves learning new words, Word Master provides the perfect platform to build and maintain your vocabulary.',
            ),

            const SizedBox(height: 24),

            // Features Section
            _buildSection(
              context,
              'Key Features',
              '• Add and organize your vocabulary words\n'
                  '• Track your learning progress with XP system\n'
                  '• Maintain daily learning streaks\n'
                  '• Review words with interactive quizzes\n'
                  '• Listen to word pronunciations\n'
                  '• Categorize words by difficulty levels\n'
                  '• Dark and light theme support\n'
                  '• Offline functionality with cloud sync',
            ),

            const SizedBox(height: 24),

            // Mission Section
            _buildSection(
              context,
              'Our Mission',
              'We believe that a rich vocabulary is the foundation of effective communication. Our mission is to make vocabulary learning engaging, systematic, and rewarding. Through gamification elements like XP points, streaks, and levels, we transform the traditional approach to vocabulary building into an enjoyable journey of discovery.',
            ),

            const SizedBox(height: 24),

            // Contact Section
            _buildSection(
              context,
              'Contact Us',
              'We\'d love to hear from you! Whether you have feedback, suggestions, or need support, feel free to reach out to us.\n\n'
                  'Email: support@wordmaster.com\n'
                  'Website: www.wordmaster.com\n'
                  'Follow us on social media for updates and tips!',
            ),

            const SizedBox(height: 24),

            // Credits Section
            _buildSection(
              context,
              'Credits',
              'Word Master is developed with ❤️ using Flutter framework. Special thanks to all the developers for making this app possible.\n\n'
                  'Icons by Material Design Icons\n'
                  'Fonts by Google Fonts\n'
                  'Built with Flutter & Dart',
            ),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '© 2024 Word Master',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Made with 💜 for vocabulary enthusiasts',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: ThemeColors.getTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
