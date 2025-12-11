import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/order_model.dart';
import 'package:arif_mart/src/widget/cached_image_widget.dart';
import 'package:arif_mart/src/widget/rating_dialog.dart';
import 'package:intl/intl.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'package:arif_mart/core/services/rated_products_service.dart';

import 'controller/shopping_dashboard_controller.dart';

class ShoppingDashboardScreen extends StatelessWidget {
  ShoppingDashboardScreen({super.key});

  final ShoppingDashboardController controller = Get.put(ShoppingDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // If we can go back, go back, otherwise go to shopping page
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offAllNamed(Routes.shopping);
            }
          },
        ),
          bottom: TabBar(
          controller: TabController(length: 2, vsync: Navigator.of(context)),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          onTap: (index) => controller.switchTab(index),
          tabs: const [
            Tab(text: "In Process"),
            Tab(text: "All"),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingOrders.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refreshOrders(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final currentOrders = controller.currentOrders;
        
        if (currentOrders.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          color: AppColors.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentOrders.length,
            itemBuilder: (context, index) {
              final order = currentOrders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            controller.selectedTabIndex.value == 0 
                ? 'No orders in process'
                : 'No completed orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.selectedTabIndex.value == 0 
                ? 'Your active orders will appear here'
                : 'Your completed orders will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderData order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header - simplified layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Text(
                  'Order #${order.invoice}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                            Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.getStatusDisplayText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Order items
            ...order.items.map((item) => _buildOrderItem(item)),
            
            const SizedBox(height: 8),
            
            // Order summary - simplified layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: ৳${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            // Rating button for delivered orders (only if not already rated)
            if (order.status.toLowerCase() == 'delivered') ...[
              const SizedBox(height: 12),
              Obx(() {
                final ratedProductsService = Get.put(RatedProductsService());
                final productIds = order.items
                    .where((item) => item.productDetails != null)
                    .map((item) => item.productDetails!.id)
                    .toList();
                
                final hasRatedProducts = productIds.any((productId) => 
                    ratedProductsService.isProductRated(productId));
                
                if (hasRatedProducts) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Products Rated',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRatingDialog(order),
                      icon: const Icon(Icons.star, size: 18),
                      label: const Text('Rate Products'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  );
                }
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Product image (now with variant image support)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _getItemImageUrl(item).isNotEmpty
                ? CachedImageWidget(
                    imageUrl: _getItemImageUrl(item),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ),
          ),
          
          const SizedBox(width: 12),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productDetails?.name ?? 'Product ID: ${item.product}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Show product price and quantity
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
                      '৳${(item.price * item.quantity).toStringAsFixed(0)}',
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

  String _getItemImageUrl(OrderItem item) {
    // Priority 1: Check if variant has images (for variant orders)
    if (item.variantDetails != null && 
        item.variantDetails!.images != null && 
        item.variantDetails!.images!.isNotEmpty) {
      // Use the fullImageUrl getter which handles primary image selection
      return item.variantDetails!.fullImageUrl;
    }
    
    // Priority 2: Fallback to product image if no variant or variant has no images
    if (item.productDetails != null && 
        item.productDetails!.pictures.isNotEmpty) {
      
      // Try to find primary product image
      final primaryImage = item.productDetails!.pictures
          .firstWhereOrNull((img) => img.isPrimary == true);
      
      // If primary product image exists, return it
      if (primaryImage != null && primaryImage.url.isNotEmpty) {
        return primaryImage.fullImageUrl;
      }
      
      // Otherwise return first product image
      if (item.productDetails!.pictures.first.url.isNotEmpty) {
        return item.productDetails!.pictures.first.fullImageUrl;
      }
    }
    
    // Return empty string if no images found
    return '';
  }

  void _showRatingDialog(OrderData order) {
    // Show rating dialog for each product in the order
    for (final item in order.items) {
      if (item.productDetails != null) {
        showDialog(
          context: Get.context!,
          builder: (context) => RatingDialog(
            productId: item.productDetails!.id,
            productName: item.productDetails!.name,
            productImage: item.productDetails!.pictures.isNotEmpty
                ? item.productDetails!.pictures.first.fullImageUrl
                : null,
          ),
        );
        // Only show dialog for first product to avoid multiple dialogs
        break;
      }
    }
  }
}