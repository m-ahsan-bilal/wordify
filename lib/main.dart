import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

// Core Services
import 'core/services/notification_service.dart';
import 'core/utils/theme_provider.dart';

// Data Sources
import 'data/datasources/local/words_local_datasource.dart';
import 'data/datasources/local/streak_local_datasource.dart';
import 'data/datasources/local/xp_local_datasource.dart';
import 'data/datasources/local/quiz_local_datasource.dart';
import 'data/datasources/remote/xp_remote_datasource.dart';

// Repositories
import 'core/repositories/word_repository.dart';
import 'core/repositories/streak_repository.dart';
import 'core/repositories/xp_repository.dart';
import 'core/repositories/quiz_repository.dart';
import 'data/repositories/word_repository_impl.dart';
import 'data/repositories/streak_repository_impl.dart';
import 'data/repositories/xp_repository_impl.dart';
import 'data/repositories/quiz_repository_impl.dart';

// ViewModels
import 'viewmodel/words_list_vm.dart';
import 'viewmodel/add_word_vm.dart';
import 'viewmodel/streak_vm.dart';
import 'viewmodel/xp_vm.dart';
import 'viewmodel/quiz_vm.dart';
import 'viewmodel/settings_vm.dart';

// Navigation
import 'navigation/go_router.dart';

/// Firebase background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // FIREBASE INITIALIZATION (with error handling)
  // ============================================================
  try {
    await Firebase.initializeApp();

    // Set up error handlers only if Firebase initialized successfully
    FlutterError.onError = (FlutterErrorDetails details) {
      try {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      } catch (e) {
        debugPrint('Error recording to Crashlytics: $e');
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (e) {
        debugPrint('Error recording to Crashlytics: $e');
      }
      return true;
    };

    // Register background FCM handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue app initialization even if Firebase fails
  }

  // ============================================================
  // HIVE INITIALIZATION (with error handling)
  // ============================================================
  try {
    await Hive.initFlutter();
  } catch (e) {
    debugPrint('Hive initialization error: $e');
    // Try to continue, but app might have issues
  }

  // Initialize local data sources (with error handling)
  try {
    await WordsLocalDatasource().init();
  } catch (e) {
    debugPrint('WordsLocalDatasource init error: $e');
  }

  try {
    await StreakLocalDatasource().init();
  } catch (e) {
    debugPrint('StreakLocalDatasource init error: $e');
  }

  try {
    await XPLocalDatasource().init();
  } catch (e) {
    debugPrint('XPLocalDatasource init error: $e');
  }

  try {
    await QuizLocalDatasource().init();
  } catch (e) {
    debugPrint('QuizLocalDatasource init error: $e');
  }

  // Initialize remote data sources (placeholders for Firebase)
  try {
    await XPRemoteDatasource().init();
  } catch (e) {
    debugPrint('XPRemoteDatasource init error: $e');
  }

  // Initialize settings box (needed for SettingsViewModel)
  try {
    await Hive.openBox('settings');
  } catch (e) {
    debugPrint('Settings box open error: $e');
  }

  // ============================================================
  // REPOSITORY INITIALIZATION (Dependency Injection)
  // ============================================================
  final wordRepository = WordRepositoryImpl();
  final streakRepository = StreakRepositoryImpl();
  final xpRepository = XPRepositoryImpl(
    localDatasource: XPLocalDatasource(),
    remoteDatasource: XPRemoteDatasource(),
  );
  final quizRepository = QuizRepositoryImpl();

  // ============================================================
  // NOTIFICATION SERVICE INITIALIZATION (with error handling)
  // ============================================================
  final notificationService = NotificationService();
  try {
    // Initialize with timeout to prevent hanging
    await notificationService.init().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('Notification service init timeout');
      },
    );

    // Wait a bit for Firebase Messaging to be fully ready
    await Future.delayed(const Duration(milliseconds: 1000));

    // Note: Topic subscriptions are optional and can be enabled later
    // Subscribe to topics asynchronously (non-blocking) with longer timeout
    // This allows app to start even if subscriptions take time
    notificationService
        .enableDailyReminders()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            debugPrint('Daily reminders subscription timeout (non-blocking)');
          },
        )
        .catchError((e) {
          debugPrint('Failed to enable daily reminders: $e');
        });

    notificationService
        .enableStreakAlerts()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            debugPrint('Streak alerts subscription timeout (non-blocking)');
          },
        )
        .catchError((e) {
          debugPrint('Failed to enable streak alerts: $e');
        });
  } catch (e) {
    debugPrint('Notification service init error: $e');
    // Continue app initialization even if notifications fail
    // Try to subscribe anyway (might work if Firebase is partially initialized)
    notificationService.enableDailyReminders().catchError((e) {
      debugPrint('Failed to enable daily reminders after init error: $e');
    });
    notificationService.enableStreakAlerts().catchError((e) {
      debugPrint('Failed to enable streak alerts after init error: $e');
    });
  }

  // ============================================================
  // ROUTER INITIALIZATION
  // ============================================================
  final router = AppRouter.createRouter();

  // Set notification click handler to navigate (with error handling)
  notificationService.onNotificationClick = (String? payload) {
    try {
      if (payload != null && payload.isNotEmpty) {
        // Use addPostFrameCallback to ensure router is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            router.go(payload);
          } catch (e) {
            debugPrint('Navigation error from notification: $e');
            // Fallback to home if navigation fails
            try {
              router.go('/home');
            } catch (_) {
              // Ignore fallback errors
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Notification click handler error: $e');
    }
  };

  // ============================================================
  // RUN APP WITH DEPENDENCY INJECTION
  // ============================================================
  runApp(
    MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Repositories (for direct access if needed)
        Provider<WordRepository>.value(value: wordRepository),
        Provider<StreakRepository>.value(value: streakRepository),
        Provider<XPRepository>.value(value: xpRepository),
        Provider<QuizRepository>.value(value: quizRepository),

        // ViewModels
        ChangeNotifierProvider(
          create: (_) => WordsListViewModel(wordRepository: wordRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AddWordViewModel(
            wordRepository: wordRepository,
            streakRepository: streakRepository,
            xpRepository: xpRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => StreakViewModel(
            streakRepository: streakRepository,
            wordRepository: wordRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => XPViewModel(xpRepository: xpRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizViewModel(
            quizRepository: quizRepository,
            xpRepository: xpRepository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: VocabApp(router: router),
    ),
  );
}

/// Main App Widget
class VocabApp extends StatelessWidget {
  final GoRouter router;
  const VocabApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Word Master',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          routerConfig: router,
        );
      },
    );
  }
}
