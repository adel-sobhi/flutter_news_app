import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../features/notifications/domain/entities/notification_entity.dart';
import 'app_navigation.dart';
import 'notification_store.dart';

const String kNewsTopic = 'all_users';

const AndroidNotificationChannel kNewsChannel = AndroidNotificationChannel(
  'news_channel',
  'Breaking News',
  description: 'Notifications when new news arrives',
  importance: Importance.high,
);

@lazySingleton
class FcmService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin localNotifications =
  FlutterLocalNotificationsPlugin();
  final NotificationStore _notificationStore = NotificationStore();

  Future<void> initialize() async {
    try {
      await requestPermission();
      await messaging.setAutoInitEnabled(true);
      await initLocalNotifications();

      String? token = await messaging.getToken();
      debugPrint("==========================================");
      debugPrint("FCM Token: $token");
      debugPrint("==========================================");

      await subscribeToNewsTopic();
      listenToForegroundMessages();
      listenToNotificationTaps();
    } catch (e) {
      debugPrint("Error initializing FCM Service: $e");
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        AppNavigation.handleNotificationPayload(response.payload);
      },
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(kNewsChannel);
  }

  Future<void> subscribeToNewsTopic() async {
    try {
      await messaging.subscribeToTopic(kNewsTopic);
      debugPrint("Successfully subscribed to topic: $kNewsTopic");
    } catch (e) {
      debugPrint("Failed to subscribe to topic: $e");
    }
  }

  Future<void> _saveIncomingNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Breaking News';
    final body = message.notification?.body ??
        message.data['body'] ??
        'New article available';
    final url = message.data['url']?.toString();
    final imageUrl = message.data['imageUrl']?.toString();

    final notification = NotificationEntity(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      url: url,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    await _notificationStore.addNotification(notification);
  }

  void listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _saveIncomingNotification(message);

      final notification = message.notification;
      if (notification == null) return;

      final payload = jsonEncode({
        'title': notification.title ?? message.data['title'] ?? 'Breaking News',
        'body': notification.body ??
            message.data['body'] ??
            'New article available',
        'url': message.data['url']?.toString(),
        'imageUrl': message.data['imageUrl']?.toString(),
      });

      await localNotifications.show(
        id: notification.hashCode,
        title: notification.title ?? 'Breaking News',
        body: notification.body ?? 'New article available',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            kNewsChannel.id,
            kNewsChannel.name,
            channelDescription: kNewsChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    });
  }

  void listenToNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload = jsonEncode({
        'title': message.notification?.title ??
            message.data['title'] ??
            'Breaking News',
        'body': message.notification?.body ??
            message.data['body'] ??
            'New article available',
        'url': message.data['url']?.toString(),
        'imageUrl': message.data['imageUrl']?.toString(),
      });
      AppNavigation.handleNotificationPayload(payload);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) return;
      final payload = jsonEncode({
        'title': message.notification?.title ??
            message.data['title'] ??
            'Breaking News',
        'body': message.notification?.body ??
            message.data['body'] ??
            'New article available',
        'url': message.data['url']?.toString(),
        'imageUrl': message.data['imageUrl']?.toString(),
      });
      AppNavigation.handleNotificationPayload(payload);
    });
  }
}
