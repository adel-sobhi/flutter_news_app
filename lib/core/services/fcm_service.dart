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
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      await requestPermission();
      await messaging.setAutoInitEnabled(true);
      await initLocalNotifications();

      // طباعة التوكن عشان تقدر تجربه يدوي من فايربيز كونسول
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

  void listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      localNotifications.show(
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

  void listenToNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final newsUrl = message.data['url'];
    });
  }
}