import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

const String kNewsTopic = 'all_users';

const AndroidNotificationChannel kNewsChannel = AndroidNotificationChannel(
  'news_channel',
  'أخبار عاجلة',
  description: 'إشعارات عند وصول خبر جديد',
  importance: Importance.high,
);

@lazySingleton
class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      await _requestPermission();
      await _messaging.setAutoInitEnabled(true);
      await _initLocalNotifications();

      // طباعة التوكن عشان تقدر تجربه يدوي من فايربيز كونسول
      String? token = await _messaging.getToken();
      debugPrint("==========================================");
      debugPrint("FCM Token: $token");
      debugPrint("==========================================");

      await _subscribeToNewsTopic();
      _listenToForegroundMessages();
      _listenToNotificationTaps();
    } catch (e) {
      debugPrint("Error initializing FCM Service: $e");
    }
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
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

    await _localNotifications.initialize(
      settings: initSettings,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(kNewsChannel);
  }

  Future<void> _subscribeToNewsTopic() async {
    try {
      await _messaging.subscribeToTopic(kNewsTopic);
      debugPrint("Successfully subscribed to topic: $kNewsTopic");
    } catch (e) {
      debugPrint("Failed to subscribe to topic: $e");
    }
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'news_channel',
            'أخبار عاجلة',
            channelDescription: 'إشعارات عند وصول خبر جديد',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['url'],
      );
    });
  }

  void _listenToNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final newsUrl = message.data['url'];
      // TODO: يمكنك توجيه المستخدم لصفحة التفاصيل هنا باستخدام newsUrl
    });
  }
}