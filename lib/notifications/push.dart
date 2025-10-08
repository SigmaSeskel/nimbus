import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

// 🔹 Initialize Firebase Messaging and Local Notifications
final FirebaseMessaging _messaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

/// Called when a notification is received in the background
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  print('💬 Background message: ${message.messageId}');
}

/// Main initialization function — call this in main() before runApp()
Future<void> initPush() async {
  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

  // Request permissions (iOS + Android 13+)
  if (Platform.isIOS) {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // 🔹 Local notifications setup
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
  await _local.initialize(initSettings);

  // 🔹 Get FCM token (you can upload it to Firestore if needed)
  final token = await _messaging.getToken();
  print('📱 FCM Token: $token');

  // 🔹 Listen to foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _local.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nimbus_channel', // channel id
            'Nimbus Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  });
}
