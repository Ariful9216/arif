import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/core/services/ecommerce_service.dart';

enum ProductCategoryType {
  freshSell,
  newProducts,
  trending,
  topSelling,
  flashSale,
  topRated,
  exclusive,
}

class ProductCategoryController extends GetxController {
  final ProductCategoryType categoryType;
  final String categoryTitle;

  ProductCategoryController({
    required this.categoryType,
    required this.categoryTitle,
  });

  // Product list and pagination
  final RxList<ProductData> products = <ProductData>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final int limit = 20;
  int currentPage = 1;

  // Scroll controller for pagination
  late ScrollController scrollController;

  // E-commerce service
  late final EcommerceService _ecommerceService;

  @override
  void onInit() {
    super.onInit();
    _ecommerceService = Get.find<EcommerceService>();
    scrollController = ScrollController();
    
    // Setup scroll listener for pagination
    scrollController.addListener(_onScroll);
    
    // Load initial data
    loadProducts();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      // Load more when user is near the bottom
      if (!isLoadingMore.value && hasMoreData.value) {
        loadMoreProducts();
      }
    }
  }

  Future<void> loadProducts({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage = 1;
        hasMoreData.value = true;
        hasError.value = false;
        products.clear();
      }

      isLoading.value = true;
      hasError.value = false;

      final response = await _getProductsByCategory();

      if (response != null && response.success) {
        if (refresh) {
          products.value = response.data.products;
        } else {
          products.addAll(response.data.products);
        }

        // Check if there's more data based on pagination or response
        final pagination = response.data.pagination;
        if (pagination != null) {
          hasMoreData.value = pagination.hasNext;
        } else {
          // If no pagination info, assume no more data if we got less than limit
          hasMoreData.value = response.data.products.length >= limit;
        }

        print('${categoryTitle} products loaded: ${products.length} total, page $currentPage');
      } else {
        hasError.value = true;
        errorMessage.value = response?.message ?? 'Failed to load products';
        print('Error loading ${categoryTitle} products: ${errorMessage.value}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading products: $e';
      print('Exception loading ${categoryTitle} products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      final response = await _getProductsByCategory();

      if (response != null && response.success) {
        products.addAll(response.data.products);

        // Check if there's more data
        final pagination = response.data.pagination;
        if (pagination != null) {
          hasMoreData.value = pagination.hasNext;
        } else {
          hasMoreData.value = response.data.products.length >= limit;
        }

        print('${categoryTitle} more products loaded: ${response.data.products.length} new, ${products.length} total');
      } else {
        // If loading more fails, go back to previous page
        currentPage--;
        print('Failed to load more ${categoryTitle} products');
      }
    } catch (e) {
      currentPage--;
      print('Exception loading more ${categoryTitle} products: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<ProductModel?> _getProductsByCategory() async {
    switch (categoryType) {
      case ProductCategoryType.freshSell:
        return await _ecommerceService.getFreshSellProducts(page: currentPage, limit: limit);
        
      case ProductCategoryType.newProducts:
        return await _ecommerceService.getFreshSellProducts(page: currentPage, limit: limit); // Same as fresh sell
        
      case ProductCategoryType.trending:
        return await _ecommerceService.getTrendingProducts(page: currentPage, limit: limit);
        
      case ProductCategoryType.topSelling:
        return await _ecommerceService.getTopSellingProducts(page: currentPage, limit: limit);
        
      case ProductCategoryType.flashSale:
        return await _ecommerceService.getFlashSaleProducts(page: currentPage, limit: limit);
        
      case ProductCategoryType.topRated:
        return await _ecommerceService.getTopRatedProducts(page: currentPage, limit: limit);
        
      case ProductCategoryType.exclusive:
        return await _ecommerceService.getExclusiveProducts(page: currentPage, limit: limit);
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }

  void retryLoading() {
    hasError.value = false;
    loadProducts();
  }

  void navigateToProductDetail(ProductData product) {
    print('Navigate to product detail: ${product.name}');
    Get.toNamed(
      Routes.productDetail,
      arguments: {'productId': product.id},
    );
  }

  // Static method to get controller instance with specific category
  static ProductCategoryController freshSell() => ProductCategoryController(
    categoryType: ProductCategoryType.freshSell,
    categoryTitle: 'Fresh Sell',
  );

  static ProductCategoryController newProducts() => ProductCategoryController(
    categoryType: ProductCategoryType.newProducts,
    categoryTitle: 'New Products',
  );

  static ProductCategoryController trending() => ProductCategoryController(
    categoryType: ProductCategoryType.trending,
    categoryTitle: 'Trending',
  );

  static ProductCategoryController topSelling() => ProductCategoryController(
    categoryType: ProductCategoryType.topSelling,
    categoryTitle: 'Top Selling',
  );

  static ProductCategoryController flashSale() => ProductCategoryController(
    categoryType: ProductCategoryType.flashSale,
    categoryTitle: 'Flash Sale',
  );

  static ProductCategoryController topRated() => ProductCategoryController(
    categoryType: ProductCategoryType.topRated,
    categoryTitle: 'Top Rated',
  );

  static ProductCategoryController exclusive() => ProductCategoryController(
    categoryType: ProductCategoryType.exclusive,
    categoryTitle: 'Exclusive',
  );
}
