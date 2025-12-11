import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/src/screens/home_screen/controller/home_controller.dart';
import '../../../../../firebase_options.dart';
class NotificationService {

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _fcm.requestPermission();

    String? token = await _fcm.getToken();
    HiveHelper.setFcmToken(token);

    //Init local notifications
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("``````````````````````````````````````onMessage: ${message.toMap()}");
      final homeIsRegistered = Get.isRegistered<HomeController>();
      if(homeIsRegistered && message.data['type'] == 'topup'){
        Get.find<HomeController>().getWallet();
      }

      showNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("`````````````````````````````````````onMessageOpenedApp: ${message.toMap()}");
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      priority: Priority.high
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // In background isolates, Firebase might not be initialized. Initialize if needed.
  try {
    if (Firebase.apps.isEmpty) {
      // Use DefaultFirebaseOptions if available; wrap in try to avoid exceptions
      try {
        if (kIsWeb) {
          await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        } else {
          await Firebase.initializeApp();
        }
      } catch (e) {
        // ignore initialization errors in background handler
        print('⚠️ Background isolate Firebase init error (ignored): $e');
      }
    }
  } catch (e) {
    print('⚠️ Error checking Firebase.apps in background: $e');
  }

  print('````````````````````````````````````````Handling background message: ${message.messageId}');
}