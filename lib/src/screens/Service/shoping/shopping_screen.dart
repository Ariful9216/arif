import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'package:arif_mart/src/widget/shopping_banner_widget.dart';
import 'package:arif_mart/src/widget/offers_widget.dart';
import 'package:arif_mart/src/screens/Service/shoping/address/address_list_screen.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/src/screens/Service/shoping/widgets/wishlist_heart_icon.dart';

import 'controller/shopping_controller.dart';

// Simple Product Card Widget
class SimpleProductCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback? onTap;

  const SimpleProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

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
                  child: product.primaryThumbnailUrl.isNotEmpty
                      ? Image.network(
                          product.primaryThumbnailUrl,
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                          cacheWidth: 300,  // Optimize memory usage
                          cacheHeight: 300,
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
                  child: WishlistHeartIcon(
                    productId: product.id,
                    iconSize: 18,
                  ),
                ),
                // Flash Sale Badge
                if (product.flashSale.isCurrentlyActive)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Brand (if available)
                    if (product.brand.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Description (if available)
                    if (product.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[500],
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Spacer to push price to bottom
                    const Spacer(flex: 1),
                    
                    // Price Section with Flash Sale Support
                    if (product.flashSale.isCurrentlyActive && 
                        product.flashSale.discountPrice != null) ...[
                      // Flash Sale Price
                      Row(
                        children: [
                          Text(
                            '৳${product.flashSale.discountPrice!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[600],
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.local_fire_department,
                            size: 11,
                            color: Colors.red[600],
                          ),
                        ],
                      ),
                      // Original Price (crossed out)
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 9,
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
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 2),
                    
                    // Reviews (Rating) - Compact display
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 10,
                            color: index < product.rating.filledStars 
                                ? Colors.amber 
                                : Colors.grey[300],
                          );
                        }),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '(${product.rating.count})',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
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
          Icon(
            Icons.image,
            size: 30,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
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

  const SimpleProductGridCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleProductCard(
      product: product,
      onTap: onTap,
    );
  }
}

class ShoppingScreen extends StatelessWidget {
  ShoppingScreen({super.key});

