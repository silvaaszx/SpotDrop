/// Local notification service.
///
/// Initialises channels and provides [show] / [onTap] hooks used
/// by the geofence trigger flow and the deep-link router.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Callback invoked when the user taps a notification.
  /// Set by the app's router so it can navigate to the right screen.
  void Function(int taskId)? onNotificationTapped;

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _handleTap,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'geofence_alerts',
              'Geofence Alerts',
              description: 'Triggered when you enter a task zone.',
              importance: Importance.high,
            ),
          );
    }
  }

  void _handleTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    final taskId = int.tryParse(payload);
    if (taskId != null) {
      onNotificationTapped?.call(taskId);
    }
  }

  /// Show a local notification triggered by a geofence event.
  Future<void> showGeofenceAlert({
    required int taskId,
    required String title,
    String? body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'geofence_alerts',
      'Geofence Alerts',
      channelDescription: 'Triggered when you enter a task zone.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF00D4AA),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      taskId,
      title,
      body ?? 'Tap to view your task.',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: taskId.toString(),
    );
  }
}
