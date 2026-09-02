import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/di.dart';
import 'core/services/fcm_background_handler.dart';
import 'core/services/fcm_service.dart';
import 'features/authentication/presentation/cubit/auth_cubit.dart';
import 'features/authentication/presentation/pages/splash_screen.dart';
import 'features/news/presentation/cubit/news_cubit.dart';
import 'features/sources/presentation/cubit/sources_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());

  initBackgroundServices();
}

void initBackgroundServices() async {
  try {
    await configureDependencies();
    await dotenv.load(fileName: ".env");
    await getIt<FcmService>().initialize();
  } catch (e) {
    debugPrint("Error initializing background services: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => getIt<AuthCubit>()),
        BlocProvider<SourcesCubit>(create: (context) => getIt<SourcesCubit>()),
        BlocProvider<NewsCubit>(create: (context) => getIt<NewsCubit>()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}