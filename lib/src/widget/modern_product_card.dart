import 'package:flutter/material.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/src/widget/flash_sale_timer.dart';

class ModernProductCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback? onTap;
  final bool showDescription;
  final double? width;
  final double? height;

  const ModernProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showDescription = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 160,
        height: height,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            _buildProductImage(),
            
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13, // Slightly smaller font
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1, // Limit to 1 line
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Brand
                    if (product.brand.isNotEmpty)
                      Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    
                    const SizedBox(height: 6),
                    
                    // Description (if enabled)
                    if (showDescription && product.description.isNotEmpty) ...[
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                    ],
                    
                    const Spacer(),
                    
                    // Rating
                    if (product.rating.count > 0)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                size: 12,
                                color: index < product.rating.filledStars 
                                    ? Colors.amber 
                                    : Colors.grey[300],
                              );
                            }),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '(${product.rating.count})',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Price Section
                    _buildPriceSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return AspectRatio(
      aspectRatio: 4/5, // Fixed 4:5 aspect ratio for consistent product images
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: product.primaryImageUrl.isNotEmpty
                  ? Image.network(
                      product.primaryImageUrl,
                      width: double.infinity,
                      height: double.infinity,
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
          
          // Flash Sale Badge with discount percentage
          if (product.flashSale.isCurrentlyActive)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.redAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
          // Flash Sale Timer (if active)
          if (product.flashSale.isCurrentlyActive)
            Positioned(
              top: 8,
              right: 8,
              child: FlashSaleTimer(
                flashSale: product.flashSale,
              ),
            ),
          
          // Stock Status
          if (!product.isInStock)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Out of Stock',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 12,
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
      height: double.infinity,
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

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (product.flashSale.isCurrentlyActive && product.flashSale.discountPrice != null) ...[
          // Flash Sale Price Display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flash Sale Price (prominently displayed)
              Row(
                children: [
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
                ],
              ),
              
              const SizedBox(height: 2),
              
              // Original Price (crossed out) & Savings
              Row(
                children: [
                  Text(
                    '৳${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Save ৳${(product.price - product.flashSale.discountPrice!).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ] else ...[
          // Regular Price
          Text(
            product.formattedPrice,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

// Grid version for search results
class ProductGridCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback? onTap;

  const ProductGridCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernProductCard(
      product: product,
      onTap: onTap,
      showDescription: false, // Changed to false to reduce height requirements
      width: double.infinity,
      height: 280, // Adjusted height for 4:5 aspect ratio
    );
  }
}

// List version for search results
class ProductListCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback? onTap;

  const ProductListCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.primaryImageUrl.isNotEmpty
                  ? Image.network(
                      product.primaryImageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[100],
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[100],
                      child: Icon(Icons.image, color: Colors.grey[400]),
                    ),
            ),
            
            const SizedBox(width: 12),
            
            // Product Info
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (product.brand.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.brand,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // Price
                  if (product.flashSale.isCurrentlyActive) ...[
                    Row(
                      children: [
                        Text(
                          '৳${product.effectivePrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '৳${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                  
                  // Rating
                  if (product.rating.count > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 14,
                            color: index < product.rating.filledStars 
                                ? Colors.amber 
                                : Colors.grey[300],
                          );
                        }),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '(${product.rating.count})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
