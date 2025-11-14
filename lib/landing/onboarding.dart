import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:word_master/core/local_db/settings_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final pages = [
    {
      'icon': Icons.book_rounded,
      'title': 'Learn New Words',
      'text': 'Save the words you discover daily.',
    },
    {
      'icon': Icons.quiz_rounded,
      'title': 'Quiz to Remember',
      'text': 'Master vocabulary through fun quizzes.',
    },
    {
      'icon': Icons.notifications_active_rounded,
      'title': 'Stay Consistent',
      'text': 'Smart reminders keep your streak alive.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => currentPage = index);
              },
              itemBuilder: (_, index) {
                final page = pages[index];
                return _buildPage(
                  icon: page['icon'] as IconData,
                  title: page['title'] as String,
                  text: page['text'] as String,
                );
              },
            ),

            // Skip button (only on first two screens)
            if (currentPage != pages.length - 1)
              Positioned(
                right: 16,
                top: 12,
                child: TextButton(
                  onPressed: () async {
                    await settings.setOnboardingSeen();
                    if (context.mounted) context.go('/home');
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(fontSize: 16, color: Colors.indigo),
                  ),
                ),
              ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SmoothPageIndicator(
              controller: _controller,
              count: pages.length,
              effect: ExpandingDotsEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: Colors.indigo,
                dotColor: Colors.black26,
              ),
            ),
            const SizedBox(height: 20),

            // Show button only on last page
            if (currentPage == pages.length - 1)
              ElevatedButton(
                onPressed: () async {
                  await settings.setOnboardingSeen();
                  if (context.mounted) context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 44,
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 150, color: Colors.indigo),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }
}
