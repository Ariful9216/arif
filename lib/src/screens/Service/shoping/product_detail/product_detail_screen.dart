import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/core/model/variant_model.dart';
import 'package:arif_mart/src/widget/flash_sale_timer.dart';
import 'package:arif_mart/src/screens/Service/shoping/widgets/wishlist_heart_icon.dart';
import 'controller/product_detail_controller.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductDetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(controller);
        }

        if (controller.product.value == null) {
          return _buildEmptyState();
        }

        return _buildProductDetail(controller);
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
            'Loading product details...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProductDetailController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Product',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Product not found',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildProductDetail(ProductDetailController controller) {
    final product = controller.product.value!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 16,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                controller.handleBackNavigation();
              },
              tooltip: 'Back to Home',
            ),
            title: Text(
              product.name ?? 'Product',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              // Share button (only show if affiliate program is enabled)
              if (product.affiliateProgram.isEnabled == true)
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    controller.shareProduct();
                  },
                  tooltip:
                      'Share & Earn ${product.affiliateProgram.formattedRate ?? '0%'}',
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              // Wishlist heart icon
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ProductDetailHeartIcon(productId: product.id ?? ''),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Images
                _buildImageGallery(controller),

                // Deep Link Indicator (if user came from deep link)
                _buildDeepLinkIndicator(controller),

                // Product Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name & Flash Sale
                      _buildProductHeader(product),

                      const SizedBox(height: 16),

                      // Price Section
                      Obx(() => _buildPriceSection(controller)),

                      const SizedBox(height: 24),

                      // Product Description
                      _buildDescription(product),

                      const SizedBox(height: 24),

                      // Product Details (Brand, Category, etc.)
                      _buildProductDetails(product),

                      const SizedBox(height: 24),

                      // Product Attributes (current viewing)
                      Obx(() => _buildCurrentAttributes(controller)),

                      const SizedBox(height: 24),

                      // Delivery Info
                      _buildDeliveryInfo(product),

                      const SizedBox(height: 24),

                      // Affiliate Program Card (only show if enabled)
                      if (product.affiliateProgram.isEnabled == true)
                        _buildAffiliateProgramCard(controller, product),

                      if (product.affiliateProgram.isEnabled == true)
                        const SizedBox(height: 24),

                      // Variant Cards (replacing reviews)
                      Obx(() => _buildVariantCards(controller)),

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProductBottomBar(controller: controller),
    );
  }

  Widget _buildImageGallery(ProductDetailController controller) {
    final product = controller.product.value!;
    final images = controller.currentImages;

    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No images available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Main image viewer
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: controller.imagePageController,
            onPageChanged: controller.onImagePageChanged,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              String imageUrl;

              // Handle both product pictures and variant images
              if (image is ProductPicture) {
                imageUrl = image.fullImageUrl;
              } else if (image is VariantImage) {
                imageUrl = image.fullImageUrl;
              } else {
                imageUrl = '';
              }

              return Container(
                color: Colors.grey[50],
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 350,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // Flash Sale Badge
        if (product.flashSale.isCurrentlyActive)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.redAccent],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '-${product.flashSale.getDiscountPercentage(product.price).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              // Flash Sale Timer
              if (product.flashSale.isCurrentlyActive)
                FlashSaleTimer(
                  flashSale: product.flashSale,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.black.withOpacity(0.7),
                ),

              // Download button
              GestureDetector(
                onTap: () {
                  final currentIndex = controller.currentImageIndex.value;
                  final image = images[currentIndex];
                  String imageUrl;

                  if (image is ProductPicture) {
                    imageUrl = image.fullImageUrl;
                  } else if (image is VariantImage) {
                    imageUrl = image.fullImageUrl;
                  } else {
                    imageUrl = '';
                  }

                  if (imageUrl.isEmpty) {
                    return;
                  }

                  controller.downloadImage(imageUrl, currentIndex);
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.download, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),

        // Image indicators (if multiple images)
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: controller.currentImageIndex.value == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          controller.currentImageIndex.value == index
                              ? AppColors.primaryColor
                              : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Thumbnail strip (if multiple images)
        if (images.length > 1)
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  String thumbnailUrl;

                  // Handle both product pictures and variant images
                  if (image is ProductPicture) {
                    thumbnailUrl = image.fullThumbnailUrl;
                  } else if (image is VariantImage) {
                    thumbnailUrl =
                        image
                            .fullImageUrl; // Variants don't have separate thumbnails
                  } else {
                    thumbnailUrl = '';
                  }

                  return Obx(
                    () => GestureDetector(
                      onTap: () => controller.goToImage(index),
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                controller.currentImageIndex.value == index
                                    ? AppColors.primaryColor
                                    : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductHeader(product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            if (product.flashSale.isCurrentlyActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SALE',
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

        // Rating and reviews
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 16,
                color:
                    index < product.rating.filledStars
                        ? Colors.amber
                        : Colors.grey[300],
              );
            }),
            const SizedBox(width: 8),
            Text(
              product.rating.formattedAverage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (product.rating.count > 0) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '(${product.rating.count} reviews)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(ProductDetailController controller) {
    final product = controller.product.value!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Price (variant or flash sale)
        Row(
          children: [
            Text(
              controller.formattedPrice,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color:
                    controller.selectedVariant.value != null
                        ? AppColors.primaryColor
                        : (product.flashSale.isCurrentlyActive
                            ? Colors.red
                            : AppColors.primaryColor),
              ),
            ),
            if (product.flashSale.isCurrentlyActive) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.local_fire_department,
                color: Colors.red[600],
                size: 20,
              ),
            ],
          ],
        ),

        // Original Price (if different)
        if (controller.formattedOriginalPrice.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                controller.formattedOriginalPrice,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              if (controller.discountPercentage > 0) ...[
                const SizedBox(width: 8),
                Text(
                  'Save ${controller.discountPercentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],

        const SizedBox(height: 8),

        // Stock Status
        Row(
          children: [
            Icon(
              controller.isInStock ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: controller.isInStock ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              controller.isInStock
                  ? 'In Stock (${controller.currentStock} available)'
                  : 'Out of Stock',
              style: TextStyle(
                fontSize: 14,
                color:
                    controller.isInStock ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Variant Selection Indicator
        if (controller.isViewingVariant.value &&
            controller.selectedVariant.value != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Selected: ${controller.selectedVariant.value!.attributes.values.join(', ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildProductDetails(product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        _buildDetailRow('Brand', product.brand),
        _buildDetailRow('SKU', product.id),
        if (product.categories.isNotEmpty)
          _buildDetailRow('Category', product.categories.first.name),
        if (product.tags.isNotEmpty)
          _buildDetailRow('Tags', product.tags.join(', ')),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Delivery Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_city, color: Colors.blue[600], size: 16),
              const SizedBox(width: 8),
              Text(
                'Inside City: ৳${product.deliveryCost.insideCity}',
                style: TextStyle(fontSize: 14, color: Colors.blue[700]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[600], size: 16),
              const SizedBox(width: 8),
              Text(
                'Outside City: ৳${product.deliveryCost.outsideCity}',
                style: TextStyle(fontSize: 14, color: Colors.blue[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Current attributes display
  Widget _buildCurrentAttributes(ProductDetailController controller) {
    final attributes = controller.currentAttributes;

    if (attributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Specifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (controller.isViewingVariant.value) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'VARIANT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        ...attributes.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    entry.key.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Text(': '),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Variant cards (replacing reviews)
  Widget _buildVariantCards(ProductDetailController controller) {
    if (controller.isLoadingVariants.value) {
      return _buildVariantsLoading();
    }

    if (!controller.hasVariants) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Available Variants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (controller.isViewingVariant.value)
              TextButton(
                onPressed: () => controller.selectVariant(null),
                child: Text(
                  'View Original',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Original product card (if viewing variant)
        if (controller.isViewingVariant.value) ...[
          _buildOriginalProductCard(controller),
          const SizedBox(height: 12),
        ],

        // Variant cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85, // Increased height for more content space
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.variants.length,
          itemBuilder: (context, index) {
            final variant = controller.variants[index];
            final isSelected =
                controller.selectedVariant.value?.id == variant.id;

            return _buildVariantCard(controller, variant, isSelected);
          },
        ),
      ],
    );
  }

  // Loading state for variants
  Widget _buildVariantsLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading variants...',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Original product card
  Widget _buildOriginalProductCard(ProductDetailController controller) {
    final product = controller.product.value!;

    return GestureDetector(
      onTap: () => controller.selectVariant(null),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              !controller.isViewingVariant.value
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                !controller.isViewingVariant.value
                    ? AppColors.primaryColor
                    : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.primaryThumbnailUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, color: Colors.grey[400]),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'ORIGINAL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      if (!controller.isViewingVariant.value)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryColor,
                          size: 16,
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      if (product.flashSale.isCurrentlyActive &&
                          product.flashSale.discountPrice != null) ...[
                        Text(
                          '৳${product.flashSale.discountPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: Colors.red[600],
                        ),
                      ] else ...[
                        Text(
                          '৳${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],

                      const Spacer(),

                      Text(
                        '${product.quantity} left',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  // Affiliate Program Card
  Widget _buildAffiliateProgramCard(
    ProductDetailController controller,
    ProductData product,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Affiliate Program',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Share this product and earn commission when someone buys through your link!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commission Rate',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      product.affiliateProgram.formattedRate,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'You Earn',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      product.formattedCashbackAmount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.shareProduct(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.share, size: 18),
              label: const Text(
                'Share & Earn',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Individual variant card
  Widget _buildVariantCard(
    ProductDetailController controller,
    ProductVariant variant,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => controller.selectVariant(variant),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Variant image
            Expanded(
              flex: 5, // Reduced flex for image to give more space to content
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child:
                        variant.images.isNotEmpty
                            ? Image.network(
                              variant.images.first.fullImageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[400],
                                      size: 24, // Smaller icon
                                    ),
                                  ),
                                );
                              },
                            )
                            : Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                  size: 24, // Smaller icon
                                ),
                              ),
                            ),
                  ),

                  // Selection indicator
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12, // Smaller check icon
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Variant info
            Expanded(
              flex: 4, // Increased flex for content area
              child: Padding(
                padding: const EdgeInsets.all(6), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Use minimum space needed
                  children: [
                    // Attributes (show only most important ones)
                    if (variant.attributes.isNotEmpty) ...[
                      Flexible(
                        // Use Flexible instead of fixed height
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                variant.attributes.entries.take(2).map((entry) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      '${entry.value}', // Show only value, not key
                                      style: const TextStyle(
                                        fontSize: 9, // Smaller font
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3), // Reduced spacing
                    ],

                    // Price and stock
                    Flexible(
                      // Use Flexible for price section
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              variant.formattedPrice,
                              style: TextStyle(
                                fontSize: 13, // Slightly smaller font
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${variant.quantity}',
                            style: TextStyle(
                              fontSize: 9, // Smaller font
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
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

  // Build deep link indicator banner
  Widget _buildDeepLinkIndicator(ProductDetailController controller) {
    // Check if user came from deep link (no previous route)
    final cameFromDeepLink = Get.previousRoute == '';

    if (!cameFromDeepLink) {
      return const SizedBox.shrink(); // Don't show if not from deep link
    }

    return Obx(() {
      if (!controller.showDeepLinkIndicator.value) {
        return const SizedBox.shrink(); // Don't show if dismissed
      }

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.link, color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You came from a shared link. Tap the back button to go to home!',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: AppColors.primaryColor, size: 18),
              onPressed: () {
                controller.showDeepLinkIndicator.value = false;
              },
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      );
    });
  }
}

// Bottom bar for add to cart and quantity
class ProductBottomBar extends StatelessWidget {
  final ProductDetailController controller;

  const ProductBottomBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          print(
            '🔍 ProductBottomBar - itemAddedToCart: ${controller.itemAddedToCart.value}',
          );
          print('🔍 ProductBottomBar - isInStock: ${controller.isInStock}');
          if (!controller.isInStock) {
            return SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Out of Stock',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }

          // Show quantity control and Go to Cart button if item was added to cart
          if (controller.itemAddedToCart.value) {
            return Row(
              children: [
                // Quantity selector
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: controller.decreaseQuantity,
                        icon: const Icon(Icons.remove),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          controller.quantity.value.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: controller.increaseQuantity,
                        icon: const Icon(Icons.add),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Go to Cart button
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.goToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Go to Cart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Show normal Add to Cart interface
          return Row(
            children: [
              // Quantity selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: controller.decreaseQuantity,
                      icon: const Icon(Icons.remove),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        controller.quantity.value.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.increaseQuantity,
                      icon: const Icon(Icons.add),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Add to cart button
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        controller.isAddingToCart.value
                            ? null
                            : controller.addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        controller.isAddingToCart.value
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              controller.isViewingVariant.value
                                  ? 'Add Variant to Cart'
                                  : 'Add to Cart',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
