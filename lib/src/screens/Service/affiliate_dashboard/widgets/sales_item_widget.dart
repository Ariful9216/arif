import 'package:flutter/material.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/affiliate_sales_model.dart';
import 'package:arif_mart/src/widget/cached_image_widget.dart';

class SalesItemWidget extends StatelessWidget {
  final AffiliateSale sale;

  const SalesItemWidget({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Info Row
          Row(
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(),
                ),
              ),
              const SizedBox(width: 12),
              
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.productId.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '৳${sale.productId.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status Badge
              _buildStatusBadge(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Sales Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Amount',
                  '৳${sale.amount.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Rate',
                  '${sale.cashbackRate.toStringAsFixed(1)}%',
                  Icons.percent,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Cashback',
                  '৳${sale.cashbackAmount.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Date
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(sale.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final primaryPicture = sale.productId.primaryPicture;
    
    if (primaryPicture != null) {
      // Use the fullThumbnailUrl for better performance in list view
      final fullImageUrl = primaryPicture.fullThumbnailUrl;
      
      print('🖼️ Product Image URL: ${primaryPicture.url}');
      print('🖼️ Full Image URL: $fullImageUrl');
      
      return CachedImageWidget(
        imageUrl: fullImageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.image,
            color: Colors.grey,
            size: 24,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 24,
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.image,
          color: Colors.grey,
          size: 24,
        ),
      );
    }
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    
    switch (sale.status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'completed':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'cancelled':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(sale.status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
