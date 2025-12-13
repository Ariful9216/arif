import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'controller/product_category_controller.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/src/screens/Service/shoping/widgets/wishlist_heart_icon.dart';

// Simple Product Card Widget
class SimpleProductCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback? onTap;

  const SimpleProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 8, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image with Heart Icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child:
                      product.primaryImageUrl.isNotEmpty
                          ? Image.network(
                            product.primaryImageUrl,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildLoadingImage();
                            },
                          )
                          : _buildPlaceholderImage(),
                ),
                // Heart Icon (Favourite)
                Positioned(
                  top: 6,
                  right: 6,
                  child: WishlistHeartIcon(productId: product.id, iconSize: 18),
                ),
                // Flash Sale Badge
                if (product.flashSale.isCurrentlyActive)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '-${product.flashSale.getDiscountPercentage(product.price).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Product Info with Flexible Space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Brand
                    if (product.brand.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.brand,
                        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Small Description (only if space allows)
                    if (product.description.isNotEmpty &&
                        product.brand.isEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[500],
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const Spacer(),

                    // Price and Rating (pushes to bottom)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Price Section with Flash Sale Support
                        if (product.flashSale.isCurrentlyActive &&
                            product.flashSale.discountPrice != null) ...[
                          // Flash Sale Price Display
                          Row(
                            children: [
                              Text(
                                '৳${product.flashSale.discountPrice!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[600],
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.local_fire_department,
                                size: 10,
                                color: Colors.red[600],
                              ),
                            ],
                          ),
                          // Original Price (crossed out)
                          Text(
                            '৳${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                              height: 1,
                            ),
                          ),
                        ] else ...[
                          // Regular Price
                          Text(
                            '৳${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],

                        const SizedBox(height: 2),

                        // Reviews (Rating) - Always show stars
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                size: 9,
                                color:
                                    index < product.rating.filledStars
                                        ? Colors.amber
                                        : Colors.grey[300],
                              );
                            }),
                            const SizedBox(width: 2),
                            Text(
                              '(${product.rating.count})',
                              style: TextStyle(
                                fontSize: 8,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 90,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 30, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      width: double.infinity,
      height: 90,
      color: Colors.grey[100],
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}

// Grid version for search results
class SimpleProductGridCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback? onTap;

  const SimpleProductGridCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SimpleProductCard(product: product, onTap: onTap);
  }
}

class ProductCategoryScreen extends StatelessWidget {
  final ProductCategoryController controller;

  const ProductCategoryScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          controller.categoryTitle,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.hasError.value && controller.products.isEmpty) {
          return _buildErrorState();
        }

        if (controller.products.isEmpty) {
          return _buildEmptyState();
        }

        return _buildProductGrid();
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading ${controller.categoryTitle.toLowerCase()}...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.retryLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No ${controller.categoryTitle.toLowerCase()} available at the moment',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: controller.refreshProducts,
      child: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          // Product count header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.products.length} products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (controller.isLoadingMore.value)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Product grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = controller.products[index];
                return SimpleProductGridCard(
                  product: product,
                  onTap: () => controller.navigateToProductDetail(product),
                );
              }, childCount: controller.products.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
            ),
          ),

          // Loading more indicator
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoadingMore.value) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  ),
                );
              }

              if (!controller.hasMoreData.value &&
                  controller.products.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No more products',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            }),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

// Specific category screens
class FreshSellProductsScreen extends StatelessWidget {
  const FreshSellProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductCategoryController>(
      init: ProductCategoryController.freshSell(),
      builder: (controller) => ProductCategoryScreen(controller: controller),
    );
  }
}

class NewProductsScreen extends StatelessWidget {
  const NewProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductCategoryController>(
      init: ProductCategoryController.newProducts(),
      builder: (controller) => ProductCategoryScreen(controller: controller),
    );
  }
}

class TrendingProductsScreen extends StatelessWidget {
  const TrendingProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductCategoryController>(
      init: ProductCategoryController.trending(),
      builder: (controller) => ProductCategoryScreen(controller: controller),
    );
  }
}

class TopSellingProductsScreen extends StatelessWidget {
  const TopSellingProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductCategoryController>(
      init: ProductCategoryController.topSelling(),
      builder: (controller) => ProductCategoryScreen(controller: controller),
    );
  }
}

class FlashSaleProductsScreen extends StatelessWidget {
  const FlashSaleProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductCategoryController>(
      init: ProductCategoryController.flashSale(),
      builder: (controller) => ProductCategoryScreen(controller: controller),
    );
  }
}

class TopRatedProductsScreen extends StatelessWidget {
  const TopRatedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductCategoryController>(
      init: ProductCategoryController.topRated(),
      builder: (controller) => ProductCategoryScreen(controller: controller),
    );
  }
}

class ExclusiveProductsScreen extends StatelessWidget {
  const ExclusiveProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductCategoryController>(
      init: ProductCategoryController.exclusive(),
      builder: (controller) => ProductCategoryScreen(controller: controller),
    );
  }
}