  final controller = Get.put(ShoppingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            const SizedBox(width: 8),
            const Text("Shopping", style: TextStyle(color: Colors.white)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () => Get.back()
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: () => Get.to(() => const AddressListScreen()),
            tooltip: 'Manage Addresses',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          await controller.refreshData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Scrollable Brand Banner Section
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Obx(() => controller.isBannersLoading.value
                  ? Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                        ),
                      ),
                    )
                  : ShoppingBannerWidget(
                      banners: controller.banners,
                      height: 180,
                      margin: EdgeInsets.zero,
                    ),
                ),
              ),

              // Search Section
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() => TextField(
                  onChanged: controller.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryColor,
                      size: 22,
                    ),
                    suffixIcon: controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            onPressed: controller.clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                )),
              ),
            // Categories Section - Horizontal Scrollable Chips
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Obx(() {
                if (controller.isCategoriesLoading.value) {
                  return Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                        ),
                      ),
                    ),
                  );
                }

                if (controller.categories.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: false,
                          onSelected: (_) => controller.selectCategory(category.id),
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
              
            // Menu Section
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MenuItem(
                    icon: Icons.dashboard, 
                    label: "Dashboard", 
                    onTap: () => Get.toNamed(Routes.shoppingDashboard)
                  ),
                  MenuItem(
                    icon: Icons.favorite, 
                    label: "Favorites",
                    onTap: controller.navigateToFavorites,
                  ),
                  Obx(() => MenuItem(
                    icon: Icons.shopping_cart, 
                    label: "Cart",
                    onTap: controller.navigateToCart,
                    badgeCount: controller.cartItemCount.value > 0 
                        ? controller.cartItemCount.value 
                        : null,
                  )),
                ],
              ),
            ),
              
              // Search Results Section (shows when searching)
              Obx(() => controller.hasSearchResults.value || controller.isLoadingSearch.value
                ? _buildSearchResults()
                : _buildProductSections()),
           ],
         ),
       ),
      ),
    );
  }

  // Search Results Section
  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Results Header
          Obx(() => Row(
            children: [
              Text(
                'Search Results',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (controller.searchResults.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '(${controller.searchResults.length})',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          )),
          
          const SizedBox(height: 16),
          
          // Search Results Content
          Obx(() {
            if (controller.isLoadingSearch.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (controller.searchResults.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching with different keywords',
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
            
            // Search Results Grid
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final product = controller.searchResults[index];
                return SimpleProductGridCard(
                  product: product,
                  onTap: () {
                    Get.toNamed(
                      Routes.productDetail,
                      arguments: {'productId': product.id},
                    );
                  },
                );
              },
            );
          }),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Product Sections (when not searching)
  Widget _buildProductSections() {
    return Column(
      children: [
        // Flash Sale Section (moved to top)
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: buildSectionHeader(
            "Flash Sale",
            onViewAllTap: () => Get.toNamed(Routes.flashSaleProducts),
          ),
        ),
        Obx(() => controller.isLoadingFlashSale.value
          ? _buildLoadingSection()
          : Container(
              height: 280,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.flashSaleProducts.length,
                itemBuilder: (_, index) {
                  final product = controller.flashSaleProducts[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: SimpleProductCard(
                      product: product,
                      onTap: () {
                        Get.toNamed(
                          Routes.productDetail,
                          arguments: {'productId': product.id},
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),

        // New Products Section
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: buildSectionHeader(
            "New Products",
            onViewAllTap: () => Get.toNamed(Routes.newProducts),
          ),
        ),
        Obx(() => controller.isLoadingNewProducts.value
          ? _buildLoadingSection()
          : Container(
              height: 280,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.newProducts.length,
                itemBuilder: (_, index) {
                  final product = controller.newProducts[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: SimpleProductCard(
                      product: product,
                      onTap: () {
                        Get.toNamed(
                          Routes.productDetail,
                          arguments: {'productId': product.id},
                        );
                      },
                    ),
                  );
                },
                ),
              ),
            ),

            const SizedBox(height: 20),
        
        // Dynamic Offers Section
        OffersWidget(
          offers: controller.offers,
          isLoading: controller.isOffersLoading,
        ).paddingSymmetric(vertical: 15),

        // Trending Section
        buildSectionHeader(
          "Trending",
          onViewAllTap: () => Get.toNamed(Routes.trendingProducts),
        ).paddingSymmetric(vertical: 10),
        Obx(() => controller.isLoadingTrending.value
          ? _buildLoadingSection()
          : SizedBox(
              height: 250, // Match SimpleProductCard height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: controller.trendingProducts.length,
                  itemBuilder: (_, index) {
                  final product = controller.trendingProducts[index];
                  return SimpleProductCard(
                    product: product,
                    onTap: () {
                      Get.toNamed(
                        Routes.productDetail,
                        arguments: {'productId': product.id},
                      );
                    },
                  );
                },
              ),
            ),
        ),
        
        // Top Selling Section
        buildSectionHeader(
          "Top Selling",
          onViewAllTap: () => Get.toNamed(Routes.topSellingProducts),
        ).paddingSymmetric(vertical: 10),
        Obx(() => controller.isLoadingTopSelling.value
          ? _buildLoadingSection()
          : SizedBox(
              height: 250, // Match SimpleProductCard height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: controller.topSellingProducts.length,
                itemBuilder: (_, index) {
                  final product = controller.topSellingProducts[index];
                  return SimpleProductCard(
                    product: product,
                    onTap: () {
                      Get.toNamed(
                        Routes.productDetail,
                        arguments: {'productId': product.id},
                      );
                    },
                  );
                },
              ),
            ),
        ),
        
        // Top Rated Section
        buildSectionHeader(
          "Top Rated",
          onViewAllTap: () => Get.toNamed(Routes.topRatedProducts),
        ).paddingSymmetric(vertical: 10),
        Obx(() => controller.isLoadingTopRated.value
          ? _buildLoadingSection()
          : SizedBox(
              height: 250, // Match SimpleProductCard height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: controller.topRatedProducts.length,
                  itemBuilder: (_, index) {
                  final product = controller.topRatedProducts[index];
                  return SimpleProductCard(
                    product: product,
                    onTap: () {
                      Get.toNamed(
                        Routes.productDetail,
                        arguments: {'productId': product.id},
                      );
                    },
                  );
                  },
                ),
              ),
            ),
        
        // Exclusive Section
        buildSectionHeader(
          "Exclusive",
          onViewAllTap: () => Get.toNamed(Routes.exclusiveProducts),
        ).paddingSymmetric(vertical: 10),
        Obx(() => controller.isLoadingExclusive.value
          ? _buildLoadingSection()
          : SizedBox(
              height: 250, // Match SimpleProductCard height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: controller.exclusiveProducts.length,
                  itemBuilder: (_, index) {
                  final product = controller.exclusiveProducts[index];
                  return SimpleProductCard(
                    product: product,
                    onTap: () {
                      Get.toNamed(
                        Routes.productDetail,
                        arguments: {'productId': product.id},
                      );
                    },
                  );
                  },
                ),
              ),
            ).paddingOnly(bottom: 10),

        // All Products Section
        buildSectionHeader(
          "All Products",
        ).paddingSymmetric(vertical: 10),
        _buildAllProductsSection(controller),
          ],
    );
  }



  Widget _buildLoadingSection() {
    return SizedBox(
      height: 220, // Match SimpleProductCard height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: 3,
        itemBuilder: (_, index) {
          return Container(
            width: 160,
            height: 220,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget buildSectionHeader(String title, {VoidCallback? onViewAllTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            title, 
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Conditionally show "View All" button
        if (title != "All Products" && onViewAllTap != null)
          GestureDetector(
            onTap: onViewAllTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                "View All", 
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function()? onTap;
  final int? badgeCount;

  const MenuItem({
    super.key, 
    required this.icon, 
    required this.label, 
    this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 28),
              if (badgeCount != null && badgeCount! > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount! > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final int? rating;
  final String? description;

  const ProductCard({super.key, required this.name, required this.price, this.rating, this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2), border: Border.all(color: Colors.grey)),
        margin: const EdgeInsets.only(right: 10),
        child: SizedBox(
          width: 140,
          child: Column(
            children: [
              Container(
                height: 70,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: const Text("Quick Bond Plush", style: TextStyle(color: AppColors.primaryColor, fontSize: 10)),
              ),
              const SizedBox(height: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(price, style: const TextStyle(color: AppColors.primaryColor)),
              if (rating != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => Icon(Icons.star, color: index < rating! ? Colors.black : Colors.grey, size: 16)),
                ),
              if (description != null) Text(description!, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// Grid version for All Products section - OPTIMIZED SIZE
class AllProductsGridCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback? onTap;

  const AllProductsGridCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            // Product Image with Heart Icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: product.primaryThumbnailUrl.isNotEmpty
                      ? Image.network(
                          product.primaryThumbnailUrl,
                          width: double.infinity,
                          height: 120, // Slightly taller for grid
                          fit: BoxFit.cover,
                          cacheWidth: 300,
                          cacheHeight: 300,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
                // Heart Icon
                Positioned(
                  top: 6,
                  right: 6,
                  child: WishlistHeartIcon(
                    productId: product.id,
                    iconSize: 18,
                  ),
                ),
                // Flash Sale Badge
                if (product.flashSale.isCurrentlyActive)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
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
            
            // Product Info - Optimized for grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name - 2 lines max
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
                    
                    // Brand - always show if available
                    if (product.brand.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Description - always show if available (1 line)
                    if (product.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[500],
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Price Section
                    if (product.flashSale.isCurrentlyActive && 
                        product.flashSale.discountPrice != null) ...[
                      // Flash Sale Price
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '৳${product.flashSale.discountPrice!.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600],
                              ),
                              overflow: TextOverflow.ellipsis,
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
                      // Original Price
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                          height: 1,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 2),
                    
                    // Rating - Compact
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 9,
                            color: index < product.rating.filledStars 
                                ? Colors.amber 
                                : Colors.grey[300],
                          );
                        }),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '(${product.rating.count})',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
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
      height: 120,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 30,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function for loading grid
Widget _buildAllProductsLoadingGrid(ShoppingController controller) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.65,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemCount: 6, // Show 6 loading cards
    itemBuilder: (context, index) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}

// Helper function for load more indicator
Widget _buildLoadMoreIndicator(ShoppingController controller) {
  return Obx(() {
    if (controller.isLoadingMoreAllProducts.value) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Center(
        child: TextButton.icon(
          onPressed: () => controller.loadMoreAllProducts(),
          icon: const Icon(Icons.refresh),
          label: const Text('Load More'),
        ),
      ),
    );
  });
}

// Main function for All Products section
Widget _buildAllProductsSection(ShoppingController controller) {
    return Obx(() {
      if (controller.isLoadingAllProducts.value) {
        return _buildAllProductsLoadingGrid(controller);
      }
      
      if (controller.allProducts.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'No products available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }
      
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65, // Changed from 0.7 to 0.65 for more height
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.allProducts.length + 
                   (controller.hasMoreAllProducts.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.allProducts.length) {
            // Load more indicator
            return _buildLoadMoreIndicator(controller);
          }
          
          final product = controller.allProducts[index];
          return AllProductsGridCard( // Changed from SimpleProductCard
            product: product,
            onTap: () {
              Get.toNamed(
                Routes.productDetail,
                arguments: {'productId': product.id},
              );
            },
          );
        },
      );
    });
  }