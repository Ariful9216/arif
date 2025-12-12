import 'package:get/get.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/core/model/wishlist_model.dart';
import 'package:arif_mart/core/services/ecommerce_service.dart';

class WishlistController extends GetxController {
  late EcommerceService _ecommerceService;

  // Wishlist state - Updated for new API structure
  final RxList<WishlistItem> wishlistItems = <WishlistItem>[].obs;
  final RxList<ProductData> wishlistProducts = <ProductData>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreProducts = true.obs;
  final RxInt totalCount = 0.obs;

  // New wishlist data
  final Rx<WishlistPagination?> pagination = Rx<WishlistPagination?>(null);
  final Rx<WishlistSummary?> summary = Rx<WishlistSummary?>(null);
  final Rx<WishlistStatsData?> stats = Rx<WishlistStatsData?>(null);

  // Track individual product wishlist status
  final RxMap<String, bool> productWishlistStatus = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    print("❤️  WishlistController initializing...");
    _ecommerceService = Get.find<EcommerceService>();

    // Load data in the background without waiting
    print("📋 Starting background wishlist loading...");
    Future.microtask(() async {
      try {
        print("📝 Loading wishlist...");
        await loadWishlist()
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () => print("⏱️ loadWishlist timeout"),
            )
            .catchError((e) => print("❌ loadWishlist error: $e"));
      } catch (e) {
        print("❌ Unexpected error in loadWishlist: $e");
      }
    });

    Future.microtask(() async {
      try {
        print("🔢 Getting wishlist count...");
        await getWishlistCount()
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () => print("⏱️ getWishlistCount timeout"),
            )
            .catchError((e) => print("❌ getWishlistCount error: $e"));
      } catch (e) {
        print("❌ Unexpected error in getWishlistCount: $e");
      }
    });

    // Initialize wishlist status in the background
    Future.microtask(() async {
      try {
        print("🏷️  Initializing wishlist status...");
        await _initializeWishlistStatus()
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () => print("⏱️ _initializeWishlistStatus timeout"),
            )
            .catchError((e) => print("❌ _initializeWishlistStatus error: $e"));
      } catch (e) {
        print("❌ Unexpected error in _initializeWishlistStatus: $e");
      }
    });

    print(
      "✅ WishlistController initialization complete (data loading in background)",
    );
  }

  // Initialize wishlist status for all products in the wishlist
  Future<void> _initializeWishlistStatus() async {
    try {
      final response = await _ecommerceService.getUserWishlist(
        page: 1,
        limit: 100,
      );
      if (response != null && response['success'] == true) {
        final messageData = response['message'];
        List<dynamic> items = [];
        if (messageData is Map && messageData['wishlistItems'] != null) {
          items = messageData['wishlistItems'];
        }

        // Mark all wishlist products as true in our reactive map
        for (var item in items) {
          if (item != null &&
              item['product'] != null &&
              item['product']['_id'] != null) {
            final productId = item['product']['_id'].toString();
            productWishlistStatus[productId] = true;
          }
        }
        productWishlistStatus.refresh();
      }
    } catch (e) {
      // Gracefully handle errors (401 unauthorized, network issues, etc.)
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        print(
          '⚠️ Wishlist: Authentication error (401) - User session may have expired',
        );
        // Don't crash the app, just skip wishlist initialization
      } else {
        print('⚠️ Wishlist initialization error: $e');
      }
    }
  }

  // Load wishlist products
  Future<void> loadWishlist({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMoreProducts.value = true;
        errorMessage.value = '';
      }

      if (currentPage.value == 1) {
        isLoading.value = true;
        wishlistProducts.clear();
      } else {
        isLoadingMore.value = true;
      }

      final response = await _ecommerceService.getUserWishlist(
        page: currentPage.value,
        limit: 20,
        sortBy: 'addedAt',
        sortOrder: 'desc',
      );

      if (response != null && response['success'] == true) {
        // Handle the new API response structure
        final data = response['data'];

        if (data != null) {
          // Parse wishlist items
          List<dynamic> items = data['wishlistItems'] ?? [];
          List<WishlistItem> newWishlistItems = [];
          List<ProductData> newProducts = [];

          for (var item in items) {
            try {
              WishlistItem wishlistItem = WishlistItem.fromJson(item);
              newWishlistItems.add(wishlistItem);
              newProducts.add(wishlistItem.product);

              // Update wishlist status
              final productId = wishlistItem.product.id;
              productWishlistStatus[productId] = true;
            } catch (e) {
              print('Error parsing wishlist item: $e');
              // Skip this item and continue with the next one
              continue;
            }
          }

          if (refresh) {
            wishlistItems.value = newWishlistItems;
            wishlistProducts.value = newProducts;
          } else {
            wishlistItems.addAll(newWishlistItems);
            wishlistProducts.addAll(newProducts);
          }

          // Update pagination
          if (data['pagination'] != null) {
            pagination.value = WishlistPagination.fromJson(data['pagination']);
            hasMoreProducts.value = pagination.value?.hasNextPage ?? false;
            totalCount.value =
                pagination.value?.totalItems ?? wishlistItems.length;
          }

          // Update summary
          if (data['summary'] != null) {
            summary.value = WishlistSummary.fromJson(data['summary']);
          }
        }

        print(
          'Loaded ${wishlistItems.length} wishlist items for page ${currentPage.value}',
        );

        if (wishlistItems.isNotEmpty) {
          currentPage.value++;
        }
      } else {
        errorMessage.value = response?['message'] ?? 'Failed to load wishlist';
        print('Failed to load wishlist: ${errorMessage.value}');
      }
    } catch (e) {
      // Gracefully handle errors without crashing the app
      String errorMsg = e.toString();

      if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
        print(
          '⚠️ Wishlist: Authentication error (401) - User session may have expired',
        );
        errorMessage.value = 'Session expired. Please log in again.';
      } else if (errorMsg.contains('Network') ||
          errorMsg.contains('SocketException')) {
        print('⚠️ Wishlist: Network error');
        errorMessage.value = 'Network error. Check your connection.';
      } else {
        errorMessage.value = 'Error loading wishlist';
        print('Error loading wishlist: $e');
      }

      // Clear any partial data on error
      if (currentPage.value == 1) {
        wishlistProducts.clear();
        productWishlistStatus.clear();
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (!isLoadingMore.value && hasMoreProducts.value) {
      await loadWishlist();
    }
  }

  // Refresh wishlist
  Future<void> refreshWishlist() async {
    await loadWishlist(refresh: true);
  }

  // Add product to wishlist
  Future<bool> addToWishlist(String productId) async {
    try {
      final response = await _ecommerceService.addToWishlist(productId);
      if (response != null && response['success'] == true) {
        productWishlistStatus[productId] = true;
        print('Product $productId added to wishlist');

        // Refresh wishlist to get updated list
        await refreshWishlist();
        return true;
      } else {
        print('Failed to add to wishlist: ${response?['message']}');
        return false;
      }
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    }
  }

  // Remove product from wishlist
  Future<bool> removeFromWishlist(String productId) async {
    try {
      final success = await _ecommerceService.removeFromWishlist(productId);
      if (success) {
        productWishlistStatus[productId] = false;

        // Remove from local list
        wishlistProducts.removeWhere((product) => product.id == productId);
        totalCount.value = wishlistProducts.length;

        print('Product $productId removed from wishlist');
        return true;
      } else {
        print('Failed to remove from wishlist');
        return false;
      }
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  // Toggle wishlist status
  Future<bool> toggleWishlist(String productId) async {
    try {
      final response = await _ecommerceService.toggleWishlist(productId);
      if (response != null && response['success'] == true) {
        // Parse the actual response to get the current status
        final messageData = response['message'];
        final bool isInWishlist;

        if (messageData is Map) {
          // New API response format
          isInWishlist = messageData['isInWishlist'] ?? false;
        } else {
          // Fallback: toggle current status
          isInWishlist = !isProductInWishlist(productId);
        }

        // Update the status for this product
        productWishlistStatus[productId] = isInWishlist;

        // Force UI update by triggering observable change
        productWishlistStatus.refresh();

        if (isInWishlist) {
          print('Product $productId added to wishlist via toggle');
          // Refresh to get the product in the list
          await refreshWishlist();
        } else {
          print('Product $productId removed from wishlist via toggle');
          // Remove from local list
          wishlistProducts.removeWhere((product) => product.id == productId);
          totalCount.value = wishlistProducts.length;
        }

        // Trigger a global update to notify all widgets
        update();

        return true;
      } else {
        print('Failed to toggle wishlist: ${response?['message']}');
        return false;
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      return false;
    }
  }

  // Check if product is in wishlist (reactive)
  bool isProductInWishlist(String productId) {
    // Access the reactive map to trigger updates
    return productWishlistStatus[productId] ?? false;
  }

  // Check product wishlist status from API
  Future<void> checkProductWishlistStatus(String productId) async {
    try {
      final isInWishlist = await _ecommerceService.checkProductInWishlist(
        productId,
      );
      productWishlistStatus[productId] = isInWishlist;
      productWishlistStatus.refresh();
    } catch (e) {
      print('Error checking wishlist status for $productId: $e');
      // Set default value on error
      productWishlistStatus[productId] = false;
      productWishlistStatus.refresh();
    }
  }

  // Get wishlist count
  Future<void> getWishlistCount() async {
    try {
      final count = await _ecommerceService.getWishlistCount();
      totalCount.value = count;
    } catch (e) {
      print('Error getting wishlist count: $e');
    }
  }

  // New wishlist methods for enhanced functionality
  Future<bool> clearWishlist() async {
    try {
      final response = await _ecommerceService.clearWishlist();
      if (response != null && response['success'] == true) {
        wishlistItems.clear();
        wishlistProducts.clear();
        productWishlistStatus.clear();
        totalCount.value = 0;
        print('Wishlist cleared successfully');
        return true;
      } else {
        print('Failed to clear wishlist: ${response?['message']}');
        return false;
      }
    } catch (e) {
      print('Error clearing wishlist: $e');
      return false;
    }
  }

  Future<void> loadWishlistStats() async {
    try {
      final response = await _ecommerceService.getWishlistStats();
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data != null) {
          stats.value = WishlistStatsData.fromJson(data);
          print('Wishlist stats loaded successfully');
        }
      } else {
        print('Failed to load wishlist stats: ${response?['message']}');
      }
    } catch (e) {
      print('Error loading wishlist stats: $e');
    }
  }

  // Helper getters
  bool get hasWishlistItems => wishlistProducts.isNotEmpty;
  bool get isWishlistEmpty => wishlistProducts.isEmpty && !isLoading.value;
  String get wishlistCountText => totalCount.value.toString();

  // New getters for enhanced data
  WishlistPagination? get wishlistPagination => pagination.value;
  WishlistSummary? get wishlistSummary => summary.value;
  WishlistStatsData? get wishlistStats => stats.value;
}
