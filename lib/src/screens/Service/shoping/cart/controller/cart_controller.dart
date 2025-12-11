import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:arif_mart/core/model/cart_model.dart';
import 'package:arif_mart/core/services/ecommerce_service.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';
import 'package:arif_mart/src/screens/Service/shoping/controller/shopping_controller.dart';

class CartController extends GetxController {
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isEmpty = true.obs;
  
  // Cart data
  final Rx<CartModel?> cartModel = Rx<CartModel?>(null);
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxInt totalItems = 0.obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble deliveryCost = 0.0.obs; // Delivery cost for current location
  final RxDouble total = 0.0.obs;
  final RxDouble totalSavings = 0.0.obs; // Flash sale savings
  
  // Delivery cost information
  final RxDouble insideCityDeliveryCost = 0.0.obs;
  final RxDouble outsideCityDeliveryCost = 0.0.obs;
  final RxBool isInsideCity = true.obs; // Default to inside city
  
  // Cart expiration removed - simplified cart system
  
  // UI state
  final RxBool isSelectMode = false.obs;
  final RxList<String> selectedItems = <String>[].obs;
  
  // Cart statistics and validation
  final Rx<CartStatsData?> cartStats = Rx<CartStatsData?>(null);
  final Rx<CartValidationData?> cartValidation = Rx<CartValidationData?>(null);
  final RxBool hasValidationIssues = false.obs;
  final RxList<CartValidationIssue> validationIssues = <CartValidationIssue>[].obs;
  
  // Cart expiration removed - simplified cart system
  
  // Services
  late final EcommerceService _ecommerceService;
  
  @override
  void onInit() {
    super.onInit();
    _ecommerceService = Get.find<EcommerceService>();
    _initializeCart();
  }

  // Initialize cart with fallback handling
  Future<void> _initializeCart() async {
    try {
      await loadCart();
      // If cart loading fails, try to create an empty cart
      if (cartModel.value == null || cartModel.value!.data.items.isEmpty) {
        print('Cart is empty or failed to load, creating empty cart');
        _createEmptyCart();
      }
    } catch (e) {
      print('Error initializing cart: $e');
      _createEmptyCart();
    }
  }

  // Create empty cart as fallback
  void _createEmptyCart() {
    cartModel.value = CartModel(
      success: true,
      message: 'Empty cart',
      data: CartData.empty(),
    );
    _updateCartData();
  }

  // Load cart from server
  Future<void> loadCart() async {
    try {
      isLoading.value = true;
      final response = await _ecommerceService.getCart();
      
      print('Cart API Response received');
      print('Success: ${response?['success']}');
      print('Message type: ${response?['message'].runtimeType}');
      print('Data type: ${response?['data'].runtimeType}');
      
      if (response != null && response['success'] == true) {
        if (response['message'] is Map || response['data'] is Map) {
          try {
            print('Attempting to parse cart data...');
            cartModel.value = CartModel.fromJson(response);
            print('Cart model parsed successfully');
            
            // Fetch variant details for items that have variant IDs but no full variant objects
            await _fetchVariantDetails();
            
            _updateCartData();
            isEmpty.value = cartItems.isEmpty;
            print('Cart loaded successfully with ${cartItems.length} items');
            // Debug: Print all item IDs
            for (int i = 0; i < cartItems.length; i++) {
              print('Cart Item $i: ID = "${cartItems[i].id}", Name = "${cartItems[i].product.name}"');
            }
          } catch (parseError) {
            print('Error parsing cart data: $parseError');
            print('Response structure: ${response.keys.toList()}');
            print('Full response: $response');
            _clearCartData();
          }
        } else {
          print('No valid cart data found in response');
          _clearCartData();
        }
      } else {
        print('Cart API failed or returned false');
        _clearCartData();
      }
    } catch (e) {
      print('Error loading cart: $e');
      print('Full error details: ${e.toString()}');
      // If cart API fails (404 or other errors), create an empty cart
      _clearCartData();
    } finally {
      isLoading.value = false;
    }
  }

