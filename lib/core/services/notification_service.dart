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

  // Callback for handling notification clicks (set from main.dart)
  void Function(String? payload)? onNotificationClick;

  /// Initialize notification service
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Request notification permissions (Android 13+, iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Notification clicked when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);

    // Handle notification that opened the app from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageClick(initialMessage);
    }

    // Optional: log FCM token
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
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
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
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
    await subscribeToTopic('daily_reminders');
  }

  /// Unsubscribe from daily reminders
  Future<void> disableDailyReminders() async {
    await unsubscribeFromTopic('daily_reminders');
  }

  /// Subscribe to streak alerts topic
  Future<void> enableStreakAlerts() async {
    await subscribeToTopic('streak_alerts');
  }

  /// Unsubscribe from streak alerts
  Future<void> disableStreakAlerts() async {
    await unsubscribeFromTopic('streak_alerts');
  }
}
