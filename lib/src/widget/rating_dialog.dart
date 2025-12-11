import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/services/rating_service.dart';
import 'package:arif_mart/core/services/rated_products_service.dart';

class RatingDialog extends StatefulWidget {
  final String productId;
  final String productName;
  final String? productImage;

  const RatingDialog({
    super.key,
    required this.productId,
    required this.productName,
    this.productImage,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Image
          if (widget.productImage != null)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.productImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, size: 40, color: Colors.grey);
                  },
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Product Name
          Text(
            widget.productName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: index < _selectedRating ? Colors.amber : Colors.grey,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Rating Text
          Text(
            _selectedRating == 0 
                ? 'Tap a star to rate'
                : 'You rated: $_selectedRating star${_selectedRating > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 14,
              color: _selectedRating == 0 ? Colors.grey[600] : Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedRating == 0 || _isSubmitting ? null : _submitRating,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _submitRating() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await RatingService.rateProduct(
        productId: widget.productId,
        rating: _selectedRating,
      );
      
      // Mark product as rated after successful submission
      final ratedProductsService = Get.put(RatedProductsService());
      ratedProductsService.markProductAsRated(widget.productId);
      
      if (mounted) {
        Navigator.of(context).pop();
        Get.snackbar(
          'Success',
          'Thank you for your rating!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to submit rating. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
