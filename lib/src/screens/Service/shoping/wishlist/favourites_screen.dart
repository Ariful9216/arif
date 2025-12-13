import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'package:arif_mart/src/screens/Service/shoping/widgets/wishlist_heart_icon.dart';
import 'controller/wishlist_controller.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WishlistController>(
      init: WishlistController(),
      builder: (controller) {
        if (controller == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              title: const Text('Favourites', style: TextStyle(color: Colors.white)),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            title: const Text(
              'Favourites',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                try {
                  Get.back();
                } catch (e) {
                  // If Get.back() fails, use Navigator directly
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              Obx(() => controller.hasWishlistItems
                  ? IconButton(
                      onPressed: () => _showClearWishlistDialog(context, controller),
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      tooltip: 'Clear Wishlist',
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingState();
            }

            if (controller.errorMessage.isNotEmpty) {
              return _buildErrorState(controller);
            }

            if (controller.isWishlistEmpty) {
              return _buildEmptyState();
            }

            return _buildWishlistContent(controller);
          }),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading your favourites...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WishlistController controller) {
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
            'Error loading favourites',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.refreshWishlist(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'No Favourites Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start adding products to your wishlist\nby tapping the heart icon',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistContent(WishlistController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshWishlist(),
      child: Column(
        children: [
          // Header with count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Obx(() => Text(
              '${controller.totalCount.value} ${controller.totalCount.value == 1 ? 'item' : 'items'} in your favourites',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            )),
          ),
          
          // Products grid
          Expanded(
            child: Obx(() => GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.52, // Further reduced to increase card height
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.wishlistProducts.length + 
                         (controller.hasMoreProducts.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.wishlistProducts.length) {
                  // Load more indicator
                  return _buildLoadMoreIndicator(controller);
                }
                
                final product = controller.wishlistProducts[index];
                return _buildWishlistProductCard(product, controller);
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistProductCard(ProductData product, WishlistController controller) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.productDetail, arguments: {'productId': product.id});
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product image with wishlist icon
            AspectRatio(
              aspectRatio: 4/5, // Fixed 4:5 aspect ratio for consistent product images
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.primaryThumbnailUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      cacheWidth: 400,
                      cacheHeight: 500, // Adjusted for 4:5 ratio
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey[400],
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Wishlist heart icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: WishlistHeartIcon(
                      productId: product.id,
                      iconSize: 20,
                      activeColor: Colors.red,
                      inactiveColor: Colors.grey[600]!,
                      showBackground: true,
                    ),
                  ),
                  
                  // Flash sale badge
                  if (product.flashSale.isCurrentlyActive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SALE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Product info
            Container(
              padding: const EdgeInsets.all(8), // Consistent spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Product name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14, // Slightly larger font
                        fontWeight: FontWeight.w600,
                        height: 1.2, // Improved line height for better readability
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8), // Consistent spacing

                    // Brand
                    if (product.brand.isNotEmpty)
                      Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: 11, // Smaller font
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 12), // Increased spacing
                    
                    // Price and rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price
                        Flexible(
                          child: product.flashSale.isCurrentlyActive &&
                                  product.flashSale.discountPrice != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '৳${product.flashSale.discountPrice!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 15, // Larger font size
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '৳${product.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey[500],
                                        decoration: TextDecoration.lineThrough,
                                        height: 1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )
                              : Text(
                                  '৳${product.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 15, // Larger font size
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        
                        // Rating
                        if (product.rating.average > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.formattedAverage,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
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

  Widget _buildLoadMoreIndicator(WishlistController controller) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return GestureDetector(
          onTap: () => controller.loadMoreProducts(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.grey[600],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Load More',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  void _showClearWishlistDialog(BuildContext context, WishlistController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text(
          'Are you sure you want to remove all items from your favourites? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              
              // Show loading indicator
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );
              
              // Call the clearWishlist method from controller
              final success = await controller.clearWishlist();
              
              // Close loading dialog
              Get.back();
              
              if (success) {
                Get.snackbar(
                  'Wishlist Cleared',
                  'All items have been removed from your favourites',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to clear wishlist. Please try again.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}