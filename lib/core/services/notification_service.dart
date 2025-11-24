import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _initialized = false;
  String? _fcmToken;

  // Callback for handling notification clicks (set from main.dart)
  void Function(String? payload)? onNotificationClick;

  /// Initialize notification service
  Future<void> init() async {
    if (_initialized) return;

    try {
      _initialized = true;

      // Request notification permissions (Android 13+, iOS)
      try {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
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
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageClick(initialMessage);
        }
      } catch (e) {
        debugPrint('Initial message error: $e');
      }

      // Get FCM token (required for topic subscriptions)
      try {
        _fcmToken = await _messaging.getToken();
        if (_fcmToken != null) {
          debugPrint('FCM Token: $_fcmToken');
        } else {
          debugPrint('FCM Token is null');
        }
      } catch (e) {
        debugPrint('FCM token error: $e');
        // Token generation is important for subscriptions, but continue
      }
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
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

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
    return await _messaging.getToken();
  }

  /// Subscribe to a topic
  /// Use topics to send notifications to multiple devices
  Future<void> subscribeToTopic(String topic) async {
    try {
      // Ensure we have FCM token before subscribing
      if (_fcmToken == null) {
        debugPrint('Waiting for FCM token before subscribing to $topic...');
        _fcmToken = await _messaging.getToken();
        if (_fcmToken == null) {
          debugPrint('FCM token still null, cannot subscribe to $topic');
          return;
        }
      }

      // Wait a bit to ensure Firebase Messaging is ready
      await Future.delayed(const Duration(milliseconds: 500));

      await _messaging.subscribeToTopic(topic);
      debugPrint('Successfully subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Failed to subscribe to topic $topic: $e');
      // Don't rethrow - allow app to continue, subscription can retry later
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Request permission for notifications (iOS)
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
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
  Future<void> enableDailyReminders() async {
    if (!_initialized) {
      debugPrint(
        'Notification service not initialized, cannot enable daily reminders',
      );
      return;
    }
    try {
      await subscribeToTopic('daily_reminders');
    } catch (e) {
      debugPrint('Failed to enable daily reminders: $e');
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
}
