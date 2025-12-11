import 'dart:async';
import 'package:get/get.dart';
import 'package:arif_mart/core/model/banner_model.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/core/model/category_model.dart';
import 'package:arif_mart/core/services/ecommerce_service.dart';
import 'package:arif_mart/core/utils/timezone_util.dart';
import 'package:arif_mart/src/screens/Service/shoping/wishlist/controller/wishlist_controller.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';

class ShoppingController extends GetxController {
  // Banner related variables
  final RxList<BannerData> banners = <BannerData>[].obs;
  final RxBool isBannersLoading = false.obs;
  final RxBool bannersLoaded = false.obs;
  
  // Offers related variables
  final RxList<BannerData> offers = <BannerData>[].obs;
  final RxBool isOffersLoading = false.obs;
  
  // Category related variables
  final RxList<CategoryData> categories = <CategoryData>[].obs;
  final RxBool isCategoriesLoading = false.obs;
  final Rxn<String> selectedCategoryId = Rxn<String>();
  
  // Shopping cart count
  final RxInt cartItemCount = 0.obs;
  final RxBool isCartLoading = false.obs;
  
  // Search functionality
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxList<ProductData> searchResults = <ProductData>[].obs;
  final RxBool hasSearchResults = false.obs;
  final RxBool isLoadingSearch = false.obs;
  Timer? _searchDebounce;
  
  // Product data from API
  final RxList<ProductData> newProducts = <ProductData>[].obs;
  final RxList<ProductData> trendingProducts = <ProductData>[].obs;
  final RxList<ProductData> topSellingProducts = <ProductData>[].obs;
  final RxList<ProductData> exclusiveProducts = <ProductData>[].obs;
  final RxList<ProductData> flashSaleProducts = <ProductData>[].obs;
  final RxList<ProductData> topRatedProducts = <ProductData>[].obs;
  
  // All products for infinite scroll
  final RxList<ProductData> allProducts = <ProductData>[].obs;
  final RxBool isLoadingAllProducts = false.obs;
  final RxBool isLoadingMoreAllProducts = false.obs;
  final RxInt allProductsCurrentPage = 1.obs;
  final RxBool hasMoreAllProducts = true.obs;
  final RxInt allProductsTotalCount = 0.obs;
  
  // Loading states for different product sections
  final RxBool isLoadingNewProducts = false.obs;
  final RxBool isLoadingTrending = false.obs;
  final RxBool isLoadingTopSelling = false.obs;
  final RxBool isLoadingExclusive = false.obs;
  final RxBool isLoadingFlashSale = false.obs;
  final RxBool isLoadingTopRated = false.obs;

  // E-commerce service
  late final EcommerceService _ecommerceService;

  @override
  void onInit() {
    super.onInit();
    print("🛒 ShoppingController initializing...");
    _ecommerceService = Get.find<EcommerceService>();
    
    // Initialize WishlistController
    print("🔖 Initializing WishlistController...");
    Get.put(WishlistController());
    
    // Load initial data in the background (don't wait for completion)
    // This ensures the UI renders while data is loading
    print("📊 Starting background data loading...");
    Future.microtask(() async {
      try {
        print("🏷️  Loading banners...");
        await loadActiveBanners().timeout(
          const Duration(seconds: 8),
          onTimeout: () => print("⏱️ loadActiveBanners timeout")
        ).catchError((e) => print("❌ loadActiveBanners error: $e"));
      } catch (e) {
        print("❌ Unexpected error in loadActiveBanners: $e");
      }
    });
    
    Future.microtask(() async {
      try {
        print("🎁 Loading offers...");
        await loadOffers().timeout(
          const Duration(seconds: 8),
          onTimeout: () => print("⏱️ loadOffers timeout")
        ).catchError((e) => print("❌ loadOffers error: $e"));
      } catch (e) {
        print("❌ Unexpected error in loadOffers: $e");
      }
    });
    
    Future.microtask(() async {
      try {
        print("📂 Loading categories...");
        await loadCategories().timeout(
          const Duration(seconds: 8),
          onTimeout: () => print("⏱️ loadCategories timeout")
        ).catchError((e) => print("❌ loadCategories error: $e"));
      } catch (e) {
        print("❌ Unexpected error in loadCategories: $e");
      }
    });
    
    Future.microtask(() async {
      try {
        print("🛍️  Loading cart count...");
        await loadCartCount().timeout(
          const Duration(seconds: 8),
          onTimeout: () => print("⏱️ loadCartCount timeout")
        ).catchError((e) => print("❌ loadCartCount error: $e"));
      } catch (e) {
        print("❌ Unexpected error in loadCartCount: $e");
      }
    });
    
    Future.microtask(() async {
      try {
        print("📦 Loading all products...");
        await loadAllProducts().timeout(
          const Duration(seconds: 30),
          onTimeout: () => print("⏱️ loadAllProducts timeout")
        ).catchError((e) => print("❌ loadAllProducts error: $e"));
      } catch (e) {
        print("❌ Unexpected error in loadAllProducts: $e");
      }
    });
    
    print("✅ ShoppingController initialization complete (data loading in background)");
  }

