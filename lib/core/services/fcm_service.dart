import 'package:firebase_messaging/firebase_messaging.dart';
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
    await _requestPermission();
    await _initLocalNotifications();
    await _subscribeToNewsTopic();
    _listenToForegroundMessages();
    _listenToNotificationTaps();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
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

    // استخدام الباراميتر المسمى settings حسب إصدار حزمتك
    await _localNotifications.initialize(
      settings: initSettings,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(kNewsChannel);
  }

  Future<void> _subscribeToNewsTopic() async {
    await _messaging.subscribeToTopic(kNewsTopic);
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      // استخدام الباراميترات المسمى لعرض الإشعار
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
