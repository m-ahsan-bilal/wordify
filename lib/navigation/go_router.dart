import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_master/landing/onboarding.dart';
import 'package:word_master/landing/splash_screen.dart';
import 'package:word_master/view/add_word.dart';
import 'package:word_master/view/home_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/add-word',
        builder: (context, state) => const AddWordScreen(),
      ),
    ],
  );
}
