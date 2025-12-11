import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/core/model/variant_model.dart';
import 'package:arif_mart/core/services/ecommerce_service.dart';
import 'package:arif_mart/core/helper/hive_helper.dart';
import 'package:arif_mart/src/screens/Service/shoping/controller/shopping_controller.dart';
import 'package:arif_mart/src/widget/affiliate_share_dialog.dart';
import 'package:arif_mart/src/utils/subscription_checker.dart';

class ProductDetailController extends GetxController {
  // Product data
  final Rx<ProductData?> product = Rx<ProductData?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Image gallery
  final RxInt currentImageIndex = 0.obs;
  final PageController imagePageController = PageController();
  
  // Variants
  final RxList<ProductVariant> variants = <ProductVariant>[].obs;
  final Rx<ProductVariant?> selectedVariant = Rx<ProductVariant?>(null);
  final RxBool isLoadingVariants = false.obs;
  
  // Current display state (can be product or variant)
  final RxBool isViewingVariant = false.obs;
  
  // Cart operations
  final RxInt quantity = 1.obs;
  final RxBool isAddingToCart = false.obs;
  final RxBool itemAddedToCart = false.obs;
  final RxString cartItemId = ''.obs;
  final RxString cartItemAddedAt = ''.obs;
  
  // Services
  late final EcommerceService _ecommerceService;
  
  // Product ID (passed as argument)
  late String productId;
  String? referrerId; // To track affiliate referrer
  
  // Deep link indicator state
  final RxBool showDeepLinkIndicator = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    _ecommerceService = Get.find<EcommerceService>();
    
