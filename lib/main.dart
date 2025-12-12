import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/io_client.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/core/model/my_profile_model.dart';
import 'package:arif_mart/core/services/chat_service.dart';
import 'package:arif_mart/core/services/ecommerce_service.dart';
import 'package:arif_mart/core/services/recharge_service.dart';
import 'package:arif_mart/core/services/address_service.dart';
import 'package:arif_mart/core/services/order_service.dart';
import 'package:arif_mart/core/services/rated_products_service.dart';
import 'package:arif_mart/core/services/deep_link_service.dart';
import 'package:arif_mart/core/utils/timezone_util.dart';
import 'package:arif_mart/src/screens/Service/shoping/wishlist/controller/wishlist_controller.dart';
import 'package:arif_mart/src/screens/Service/shoping/controller/shopping_controller.dart';

import 'core/constants/routes/pages.dart';
import 'core/constants/routes/routes.dart';

import 'core/helper/notification_service.dart';
import 'firebase_options.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // You can add custom validation logic here if needed
        print('Allowing self-signed certificate: $host');
        return true; // Always allow
      };
  }
}

Future<bool> checkUserIsLogin() async {
  if (HiveHelper.getIsLogin) {
    try {
      MyProfileModel? response = await Repository.getMyProfile();
      if (response?.data != null) {
        // If user is active, allow login regardless of verification status
        // This allows unverified users to access payment screen
        if (response!.data!.isActive == true) {
          return true;
        }
        // If user is verified and active, also allow login
        return (response.data!.isVerified ?? false) &&
            (response.data!.isActive ?? false);
      }
      return false;
    } catch (e) {
      // If there's an error (like 401, token expired), clear login state and return false
      print('Error checking user login status: $e');
      await HiveHelper.setIsLogin(false);
      return false;
    }
  } else {
    return false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Initialize Hive (fast local storage)
  await HiveHelper.init();

  // Clean up expired referrer links in background (non-blocking)
  HiveHelper.cleanExpiredReferrers().catchError(
    (e) => print('Error cleaning referrers: $e'),
  );

  // Log timezone information for debugging
  _logTimezoneDebugInfo();

  // Initialize Firebase synchronously (required for proper initialization)
  await _initializeFirebase();

  // Initialize services lazily (only when needed)
  _initializeServicesLazily();

  // Initialize deep link service immediately (required for deep links)
  print('🔗 Initializing DeepLinkService...');
  await Get.putAsync(() => DeepLinkService().init());
  print('✅ DeepLinkService initialized successfully');

  // Check login status from local storage first (fast)
  bool isLogin = HiveHelper.getIsLogin;

  // Start the app immediately
  runApp(MyApp(initialRoute: isLogin ? Routes.home : Routes.login));

  // Verify login status in background (non-blocking)
  _verifyLoginStatusInBackground();
}

// Initialize Firebase synchronously
// Shared future to ensure Firebase initializeApp is only invoked once
Future<void>? _firebaseInitFuture;

Future<void> _initializeFirebase() {
  // If initialization already in progress/complete, return the same future
  if (_firebaseInitFuture != null) return _firebaseInitFuture!;

  _firebaseInitFuture = () async {
    try {
      // Double-check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        print('🔥 Initializing Firebase...');
        if (kIsWeb) {
          // On web we must supply options
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } else {
          // On mobile platforms, prefer default native initialization
          // Calling initializeApp() without options lets the native side use google-services config
          await Firebase.initializeApp();
        }
        print('✅ Firebase initialized successfully');
      } else {
        print('✅ Firebase already initialized (${Firebase.apps.length} apps)');
      }

      // Set up background message handler only once
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      print('✅ Background message handler set up');

      // Initialize notification service
      await NotificationService().init();
      print('✅ Notification service initialized');
    } on FirebaseException catch (e) {
      // Handle duplicate-app safely and continue
      final code = e.code ?? '';
      if (code.contains('duplicate') ||
          e.message?.contains('already exists') == true) {
        print('⚠️ Duplicate Firebase app detected, safe to continue: $e');
      } else {
        print('❌ Firebase initialization failed (FirebaseException): $e');
      }
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      print('⚠️ Continuing without Firebase...');
    }
  }();

  return _firebaseInitFuture!;
}

// Initialize services lazily
void _initializeServicesLazily() {
  // Initialize only essential services immediately
  Get.put(EcommerceService());
  Get.put(OrderService()); // OrderService needed by OrderController
  Get.put(AddressService()); // AddressService needed by OrderController

  // Initialize other services lazily (when first accessed)
  Get.lazyPut(() => ChatService());
  Get.lazyPut(() => RechargeService());
  Get.lazyPut(() => RatedProductsService());

  // Initialize WishlistController immediately (needed for heart icons)
  Get.put(WishlistController());

  // Initialize ShoppingController immediately (needed by ProductDetailController)
  Get.put(ShoppingController());
}

