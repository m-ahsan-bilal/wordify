import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:word_master/navigation/go_router.dart';
import 'package:word_master/core/local_db/words_service.dart';
import 'package:word_master/core/local_db/settings_service.dart';
import 'package:word_master/view%20model/words_list_vm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // firebase init for crashlytics
  await Firebase.initializeApp();
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // hive intialization
  await Hive.initFlutter();
  await WordsService().init();
  await SettingsService().init();

  final router = AppRouter.createRouter();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WordsListViewModel())],
      child: VocabApp(router: router),
    ),
  );
}

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
      ),
      routerConfig: router,
    );
  }
}
