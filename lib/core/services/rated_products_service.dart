import 'package:get/get.dart';
import 'package:arif_mart/core/helper/hive_helper.dart';

class RatedProductsService extends GetxService {
  static const String _ratedProductsKey = 'rated_products';
  
  // List of product IDs that have been rated
  final RxSet<String> _ratedProducts = <String>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadRatedProducts();
  }
  
  /// Load rated products from local storage
  void _loadRatedProducts() {
    try {
      final List<dynamic>? stored = HiveHelper.hive.get(_ratedProductsKey);
      if (stored != null) {
        _ratedProducts.assignAll(Set<String>.from(stored));
      }
    } catch (e) {
      print('Error loading rated products: $e');
    }
  }
  
  /// Save rated products to local storage
  void _saveRatedProducts() {
    try {
      HiveHelper.hive.put(_ratedProductsKey, _ratedProducts.toList());
    } catch (e) {
      print('Error saving rated products: $e');
    }
  }
  
  /// Check if a product has been rated
  bool isProductRated(String productId) {
    return _ratedProducts.contains(productId);
  }
  
  /// Mark a product as rated
  void markProductAsRated(String productId) {
    _ratedProducts.add(productId);
    _saveRatedProducts();
  }
  
  /// Get all rated product IDs
  Set<String> get ratedProducts => _ratedProducts.toSet();
  
  /// Clear all rated products (for testing or reset)
  void clearRatedProducts() {
    _ratedProducts.clear();
    _saveRatedProducts();
  }
  
  /// Check if any products in an order have been rated
  bool hasOrderProductsBeenRated(List<String> productIds) {
    return productIds.any((productId) => isProductRated(productId));
  }
}
