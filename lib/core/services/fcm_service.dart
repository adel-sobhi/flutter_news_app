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
    final title = message.data['title']?.toString() ??
        message.notification?.title ??
        'Breaking News';
    final body = message.data['body']?.toString() ??
        message.notification?.body ??
        'New article available';
    final url = message.data['url']?.toString();
    final imageUrl = message.data['imageUrl']?.toString();
    final sourceId = message.data['sourceId']?.toString() ??
        message.data['source_id']?.toString();
    final categoryId = message.data['categoryId']?.toString() ??
        message.data['category_id']?.toString();
    final author = message.data['author']?.toString();
    final publishedAt = message.data['publishedAt']?.toString();
    final description = message.data['description']?.toString();
    final content = message.data['content']?.toString();
    final notificationId =
        message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}';

    final notification = NotificationEntity(
      id: notificationId,
      title: title,
      body: body,
      url: url,
      imageUrl: imageUrl,
      sourceId: sourceId,
      categoryId: categoryId,
      author: author,
      publishedAt: publishedAt,
      description: description,
      content: content,
      createdAt: DateTime.now(),
    );

    await _notificationStore.addNotification(notification);

    // update app badge to reflect new unread count
    await updateBadgeCount();
  }

  void listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _saveIncomingNotification(message);

      final notification = message.notification;
      if (notification == null) return;

      final unreadCount = await _notificationStore.getUnreadCount();

      final payload = jsonEncode({
        'id': message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}',
        'title': message.data['title']?.toString() ??
            notification.title ??
            'Breaking News',
        'body': message.data['body']?.toString() ??
            notification.body ??
            'New article available',
        'url': message.data['url']?.toString(),
        'imageUrl': message.data['imageUrl']?.toString(),
        'sourceId': message.data['sourceId']?.toString() ??
            message.data['source_id']?.toString(),
        'categoryId': message.data['categoryId']?.toString() ??
            message.data['category_id']?.toString(),
        'author': message.data['author']?.toString(),
        'publishedAt': message.data['publishedAt']?.toString(),
        'description': message.data['description']?.toString(),
        'content': message.data['content']?.toString(),
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
            // set number so some Android launchers show badge counts
            number: unreadCount,
          ),
          iOS: DarwinNotificationDetails(badgeNumber: unreadCount),
        ),
        payload: payload,
      );

      // Also try to set the iOS app badge explicitly
      await updateBadgeCount();
    });
  }

  void listenToNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload = jsonEncode({
        'id': message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}',
        'title': message.data['title']?.toString() ??
            message.notification?.title ??
            'Breaking News',
        'body': message.data['body']?.toString() ??
            message.notification?.body ??
            'New article available',
        'url': message.data['url']?.toString(),
        'imageUrl': message.data['imageUrl']?.toString(),
        'sourceId': message.data['sourceId']?.toString() ??
            message.data['source_id']?.toString(),
        'categoryId': message.data['categoryId']?.toString() ??
            message.data['category_id']?.toString(),
        'author': message.data['author']?.toString(),
        'publishedAt': message.data['publishedAt']?.toString(),
        'description': message.data['description']?.toString(),
        'content': message.data['content']?.toString(),
      });
      AppNavigation.handleNotificationPayload(payload);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message == null) return;
      final payload = jsonEncode({
        'id': message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}',
        'title': message.data['title']?.toString() ??
            message.notification?.title ??
            'Breaking News',
        'body': message.data['body']?.toString() ??
            message.notification?.body ??
            'New article available',
        'url': message.data['url']?.toString(),
        'imageUrl': message.data['imageUrl']?.toString(),
        'sourceId': message.data['sourceId']?.toString() ??
            message.data['source_id']?.toString(),
        'categoryId': message.data['categoryId']?.toString() ??
            message.data['category_id']?.toString(),
        'author': message.data['author']?.toString(),
        'publishedAt': message.data['publishedAt']?.toString(),
        'description': message.data['description']?.toString(),
        'content': message.data['content']?.toString(),
      });
      AppNavigation.handleNotificationPayload(payload);
    });
  }

  /// Update the app badge (no-op fallback).
  /// Setting the system app icon badge reliably requires a dedicated package
  /// (e.g., flutter_app_badger) or native platform code. For now this logs
  /// the unread count so behavior is predictable and compilation succeeds.
  Future<void> updateBadgeCount() async {
    try {
      final unread = await _notificationStore.getUnreadCount();
      debugPrint('Unread notifications: $unread');
    } catch (e) {
      debugPrint('Failed to compute unread count: $e');
    }
  }
}
