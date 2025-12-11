import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/cart_model.dart';
import 'package:arif_mart/src/screens/Service/shoping/cart/controller/cart_controller.dart';
import 'package:arif_mart/src/screens/Service/shoping/order/checkout_screen.dart';
import 'package:arif_mart/src/widget/app_image.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text(
                "Shopping Cart",
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Obx(() => controller.totalItems.value > 0
                ? Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Text(
                      '${controller.totalItems.value}',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Debug button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              print('Manual cart refresh triggered');
              controller.loadCart();
            },
          ),
          Obx(() => controller.cartItems.isNotEmpty
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    switch (value) {
                      case 'select':
                        controller.toggleSelectMode();
                        break;
                      case 'clear':
                        _showClearCartDialog();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'select',
                      child: Row(
                        children: [
                          Icon(controller.isSelectMode.value 
                              ? Icons.check_circle 
                              : Icons.check_circle_outline),
                          const SizedBox(width: 8),
                          Text(controller.isSelectMode.value 
                              ? 'Cancel Select' 
                              : 'Select Items'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Clear Cart', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadCart();
        },
        child: Obx(() {
          print('Cart Screen - isLoading: ${controller.isLoading.value}, isEmpty: ${controller.isEmpty.value}, items: ${controller.cartItems.length}');
          
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (controller.isEmpty.value) {
            return _buildEmptyCart();
          }

        return Column(
          children: [
            // Cart expiration warning removed - simplified cart system
            
            // Select mode header
            Obx(() => controller.isSelectMode.value
                ? _buildSelectModeHeader()
                : const SizedBox.shrink()),
            
            // Cart items list
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: () => controller.refreshCart(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    return _buildCartItem(item, index);
                  },
                ),
              ),
            ),
            
            // Cart summary
            _buildCartSummary(),
          ],
        );
        }),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your cart is empty\n\nCart system is being updated.\nPlease try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Expiration warning removed - simplified cart system

  Widget _buildSelectModeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.blue[50],
      child: Row(
        children: [
          Obx(() => Checkbox(
            value: controller.selectedItems.length == controller.cartItems.length,
            onChanged: (value) {
              if (value == true) {
                controller.selectAllItems();
              } else {
                controller.deselectAllItems();
              }
            },
          )),
          const Text('Select All'),
          const Spacer(),
          Obx(() => controller.selectedItems.isNotEmpty
              ? TextButton.icon(
                  onPressed: () => controller.removeSelectedItems(),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    'Remove (${controller.selectedItems.length})',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Select mode checkbox
            Obx(() => controller.isSelectMode.value
                ? Checkbox(
                    value: controller.isItemSelected(item.id),
                    onChanged: (value) => controller.toggleItemSelection(item.id),
                  )
                : const SizedBox.shrink()),
            
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppImage(
                imageUrl: _getCartItemImageUrl(item),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Brand
                  if (item.product.brand.isNotEmpty)
                    Text(
                      item.product.brand,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Price and quantity controls
                  Row(
                    children: [
                      // Price display with flash sale support
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current effective price
                          Text(
                            '৳${item.calculatedEffectivePrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          
                          // Original price (if discounted)
                          if (item.hasDiscount) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '৳${item.originalPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '-${item.discountPercentage.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: controller.isUpdating.value 
                                  ? null 
                                  : () => controller.decrementQuantity(item),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.remove, size: 18),
                              ),
                            ),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            
                            InkWell(
                              onTap: controller.isUpdating.value 
                                  ? null 
                                  : () => controller.incrementQuantity(item),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.add, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Stock warning
                  if (item.exceedsStock)
                    Text(
                      'Only ${item.availableStock} available',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    )
                  else if (!item.isInStock)
                    const Text(
                      'Out of stock',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  
                  // Item total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: \$${item.itemTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      
                      // Remove button
                      if (!controller.isSelectMode.value)
                        InkWell(
                          onTap: () => controller.removeFromCart(item.id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCostInfo() {
    return Obx(() {
      if (controller.insideCityDeliveryCost.value == 0 && controller.outsideCityDeliveryCost.value == 0) {
        return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.blue[600], size: 16),
              const SizedBox(width: 8),
              Text(
                'Delivery Cost Information',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
            
            // Location toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Location:',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                GestureDetector(
                  onTap: () => controller.toggleDeliveryLocation(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: controller.isInsideCity.value ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: controller.isInsideCity.value ? Colors.green[300]! : Colors.orange[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.isInsideCity.value ? Icons.location_city : Icons.location_on,
                          size: 14,
                          color: controller.isInsideCity.value ? Colors.green[700] : Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.isInsideCity.value ? 'Inside City' : 'Outside City',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: controller.isInsideCity.value ? Colors.green[700] : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Delivery cost options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inside City:',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              Text(
                  '৳${controller.insideCityDeliveryCost.value.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Outside City:',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              Text(
                  '৳${controller.outsideCityDeliveryCost.value.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
            
            const SizedBox(height: 8),
            
            // Current delivery cost
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: controller.isInsideCity.value ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: controller.isInsideCity.value ? Colors.green[200]! : Colors.orange[200]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Delivery Cost:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: controller.isInsideCity.value ? Colors.green[800] : Colors.orange[800],
                      fontSize: 13,
                    ),
                  ),
          Text(
                    '৳${controller.deliveryCost.value.toStringAsFixed(0)}',
            style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: controller.isInsideCity.value ? Colors.green[800] : Colors.orange[800],
                      fontSize: 14,
                    ),
                  ),
                ],
            ),
          ),
        ],
      ),
    );
    });
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Summary details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Obx(() => Text(
                '৳${controller.subtotal.value.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Delivery cost
          Obx(() => controller.deliveryCost.value > 0 
            ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Cost (${controller.isInsideCity.value ? 'Inside City' : 'Outside City'}):',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '৳${controller.deliveryCost.value.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.isInsideCity.value ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              )
            : const SizedBox.shrink()),
          
          // Show savings if any flash sale discounts are applied
          Obx(() => controller.totalSavings.value > 0 
            ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'You Save:',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '৳${controller.totalSavings.value.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              )
            : const SizedBox.shrink()),
          
          // Delivery cost information
          _buildDeliveryCostInfo(),
          
          const Divider(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Text(
                '৳${controller.total.value.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              )),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Checkout button
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: controller.cartItems.isEmpty || controller.isUpdating.value
                  ? null
                  : _handleCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isUpdating.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            )),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCart();
            },
            child: const Text(
              'Clear Cart',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout() async {
    // Validate cart before checkout
    await controller.validateCart();
    if (controller.hasValidationIssues.value) {
      Get.snackbar(
        'Cart Issues',
        'Please resolve cart issues before checkout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Navigate to checkout screen with cart data
    Get.to(() => CheckoutScreen(
      cartItems: controller.cartItems,
      subtotal: controller.subtotal.value,
      deliveryCost: controller.deliveryCost.value,
      isInsideCity: controller.isInsideCity.value,
    ));
  }

  // Helper method to get the correct image URL for cart items
  String _getCartItemImageUrl(CartItem item) {
    // If there's a variant with images, use the variant's primary image
    if (item.variant != null && item.variant!.images.isNotEmpty) {
      // Find primary image or use first image
      final primaryVariantImage = item.variant!.images.firstWhere(
        (img) => img.isPrimary,
        orElse: () => item.variant!.images.first,
      );
      return primaryVariantImage.fullImageUrl;
    }
    
    // Fallback to product's primary image
    if (item.product.pictures.isNotEmpty) {
      final primaryProductImage = item.product.pictures.firstWhere(
        (pic) => pic.isPrimary,
        orElse: () => item.product.pictures.first,
      );
      return primaryProductImage.fullImageUrl;
    }
    
    return '';
  }

}