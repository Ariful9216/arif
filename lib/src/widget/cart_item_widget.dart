import 'package:flutter/material.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/cart_model.dart';
import 'package:arif_mart/src/widget/app_image.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;
  final bool isUpdating;

  const CartItemWidget({
    super.key,
    required this.item,
    this.isSelectMode = false,
    this.isSelected = false,
    this.onToggleSelect,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
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
            if (isSelectMode)
              Checkbox(
                value: isSelected,
                onChanged: (value) => onToggleSelect?.call(),
              ),
            
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
                      Expanded(
                        child: Text(
                          '\$${item.calculatedEffectivePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(width: 4),
                      
                      // Quantity controls
                      _buildQuantityControls(),
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
                  
                  // Item total and remove button
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
                      if (!isSelectMode)
                        InkWell(
                          onTap: onRemove,
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

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: isUpdating ? null : onDecrement,
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.remove, 
                size: 16,
                color: isUpdating ? Colors.grey : null,
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            constraints: const BoxConstraints(minWidth: 32),
            child: isUpdating
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          
          InkWell(
            onTap: isUpdating ? null : onIncrement,
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.add, 
                size: 16,
                color: isUpdating ? Colors.grey : null,
              ),
            ),
          ),
        ],
      ),
    );
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