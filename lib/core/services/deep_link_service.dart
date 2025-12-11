import 'dart:async';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'package:arif_mart/core/helper/hive_helper.dart';
import 'package:arif_mart/src/screens/Service/shoping/product_detail/controller/product_detail_controller.dart';

class DeepLinkService extends GetxService {
  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;
  
  Future<DeepLinkService> init() async {
    print('🔗 DeepLinkService: Starting initialization...');
    _appLinks = AppLinks();
    print('🔗 DeepLinkService: AppLinks created');
    
    // Handle initial link when app is opened from terminated state
    try {
      print('🔗 DeepLinkService: Checking for initial link...');
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('📱 Initial deep link: $initialUri');
        _handleDeepLink(initialUri);
      } else {
        print('🔗 DeepLinkService: No initial link found');
      }
    } catch (e) {
      print('❌ Error getting initial link: $e');
    }
    
    // Handle links when app is running in background or foreground
    print('🔗 DeepLinkService: Setting up link stream listener...');
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      print('📱 Received deep link: $uri');
      _handleDeepLink(uri);
    }, onError: (err) {
      print('❌ Error listening to link stream: $err');
    });
    
    print('✅ DeepLinkService: Initialization complete');
    return this;
  }
  
  // Refresh product data when already on the same product page
  void _refreshProductData(String productId, String? referrerId) async {
    try {
      print('🔄 Refreshing product data for: $productId');
      
      // Save referrerId if provided
      if (referrerId != null && referrerId.isNotEmpty) {
        await HiveHelper.setProductReferrer(productId, referrerId);
        print('💾 Updated referrer in localStorage: $referrerId');
      }
      
      // Trigger a refresh of the current product detail controller
      // This will cause the controller to reload the product data
      Get.find<ProductDetailController>().refreshProduct();
      
    } catch (e) {
      print('❌ Error refreshing product data: $e');
    }
  }
  
  Future<void> _handleDeepLink(Uri uri) async {
    try {
      print('🔗 Parsing URI - Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
      
  // Handle arifmart://products/{productId}?ref={userId}
  if (uri.scheme == 'arifmart' && uri.host == 'products') {
        // Extract product ID from path
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final productId = pathSegments[0];
          final referrerId = uri.queryParameters['ref'];
          
          print('✅ Navigating to product: $productId, Referrer: $referrerId');
          
          // Save referrerId to local storage for this product
          if (referrerId != null && referrerId.isNotEmpty) {
            await HiveHelper.setProductReferrer(productId, referrerId);
            print('💾 Saved referrer to localStorage for product: $productId');
          }
          
          // Navigate to product detail screen
          print('🚀 Navigating to product detail with ID: $productId');
          
          // Add a small delay to ensure app is fully initialized
          await Future.delayed(const Duration(milliseconds: 1000));
          
          // Use a more robust navigation approach
          try {
            // Check if we're already on the product detail page with the same product
            if (Get.currentRoute == Routes.productDetail) {
              final currentArgs = Get.arguments;
              if (currentArgs != null && 
                  currentArgs is Map && 
                  currentArgs['productId'] == productId) {
                print('⚠️ Already on same product detail page, refreshing data');
                // Refresh the product data instead of navigating
                _refreshProductData(productId, referrerId);
                return;
              }
            }
            
            // Use toNamed instead of offAllNamed to preserve navigation stack
            Get.toNamed(
              Routes.productDetail,
              arguments: {
                'productId': productId,
                'referrerId': referrerId, // Optional: track referrer
              },
            );
            print('✅ Navigation command sent with toNamed');
          } catch (e) {
            print('❌ Navigation error: $e');
            // Fallback: use offAllNamed if toNamed fails
            try {
              Get.offAllNamed(
                Routes.productDetail,
                arguments: {
                  'productId': productId,
                  'referrerId': referrerId, // Optional: track referrer
                },
              );
              print('✅ Navigation command sent with offAllNamed (fallback)');
            } catch (fallbackError) {
              print('❌ Fallback navigation also failed: $fallbackError');
            }
          }
        } else {
          print('⚠️ No product ID in path segments');
        }
      }
      // Handle arifmart://login -> navigate to login screen
      else if (uri.scheme == 'arifmart' && uri.host == 'login') {
        print('✅ Deep link to login detected');
        try {
          // Give app time to initialize
          await Future.delayed(const Duration(milliseconds: 500));
          Get.toNamed(Routes.login);
          print('✅ Navigated to login route');
        } catch (e) {
          print('❌ Navigation to login failed: $e');
        }
      }
      // Handle https://yourdomain.com/products/{productId}?ref={userId}
      else if (uri.scheme == 'https' && uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'products') {
        if (uri.pathSegments.length > 1) {
          final productId = uri.pathSegments[1];
          final referrerId = uri.queryParameters['ref'];
          
          print('✅ Navigating to product via HTTPS: $productId, Referrer: $referrerId');
          
          // Save referrerId to local storage for this product
          if (referrerId != null && referrerId.isNotEmpty) {
            await HiveHelper.setProductReferrer(productId, referrerId);
            print('💾 Saved referrer to localStorage for product: $productId');
          }
          
          Get.toNamed(
            Routes.productDetail,
            arguments: {
              'productId': productId,
              'referrerId': referrerId,
            },
          );
        }
      } else {
        print('⚠️ Unhandled deep link format: $uri');
      }
    } catch (e) {
      print('❌ Error handling deep link: $e');
    }
  }
  
  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
