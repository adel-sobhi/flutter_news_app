import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart';

/// لازم يكون top-level function (مش جوه أي class) عشان FCM يقدر
/// ينادّيه من isolate منفصل لما التطبيق يكون مقفول تمامًا (terminated).
///
/// الـ isolate ده منفصل عن main()، فمحتاجين نعمل Firebase.initializeApp()
/// تاني هنا حتى لو اتعمل قبل كده في main().
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // مفيش حاجة تانية مطلوبة هنا - نظام التشغيل هو اللي بيعرض
  // الإشعار تلقائيًا لما التطبيق يكون في background/terminated،
  // طالما الـ message فيه "notification" payload (وده اللي سكريبت
  // الـ GitHub Action بيبعته).
}
