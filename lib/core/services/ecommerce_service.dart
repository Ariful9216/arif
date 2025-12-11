import 'dart:convert';
import 'package:dio/dio.dart' as diox;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/helper/dio_helper.dart';
import 'package:arif_mart/core/model/banner_model.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/core/model/variant_model.dart';

class EcommerceService extends GetxService {
  static EcommerceService get to => Get.find();

  // Banner related methods
  Future<BannerModel?> getActiveBanners({String? type}) async {
    try {
      String url = Apis.activeBanners;
      if (type != null && type.isNotEmpty) {
        url += '?type=$type';
      }
      
      print('Fetching banners from: ${Apis.ecommerceBaseUrl}$url');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: false)
          .get(url: url);
      
      if (data != null) {
        print('Banner API response: $data');
        BannerModel bannerModel = BannerModel.fromJson(data);
        print('Parsed ${bannerModel.data.length} banners');
        return bannerModel;
      } else {
        print('Banner API returned null data');
      }
      return null;
    } catch (e) {
      print('Error fetching active banners: $e');
      return null;
    }
  }

  Future<BannerModel?> getAllBanners({String? type}) async {
    try {
      String url = Apis.banners;
      if (type != null && type.isNotEmpty) {
        url += '?type=$type';
      }
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: false)
          .get(url: url);
      
      if (data != null) {
        BannerModel bannerModel = BannerModel.fromJson(data);
        return bannerModel;
      }
      return null;
    } catch (e) {
      print('Error fetching banners: $e');
      return null;
    }
  }

  // Get offer banners specifically
  Future<BannerModel?> getOfferBanners() async {
    return await getActiveBanners(type: 'offer');
  }

  // Products related methods
  Future<ProductData?> getProductById(String productId) async {
    try {
      print('Fetching product details for ID: $productId');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: false)
          .get(url: '${Apis.productById}$productId');
      
      if (data != null && data['success'] == true) {
        print('Product details API response: ${data.toString()}');
        ProductData product = ProductData.fromJson(data['data']);
        return product;
      } else {
        print('Failed to fetch product details: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching product details: $e');
      return null;
    }
  }
  Future<ProductModel?> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? brand,
    List<String>? tags,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool? isActive,
  }) async {
    try {
      String queryParams = '?page=$page&limit=$limit&sortBy=$sortBy&sortOrder=$sortOrder';
      
      if (search != null && search.isNotEmpty) {
        queryParams += '&search=${Uri.encodeComponent(search)}';
      }
      if (category != null && category.isNotEmpty) {
        queryParams += '&category=$category';
      }
      if (minPrice != null) {
        queryParams += '&minPrice=$minPrice';
      }
      if (maxPrice != null) {
        queryParams += '&maxPrice=$maxPrice';
      }
      if (brand != null && brand.isNotEmpty) {
        queryParams += '&brand=${Uri.encodeComponent(brand)}';
      }
      if (tags != null && tags.isNotEmpty) {
        queryParams += '&tags=${tags.map((tag) => Uri.encodeComponent(tag)).join(',')}';
      }
      if (isActive != null) {
        queryParams += '&isActive=$isActive';
      }

      print('Fetching products from: ${Apis.ecommerceBaseUrl}${Apis.products}$queryParams');

      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: false)
          .get(url: '${Apis.products}$queryParams');
      
      if (data != null) {
        print('Products API response: ${data['data']['products']?.length ?? 0} products found');
        ProductModel productModel = ProductModel.fromJson(data);
        return productModel;
      }
      return null;
    } catch (e) {
      print('Error fetching products: $e');
      return null;
    }
  }

  // Search products specifically
  Future<ProductModel?> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    return await getProducts(
      search: query,
      page: page,
      limit: limit,
      sortBy: sortBy,
      sortOrder: sortOrder,
      isActive: true,
    );
  }

  // Get all mobile products
  Future<ProductModel?> getAllMobileProducts({int page = 1, int limit = 20}) async {
    return await _fetchProductsFromEndpoint(Apis.mobileProductsAll, page: page, limit: limit);
  }

  // Get fresh sell products (new products)
  Future<ProductModel?> getFreshSellProducts({int page = 1, int limit = 10}) async {
    return await _fetchProductsFromEndpoint(Apis.mobileProductsNew, page: page, limit: limit);
  }

  // Get trending products
  Future<ProductModel?> getTrendingProducts({int page = 1, int limit = 10}) async {
    return await _fetchProductsFromEndpoint(Apis.mobileProductsTrending, page: page, limit: limit);
  }

  // Get top selling products
  Future<ProductModel?> getTopSellingProducts({int page = 1, int limit = 10}) async {
    return await _fetchProductsFromEndpoint(Apis.mobileProductsTopSelling, page: page, limit: limit);
  }

  // Get exclusive products
  Future<ProductModel?> getExclusiveProducts({int page = 1, int limit = 10}) async {
    return await _fetchProductsFromEndpoint(Apis.mobileProductsExclusive, page: page, limit: limit);
  }

  // Get flash sale products
  Future<ProductModel?> getFlashSaleProducts({int page = 1, int limit = 10}) async {
    final now = DateTime.now();
    print('\n🔍 DEBUG: Fetching flash sale products (page $page, limit $limit)');
    print('🕒 Current time (local): $now (${now.hour}:${now.minute})');
    print('🕒 Current time (UTC): ${now.toUtc()} (${now.toUtc().hour}:${now.toUtc().minute})');
    print('🕒 Time offset: ${now.timeZoneOffset.inHours}h ${now.timeZoneOffset.inMinutes % 60}m');
    
    final result = await _fetchProductsFromEndpoint(Apis.productsFlashSale, page: page, limit: limit);
    
    // Log debug info about flash sale products
    if (result != null) {
      print('✅ Loaded ${result.data.products.length} flash sale products');
      
      // Show detailed info about received flash sale products
      if (result.data.products.isNotEmpty) {
        print('\n📦 RECEIVED FLASH SALE PRODUCTS:');
        
        for (int i = 0; i < result.data.products.length; i++) {
          final product = result.data.products[i];
          final fs = product.flashSale;
          
          print('\n📝 Product #${i+1}: ${product.name}');
          print('   ID: ${product.id}');
          
          // Check if flash sale is enabled
          if (!fs.isActive) {
            print('   ❌ Flash sale not enabled');
            continue;
          }
          
          print('   💲 Regular price: ${product.price}');
          print('   💲 Flash sale price: ${fs.discountPrice}');
          
          // Show dates and check if active
          if (fs.startDate != null && fs.endDate != null) {
            print('   📅 Start date: ${fs.startDate} (${fs.startDate!.hour}:${fs.startDate!.minute})');
            print('   � End date: ${fs.endDate} (${fs.endDate!.hour}:${fs.endDate!.minute})');
            print('   🟢 Is active: ${fs.isCurrentlyActive ? 'YES' : 'NO'}');
            
            // Show helpful millisecond timestamps for comparing
            print('   🔢 Start milliseconds: ${fs.startDate!.millisecondsSinceEpoch}');
            print('   🔢 Now milliseconds: ${now.millisecondsSinceEpoch}');
            print('   🔢 End milliseconds: ${fs.endDate!.millisecondsSinceEpoch}');
            
            // Compare with now
            final afterStart = now.isAfter(fs.startDate!);
            final beforeEnd = now.isBefore(fs.endDate!);
            
            print('   ⏰ After start time: $afterStart');
            print('   ⏰ Before end time: $beforeEnd');
            print('   ✅ Should be active: ${afterStart && beforeEnd}');
            print('   ✅ Actually active: ${fs.isCurrentlyActive}');
            
            if (afterStart && beforeEnd != fs.isCurrentlyActive) {
              print('   ⚠️ WARNING: Unexpected active status!');
            }
          } else {
            print('   ⚠️ Missing start or end date!');
          }
        }
      }
      
      // Check active flash sales summary
      int activeCount = 0;
      int hasTimeDataCount = 0;
      
      for (var product in result.data.products) {
        final fs = product.flashSale;
        
        if (fs.startDate != null && fs.endDate != null) {
          hasTimeDataCount++;
        }
        
        if (fs.isCurrentlyActive) {
          activeCount++;
        }
      }
      
      print('\n� FLASH SALE SUMMARY:');
      print('   Total products: ${result.data.products.length}');
      print('   Products with time data: $hasTimeDataCount');
      print('   Currently active flash sales: $activeCount');
    } else {
      print('❌ Failed to load flash sale products');
    }
    
    return result;
  }

  // Get top rated products
  Future<ProductModel?> getTopRatedProducts({int page = 1, int limit = 10}) async {
    return await _fetchProductsFromEndpoint(Apis.productsTopRated, page: page, limit: limit);
  }

  // Helper method to fetch products from any endpoint
  Future<ProductModel?> _fetchProductsFromEndpoint(String endpoint, {int page = 1, int limit = 10}) async {
    try {
      String queryParams = '?page=$page&limit=$limit';

      print('Fetching products from: ${Apis.ecommerceBaseUrl}$endpoint$queryParams');

      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: false)
          .get(url: '$endpoint$queryParams');
      
      if (data != null) {
        print('API response for $endpoint: ${data.toString()}');
        
        // Check if the response has the expected structure
        if (data['success'] == true) {
          // Handle different response structures
          dynamic responseData = data['data'];
          
          // Case 1: data contains products array directly
          if (responseData is Map && responseData.containsKey('products')) {
            print('Found products array with ${responseData['products']?.length ?? 0} items');
            ProductModel productModel = ProductModel.fromJson(data);
            return productModel;
          }
          // Case 2: data is directly an array of products
          else if (responseData is List) {
            print('Found direct products array with ${responseData.length} items');
            // Convert to expected format
            Map<String, dynamic> formattedData = {
              'success': true,
              'message': data['message'] ?? 'Products retrieved successfully',
              'data': {
                'products': responseData,
                'pagination': null
              }
            };
            ProductModel productModel = ProductModel.fromJson(formattedData);
            return productModel;
          }
          // Case 3: Single product or other structure
          else {
            print('Unexpected data structure: $responseData');
            // Try to handle as single product or empty
            Map<String, dynamic> formattedData = {
              'success': true,
              'message': data['message'] ?? 'Products retrieved successfully',
              'data': {
                'products': responseData != null ? [responseData] : [],
                'pagination': null
              }
            };
            ProductModel productModel = ProductModel.fromJson(formattedData);
            return productModel;
          }
        } else {
          print('API returned unsuccessful response: ${data['message']}');
        }
      }
      return null;
    } catch (e) {
      print('Error fetching products from $endpoint: $e');
      return null;
    }
  }

  // Get all brands
  Future<List<String>?> getAllBrands() async {
    try {
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: false)
          .get(url: Apis.productsBrands);
      
      if (data != null && data['success'] == true) {
        List<String> brands = List<String>.from(data['data'] ?? []);
        print('Brands retrieved: ${brands.length}');
        return brands;
      }
      return null;
    } catch (e) {
      print('Error fetching brands: $e');
      return null;
    }
  }

  // Get all tags
  Future<List<String>?> getAllTags() async {
    try {
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: false)
          .get(url: Apis.productsTags);
      
      if (data != null && data['success'] == true) {
        List<String> tags = List<String>.from(data['data'] ?? []);
        print('Tags retrieved: ${tags.length}');
        return tags;
      }
      return null;
    } catch (e) {
      print('Error fetching tags: $e');
      return null;
    }
  }

  // Categories related methods
  Future<Map<String, dynamic>?> getCategories() async {
    try {
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.categories);
      
      return data;
    } catch (e) {
      print('Error fetching categories: $e');
      return null;
    }
  }

  // Get products by category ID
  Future<ProductModel?> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      String endpoint = '${Apis.productsByCategory}$categoryId';
      String queryParams = '?page=$page&limit=$limit&sortBy=$sortBy&sortOrder=$sortOrder';
      
      print('Fetching products for category: ${Apis.ecommerceBaseUrl}$endpoint$queryParams');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: '$endpoint$queryParams');
      
      if (data != null && data['success'] == true) {
        ProductModel productModel = ProductModel.fromJson(data);
        print('Category products loaded: ${productModel.data.products.length}');
        return productModel;
      }
      return null;
    } catch (e) {
      print('Error fetching products by category: $e');
      return null;
    }
  }

  // Cart related methods
  Future<Map<String, dynamic>?> getCart() async {
    try {
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.cart);
      
      return data;
    } catch (e) {
      print('Error fetching cart: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCartCount() async {
    try {
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.cartCount);
      
      return data;
    } catch (e) {
      print('Error fetching cart count: $e');
      return null;
    }
  }

  // Cart management methods
  Future<Map<String, dynamic>?> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
    String? referrerId, // Affiliate referrer ID
  }) async {
    try {
      print('Adding to cart - ProductID: $productId, Quantity: $quantity, VariantID: $variantId, ReferrerID: $referrerId');
      
      Map<String, dynamic> requestBody = {
        'productId': productId,
        'quantity': quantity,
      };
      
      if (variantId != null && variantId.isNotEmpty) {
        requestBody['variantId'] = variantId;
      }
      
      // Add referrerId if provided (for affiliate tracking)
      if (referrerId != null && referrerId.isNotEmpty) {
        requestBody['referrerId'] = referrerId;
        print('👥 Tracking affiliate referrer: $referrerId');
      }
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .post(url: Apis.cartItems, body: requestBody);
      
      if (data != null) {
        print('Add to cart API response: ${data.toString()}');
        return data;
      } else {
        print('Failed to add to cart: No response data');
      }
      return null;
    } catch (e) {
      print('Error adding to cart: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      print('Updating cart item - ItemID: $itemId, Quantity: $quantity');
      
      Map<String, dynamic> requestBody = {
        'quantity': quantity,
      };
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .put(url: '${Apis.cartItems}/$itemId', body: requestBody);
      
      if (data != null) {
        print('Update cart item API response: ${data.toString()}');
        return data;
      } else {
        print('Failed to update cart item: No response data');
      }
      return null;
    } catch (e) {
      print('Error updating cart item: $e');
      return null;
    }
  }

  Future<bool> removeFromCart(String itemId) async {
    try {
      print('🗑️ Removing from cart - ItemID: $itemId');
      
      // Use the new carts API endpoint: DELETE /api/v1/carts/items/:itemId
      String url = '${Apis.cartItems}/$itemId';
      print('🗑️ DELETE URL: ${Apis.ecommerceBaseUrl}$url');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .delete(url: url);
      
      print('🗑️ Remove from cart API response: $data');
      
      if (data != null) {
        // Check response structure
        bool success = false;
        String message = '';
        
        if (data['success'] == true) {
          success = true;
          message = data['message'] ?? 'Item removed successfully';
        }
        
        if (success) {
          print('✅ Successfully removed from cart: $message');
          return true;
        } else {
          print('❌ Failed to remove from cart: ${data['message'] ?? "Unknown error"}');
        }
      } else {
        print('❌ Remove from cart returned null response');
      }
      return false;
    } catch (e) {
      print('❌ Error removing from cart: $e');
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      print('Clearing cart');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .delete(url: Apis.cartClear);
      
      if (data != null && data['success'] == true) {
        print('Clear cart API response: ${data.toString()}');
        return true;
      } else {
        print('Failed to clear cart: ${data?['message'] ?? "Unknown error"}');
      }
      return false;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCartTotal() async {
    try {
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.cartTotal);
      
      return data;
    } catch (e) {
      print('Error fetching cart total: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> validateCart() async {
    try {
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.cartValidate);
      
      return data;
    } catch (e) {
      print('Error validating cart: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> extendCartExpiration() async {
    try {
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .put(url: Apis.cartExtendExpiration, body: {});
      
      return data;
    } catch (e) {
      print('Error extending cart expiration: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkProductInCart({
    required String productId,
    String? variantId,
  }) async {
    try {
      String url = '${Apis.cartCheckProduct}?productId=$productId';
      if (variantId != null && variantId.isNotEmpty) {
        url += '&variantId=$variantId';
      }
      
      print('Checking cart status: $url');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: url);
      
      return data;
    } catch (e) {
      print('Error checking product in cart: $e');
      return null;
    }
  }

  // Get or create cart
  Future<Map<String, dynamic>?> getOrCreateCart() async {
    try {
      print('Getting or creating cart');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: '${Apis.cart}/create');
      
      return data;
    } catch (e) {
      print('Error getting or creating cart: $e');
      return null;
    }
  }

  // Get cart statistics
  Future<Map<String, dynamic>?> getCartStats() async {
    try {
      print('Fetching cart statistics');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.cartStats);
      
      return data;
    } catch (e) {
      print('Error fetching cart statistics: $e');
      return null;
    }
  }

  // Get specific cart item
  Future<Map<String, dynamic>?> getCartItem({
    required String productId,
    String? variantId,
  }) async {
    try {
      String url = '${Apis.cart}/item?productId=$productId';
      if (variantId != null && variantId.isNotEmpty) {
        url += '&variantId=$variantId';
      }
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: url);
      
      return data;
    } catch (e) {
      print('Error fetching cart item: $e');
      return null;
    }
  }

  // Bulk update cart items
  Future<Map<String, dynamic>?> bulkUpdateCartItems(List<Map<String, dynamic>> updates) async {
    try {
      print('Bulk updating cart items');
      Map<String, dynamic> requestBody = {
        'updates': updates,
      };
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .patch(url: '${Apis.cart}/bulk-update', body: requestBody);
      
      return data;
    } catch (e) {
      print('Error bulk updating cart items: $e');
      return null;
    }
  }

  // Merge carts (for guest to user conversion)
  Future<Map<String, dynamic>?> mergeCarts(List<Map<String, dynamic>> guestCartItems) async {
    try {
      print('Merging carts');
      Map<String, dynamic> requestBody = {
        'guestCartItems': guestCartItems,
      };
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .post(url: '${Apis.cart}/merge', body: requestBody);
      
      return data;
    } catch (e) {
      print('Error merging carts: $e');
      return null;
    }
  }

  // Duplicate methods removed - already exist above

  // Variant management methods
  Future<VariantModel?> getProductVariants(String productId) async {
    try {
      print('Fetching variants for product ID: $productId');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: false)
          .get(url: '${Apis.variants}/$productId');
      
      if (data != null && data['success'] == true) {
        print('Variants API response: ${data.toString()}');
        VariantModel variants = VariantModel.fromJson(data);
        print('Loaded ${variants.data.length} variants for product $productId');
        return variants;
      } else {
        print('Failed to fetch variants: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching variants: $e');
      return null;
    }
  }

  Future<ProductVariant?> getVariantById(String variantId) async {
    try {
      print('Fetching variant by ID: $variantId');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: false)
          .get(url: '${Apis.variantById}/$variantId');
      
      if (data != null && data['success'] == true) {
        print('Variant API response: ${data.toString()}');
        ProductVariant variant = ProductVariant.fromJson(data['data']);
        return variant;
      } else {
        print('Failed to fetch variant: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching variant: $e');
      return null;
    }
  }

  Future<List<ProductVariant>?> getVariantsByAttribute({
    required String productId,
    Map<String, String>? attributes,
  }) async {
    try {
      String queryParams = '';
      if (attributes != null && attributes.isNotEmpty) {
        queryParams = '?' + attributes.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }
      
      print('Fetching variants by attribute for product $productId with params: $queryParams');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: false)
          .get(url: '${Apis.variants}/$productId/by-attribute$queryParams');
      
      if (data != null && data['success'] == true) {
        print('Variants by attribute API response: ${data.toString()}');
        VariantModel variantModel = VariantModel.fromJson(data);
        return variantModel.data;
      } else {
        print('Failed to fetch variants by attribute: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching variants by attribute: $e');
      return null;
    }
  }

  // Wishlist methods - Updated for new API structure
  Future<Map<String, dynamic>?> addToWishlist(String productId) async {
    try {
      print('Adding product to wishlist - ProductID: $productId');
      Map<String, dynamic> requestBody = {
        'productId': productId,
      };
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .post(url: Apis.wishlist, body: requestBody);
      if (data != null) {
        print('Add to wishlist API response: ${data.toString()}');
        return data;
      } else {
        print('Failed to add to wishlist: No response data');
      }
      return null;
    } catch (e) {
      print('Error adding to wishlist: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> toggleWishlist(String productId) async {
    try {
      print('Toggling wishlist for product - ProductID: $productId');
      Map<String, dynamic> requestBody = {
        'productId': productId,
      };
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .post(url: Apis.wishlistToggle, body: requestBody);
      if (data != null) {
        print('Toggle wishlist API response: ${data.toString()}');
        return data;
      } else {
        print('Failed to toggle wishlist: No response data');
      }
      return null;
    } catch (e) {
      print('Error toggling wishlist: $e');
      return null;
    }
  }

  Future<bool> removeFromWishlist(String productId) async {
    try {
      print('Removing from wishlist - ProductID: $productId');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .delete(url: '${Apis.wishlist}/$productId');
      if (data != null && data['success'] == true) {
        print('Remove from wishlist API response: ${data.toString()}');
        return true;
      } else {
        print('Failed to remove from wishlist: ${data?['message'] ?? "Unknown error"}');
      }
      return false;
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserWishlist({int page = 1, int limit = 20, String sortBy = 'addedAt', String sortOrder = 'desc'}) async {
    try {
      String queryParams = '?page=$page&limit=$limit&sortBy=$sortBy&sortOrder=$sortOrder';
      print('Fetching user wishlist: ${Apis.ecommerceBaseUrl}${Apis.wishlist}$queryParams');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: '${Apis.wishlist}$queryParams');
      if (data != null && data['success'] == true) {
        print('Wishlist API response: ${data.toString()}');
        return data;
      } else {
        print('Failed to fetch wishlist: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching wishlist: $e');
      return null;
    }
  }

  Future<bool> checkProductInWishlist(String productId) async {
    try {
      print('Checking if product in wishlist - ProductID: $productId');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: '${Apis.wishlistCheck}/$productId');
      if (data != null && data['success'] == true) {
        print('Check wishlist API response: ${data.toString()}');
        // Check both possible locations for isInWishlist
        final messageData = data['message'];
        if (messageData is Map<String, dynamic>) {
          return messageData['isInWishlist'] ?? false;
        }
        // Fallback to data location
        return data['data']?['isInWishlist'] ?? false;
      } else {
        print('Failed to check wishlist: ${data?['message'] ?? "Unknown error"}');
      }
      return false;
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  Future<int> getWishlistCount() async {
    try {
      print('Fetching wishlist count');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.wishlistCount);
      if (data != null && data['success'] == true) {
        print('Wishlist count API response: ${data.toString()}');
        return data['data']?['count'] ?? 0;
      } else {
        print('Failed to fetch wishlist count: ${data?['message'] ?? "Unknown error"}');
      }
      return 0;
    } catch (e) {
      print('Error fetching wishlist count: $e');
      return 0;
    }
  }

  // New wishlist methods for enhanced functionality
  Future<Map<String, dynamic>?> clearWishlist() async {
    try {
      print('Clearing wishlist');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .delete(url: Apis.wishlistClear);
      if (data != null) {
        print('Clear wishlist API response: ${data.toString()}');
        return data;
      } else {
        print('Failed to clear wishlist: No response data');
      }
      return null;
    } catch (e) {
      print('Error clearing wishlist: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getWishlistStats() async {
    try {
      print('Fetching wishlist statistics');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.wishlistStats);
      if (data != null) {
        print('Wishlist stats API response: ${data.toString()}');
        return data;
      } else {
        print('Failed to fetch wishlist stats: No response data');
      }
      return null;
    } catch (e) {
      print('Error fetching wishlist stats: $e');
      return null;
    }
  }
}

// Custom Dio Helper for E-commerce API
class EcommerceDioHelper extends DioApiHelper {
  EcommerceDioHelper({bool? isTokenNeeded}) : super(isTokeNeeded: isTokenNeeded);

  @override
  Future<dynamic> get({
    required String url, 
    bool? showErrorToast = true, 
    Map<String, dynamic>? body, 
    bool? addBaseUrl = true
  }) async {
    try {
      final String fullUrl = addBaseUrl == true 
          ? '${Apis.ecommerceBaseUrl}$url' 
          : url;
      
      return await super.get(
        url: fullUrl,
        showErrorToast: showErrorToast,
        body: body,
        addBaseUrl: false, // We've already added the base URL
      );
    } catch (e) {
      print('EcommerceDioHelper GET error: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> post({
    required String url, 
    required Map<String, dynamic> body
  }) async {
    try {
      final String fullUrl = '${Apis.ecommerceBaseUrl}$url';
      
      // Since parent post method uses Apis.baseUrl, we need to override
      final response = await dio.post(
        fullUrl,
        options: diox.Options(headers: header),
        data: body,
      );
      
      final logger = Logger();
      logger.i(
        "StatusCode : ${response.statusCode} \n"
        "Api : ${response.requestOptions.uri} \n"
        "Body : ${response.requestOptions.data} \n"
        "Response : ${jsonEncode(response.data)}"
      );
      
      return response.data;
    } catch (e) {
      print('EcommerceDioHelper POST error: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> put({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    try {
      final String fullUrl = '${Apis.ecommerceBaseUrl}$url';
      
      final response = await dio.put(
        fullUrl,
        options: diox.Options(headers: header),
        data: body,
      );
      
      final logger = Logger();
      logger.i(
        "StatusCode : ${response.statusCode} \n"
        "Api : ${response.requestOptions.uri} \n"
        "Body : ${response.requestOptions.data} \n"
        "Response : ${jsonEncode(response.data)}"
      );
      
      return response.data;
    } catch (e) {
      print('EcommerceDioHelper PUT error: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> delete({
    required String url,
    Map<String, dynamic>? body,
    bool? addBaseUrl,
  }) async {
    try {
      final String fullUrl = '${Apis.ecommerceBaseUrl}$url';
      
      final response = await dio.delete(
        fullUrl,
        options: diox.Options(headers: header),
        data: body,
      );
      
      final logger = Logger();
      logger.i(
        "StatusCode : ${response.statusCode} \n"
        "Api : ${response.requestOptions.uri} \n"
        "Body : ${response.requestOptions.data} \n"
        "Response : ${jsonEncode(response.data)}"
      );
      
      return response.data;
    } catch (e) {
      print('EcommerceDioHelper DELETE error: $e');
      rethrow;
    }
  }
}

// Affiliate Service Extension
extension AffiliateService on EcommerceService {
  /// Generate affiliate shareable link for a product
  Future<Map<String, dynamic>?> generateAffiliateLink(String productId) async {
    try {
      print('Generating affiliate link for product: $productId');
      
      Map<String, dynamic> requestBody = {
        'productId': productId,
      };
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .post(url: Apis.affiliateGenerateLink, body: requestBody);
      
      if (data != null) {
        print('Affiliate link generated successfully: $data');
        return data;
      } else {
        print('Failed to generate affiliate link');
        return null;
      }
    } catch (e) {
      print('Error generating affiliate link: $e');
      return null;
    }
  }
  
  /// Get user's affiliate sales/commissions
  Future<Map<String, dynamic>?> getMyAffiliateSales({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      String url = Apis.affiliateMySales;
      url += '?page=$page&limit=$limit';
      if (status != null && status.isNotEmpty) {
        url += '&status=$status';
      }
      
      print('Fetching affiliate sales from: ${Apis.ecommerceBaseUrl}$url');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: url);
      
      if (data != null) {
        print('Affiliate sales fetched successfully');
        return data;
      } else {
        print('Failed to fetch affiliate sales');
        return null;
      }
    } catch (e) {
      print('Error fetching affiliate sales: $e');
      return null;
    }
  }

  /// Get user's affiliate statistics/analytics
  Future<Map<String, dynamic>?> getAffiliateStatistics({
    int page = 1,
    int limit = 10,
    String type = 'daily',
  }) async {
    try {
      String url = Apis.affiliateStatistics;
      url += '?page=$page&limit=$limit&type=$type';
      
      print('Fetching affiliate statistics from: ${Apis.ecommerceBaseUrl}$url');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: url);
      
      if (data != null) {
        print('Affiliate statistics fetched successfully');
        return data;
      } else {
        print('Failed to fetch affiliate statistics');
        return null;
      }
    } catch (e) {
      print('Error fetching affiliate statistics: $e');
      return null;
    }
  }
}
