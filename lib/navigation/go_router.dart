import 'package:go_router/go_router.dart';
import 'package:word_master/landing/onboarding.dart';
import 'package:word_master/landing/splash_screen.dart';
import 'package:word_master/core/local_db/settings_service.dart';
import 'package:word_master/view/add_word.dart';
import 'package:word_master/view/home_screen.dart';
import 'package:word_master/view/quiz_screen.dart';
import 'package:word_master/view/word_details_screen.dart';
import 'package:word_master/view/word_list.dart';

class AppRouter {
  static GoRouter createRouter() {
    final settings = SettingsService();
    final hasSeen = settings.hasSeenOnboarding();

    return GoRouter(
      initialLocation: hasSeen ? '/home' : '/onboarding',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/add-word', builder: (_, __) => const AddWordScreen()),
        GoRoute(
          path: '/word-details',
          builder: (context, state) {
            final index = state.extra as int? ?? 0;
            return WordDetailsScreen(wordIndex: index);
          },
        ),
        GoRoute(path: '/quiz', builder: (_, __) => QuizScreen()),
        GoRoute(path: '/list', builder: (_, __) => const WordsListScreen()),
      ],
    );
  }
}
