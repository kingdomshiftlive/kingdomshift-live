import 'dart:async';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:upgrader/upgrader.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shortzz/common/controller/firebase_firestore_controller.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/common/widget/restart_widget.dart';
import 'package:shortzz/languages/dynamic_translations.dart';
import 'package:shortzz/screen/splash_screen/splash_screen.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'common/service/network_helper/network_helper.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Loggers.success("Handling a background message: ${message.data}");
  await Firebase.initializeApp();
  if (Platform.isIOS) {
    FirebaseNotificationManager.instance.showNotification(message);
  }
}

Future<void> initializeGogleLogin() async {
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FlutterDownloader.initialize(
      debug: kDebugMode, // false in production
      ignoreSsl: true, // false if URLs have valid SSL
    );
    print('download test FlutterDownloader initialized successfully');
  } catch (e) {
    print('download test FlutterDownloader initialization failed: $e');
  }
  try {
    await Firebase.initializeApp();

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await GetStorage.init('shortzz');
    await GetStorage.init('video_cache_');

    // Init RevenueCat (handle errors gracefully)
    try {
      await SubscriptionManager.shared.initPlatformState();
    } catch (e, st) {
      Loggers.error('SubscriptionManager init error: $e\n$st');
    }
    // Request App Tracking Transparency permission on iOS before initializing ads
    if (Platform.isIOS) {
      // Wait for the first frame to render before showing the ATT dialog
      final trackingStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (trackingStatus == TrackingStatus.notDetermined) {
        // Small delay to ensure the app is fully loaded before showing the dialog
        await Future.delayed(const Duration(milliseconds: 500));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }

    MobileAds.instance.initialize();

    NetworkHelper().initialize();

    // Load Translations
    Get.put(DynamicTranslations(), permanent: true);
    initializeGogleLogin();

    // Run app
    runApp(const RestartWidget(child: MyApp()));
  } catch (e, st) {
    Loggers.error('Fatal crash during app startup $st');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void linkNotification() {
    FirebaseMessaging.instance.subscribeToTopic("all_notifications");
  }

  @override
  void initState() {
    super.initState();
    linkNotification();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Ensure text scaling is locked to 1.0
      builder: (context, child) {
        return UpgradeAlert(
          upgrader: Upgrader(debugLogging: kDebugMode),
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            ),
          ),
        );
      },
      onInit: () {
        Get.put(FirebaseFirestoreController());
      },
      translations: Get.find<DynamicTranslations>(),
      locale: Locale(SessionManager.instance.getLang()),
      fallbackLocale: Locale(SessionManager.instance.getFallbackLang()),
      themeMode: ThemeMode.light,
      darkTheme: ThemeRes.darkTheme(context),
      theme: ThemeRes.lightTheme(context),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
