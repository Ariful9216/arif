import 'package:flutter/material.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/product_model.dart';

class CategoryProductCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback onTap;

  const CategoryProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.primaryThumbnailUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      cacheWidth: 400,  // Optimize memory usage
                      cacheHeight: 400,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildPlaceholderImage();
                      },
                    ),
                  ),
                  
                  // Flash Sale Badge
                  if (product.flashSale.isCurrentlyActive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${_calculateDiscountPercentage(product)}% OFF',
                              style: const TextStyle(
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
            
            // Product Info
            Padding(
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
                  
                  const SizedBox(height: 4),
                  
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
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.grey[400],
          size: 40,
        ),
      ),
    );
  }

  // Calculate discount percentage from original price and flash sale price
  int _calculateDiscountPercentage(ProductData product) {
    if (product.flashSale.discountPrice == null || product.price <= 0) {
      return 0;
    }
    final originalPrice = product.price;
    final discountPrice = product.flashSale.discountPrice!;
    final discount = ((originalPrice - discountPrice) / originalPrice * 100).round();
    return discount > 0 ? discount : 0;
  }
}
