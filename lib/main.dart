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

// Data Sources
import 'data/datasources/local/words_local_datasource.dart';
import 'data/datasources/local/streak_local_datasource.dart';

// Repositories
import 'core/repositories/word_repository.dart';
import 'core/repositories/streak_repository.dart';
import 'data/repositories/word_repository_impl.dart';
import 'data/repositories/streak_repository_impl.dart';

// ViewModels
import 'viewmodel/words_list_vm.dart';
import 'viewmodel/add_word_vm.dart';
import 'viewmodel/streak_vm.dart';
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
  // FIREBASE INITIALIZATION
  // ============================================================
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Register background FCM handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ============================================================
  // HIVE INITIALIZATION
  // ============================================================
  await Hive.initFlutter();

  // Initialize local data sources
  await WordsLocalDatasource().init();
  await StreakLocalDatasource().init();

  // Initialize settings box (needed for SettingsViewModel)
  await Hive.openBox('settings');

  // ============================================================
  // REPOSITORY INITIALIZATION (Dependency Injection)
  // ============================================================
  final wordRepository = WordRepositoryImpl();
  final streakRepository = StreakRepositoryImpl();

  // ============================================================
  // NOTIFICATION SERVICE INITIALIZATION
  // ============================================================
  final notificationService = NotificationService();
  await notificationService.init();

  // Note: Topic subscriptions are optional and can be enabled later
  // Uncomment when you're ready to use Firebase Cloud Messaging for notifications
  // await notificationService.enableDailyReminders();
  // await notificationService.enableStreakAlerts();

  // ============================================================
  // ROUTER INITIALIZATION
  // ============================================================
  final router = AppRouter.createRouter();

  // Set notification click handler to navigate
  notificationService.onNotificationClick = (String? payload) {
    if (payload != null && payload.isNotEmpty) {
      router.go(payload);
    }
  };

  // ============================================================
  // RUN APP WITH DEPENDENCY INJECTION
  // ============================================================
  runApp(
    MultiProvider(
      providers: [
        // Repositories (for direct access if needed)
        Provider<WordRepository>.value(value: wordRepository),
        Provider<StreakRepository>.value(value: streakRepository),

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
    return MaterialApp.router(
      title: 'Word Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Poppins',
        // Optional: Add custom theme settings
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0.7),
      ),
      routerConfig: router,
    );
  }
}
