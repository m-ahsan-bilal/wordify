import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../landing/onboarding.dart';
import '../landing/splash_screen.dart';
import '../view/add_word.dart';
import '../view/home_screen.dart';
import '../view/quiz_screen.dart';
import '../view/word_details_screen.dart';
import '../view/word_list.dart';

/// App Router - Handles all navigation
/// Uses GoRouter for declarative routing
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) async {
        // Check if user has seen onboarding (only on initial load)
        if (state.matchedLocation == '/') {
          // Open settings box to check onboarding status
          final box = await Hive.openBox('settings');
          final hasSeen = box.get('onboarding', defaultValue: false);
          
          if (hasSeen) {
            return '/home';
          } else {
            return '/onboarding';
          }
        }
        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/add-word',
          builder: (_, __) => const AddWordScreen(),
        ),
        GoRoute(
          path: '/word-details',
          builder: (context, state) {
            final index = state.extra as int? ?? 0;
            return WordDetailsScreen(wordIndex: index);
          },
        ),
        GoRoute(
          path: '/quiz',
          builder: (_, __) => QuizScreen(),
        ),
        GoRoute(
          path: '/list',
          builder: (_, __) => const WordsListScreen(),
        ),
      ],
    );
  }
}