  // Add item to cart
  Future<bool> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    try {
      isUpdating.value = true;
      final response = await _ecommerceService.addToCart(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );
      
      if (response != null && response['success'] == true) {
        showToast(response['message'] ?? 'Item added to cart');
        await loadCart(); // Reload cart to get updated data
        return true;
      } else {
        showToast(response?['message'] ?? 'Failed to add item to cart');
        return false;
      }
    } catch (e) {
      print('Error adding to cart: $e');
      showToast('Failed to add item to cart');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Update cart item quantity
  Future<bool> updateItemQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      return await removeFromCart(itemId);
    }
    
    try {
      isUpdating.value = true;
      final response = await _ecommerceService.updateCartItem(
        itemId: itemId,
        quantity: quantity,
      );
      
      if (response != null && response['success'] == true) {
        showToast('Cart updated');
        await loadCart(); // Reload cart to get updated data
        return true;
      } else {
        showToast(response?['message'] ?? 'Failed to update cart');
        return false;
      }
    } catch (e) {
      print('Error updating cart item: $e');
      showToast('Failed to update cart');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String itemId) async {
    try {
      print('CartController: Starting remove process for itemId: $itemId');
      if (itemId.isEmpty) {
        print('CartController: ERROR - ItemId is empty!');
        showToast('Invalid item ID');
        return false;
      }
      
      isUpdating.value = true;
      final success = await _ecommerceService.removeFromCart(itemId);
      
      if (success) {
        showToast('Item removed from cart');
        print('CartController: Item removed successfully, reloading cart...');
        await loadCart(); // Reload cart to get updated data
        return true;
      } else {
        showToast('Failed to remove item from cart');
        return false;
      }
    } on dio.DioException catch (dioError) {
      print('DioException in removeFromCart: ${dioError.message}');
      print('Response data: ${dioError.response?.data}');
      showToast('Server error: Failed to remove item');
      return false;
    } catch (e) {
      print('Error removing from cart: $e');
      showToast('Failed to remove item from cart');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    try {
      isUpdating.value = true;
      final success = await _ecommerceService.clearCart();
      
      if (success) {
        showToast('Cart cleared');
        _clearCartData();
        return true;
      } else {
        showToast('Failed to clear cart');
        return false;
      }
    } catch (e) {
      print('Error clearing cart: $e');
      showToast('Failed to clear cart');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Increment item quantity
  Future<void> incrementQuantity(CartItem item) async {
    // Check stock availability
    if (item.quantity >= item.availableStock) {
      showToast('Maximum available quantity reached');
      return;
    }
    
    await updateItemQuantity(item.id, item.quantity + 1);
  }

  // Decrement item quantity
  Future<void> decrementQuantity(CartItem item) async {
    if (item.quantity <= 1) {
      // Show confirmation dialog before removing
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Remove Item'),
          content: const Text('Are you sure you want to remove this item from cart?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        await removeFromCart(item.id);
      }
    } else {
      await updateItemQuantity(item.id, item.quantity - 1);
    }
  }

  // Validate cart (check stock availability) - returns bool for compatibility
  Future<bool> validateCartStock() async {
    try {
      final response = await _ecommerceService.validateCart();
      
      if (response != null && response['success'] == true) {
        final isValid = response['data']['isValid'] ?? false;
        if (!isValid) {
          showToast('Some items in your cart are no longer available');
          await loadCart(); // Reload to get updated availability
        }
        return isValid;
      }
      return false;
    } catch (e) {
      print('Error validating cart: $e');
      return false;
    }
  }

  // Extend cart expiration
  Future<void> extendExpiration() async {
    try {
      final response = await _ecommerceService.extendCartExpiration();
      
      if (response != null && response['success'] == true) {
        showToast('Cart expiration extended');
        await loadCart();
      } else {
        showToast('Failed to extend cart expiration');
      }
    } catch (e) {
      print('Error extending cart expiration: $e');
      showToast('Failed to extend cart expiration');
    }
  }

  // Check if product is in cart (local check)
  bool isProductInCartLocal(String productId, {String? variantId}) {
    return cartItems.any((item) => 
        item.product.id == productId && 
        (variantId == null || item.variant?.id == variantId)
    );
  }

  // Get cart item for a product (local search)
  CartItem? getLocalCartItem(String productId, {String? variantId}) {
    try {
      return cartItems.firstWhere((item) => 
          item.product.id == productId && 
          (variantId == null || item.variant?.id == variantId)
      );
    } catch (e) {
      return null;
    }
  }

  // Get quantity of a product in cart
  int getProductQuantity(String productId, {String? variantId}) {
    final item = getLocalCartItem(productId, variantId: variantId);
    return item?.quantity ?? 0;
  }

  // Selection methods for bulk operations
  void toggleSelectMode() {
    isSelectMode.value = !isSelectMode.value;
    if (!isSelectMode.value) {
      selectedItems.clear();
    }
  }

  void toggleItemSelection(String itemId) {
    if (selectedItems.contains(itemId)) {
      selectedItems.remove(itemId);
    } else {
      selectedItems.add(itemId);
    }
  }

  void selectAllItems() {
    selectedItems.clear();
    selectedItems.addAll(cartItems.map((item) => item.id));
  }

  void deselectAllItems() {
    selectedItems.clear();
  }

  bool isItemSelected(String itemId) {
    return selectedItems.contains(itemId);
  }

  // Remove selected items
  Future<void> removeSelectedItems() async {
    if (selectedItems.isEmpty) return;
    
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Items'),
        content: Text('Are you sure you want to remove ${selectedItems.length} selected items?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      isUpdating.value = true;
      try {
        // Remove items one by one
        for (String itemId in selectedItems) {
          await _ecommerceService.removeFromCart(itemId);
        }
        showToast('Selected items removed');
        selectedItems.clear();
        isSelectMode.value = false;
        await loadCart();
      } catch (e) {
        showToast('Failed to remove some items');
      } finally {
        isUpdating.value = false;
      }
    }
  }

  // Calculate totals
  void _calculateTotals() {
    double itemsSubtotal = 0.0;
    double savings = 0.0;
    
    for (CartItem item in cartItems) {
      itemsSubtotal += item.itemTotal;
      savings += item.discountAmount * item.quantity;
    }
    
    subtotal.value = itemsSubtotal;
    _calculateDeliveryCost();
    total.value = itemsSubtotal + deliveryCost.value;
    totalSavings.value = savings;
  }
  
  // Calculate delivery cost based on current location and cart items
  void _calculateDeliveryCost() {
    if (cartItems.isEmpty) {
      deliveryCost.value = 0.0;
      return;
    }
    
    // Get delivery cost from first item (assuming all items have same delivery cost)
    final firstItem = cartItems.first;
    if (firstItem.product.deliveryCost.insideCity > 0 || firstItem.product.deliveryCost.outsideCity > 0) {
      insideCityDeliveryCost.value = firstItem.product.deliveryCost.insideCity.toDouble();
      outsideCityDeliveryCost.value = firstItem.product.deliveryCost.outsideCity.toDouble();
      
      // Set delivery cost based on current location
      deliveryCost.value = isInsideCity.value 
          ? insideCityDeliveryCost.value 
          : outsideCityDeliveryCost.value;
    } else {
      deliveryCost.value = 0.0;
    }
  }
  
  // Toggle delivery location (inside/outside city)
  void toggleDeliveryLocation() {
    isInsideCity.value = !isInsideCity.value;
    _calculateDeliveryCost();
    total.value = subtotal.value + deliveryCost.value;
  }
  
  // Set delivery location
  void setDeliveryLocation(bool isInside) {
    isInsideCity.value = isInside;
    _calculateDeliveryCost();
    total.value = subtotal.value + deliveryCost.value;
  }

  // Fetch variant details for cart items that only have variant IDs
  Future<void> _fetchVariantDetails() async {
    if (cartModel.value?.data?.items == null) return;
    
    for (int i = 0; i < cartModel.value!.data.items.length; i++) {
      final item = cartModel.value!.data.items[i];
      
      // If variant exists but has no attributes (only ID), fetch full variant details
      if (item.variant != null && item.variant!.attributes.isEmpty) {
        try {
          print('Fetching variant details for: ${item.variant!.id}');
          final variantDetails = await _ecommerceService.getVariantById(item.variant!.id);
          
          if (variantDetails != null) {
            // Update the variant with full details
            cartModel.value!.data.items[i] = CartItem(
              id: item.id,
              product: item.product,
              variant: variantDetails,
              quantity: item.quantity,
              addedAt: item.addedAt,
              effectivePrice: item.effectivePrice,
              isFlashSaleActive: item.isFlashSaleActive,
              savings: item.savings,
            );
            print('Variant details fetched: ${variantDetails.attributes}');
          }
        } catch (e) {
          print('Error fetching variant details: $e');
        }
      }
    }
  }

  // Update cart data from model
  void _updateCartData() {
    if (cartModel.value?.data != null) {
      final data = cartModel.value!.data;
      print('Updating cart data: ${data.items.length} items');
      
      // Debug each cart item
      for (int i = 0; i < data.items.length; i++) {
        final item = data.items[i];
        print('Cart item $i:');
        print('  Product: ${item.product.name}');
        print('  Variant: ${item.variant?.id}');
        print('  Variant attributes: ${item.variant?.attributes}');
        print('  Display name: ${item.displayName}');
        print('  Quantity: ${item.quantity}');
        print('  Price: ${item.effectivePrice ?? item.calculatedEffectivePrice}');
        print('  Delivery Cost - Inside: ${item.product.deliveryCost.insideCity}, Outside: ${item.product.deliveryCost.outsideCity}');
      }
      
      cartItems.value = data.items;
      totalItems.value = data.items.length;
      // Expiration removed - simplified cart system
      _calculateTotals();
      isEmpty.value = cartItems.isEmpty;
      
      print('Cart items after update: ${cartItems.length}');
      print('Is empty: ${isEmpty.value}');
      
      // Update shopping controller's cart count
      _updateShoppingCartCount();
    } else {
      print('Cart model data is null');
    }
  }

  // Update shopping controller cart count
  void _updateShoppingCartCount() {
    try {
      if (Get.isRegistered<ShoppingController>()) {
        final shoppingController = Get.find<ShoppingController>();
        shoppingController.cartItemCount.value = totalItems.value;
      }
    } catch (e) {
      print('Could not update shopping cart count: $e');
    }
  }

  // Clear cart data
  void _clearCartData() {
    cartModel.value = null;
    cartItems.clear();
    totalItems.value = 0;
    subtotal.value = 0.0;
    deliveryCost.value = 0.0;
    insideCityDeliveryCost.value = 0.0;
    outsideCityDeliveryCost.value = 0.0;
    isInsideCity.value = true;
    total.value = 0.0;
    totalSavings.value = 0.0;
    // Expiration fields removed - simplified cart system
    isEmpty.value = true;
    selectedItems.clear();
    isSelectMode.value = false;
    
    // Update shopping controller's cart count
    _updateShoppingCartCount();
  }

  // Refresh cart data
  Future<void> refreshCart() async {
    await loadCart();
  }

  // Load cart statistics
  Future<void> loadCartStats() async {
    try {
      final response = await _ecommerceService.getCartStats();
      if (response != null && response['success'] == true) {
        cartStats.value = CartStatsData.fromJson(response['data'] ?? {});
      }
    } catch (e) {
      print('Error loading cart stats: $e');
      // If stats API fails, create empty stats
      cartStats.value = null;
    }
  }

  // Validate cart
  Future<void> validateCart() async {
    try {
      final response = await _ecommerceService.validateCart();
      if (response != null && response['success'] == true) {
        cartValidation.value = CartValidationData.fromJson(response['data'] ?? {});
        validationIssues.value = cartValidation.value?.issues ?? [];
        hasValidationIssues.value = !(cartValidation.value?.valid ?? true);
      }
    } catch (e) {
      print('Error validating cart: $e');
      // If validation API fails, assume cart is valid
      cartValidation.value = null;
      validationIssues.value = [];
      hasValidationIssues.value = false;
    }
  }

  // Cart expiration methods removed - simplified cart system

  // Bulk update cart items
  Future<bool> bulkUpdateItems(List<Map<String, dynamic>> updates) async {
    try {
      isUpdating.value = true;
      final response = await _ecommerceService.bulkUpdateCartItems(updates);
      
      if (response != null && response['success'] == true) {
        showToast('Cart updated successfully');
        await loadCart();
        return true;
      } else {
        showToast('Failed to update cart items');
        return false;
      }
    } catch (e) {
      print('Error bulk updating cart items: $e');
      showToast('Failed to update cart items');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Merge guest cart
  Future<bool> mergeGuestCart(List<Map<String, dynamic>> guestItems) async {
    try {
      isUpdating.value = true;
      final response = await _ecommerceService.mergeCarts(guestItems);
      
      if (response != null && response['success'] == true) {
        showToast('Cart merged successfully');
        await loadCart();
        return true;
      } else {
        showToast('Failed to merge cart');
        return false;
      }
    } catch (e) {
      print('Error merging cart: $e');
      showToast('Failed to merge cart');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Get cart item by product and variant
  Future<CartItem?> getCartItem({
    required String productId,
    String? variantId,
  }) async {
    try {
      final response = await _ecommerceService.getCartItem(
        productId: productId,
        variantId: variantId,
      );
      
      if (response != null && response['success'] == true) {
        final itemData = response['data']?['cartItem'];
        if (itemData != null) {
          return CartItem.fromJson(itemData);
        }
      }
      return null;
    } catch (e) {
      print('Error getting cart item: $e');
      return null;
    }
  }

  // Check if product is in cart
  Future<bool> isProductInCart(String productId, {String? variantId}) async {
    try {
      final response = await _ecommerceService.checkProductInCart(
        productId: productId,
        variantId: variantId,
      );
      if (response != null && response['success'] == true) {
        return response['data']?['isInCart'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking if product is in cart: $e');
      return false;
    }
  }


  // Get flash sale items count
  int get flashSaleItemsCount {
    return cartItems.where((item) => item.isFlashSaleActive).length;
  }

  // Get total savings from flash sales
  double get totalFlashSaleSavings {
    return cartItems.fold(0.0, (sum, item) => sum + (item.savings ?? 0.0));
  }

  // Check if cart has flash sale items
  bool get hasFlashSaleItems {
    return cartItems.any((item) => item.isFlashSaleActive);
  }

  // Get cart summary for checkout
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': totalItems.value,
      'subtotal': subtotal.value,
      'deliveryCost': deliveryCost.value,
      'insideCityDeliveryCost': insideCityDeliveryCost.value,
      'outsideCityDeliveryCost': outsideCityDeliveryCost.value,
      'isInsideCity': isInsideCity.value,
      'total': total.value,
      'totalSavings': totalSavings.value,
      'hasFlashSaleItems': hasFlashSaleItems,
      'flashSaleItemsCount': flashSaleItemsCount,
      // Expiration removed - simplified cart system
      'validationIssues': validationIssues.length,
    };
  }

}