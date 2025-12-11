import 'package:get/get.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/core/services/ecommerce_service.dart';

class CategoryProductsController extends GetxController {
  final RxList<ProductData> products = <ProductData>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxInt totalCount = 0.obs;
  final RxString categoryId = ''.obs;
  final RxString categoryName = 'Category'.obs;

  late final EcommerceService _ecommerceService;

  @override
  void onInit() {
    super.onInit();
    _ecommerceService = Get.find<EcommerceService>();
    
    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      categoryId.value = args['categoryId'] ?? '';
      categoryName.value = args['categoryName'] ?? 'Category';
    }

    // Load initial products
    if (categoryId.value.isNotEmpty) {
      loadProducts();
    }
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMore.value = true;

      final response = await _ecommerceService.getProductsByCategory(
        categoryId: categoryId.value,
        page: currentPage.value,
        limit: 20,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );

      if (response != null && response.success) {
        products.value = response.data.products;
        
        // If pagination exists, use it; otherwise use products length
        if (response.data.pagination != null) {
          totalCount.value = response.data.pagination!.totalItems;
          hasMore.value = response.data.pagination!.hasNext;
        } else {
          // No pagination, use products length
          totalCount.value = response.data.products.length;
          hasMore.value = false;
        }
        
        print('Category products loaded: ${products.length} of ${totalCount.value}');
      } else {
        products.clear();
        totalCount.value = 0;
        hasMore.value = false;
      }
    } catch (e) {
      print('Error loading category products: $e');
      products.clear();
      totalCount.value = 0;
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (!hasMore.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      final nextPage = currentPage.value + 1;

      final response = await _ecommerceService.getProductsByCategory(
        categoryId: categoryId.value,
        page: nextPage,
        limit: 20,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );

      if (response != null && response.success) {
        products.addAll(response.data.products);
        currentPage.value = nextPage;
        
        // Update hasMore based on pagination or if no more products returned
        if (response.data.pagination != null) {
          hasMore.value = response.data.pagination!.hasNext;
        } else {
          // If no pagination and no products returned, no more products
          hasMore.value = response.data.products.isNotEmpty;
        }
        
        print('Loaded more products: ${response.data.products.length}, total: ${products.length}');
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      print('Error loading more products: $e');
      hasMore.value = false;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts();
  }
}