    // Get product ID from route arguments
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map && arguments.containsKey('productId')) {
      productId = arguments['productId'] as String;
      referrerId = arguments['referrerId'] as String?; // Get referrer ID if present from deep link
      
      // If no referrerId from deep link, check localStorage
      if (referrerId == null || referrerId!.isEmpty) {
        referrerId = HiveHelper.getProductReferrer(productId);
        if (referrerId != null) {
          print('� Retrieved referrer from localStorage: $referrerId');
        }
      } else {
        // Save referrerId to localStorage if it came from deep link
        HiveHelper.setProductReferrer(productId, referrerId!);
        print('💾 Saved referrer to localStorage: $referrerId');
      }
      
      print('🔍 ProductDetailController onInit - Product ID: $productId');
      if (referrerId != null) {
        print('👥 Active Referrer ID: $referrerId');
      }
      
      loadProduct();
      // Check if product is already in cart
      print('🔍 ProductDetailController onInit - Calling _checkCartStatus()');
      _checkCartStatus();
    } else {
      errorMessage.value = 'Product ID not provided';
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh cart status when page becomes ready (user returns to page)
    print('🔍 ProductDetailController onReady - Calling _checkCartStatus()');
    _checkCartStatus();
  }
  
  @override
  void onClose() {
    imagePageController.dispose();
    super.onClose();
  }
  
  // Load product details
  Future<void> loadProduct() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print('Loading product details for ID: $productId');
      
      final productData = await _ecommerceService.getProductById(productId);
      
      if (productData != null) {
        product.value = productData;
        
        // Load variants after product is loaded
        await loadVariants();
        
        print('Product loaded successfully: ${product.value!.name}');
      } else {
        errorMessage.value = 'Failed to load product details';
        print('Failed to load product: No data returned');
      }
    } catch (e) {
      errorMessage.value = 'Error loading product: $e';
      print('Error loading product: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Refresh product data (called when deep link is re-entered)
  Future<void> refreshProduct() async {
    print('🔄 Refreshing product data for: $productId');
    await loadProduct();
    await _checkCartStatus();
  }
  
  // Handle back navigation (smart navigation based on entry method)
  void handleBackNavigation() {
    try {
      // Check if user came from deep link (no previous route)
      if (Get.previousRoute == null || Get.previousRoute == '') {
        print('🔙 Deep link navigation detected, going to home');
        Get.offAllNamed(Routes.home);
      } else {
        print('🔙 Normal navigation detected, going back');
        Get.back();
      }
    } catch (e) {
      print('❌ Error in back navigation: $e');
      // Fallback: go to home
      Get.offAllNamed(Routes.home);
    }
  }
  
  // Load product variants
  Future<void> loadVariants() async {
    try {
      isLoadingVariants.value = true;
      
      final variantModel = await _ecommerceService.getProductVariants(productId);
      
      if (variantModel != null && variantModel.data.isNotEmpty) {
        variants.value = variantModel.data.where((v) => v.isActive).toList();
        
        print('Loaded ${variants.length} active variants for product $productId');
        
        // By default, show the main product (not a variant)
        selectedVariant.value = null;
        isViewingVariant.value = false;
        
        for (var variant in variants) {
          print('Variant: ${variant.attributes} - Price: ${variant.formattedPrice}');
        }
      } else {
        print('No variants found for product $productId');
        variants.clear();
      }
    } catch (e) {
      print('Error loading variants: $e');
      variants.clear();
    } finally {
      isLoadingVariants.value = false;
    }
  }

  // Select a variant (navigation-style)
  void selectVariant(ProductVariant? variant) {
    print('=== VARIANT SELECTION DEBUG ===');
    print('Previous variant: ${selectedVariant.value?.id}');
    print('New variant: ${variant?.id}');
    print('Variant attributes: ${variant?.attributes}');
    print('Variant price: ${variant?.formattedPrice}');
    
    selectedVariant.value = variant;
    isViewingVariant.value = variant != null;
    
    print('After selection - selectedVariant: ${selectedVariant.value?.id}');
    print('After selection - isViewingVariant: ${isViewingVariant.value}');
    print('================================');
    
    // Reset cart state when switching variants
    resetCartState();
    
    // Check cart status for the selected variant
    _checkCartStatus();
    
    // Reset image to first image
    currentImageIndex.value = 0;
    imagePageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    if (variant != null) {
      print('Selected variant: ${variant.id} - ${variant.attributes} - ${variant.formattedPrice}');
    } else {
      print('Selected main product');
    }
  }
  
  // Image gallery methods
  void onImagePageChanged(int index) {
    currentImageIndex.value = index;
  }
  
  void goToImage(int index) {
    currentImageIndex.value = index;
    imagePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  // Quantity management (methods moved to bottom with cart synchronization)
  
  void setQuantity(int newQuantity) {
    int maxQuantity = _getMaxQuantity();
    if (newQuantity >= 1 && newQuantity <= maxQuantity) {
      quantity.value = newQuantity;
    }
  }
  
  // Get maximum quantity based on selected variant or product
  int _getMaxQuantity() {
    if (selectedVariant.value != null) {
      return selectedVariant.value!.quantity;
    }
    return product.value?.quantity ?? 0;
  }
  
  
  // Cart operations
  Future<void> addToCart() async {
    if (product.value == null) {
      Get.snackbar(
        'Error',
        'Product not loaded',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }
    
    try {
      isAddingToCart.value = true;
      
      // Include selected variant ID if available
      String? variantId = selectedVariant.value?.id;
      
      print('=== ADD TO CART DEBUG ===');
      print('Product ID: $productId');
      print('Selected Variant: ${selectedVariant.value?.id}');
      print('Is Viewing Variant: ${isViewingVariant.value}');
      print('Variant ID to send: $variantId');
      print('Quantity: ${quantity.value}');
      print('Item already in cart: ${itemAddedToCart.value}');
      print('========================');
      
      Map<String, dynamic>? result;
      
      if (itemAddedToCart.value) {
        // Product is already in cart, update quantity
        print('🔄 Updating existing cart item quantity to ${quantity.value}');
        result = await _ecommerceService.addToCart(
          productId: productId,
          quantity: quantity.value,
          variantId: variantId,
          referrerId: referrerId, // Pass referrer ID for affiliate tracking
        );
      } else {
        // Product not in cart, add new item
        print('➕ Adding new item to cart with quantity ${quantity.value}');
        if (referrerId != null) {
          print('👥 Adding with referrer tracking: $referrerId');
        }
        result = await _ecommerceService.addToCart(
          productId: productId,
          quantity: quantity.value,
          variantId: variantId,
          referrerId: referrerId, // Pass referrer ID for affiliate tracking
        );
      }
      
      if (result != null && result['success'] == true) {
        String productName = isViewingVariant.value && selectedVariant.value != null 
            ? '${product.value!.name} (${selectedVariant.value!.attributes.values.join(', ')})'
            : product.value!.name;
            
        String action = itemAddedToCart.value ? 'updated' : 'added';
        Get.snackbar(
          'Success',
          '$productName $action to cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 2),
        );
        
        // Set item added to cart state
        itemAddedToCart.value = true;
        
        // You might want to update cart count in shopping controller
        _updateCartCount();
        
      } else {
        Get.snackbar(
          'Failed',
          result?['message'] ?? 'Failed to add item to cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      print('Error adding to cart: $e');
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isAddingToCart.value = false;
    }
  }
  
  
  // Quantity control methods
  void increaseQuantity() {
    int maxQuantity = _getMaxQuantity();
    if (quantity.value < maxQuantity) {
      quantity.value++;
      print('🔢 Quantity increased to: ${quantity.value}');
      
      // If item is already in cart, update cart quantity
      if (itemAddedToCart.value) {
        _updateCartQuantity();
      }
    } else {
      Get.snackbar(
        'Maximum Quantity',
        'Cannot add more than $maxQuantity items',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
      );
    }
  }
  
  void decreaseQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
      print('🔢 Quantity decreased to: ${quantity.value}');
      
      // If item is already in cart, update cart quantity
      if (itemAddedToCart.value) {
        _updateCartQuantity();
      }
    }
  }
  
  // Update cart quantity when quantity changes
  Future<void> _updateCartQuantity() async {
    try {
      print('🔄 Updating cart quantity to ${quantity.value}');
      
      String? variantId = selectedVariant.value?.id;
      
      // Use addToCart which handles both adding and updating
      final result = await _ecommerceService.addToCart(
        productId: productId,
        quantity: quantity.value,
        variantId: variantId,
        referrerId: referrerId, // Pass referrer ID for affiliate tracking
      );
      
      if (result != null && result['success'] == true) {
        print('✅ Cart quantity updated successfully');
        _updateCartCount();
      } else {
        print('❌ Failed to update cart quantity: ${result?['message']}');
      }
    } catch (e) {
      print('❌ Error updating cart quantity: $e');
    }
  }

  // Navigation to cart
  void goToCart() {
    Get.toNamed(Routes.cart);
  }
  
  // Reset cart state (when user changes variant or product)
  void resetCartState() {
    itemAddedToCart.value = false;
    quantity.value = 1;
    cartItemId.value = '';
    cartItemAddedAt.value = '';
  }

  // Check if product is already in cart
  Future<void> _checkCartStatus() async {
    try {
      print('Checking cart status for product: $productId, variant: ${selectedVariant.value?.id}');
      final response = await _ecommerceService.checkProductInCart(
        productId: productId,
        variantId: selectedVariant.value?.id,
      );
      
      print('Cart check response: $response');
      
      if (response != null && response['success'] == true) {
        final data = response['data'];
        final isInCart = data?['isInCart'] ?? false;
        final cartQuantity = data?['quantity'] ?? 0;
        final itemId = data?['itemId'] ?? '';
        final addedAt = data?['addedAt'] ?? '';
        
        print('Product cart status: $isInCart, quantity: $cartQuantity, itemId: $itemId, addedAt: $addedAt');
        
        if (isInCart && cartQuantity > 0) {
          itemAddedToCart.value = true;
          quantity.value = cartQuantity; // Sync quantity with cart
          cartItemId.value = itemId; // Store cart item ID
          cartItemAddedAt.value = addedAt; // Store added timestamp
          print('✅ Product is already in cart with quantity $cartQuantity, showing "Go to Cart" button');
          print('🔍 itemAddedToCart.value set to: ${itemAddedToCart.value}');
          print('🔍 quantity.value set to: ${quantity.value}');
          print('🔍 Cart item ID: $itemId');
          print('🔍 Added at: $addedAt');
        } else {
          itemAddedToCart.value = false;
          quantity.value = 1; // Reset to default quantity
          cartItemId.value = ''; // Clear cart item ID
          cartItemAddedAt.value = ''; // Clear added timestamp
          print('❌ Product not in cart, showing "Add to Cart" button');
          print('🔍 itemAddedToCart.value set to: ${itemAddedToCart.value}');
          print('🔍 quantity.value set to: ${quantity.value}');
        }
      } else {
        print('⚠️ Failed to check cart status (${response?['message'] ?? 'Unknown error'}), defaulting to "Add to Cart"');
        itemAddedToCart.value = false;
        quantity.value = 1;
      }
    } catch (e) {
      print('❌ Error checking cart status: $e');
      itemAddedToCart.value = false;
      quantity.value = 1;
    }
  }

  // Helper methods
  bool get isInStock {
    if (isViewingVariant.value && selectedVariant.value != null) {
      return selectedVariant.value!.isInStock;
    }
    return product.value?.quantity != null && product.value!.quantity > 0;
  }
  
  bool get hasMultipleImages {
    if (isViewingVariant.value && selectedVariant.value != null) {
      return selectedVariant.value!.images.length > 1;
    }
    return product.value?.pictures.length != null && product.value!.pictures.length > 1;
  }
  
  double get effectivePrice {
    // If viewing variant, use variant price (no flash sale discount)
    if (isViewingVariant.value && selectedVariant.value != null) {
      return selectedVariant.value!.price.toDouble();
    }
    
    // For main product, check flash sale
    if (product.value?.flashSale.isCurrentlyActive == true && 
        product.value?.flashSale.discountPrice != null) {
      return product.value!.flashSale.discountPrice!.toDouble();
    }
    
    // Default to product price
    return product.value?.price.toDouble() ?? 0.0;
  }
  
  double get originalPrice {
    if (isViewingVariant.value && selectedVariant.value != null) {
      return selectedVariant.value!.price.toDouble();
    }
    return product.value?.price.toDouble() ?? 0.0;
  }
  
  String get formattedPrice {
    return '৳${effectivePrice.toStringAsFixed(0)}';
  }
  
  String get formattedOriginalPrice {
    // Only show original price for main product flash sale
    if (!isViewingVariant.value && product.value?.flashSale.isCurrentlyActive == true) {
      return '৳${product.value!.price.toStringAsFixed(0)}';
    }
    return '';
  }
  
  double get discountPercentage {
    // Only main product has flash sale discount
    if (!isViewingVariant.value && 
        product.value?.flashSale.isCurrentlyActive == true && 
        product.value?.flashSale.discountPrice != null) {
      return product.value!.flashSale.getDiscountPercentage(product.value!.price);
    }
    return 0.0;
  }
  
  bool get hasVariants {
    return variants.isNotEmpty;
  }
  
  // Get current stock count for display
  int get currentStock {
    if (isViewingVariant.value && selectedVariant.value != null) {
      return selectedVariant.value!.quantity;
    }
    return product.value?.quantity ?? 0;
  }
  
  // Get current images for display
  List<dynamic> get currentImages {
    if (isViewingVariant.value && selectedVariant.value != null) {
      return selectedVariant.value!.images;
    }
    return product.value?.pictures ?? [];
  }
  
  // Get current attributes for display
  Map<String, dynamic> get currentAttributes {
    if (isViewingVariant.value && selectedVariant.value != null) {
      return selectedVariant.value!.attributes;
    }
    return product.value?.attributes ?? {};
  }
  
  // Update cart count in shopping controller (if available)
  void _updateCartCount() {
    try {
      // Try to find shopping controller and refresh cart count
      if (Get.isRegistered<ShoppingController>()) {
        final shoppingController = Get.find<ShoppingController>();
        shoppingController.updateCartCount();
      }
    } catch (e) {
      // Shopping controller not found
      print('Could not update cart count: $e');
    }
  }
  
  
  // Generate affiliate link for the product
  Future<String> generateAffiliateLink() async {
    try {
      // Get current user ID from HiveHelper
      final userId = HiveHelper.getUserId;
      
      if (userId == null || userId.isEmpty) {
        throw Exception('User must be logged in to share affiliate links');
      }
      
      // Generate deep link with referrer ID
      // Format: arifmart://products/{productId}?ref={userId}
      final deepLink = 'arifmart://products/$productId?ref=$userId';
      
      // You can also generate an HTTP link that redirects to the deep link
      // final httpLink = 'https://ecommerce.arifmart.app/products/$productId?ref=$userId';
      
      return deepLink;
    } catch (e) {
      print('Error generating affiliate link: $e');
      rethrow;
    }
  }
  
  // Share product with affiliate link
  Future<void> shareProduct() async {
    // Check subscription first
    SubscriptionChecker.checkAffiliateFeature(() async {
      try {
        final currentProduct = product.value;
        if (currentProduct == null) {
          throw Exception('No product loaded');
        }
        
        // Check if affiliate program is enabled
        if (!currentProduct.affiliateProgram.isEnabled) {
          throw Exception('Affiliate program not enabled for this product');
        }
      
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // Generate affiliate link via API
      final response = await _ecommerceService.generateAffiliateLink(productId);
      
      // Close loading dialog
      Get.back();
      
      if (response == null || response['success'] != true) {
        throw Exception(response?['message'] ?? 'Failed to generate affiliate link');
      }
      
      final shareableLink = response['data']?['shareableLink'] ?? '';
      if (shareableLink.isEmpty) {
        throw Exception('No shareable link received from server');
      }
      
      // Calculate cashback
      final cashbackAmount = currentProduct.affiliateProgram.calculateCashback(currentProduct.effectivePrice);
      final cashbackRate = currentProduct.affiliateProgram.formattedRate;
      
      // Show share dialog
      Get.dialog(
        AffiliateShareDialog(
          product: currentProduct,
          shareableLink: shareableLink,
          cashbackAmount: cashbackAmount,
          cashbackRate: cashbackRate,
        ),
      );
      
      } catch (e) {
        print('Error sharing product: $e');
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }
}
