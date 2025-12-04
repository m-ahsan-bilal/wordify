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
import 'core/services/admob_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/utils/theme_provider.dart';
import 'core/utils/language_provider.dart';
import 'l10n/app_localizations.dart';

// Data Sources
import 'data/datasources/local/words_local_datasource.dart';
import 'data/datasources/local/streak_local_datasource.dart';
import 'data/datasources/local/quiz_local_datasource.dart';

// Repositories
import 'core/repositories/word_repository.dart';
import 'core/repositories/streak_repository.dart';
import 'core/repositories/quiz_repository.dart';
import 'data/repositories/word_repository_impl.dart';
import 'data/repositories/streak_repository_impl.dart';
import 'data/repositories/quiz_repository_impl.dart';

// ViewModels
import 'viewmodel/words_list_vm.dart';
import 'viewmodel/add_word_vm.dart';
import 'viewmodel/streak_vm.dart';
import 'viewmodel/quiz_vm.dart';
import 'viewmodel/settings_vm.dart';
import 'viewmodel/backup_vm.dart';

// Navigation
import 'navigation/go_router.dart';

/// Firebase background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📬 Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // MINIMAL INITIALIZATION - Run app immediately for fastest startup
  // Native splash will disappear almost instantly
  // ============================================================

  // ============================================================
  // REPOSITORY INITIALIZATION (Dependency Injection)
  // ============================================================
  final wordRepository = WordRepositoryImpl();
  final streakRepository = StreakRepositoryImpl();
  final quizRepository = QuizRepositoryImpl();

  // ============================================================
  // ROUTER INITIALIZATION
  // ============================================================
  final router = AppRouter.createRouter();

  // ============================================================
  // RUN APP IMMEDIATELY (don't wait for Hive)
  // Native splash disappears as soon as Flutter draws first frame
  // ============================================================
  runApp(
    MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Language Provider
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        // Repositories (for direct access if needed)
        Provider<WordRepository>.value(value: wordRepository),
        Provider<StreakRepository>.value(value: streakRepository),
        Provider<QuizRepository>.value(value: quizRepository),

        // ViewModels
        ChangeNotifierProvider(
          create: (_) => WordsListViewModel(wordRepository: wordRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AddWordViewModel(
            wordRepository: wordRepository,
            streakRepository: streakRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => StreakViewModel(
            streakRepository: streakRepository,
            wordRepository: wordRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizViewModel(quizRepository: quizRepository),
        ),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => BackupViewModel()),
      ],
      child: VocabApp(router: router),
    ),
  );

  // ============================================================
  // BACKGROUND INITIALIZATION (runs in parallel after app starts)
  // This doesn't block the first frame, so native splash disappears quickly
  // ============================================================

  // Hive initialization in background (runs in parallel with app startup)
  final hiveInitFuture = Future.microtask(() async {
    try {
      await Hive.initFlutter().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('Hive init timeout - continuing anyway');
        },
      );

      // Initialize settings box after Hive is ready
      try {
        await Hive.openBox('settings').timeout(
          const Duration(milliseconds: 500),
          onTimeout: () {
            debugPrint('Settings box open timeout');
            return Hive.box('settings');
          },
        );
      } catch (e) {
        debugPrint('Settings box open error: $e');
        try {
          Hive.box('settings');
        } catch (_) {
          // Ignore if box doesn't exist yet
        }
      }
      debugPrint('✅ Hive initialized successfully');
    } catch (e) {
      debugPrint('Hive initialization error: $e');
    }
  });

  // Helper function to initialize NotificationService after Firebase is ready
  void _initializeNotificationService() {
    Future.microtask(() async {
      final notificationService = NotificationService();
      try {
        await notificationService.init().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('Notification service init timeout');
          },
        );

        // Check if notifications are enabled in settings before subscribing
        try {
          final settingsBox = await Hive.openBox('settings').timeout(
            const Duration(seconds: 2),
            onTimeout: () => Hive.box('settings'),
          );
          final notificationsEnabled = settingsBox.get(
            'notificationsEnabled',
            defaultValue: true,
          );

          if (notificationsEnabled) {
            notificationService
                .enableDailyReminders(checkSettings: false)
                .timeout(
                  const Duration(seconds: 10),
                  onTimeout: () {
                    debugPrint('Daily reminders subscription timeout');
                  },
                )
                .catchError((e) {
                  debugPrint('Failed to enable daily reminders: $e');
                });

            notificationService
                .enableStreakAlerts()
                .timeout(
                  const Duration(seconds: 10),
                  onTimeout: () {
                    debugPrint('Streak alerts subscription timeout');
                  },
                )
                .catchError((e) {
                  debugPrint('Failed to enable streak alerts: $e');
                });
          }
        } catch (e) {
          debugPrint('Could not check notification settings: $e');
        }

        // Set notification click handler
        notificationService.onNotificationClick = (String? payload) {
          try {
            if (payload != null && payload.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  router.go(payload);
                } catch (e) {
                  debugPrint('Navigation error from notification: $e');
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
      } catch (e) {
        debugPrint('Notification service init error: $e');
      }
    });
  }

  // Initialize data sources in background - AFTER Hive is ready
  Future.microtask(() async {
    // Wait for Hive to be initialized first (runs in parallel with app startup)
    try {
      await hiveInitFuture;
    } catch (e) {
      debugPrint('Hive not ready for data sources: $e');
      // Retry after delay if Hive failed
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        await hiveInitFuture;
      } catch (e2) {
        debugPrint('Hive retry failed: $e2');
      }
    }

    // Now initialize data sources (Hive should be ready)
    try {
      await WordsLocalDatasource().init();
      debugPrint('✅ WordsLocalDatasource initialized');
    } catch (e) {
      debugPrint('WordsLocalDatasource init error: $e');
      // Retry after a delay if Hive wasn't ready
      Future.delayed(const Duration(milliseconds: 500), () async {
        try {
          await WordsLocalDatasource().init();
        } catch (e2) {
          debugPrint('WordsLocalDatasource retry failed: $e2');
        }
      });
    }

    try {
      await StreakLocalDatasource().init();
      debugPrint('✅ StreakLocalDatasource initialized');
    } catch (e) {
      debugPrint('StreakLocalDatasource init error: $e');
    }

    try {
      await QuizLocalDatasource().init();
      debugPrint('✅ QuizLocalDatasource initialized');
    } catch (e) {
      debugPrint('QuizLocalDatasource init error: $e');
    }
  });

  // Firebase initialization in background - MUST complete before NotificationService
  Future.microtask(() async {
    try {
      await Firebase.initializeApp().timeout(
        const Duration(seconds: 5),
        onTimeout: () async {
          debugPrint('Firebase init timeout');
          // Try to get existing Firebase app if timeout
          try {
            return Firebase.app();
          } catch (_) {
            // If no app exists, return a dummy (won't be used)
            rethrow;
          }
        },
      );

      debugPrint('✅ Firebase initialized successfully');

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
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Now that Firebase is initialized, initialize NotificationService
      _initializeNotificationService();
    } catch (e, stackTrace) {
      debugPrint('Firebase initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      // Even if Firebase fails, try to initialize NotificationService (it will handle errors)
      _initializeNotificationService();
    }
  });

  // AdMob initialization in background (non-blocking)
  Future.microtask(() async {
    final adMobService = AdMobService();
    try {
      await adMobService.init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ AdMob service init timeout');
        },
      );
      if (adMobService.isInitialized) {
        debugPrint('✅ AdMob initialized');
      }
    } catch (e) {
      debugPrint('❌ AdMob initialization error: $e');
    }
  });

  // Connectivity service initialization in background
  Future.microtask(() {
    final connectivityService = ConnectivityService();
    try {
      connectivityService.checkConnectivity().catchError((e) {
        debugPrint('Connectivity check failed (non-critical): $e');
        return true;
      });
      connectivityService.startMonitoring();
    } catch (e) {
      debugPrint('Error initializing connectivity service: $e');
    }
  });
}

/// Main App Widget
class VocabApp extends StatelessWidget {
  final GoRouter router;
  const VocabApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp.router(
          title: 'Word Master',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: languageProvider.locale,
          routerConfig: router,
        );
      },
    );
  }
}
