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
  final NotificationStore notificationStore = NotificationStore();

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

  static String? _readStringValue(
      Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null || value is Map || value is List) continue;
      final text = value.toString();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static String? _readSourceOrCategoryId(
      Map<String, dynamic> data, List<String> keys) {
    final direct = _readStringValue(data, keys);
    if (direct != null && direct.isNotEmpty) return direct;

    final sourceData = data['source'];
    if (sourceData is Map) {
      for (final key in ['id', 'sourceId', 'source_id']) {
        if (sourceData[key] != null) {
          final value = sourceData[key].toString();
          if (value.isNotEmpty) return value;
        }
      }
    }

    final categoryData = data['category'];
    if (categoryData is Map) {
      for (final key in ['id', 'categoryId', 'category_id']) {
        if (categoryData[key] != null) {
          final value = categoryData[key].toString();
          if (value.isNotEmpty) return value;
        }
      }
    }

    return null;
  }

  Future<void> saveIncomingNotification(RemoteMessage message) async {
    final data = message.data;
    final title = _readStringValue(data, ['title']) ??
        message.notification?.title ??
        'Breaking News';
    final body = _readStringValue(data, ['body']) ??
        message.notification?.body ??
        'New article available';
    final url = _readStringValue(data, ['url', 'articleUrl']);
    final imageUrl = _readStringValue(data, ['imageUrl', 'image_url']);
    final sourceId =
        _readSourceOrCategoryId(data, ['sourceId', 'source_id', 'source']);
    final categoryId = _readSourceOrCategoryId(
        data, ['categoryId', 'category_id', 'category']);
    final author = _readStringValue(data, ['author']);
    final publishedAt = _readStringValue(data, ['publishedAt', 'published_at']);
    final description = _readStringValue(data, ['description']);
    final content = _readStringValue(data, ['content']);
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

    await notificationStore.addNotification(notification);

    await updateBadgeCount();
  }

  void listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await saveIncomingNotification(message);

      final notification = message.notification;
      if (notification == null) return;

      final unreadCount = await notificationStore.getUnreadCount();

      final payload = jsonEncode({
        'id': message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}',
        'title': _readStringValue(message.data, ['title']) ??
            notification.title ??
            'Breaking News',
        'body': _readStringValue(message.data, ['body']) ??
            notification.body ??
            'New article available',
        'url': _readStringValue(message.data, ['url', 'articleUrl']),
        'imageUrl': _readStringValue(message.data, ['imageUrl', 'image_url']),
        'sourceId': _readSourceOrCategoryId(
          message.data,
          ['sourceId', 'source_id', 'source'],
        ),
        'categoryId': _readSourceOrCategoryId(
          message.data,
          ['categoryId', 'category_id', 'category'],
        ),
        'author': _readStringValue(message.data, ['author']),
        'publishedAt':
            _readStringValue(message.data, ['publishedAt', 'published_at']),
        'description': _readStringValue(message.data, ['description']),
        'content': _readStringValue(message.data, ['content']),
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

      await updateBadgeCount();
    });
  }

  void listenToNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload = jsonEncode({
        'id': message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}',
        'title': _readStringValue(message.data, ['title']) ??
            message.notification?.title ??
            'Breaking News',
        'body': _readStringValue(message.data, ['body']) ??
            message.notification?.body ??
            'New article available',
        'url': _readStringValue(message.data, ['url', 'articleUrl']),
        'imageUrl': _readStringValue(message.data, ['imageUrl', 'image_url']),
        'sourceId': _readSourceOrCategoryId(
          message.data,
          ['sourceId', 'source_id', 'source'],
        ),
        'categoryId': _readSourceOrCategoryId(
          message.data,
          ['categoryId', 'category_id', 'category'],
        ),
        'author': _readStringValue(message.data, ['author']),
        'publishedAt':
            _readStringValue(message.data, ['publishedAt', 'published_at']),
        'description': _readStringValue(message.data, ['description']),
        'content': _readStringValue(message.data, ['content']),
      });
      AppNavigation.handleNotificationPayload(payload);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message == null) return;
      final payload = jsonEncode({
        'id': message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}',
        'title': _readStringValue(message.data, ['title']) ??
            message.notification?.title ??
            'Breaking News',
        'body': _readStringValue(message.data, ['body']) ??
            message.notification?.body ??
            'New article available',
        'url': _readStringValue(message.data, ['url', 'articleUrl']),
        'imageUrl': _readStringValue(message.data, ['imageUrl', 'image_url']),
        'sourceId': _readSourceOrCategoryId(
          message.data,
          ['sourceId', 'source_id', 'source'],
        ),
        'categoryId': _readSourceOrCategoryId(
          message.data,
          ['categoryId', 'category_id', 'category'],
        ),
        'author': _readStringValue(message.data, ['author']),
        'publishedAt':
            _readStringValue(message.data, ['publishedAt', 'published_at']),
        'description': _readStringValue(message.data, ['description']),
        'content': _readStringValue(message.data, ['content']),
      });
      AppNavigation.handleNotificationPayload(payload);
    });
  }

  Future<void> updateBadgeCount() async {
    try {
      final unread = await notificationStore.getUnreadCount();
      debugPrint('Unread notifications: $unread');
    } catch (e) {
      debugPrint('Failed to compute unread count: $e');
    }
  }
}
