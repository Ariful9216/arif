import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'package:arif_mart/core/model/cart_model.dart';
import 'package:arif_mart/core/model/address_model.dart';
import 'package:arif_mart/src/screens/Service/shoping/order/controller/order_controller.dart';
import 'package:arif_mart/src/screens/Service/shoping/address/address_list_screen.dart';
import 'package:arif_mart/src/screens/Service/shoping/address/address_form_screen.dart';
import 'package:arif_mart/src/widget/app_image.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double deliveryCost;
  final bool isInsideCity;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryCost,
    required this.isInsideCity,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());
    
    // Initialize checkout with cart data
    controller.initializeCheckout(cartItems, subtotal, deliveryCost, isInsideCity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              _buildOrderSummary(controller),
              
              const SizedBox(height: 24),
              
              // Delivery Address Section
              _buildAddressSection(controller),
              
              const SizedBox(height: 24),
              
              // Place Order Button
              _buildPlaceOrderButton(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderSummary(OrderController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Items list
            ...controller.checkoutItems.map((item) => _buildOrderItem(item)),
            
            const Divider(),
            
            // Price breakdown
            _buildPriceBreakdown(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppImage(
              imageUrl: _getItemImageUrl(item),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (item.variant != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Variant: ${item.variant!.attributes.values.join(', ')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                
                const SizedBox(height: 4),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '৳${(item.calculatedEffectivePrice * item.quantity).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(OrderController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal:'),
            Text('৳${controller.checkoutSubtotal.value.toStringAsFixed(0)}'),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delivery Cost (${controller.isInsideCity.value ? 'Inside City' : 'Outside City'}):'),
            Text('৳${controller.checkoutDeliveryCost.value.toStringAsFixed(0)}'),
          ],
        ),
        
        const Divider(),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '৳${controller.checkoutTotal.value.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressSection(OrderController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text(
               'Delivery Address',
               style: TextStyle(
                 fontSize: 18,
                 fontWeight: FontWeight.bold,
                 color: AppColors.primaryColor,
               ),
             ),
            
            const SizedBox(height: 16),
            
            Obx(() {
              if (controller.isLoadingAddresses.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (controller.availableAddresses.isEmpty) {
                return _buildNoAddressState();
              }
              
              return _buildAddressSelection(controller);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAddressState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: Colors.grey[400],
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            'No Address Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Please add a delivery address to continue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: () async {
              await Get.to(() => const AddressFormScreen());
              // Refresh addresses after returning from address form
              Get.find<OrderController>().refreshAddresses();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSelection(OrderController controller) {
    return Column(
      children: [
        // Address options
        ...controller.availableAddresses.map((address) => _buildAddressOption(address, controller)),
        
        const SizedBox(height: 16),
        
        // Add new address button
        OutlinedButton.icon(
          onPressed: () async {
            await Get.to(() => const AddressFormScreen());
            // Refresh addresses after returning from address form
            Get.find<OrderController>().refreshAddresses();
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add New Address'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: BorderSide(color: AppColors.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressOption(AddressData address, OrderController controller) {
    final isSelected = controller.selectedAddress.value?.id == address.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<AddressData>(
        value: address,
        groupValue: controller.selectedAddress.value,
        onChanged: (value) => controller.selectAddress(value!),
        title: Row(
          children: [
            Text(address.addressTypeIcon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (address.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DEFAULT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              address.displayAddress,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (address.landmark.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Landmark: ${address.landmark}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        activeColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildPlaceOrderButton(OrderController controller) {
    return Obx(() {
      final canPlaceOrder = controller.hasSelectedAddress && controller.checkoutItems.isNotEmpty;
      
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: canPlaceOrder ? () => _placeOrder(controller) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canPlaceOrder ? AppColors.primaryColor : Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Place Order',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  Future<void> _placeOrder(OrderController controller) async {
    try {
      final success = await controller.createOrderFromCheckout();
      
      if (success) {
        Get.snackbar(
          'Success',
          'Order placed successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate to Dashboard page after successful order
        Get.offNamed(Routes.shoppingDashboard);
      } else {
        Get.snackbar(
          'Error',
          controller.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to place order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Helper method to get the correct image URL for cart items
  String _getItemImageUrl(CartItem item) {
    // If there's a variant with images, use the variant's primary image
    if (item.variant != null && item.variant!.images.isNotEmpty) {
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
