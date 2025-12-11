// Simple Product Card Widget with Flash Sale Support
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
            // Product Image with Heart Icon and Flash Sale Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: product.primaryImageUrl.isNotEmpty
                      ? Image.network(
                          product.primaryImageUrl,
                          width: double.infinity,
                          height: 90,
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
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Group 1: Title and Brand (stays at top)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        
                        const SizedBox(height: 2),
                        
                        // Brand
                        if (product.brand.isNotEmpty)
                          Text(
                            product.brand,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    
                    // Group 2: Price and Rating (pushes to bottom)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Section with Flash Sale Support
                        if (product.flashSale.isCurrentlyActive && 
                            product.flashSale.discountPrice != null) ...[
                          // Flash Sale Price Display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Flash Sale Price (prominently displayed)
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
                                    size: 12,
                                    color: Colors.red[600],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              // Original Price (crossed out)
                              Text(
                                '৳${product.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
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
                        
                        // Reviews (Rating) - Always show stars
                        Row(
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
                            Text(
                              '(${product.rating.count})',
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
            size: 24,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 2),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 8,
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
          width: 16,
          height: 16,
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
