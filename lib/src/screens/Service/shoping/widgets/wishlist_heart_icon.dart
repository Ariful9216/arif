import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/src/screens/Service/shoping/wishlist/controller/wishlist_controller.dart';

class WishlistHeartIcon extends StatefulWidget {
  final String productId;
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showBackground;
  final VoidCallback? onToggle;

  const WishlistHeartIcon({
    super.key,
    required this.productId,
    this.iconSize = 24,
    this.activeColor,
    this.inactiveColor,
    this.showBackground = false,
    this.onToggle,
  });

  @override
  State<WishlistHeartIcon> createState() => _WishlistHeartIconState();
}

class _WishlistHeartIconState extends State<WishlistHeartIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Check initial wishlist status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialStatus();
    });
  }

  void _checkInitialStatus() {
    try {
      final controller = Get.find<WishlistController>();
      // Always check status from API to ensure synchronization
      controller.checkProductWishlistStatus(widget.productId);
      
      // Force a UI update
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('WishlistController not found: $e');
      // Try again after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _checkInitialStatus();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleWishlist() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    final controller = Get.find<WishlistController>();
    final success = await controller.toggleWishlist(widget.productId);

    if (success) {
      // Animate the heart
      await _animationController.forward();
      await _animationController.reverse();
      
      // Show feedback
      final isInWishlist = controller.isProductInWishlist(widget.productId);
      Get.snackbar(
        isInWishlist ? 'Added to Wishlist' : 'Removed from Wishlist',
        isInWishlist 
            ? 'Product added to your favourites'
            : 'Product removed from your favourites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isInWishlist ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: Icon(
          isInWishlist ? Icons.favorite : Icons.heart_broken,
          color: Colors.white,
        ),
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to update wishlist. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }

    setState(() {
      _isAnimating = false;
    });

    // Call optional callback
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WishlistController>(
      builder: (controller) {
        if (controller == null) {
          // Show default heart icon when controller is not available
          return Icon(
            Icons.favorite_border,
            size: widget.iconSize,
            color: widget.inactiveColor ?? Colors.grey[400]!,
          );
        }
        
        return Obx(() {
          final isInWishlist = controller.isProductInWishlist(widget.productId);
          final activeColor = widget.activeColor ?? Colors.red;
          final inactiveColor = widget.inactiveColor ?? Colors.grey[400]!;

          Widget heartIcon = AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  size: widget.iconSize,
                  color: isInWishlist ? activeColor : inactiveColor,
                ),
              );
            },
          );

          if (widget.showBackground) {
            heartIcon = Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: heartIcon,
            );
          }

          return GestureDetector(
            onTap: _isAnimating ? null : _toggleWishlist,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: heartIcon,
            ),
          );
        });
      },
    );
  }
}

// Specific widget for product detail page
class ProductDetailHeartIcon extends StatelessWidget {
  final String productId;

  const ProductDetailHeartIcon({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return WishlistHeartIcon(
      productId: productId,
      iconSize: 26,
      activeColor: Colors.red,
      inactiveColor: Colors.white,
      showBackground: false,
    );
  }
}

// Specific widget for product cards
class ProductCardHeartIcon extends StatelessWidget {
  final String productId;

  const ProductCardHeartIcon({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: WishlistHeartIcon(
        productId: productId,
        iconSize: 20,
        activeColor: Colors.red,
        inactiveColor: Colors.grey[600]!,
        showBackground: true,
      ),
    );
  }
}