  // Banner methods
  Future<void> loadActiveBanners() async {
    // Prevent repeated fetching if already loaded
    if (bannersLoaded.value) {
      print('Banners already loaded, skipping fetch');
      return;
    }
    
    try {
      isBannersLoading.value = true;
      final response = await _ecommerceService.getActiveBanners(type: 'banner');
      
      if (response != null && response.success) {
        // Filter only currently active banners
        banners.value = response.data
            .where((banner) => banner.isCurrentlyActive)
            .toList();
        
        // Sort by display order
        banners.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        
        print('Active banners with type="banner" loaded: ${banners.length}');
        for (var banner in banners) {
          print('Banner: ${banner.title}');
          print('Image URL from API: ${banner.imageUrl}');
          print('Full Image URL: ${banner.fullImageUrl}');
        }
        
        // Mark banners as loaded
        bannersLoaded.value = true;
        
        // If no banners from API, add a test banner for debugging
        if (banners.isEmpty) {
          print('No banners from API, adding test banner');
          banners.add(BannerData(
            id: 'test',
            title: 'Test Banner',
            description: 'Test banner for debugging',
            imageUrl: '/images/banners/1758596642699-835880651_original.webp',
            linkUrl: '',
            isActive: true,
            displayOrder: 1,
            createdAt: DateTime.now(),
          ));
        }
      } else {
        print('Failed to load banners: ${response?.message ?? "Unknown error"}');
        // Add test banner for debugging
        print('Adding test banner for debugging');
        banners.clear();
        banners.add(BannerData(
          id: 'test',
          title: 'Test Banner',
          description: 'Test banner for debugging',
          imageUrl: '/images/banners/1758596642699-835880651_original.webp',
          linkUrl: '',
          isActive: true,
          displayOrder: 1,
          createdAt: DateTime.now(),
        ));
      }
    } catch (e) {
      print('Error loading banners: $e');
      // Add test banner for debugging
      print('Adding test banner due to error');
      banners.clear();
      banners.add(BannerData(
        id: 'test',
        title: 'Test Banner',
        description: 'Test banner for debugging - Error occurred',
        imageUrl: '/images/banners/1758596642699-835880651_original.webp',
        linkUrl: '',
        isActive: true,
        displayOrder: 1,
        createdAt: DateTime.now(),
      ));
    } finally {
      isBannersLoading.value = false;
    }
  }

  // Load offers (banners with type="offer")
  Future<void> loadOffers() async {
    try {
      isOffersLoading.value = true;
      final response = await _ecommerceService.getOfferBanners();
      
      if (response != null && response.success) {
        // Filter only currently active offer banners
        offers.value = response.data
            .where((banner) => banner.isCurrentlyActive)
            .toList();
        
        // Sort by display order
        offers.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        
        print('Active offers with type="offer" loaded: ${offers.length}');
        for (var offer in offers) {
          print('Offer: ${offer.title}');
          print('Description: ${offer.description}');
          print('Full Image URL: ${offer.fullImageUrl}');
        }
      } else {
        print('Failed to load offers: ${response?.message ?? "Unknown error"}');
        offers.clear();
      }
    } catch (e) {
      print('Error loading offers: $e');
      offers.clear();
    } finally {
      isOffersLoading.value = false;
    }
  }

