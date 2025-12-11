import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {

  static late Box hive;
  static const token = "token";
  static const refreshToken = "refresh_token";
  static const accessToken = "access_token";
  static const checkList = "check_list";
  static const firstTime = "first_time";
  static const fcmToken = "fcmToken";
  static const consonantsIndex = "consonantsIndex";
  static const numbersIndex = "numbersIndex";
  static const lat = "lat";
  static const long = "long";
  static const isLogin = "isLogin";
  static const userId = "user_id";
  static const productReferrers = "product_referrers"; // Store referrerId per product

  static Future<void> init() async {
    await Hive.initFlutter();
    hive = await Hive.openBox('kita');
  }

  static bool? get getFirstTime => hive.get(firstTime);

  static bool get getIsLogin => hive.get(isLogin)??false;

  static String? get getRefreshToken => hive.get(refreshToken);

  static String? get getToken => hive.get(token);

  static String? get getAccessToken => hive.get(accessToken);

  static String? get getFcmToken => hive.get(fcmToken);

  static String? get getUserId => hive.get(userId);

  static int? get getConsonantsIndex => hive.get(consonantsIndex);

  static int? get getNumberIndex => hive.get(numbersIndex);

  static Map<String, bool>? get getCheckList => hive.get(checkList);

  static double? get latUser => hive.get(lat);
  static double? get longUser => hive.get(long);

  // Check if popup was shown before
  static bool hasSeenPopup() {
    return hive.get('hasSeenPopup', defaultValue: false);
  }

  // Save that popup was shown
  static void setPopupShown() {
    hive.put('hasSeenPopup', true);
  }

  static Future<void> setFirstTimeState(bool? val) async => await hive.put(firstTime, val);

  static Future<void> setIsLogin(bool? val) async => await hive.put(isLogin, val);

  static Future<void> setRefreshToken(String? val) async => await hive.put(refreshToken, val);

  static Future<void> setToken(String? val) async => await hive.put(token, val);

  static Future<void> setAccessToken(String? val) async => await hive.put(accessToken, val);

  static Future<void> setLat(double? val) async => await hive.put(lat, val);

  static Future<void> setLong(double? val) async => await hive.put(long, val);

  static Future<void> setCheckList(Map<String, bool>? val) async => await hive.put(checkList, val);

  static Future<void> setConsonantsIndex(int? val) async => await hive.put(consonantsIndex, val);

  static Future<void> setNumberIndex(int? val) async => await hive.put(numbersIndex, val);

  static Future<void> setFcmToken(String? val) async => await hive.put(fcmToken, val);

  static Future<void> setUserId(String? val) async => await hive.put(userId, val);

  // Referrer tracking methods
  // Save referrer for a specific product
  static Future<void> setProductReferrer(String productId, String referrerId) async {
    Map<String, dynamic> referrers = getProductReferrers();
    referrers[productId] = {
      'referrerId': referrerId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await hive.put(productReferrers, referrers);
    print('💾 Saved referrer for product $productId: $referrerId');
  }

  // Get referrer for a specific product
  static String? getProductReferrer(String productId) {
    Map<String, dynamic> referrers = getProductReferrers();
    if (referrers.containsKey(productId)) {
      final data = referrers[productId];
      if (data is Map) {
        final timestamp = DateTime.parse(data['timestamp'] as String);
        final now = DateTime.now();
        
        // Referrer link is valid for 30 days
        if (now.difference(timestamp).inDays <= 30) {
          print('📖 Retrieved referrer for product $productId: ${data['referrerId']}');
          return data['referrerId'] as String?;
        } else {
          print('⏰ Referrer for product $productId has expired (>30 days)');
          removeProductReferrer(productId); // Clean up expired referrer
        }
      }
    }
    return null;
  }

  // Get all product referrers
  static Map<String, dynamic> getProductReferrers() {
    final data = hive.get(productReferrers);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  // Remove referrer for a specific product (after order is placed)
  static Future<void> removeProductReferrer(String productId) async {
    Map<String, dynamic> referrers = getProductReferrers();
    referrers.remove(productId);
    await hive.put(productReferrers, referrers);
    print('🗑️ Removed referrer for product $productId');
  }

  // Clear all expired referrers (can be called on app start)
  static Future<void> cleanExpiredReferrers() async {
    Map<String, dynamic> referrers = getProductReferrers();
    final now = DateTime.now();
    bool hasChanges = false;

    referrers.removeWhere((productId, data) {
      if (data is Map && data.containsKey('timestamp')) {
        final timestamp = DateTime.parse(data['timestamp'] as String);
        if (now.difference(timestamp).inDays > 30) {
          print('🧹 Cleaning expired referrer for product $productId');
          hasChanges = true;
          return true;
        }
      }
      return false;
    });

    if (hasChanges) {
      await hive.put(productReferrers, referrers);
      print('✨ Cleaned up expired referrers');
    }
  }

  // Clear all referrers
  static Future<void> clearAllReferrers() async {
    await hive.delete(productReferrers);
    print('🗑️ Cleared all product referrers');
  }

  static Future<void> clearHive() async => await hive.clear();
}