// Verify login status in background
void _verifyLoginStatusInBackground() async {
  try {
    bool isActuallyLogin = await checkUserIsLogin();
    if (isActuallyLogin != HiveHelper.getIsLogin) {
      // If login status changed, update the app state
      print('🔄 Login status changed, updating app state');
      // You can add logic here to update the app state if needed
    }
  } catch (e) {
    print('❌ Error verifying login status: $e');
  }
}

// Log timezone debug information at app startup
void _logTimezoneDebugInfo() {
  try {
    final now = DateTime.now();
    final utc = now.toUtc();
    final offset = now.timeZoneOffset;

    print('\n');
    print('🕒 TIMEZONE DEBUG INFO AT APP STARTUP:');
    print('📱 Local time: $now (${now.hour}:${now.minute})');
    print('🌐 UTC time: $utc (${utc.hour}:${utc.minute})');
    print('🔀 Device offset: ${offset.inHours}h ${offset.inMinutes % 60}m');
    print(
      '🌐 Is Bangladesh timezone (GMT+6): ${offset.inHours == 6 ? "YES" : "NO"}',
    );

    // Example UTC string with Z suffix
    final exampleTime = "2023-10-22T13:30:00.000Z"; // Time with Z suffix

    // 1. Parse with standard method (interprets Z as UTC)
    final parsedStandard = DateTime.parse(exampleTime);

    // 2. Parse with our custom method (ignores Z suffix)
    final parsedCustom = TimezoneUtil.parseAsLocalTime(exampleTime);

    print('\n🔄 TIMEZONE HANDLING COMPARISON:');
    print('   Original string: $exampleTime');
    print(
      '   Standard parsing: $parsedStandard (Hour: ${parsedStandard.hour})',
    );
    print(
      '   Custom parsing (ignoring Z): $parsedCustom (Hour: ${parsedCustom?.hour})',
    );

    // Show the practical difference between the two
    if (parsedCustom != null) {
      final hourDifference = parsedCustom.hour - parsedStandard.hour;
      print('   Hour difference: $hourDifference hour(s)');
    }

    // Flash sale active comparison example
    final exampleStartTime = "2023-10-22T08:00:00.000Z";
    final exampleEndTime = "2023-10-22T20:00:00.000Z";

    // Standard parsing (with timezone conversion)
    final standardStart = DateTime.parse(exampleStartTime);
    final standardEnd = DateTime.parse(exampleEndTime);
    final isActiveStandard =
        now.isAfter(standardStart) && now.isBefore(standardEnd);

    // Custom parsing (ignoring timezone)
    final customStart = TimezoneUtil.parseAsLocalTime(exampleStartTime);
    final customEnd = TimezoneUtil.parseAsLocalTime(exampleEndTime);
    final isActiveCustom =
        customStart != null &&
        customEnd != null &&
        now.isAfter(customStart) &&
        now.isBefore(customEnd);

    print('\n🛒 FLASH SALE ACTIVE EXAMPLE:');
    print('   Current hour: ${now.hour}');
    print(
      '   Standard parsing: Start ${standardStart.hour}h, End ${standardEnd.hour}h → Active: $isActiveStandard',
    );
    print(
      '   Custom parsing: Start ${customStart?.hour ?? "N/A"}h, End ${customEnd?.hour ?? "N/A"}h → Active: $isActiveCustom',
    );

    print('\n💡 IMPORTANT: Our implementation now ignores the Z suffix');
    print('💡 All times are treated as local time regardless of Z suffix');
    print(
      '💡 This ensures consistent time comparison in Bangladesh timezone (GMT+6)',
    );
    print('\n');
  } catch (e) {
    print('❌ Error logging timezone debug info: $e');
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  Future<bool> checkUserIsLogin() async {
    MyProfileModel? response = await Repository.getMyProfile();
    return response?.data?.isVerified ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Arif Mart',
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      initialRoute: initialRoute,
      // Add unique navigator key to prevent conflicts
      navigatorKey: Get.key,
      // Prevent multiple navigators
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(body: Center(child: Text('Page Not Found'))),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        // Use system font initially, Google Fonts will load in background
        fontFamily: 'Roboto',
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Colors.white,
        ),
      ),
      builder: (context, child) {
        final data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaler: const TextScaler.linear(1)),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
