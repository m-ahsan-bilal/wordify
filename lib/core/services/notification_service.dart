import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';

/// Notification Service - Handles Firebase Cloud Messaging
/// Singleton pattern for global access
/// Supports navigation payloads for routing
///
/// Note: This service uses Firebase Cloud Messaging exclusively.
/// For scheduled notifications, use Firebase Cloud Functions to send messages at specific times.
class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Lazy initialization - only access Firebase when needed
  FirebaseMessaging? _messaging;
  FirebaseMessaging get messaging {
    _messaging ??= FirebaseMessaging.instance;
    return _messaging!;
  }

  bool _initialized = false;
  String? _fcmToken;

  // Callback for handling notification clicks (set from main.dart)
  void Function(String? payload)? onNotificationClick;

  /// Initialize notification service
  Future<void> init() async {
    if (_initialized) {
      debugPrint('Notification service already initialized');
      return;
    }

    try {
      debugPrint('Initializing notification service...');
      _initialized = true;

      // Request notification permissions (Android 13+, iOS)
      try {
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        debugPrint(
          'Notification permission status: ${settings.authorizationStatus}',
        );
        debugPrint(
          'Alert: ${settings.alert}, Badge: ${settings.badge}, Sound: ${settings.sound}',
        );
      } catch (e) {
        debugPrint('Permission request error: $e');
        // Continue even if permission request fails
      }

      // Foreground message handler (with error handling)
      try {
        FirebaseMessaging.onMessage.listen(
          _handleForegroundMessage,
          onError: (error) {
            debugPrint('Foreground message error: $error');
          },
        );
      } catch (e) {
        debugPrint('Foreground message handler setup error: $e');
      }

      // Notification clicked when app is in background
      try {
        FirebaseMessaging.onMessageOpenedApp.listen(
          _handleMessageClick,
          onError: (error) {
            debugPrint('Message opened app error: $error');
          },
        );
      } catch (e) {
        debugPrint('Message opened app handler setup error: $e');
      }

      // Handle notification that opened the app from terminated state
      try {
        final initialMessage = await messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageClick(initialMessage);
        }
      } catch (e) {
        debugPrint('Initial message error: $e');
      }

      // Get FCM token (required for topic subscriptions)
      try {
        _fcmToken = await messaging.getToken();
        if (_fcmToken != null && _fcmToken!.isNotEmpty) {
          debugPrint(
            '✅ FCM Token obtained: ${_fcmToken!.substring(0, _fcmToken!.length > 20 ? 20 : _fcmToken!.length)}...',
          );
        } else {
          debugPrint('❌ FCM Token is null - retrying...');
          // Retry after a delay
          await Future.delayed(const Duration(seconds: 2));
          _fcmToken = await messaging.getToken();
          if (_fcmToken != null && _fcmToken!.isNotEmpty) {
            debugPrint(
              '✅ FCM Token obtained on retry: ${_fcmToken!.substring(0, _fcmToken!.length > 20 ? 20 : _fcmToken!.length)}...',
            );
          } else {
            debugPrint('❌ FCM Token still null after retry');
          }
        }
      } catch (e) {
        debugPrint('FCM token error: $e');
        // Token generation is important for subscriptions, but continue
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        if (newToken.isNotEmpty) {
          debugPrint(
            'FCM Token refreshed: ${newToken.substring(0, newToken.length > 20 ? 20 : newToken.length)}...',
          );
          _fcmToken = newToken;
        }
      });

      debugPrint('✅ Notification service initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Notification service init error: $e');
      debugPrint('Stack trace: $stackTrace');
      // Reset initialized flag so we can retry later
      _initialized = false;
      rethrow; // Re-throw to let caller handle
    }
  }

  /// Handle foreground FCM message
  /// Shows notification when app is in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Received foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
    debugPrint('From: ${message.from}');
    debugPrint('Sent time: ${message.sentTime}');

    // Note: FCM handles showing notifications automatically on Android
    // when app is in background. In foreground, you can handle it here
    // or let the system handle it.
  }

  /// Handle FCM notification click
  void _handleMessageClick(RemoteMessage message) {
    debugPrint('Notification clicked: ${message.data}');
    final route = message.data['route'] ?? '/home';

    if (onNotificationClick != null) {
      onNotificationClick!(route);
    }
  }

  /// Get FCM token for this device
  /// Use this token to send notifications from your backend/Firebase Console
  Future<String?> getFCMToken() async {
    return await messaging.getToken();
  }

  /// Subscribe to a topic
  /// Use topics to send notifications to multiple devices
  Future<void> subscribeToTopic(String topic) async {
    try {
      // Ensure we have FCM token before subscribing
      if (_fcmToken == null) {
        debugPrint('⏳ Waiting for FCM token before subscribing to $topic...');
        _fcmToken = await messaging.getToken();
        if (_fcmToken == null) {
          debugPrint('❌ FCM token still null, cannot subscribe to $topic');
          return;
        }
        debugPrint('✅ FCM token obtained for topic subscription');
      }

      // Wait a bit to ensure Firebase Messaging is ready
      await Future.delayed(const Duration(milliseconds: 1000));

      await messaging.subscribeToTopic(topic);
      debugPrint('✅ Successfully subscribed to topic: $topic');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to subscribe to topic $topic: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't rethrow - allow app to continue, subscription can retry later
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Request permission for notifications (iOS)
  Future<bool> requestPermission() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // ============================================================
  // SCHEDULED NOTIFICATIONS WITH FIREBASE
  // ============================================================
  // To send scheduled notifications, use Firebase Cloud Functions:
  //
  // 1. Create a Cloud Function that runs daily at a specific time
  // 2. Function checks which users need reminders
  // 3. Function sends FCM messages to those users
  //
  // Example Cloud Function (JavaScript):
  // ```javascript
  // exports.sendDailyReminder = functions.pubsub
  //   .schedule('0 20 * * *') // 8 PM daily
  //   .onRun(async (context) => {
  //     const message = {
  //       notification: {
  //         title: 'Add your daily word! 📚',
  //         body: 'Keep your streak alive by adding a word today.'
  //       },
  //       data: { route: '/add-word' },
  //       topic: 'daily_reminders'
  //     };
  //     await admin.messaging().send(message);
  //   });
  // ```
  //
  // Then subscribe users to the topic:
  // await NotificationService().subscribeToTopic('daily_reminders');
  // ============================================================

  /// Subscribe to daily reminders topic
  /// Your backend will send notifications to this topic at scheduled times
  Future<void> enableDailyReminders({bool checkSettings = true}) async {
    if (!_initialized) {
      debugPrint(
        '❌ Notification service not initialized, cannot enable daily reminders',
      );
      // Try to initialize first
      try {
        await init();
      } catch (e) {
        debugPrint('Failed to initialize notification service: $e');
        return;
      }
    }

    // Check if notifications are enabled in settings (if checkSettings is true)
    if (checkSettings) {
      try {
        // Wait for Hive to be ready
        Box settingsBox;
        if (Hive.isBoxOpen('settings')) {
          settingsBox = Hive.box('settings');
        } else {
          settingsBox = await Hive.openBox('settings').timeout(
            const Duration(seconds: 2),
            onTimeout: () => Hive.box('settings'),
          );
        }
        final notificationsEnabled = settingsBox.get(
          'notificationsEnabled',
          defaultValue: true,
        );
        if (!notificationsEnabled) {
          debugPrint(
            '⏸️ Notifications are disabled in settings, skipping subscription',
          );
          return;
        }
      } catch (e) {
        debugPrint('Could not check notification settings: $e');
        // Continue anyway
      }
    }

    try {
      debugPrint('📅 Enabling daily reminders...');
      await subscribeToTopic('daily_reminders');
      debugPrint('✅ Daily reminders enabled');
    } catch (e) {
      debugPrint('❌ Failed to enable daily reminders: $e');
      // Don't rethrow - allow app to continue
    }
  }

  /// Unsubscribe from daily reminders
  Future<void> disableDailyReminders() async {
    try {
      await unsubscribeFromTopic('daily_reminders');
    } catch (e) {
      debugPrint('Failed to disable daily reminders: $e');
    }
  }

  /// Subscribe to streak alerts topic
  Future<void> enableStreakAlerts() async {
    if (!_initialized) {
      debugPrint(
        'Notification service not initialized, cannot enable streak alerts',
      );
      return;
    }
    try {
      await subscribeToTopic('streak_alerts');
    } catch (e) {
      debugPrint('Failed to enable streak alerts: $e');
      // Don't rethrow - allow app to continue
    }
  }

  /// Unsubscribe from streak alerts
  Future<void> disableStreakAlerts() async {
    try {
      await unsubscribeFromTopic('streak_alerts');
    } catch (e) {
      debugPrint('Failed to disable streak alerts: $e');
    }
  }

  /// Verify FCM is working properly
  Future<Map<String, dynamic>> verifyFCMStatus() async {
    final status = <String, dynamic>{
      'initialized': _initialized,
      'hasToken': _fcmToken != null,
      'token': _fcmToken != null ? '${_fcmToken!.substring(0, 20)}...' : null,
    };

    try {
      final permission = await messaging.requestPermission();
      status['permissionStatus'] = permission.authorizationStatus.toString();
      status['permissionGranted'] =
          permission.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      status['permissionError'] = e.toString();
    }

    try {
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        status['currentToken'] = token.toString();
      } else {
        status['currentToken'] = null;
      }
    } catch (e) {
      status['tokenError'] = e.toString();
    }

    debugPrint('FCM Status: $status');
    return status;
  }
}