  // Cart methods
  Future<void> loadCartCount() async {
    try {
      isCartLoading.value = true;
      final response = await _ecommerceService.getCartCount();
      
      if (response != null && response['success'] == true) {
        cartItemCount.value = response['data']['itemCount'] ?? 0;
        print('Cart count loaded: ${cartItemCount.value}');
      } else {
        cartItemCount.value = 0;
      }
    } catch (e) {
      print('Error loading cart count: $e');
      cartItemCount.value = 0;
    } finally {
      isCartLoading.value = false;
    }
  }

  // Search methods
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    
    // Cancel previous search if exists
    _searchDebounce?.cancel();
    
    if (query.isEmpty) {
      clearSearch();
      return;
    }
    
    // Debounce search to avoid too many API calls
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      performSearch(query);
    });
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    hasSearchResults.value = false;
    isLoadingSearch.value = false;
    _searchDebounce?.cancel();
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      isLoadingSearch.value = true;
      hasSearchResults.value = false;
      
      final response = await _ecommerceService.searchProducts(
        query: query.trim(),
        limit: 20,
      );
      
      if (response != null && response.success) {
        searchResults.value = response.data.products;
        hasSearchResults.value = searchResults.isNotEmpty;
        print('Search results: ${searchResults.length} products found for "$query"');
      } else {
        searchResults.clear();
        hasSearchResults.value = false;
        print('No search results for "$query"');
      }
    } catch (e) {
      print('Error performing search: $e');
      searchResults.clear();
      hasSearchResults.value = false;
    } finally {
      isLoadingSearch.value = false;
    }
  }

  // Product loading methods
  Future<void> loadAllProducts() async {
    await Future.wait([
      loadNewProducts(),
      loadTrendingProducts(),
      loadTopSellingProducts(),
      loadExclusiveProducts(),
      loadFlashSaleProducts(),
      loadTopRatedProducts(),
      loadAllProductsInitial(),
    ]);
  }

  Future<void> loadNewProducts() async {
    try {
      isLoadingNewProducts.value = true;
      final response = await _ecommerceService.getFreshSellProducts(limit: 10);
      
      if (response != null && response.success) {
        newProducts.value = response.data.products;
        print('New products loaded: ${newProducts.length}');
      } else {
        newProducts.clear();
      }
    } catch (e) {
      print('Error loading new products: $e');
      newProducts.clear();
    } finally {
      isLoadingNewProducts.value = false;
    }
  }

  Future<void> loadTrendingProducts() async {
    try {
      isLoadingTrending.value = true;
      final response = await _ecommerceService.getTrendingProducts(limit: 10);
      
      if (response != null && response.success) {
        trendingProducts.value = response.data.products;
        print('Trending products loaded: ${trendingProducts.length}');
      } else {
        trendingProducts.clear();
      }
    } catch (e) {
      print('Error loading trending products: $e');
      trendingProducts.clear();
    } finally {
      isLoadingTrending.value = false;
    }
  }

  Future<void> loadTopSellingProducts() async {
    try {
      isLoadingTopSelling.value = true;
      final response = await _ecommerceService.getTopSellingProducts(limit: 10);
      
      if (response != null && response.success) {
        topSellingProducts.value = response.data.products;
        print('Top selling products loaded: ${topSellingProducts.length}');
      } else {
        topSellingProducts.clear();
      }
    } catch (e) {
      print('Error loading top selling products: $e');
      topSellingProducts.clear();
    } finally {
      isLoadingTopSelling.value = false;
    }
  }

  Future<void> loadExclusiveProducts() async {
    try {
      isLoadingExclusive.value = true;
      final response = await _ecommerceService.getExclusiveProducts(limit: 10);
      
      if (response != null && response.success) {
        exclusiveProducts.value = response.data.products;
        print('Exclusive products loaded: ${exclusiveProducts.length}');
      } else {
        exclusiveProducts.clear();
      }
    } catch (e) {
      print('Error loading exclusive products: $e');
      exclusiveProducts.clear();
    } finally {
      isLoadingExclusive.value = false;
    }
  }

  Future<void> loadFlashSaleProducts() async {
    try {
      isLoadingFlashSale.value = true;
      print('🔍 Loading flash sale products...');
      
      // Import the flash sale debugger at the top of the file
      // import 'package:arif_mart/core/utils/flash_sale_debugger.dart';
      final response = await _ecommerceService.getFlashSaleProducts(limit: 10);
      
      if (response != null && response.success) {
        flashSaleProducts.value = response.data.products;
        print('Flash sale products loaded: ${flashSaleProducts.length}');
        
        // Flash sale products loaded; no debug analysis in production
      } else {
        flashSaleProducts.clear();
        print('❌ Failed to load flash sale products: ${response?.message ?? "Unknown error"}');
      }
    } catch (e) {
      print('❌ Error loading flash sale products: $e');
      flashSaleProducts.clear();
    } finally {
      isLoadingFlashSale.value = false;
    }
  }

  Future<void> loadTopRatedProducts() async {
    try {
      isLoadingTopRated.value = true;
      final response = await _ecommerceService.getTopRatedProducts(limit: 10);
      
      if (response != null && response.success) {
        topRatedProducts.value = response.data.products;
        print('Top rated products loaded: ${topRatedProducts.length}');
      } else {
        topRatedProducts.clear();
      }
    } catch (e) {
      print('Error loading top rated products: $e');
      topRatedProducts.clear();
    } finally {
      isLoadingTopRated.value = false;
    }
  }

  // All products methods for infinite scroll
  Future<void> loadAllProductsInitial() async {
    try {
      isLoadingAllProducts.value = true;
      allProductsCurrentPage.value = 1;
      hasMoreAllProducts.value = true;
      
      final response = await _ecommerceService.getProducts(
        page: 1,
        limit: 20,
        isActive: true,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );
      
      if (response != null && response.success) {
        allProducts.value = response.data.products;
        allProductsTotalCount.value = response.data.pagination?.totalItems ?? allProducts.length;
        hasMoreAllProducts.value = response.data.pagination?.hasNext ?? false;
        print('All products loaded: ${allProducts.length}');
      } else {
        allProducts.clear();
        hasMoreAllProducts.value = false;
      }
    } catch (e) {
      print('Error loading all products: $e');
      allProducts.clear();
      hasMoreAllProducts.value = false;
    } finally {
      isLoadingAllProducts.value = false;
    }
  }

  Future<void> loadMoreAllProducts() async {
    if (!hasMoreAllProducts.value || isLoadingMoreAllProducts.value) return;
    
    try {
      isLoadingMoreAllProducts.value = true;
      final nextPage = allProductsCurrentPage.value + 1;
      
      final response = await _ecommerceService.getProducts(
        page: nextPage,
        limit: 20,
        isActive: true,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );
      
      if (response != null && response.success) {
        allProducts.addAll(response.data.products);
        allProductsCurrentPage.value = nextPage;
        hasMoreAllProducts.value = response.data.pagination?.hasNext ?? false;
        print('Loaded more products: ${response.data.products.length}, total: ${allProducts.length}');
      } else {
        hasMoreAllProducts.value = false;
      }
    } catch (e) {
      print('Error loading more products: $e');
      hasMoreAllProducts.value = false;
    } finally {
      isLoadingMoreAllProducts.value = false;
    }
  }

  Future<void> refreshAllProducts() async {
    await loadAllProductsInitial();
  }

  // Navigation methods
  void navigateToCart() {
    Get.toNamed(Routes.cart);
  }

  void navigateToFavorites() {
    Get.toNamed(Routes.favourites);
  }

  // Category methods
  Future<void> loadCategories() async {
    try {
      isCategoriesLoading.value = true;
      final response = await _ecommerceService.getCategories();
      
      if (response != null && response['success'] == true) {
        final categoryModel = CategoryModel.fromJson(response);
        // Filter only active categories
        categories.value = categoryModel.data
            .where((category) => category.isActive)
            .toList();
        print('Categories loaded: ${categories.length}');
      } else {
        categories.clear();
      }
    } catch (e) {
      print('Error loading categories: $e');
      categories.clear();
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId.value = categoryId;
    if (categoryId != null) {
      // Navigate to category products screen
      Get.toNamed(
        Routes.categoryProducts,
        arguments: {
          'categoryId': categoryId,
          'categoryName': categories.firstWhere((c) => c.id == categoryId).name,
        },
      );
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadActiveBanners(),
      loadOffers(),
      loadCategories(),
      loadCartCount(),
      loadAllProducts(),
    ]);
  }

  // Method to update cart count from other controllers
  void updateCartCount() {
    loadCartCount();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }
}
