import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/banner_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ShoppingBannerWidget extends StatefulWidget {
  final List<BannerData> banners;
  final double height;
  final EdgeInsets margin;
  final BorderRadius? borderRadius;

  const ShoppingBannerWidget({
    super.key,
    required this.banners,
    this.height = 160,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius,
  });

  @override
  State<ShoppingBannerWidget> createState() => _ShoppingBannerWidgetState();
}

class _ShoppingBannerWidgetState extends State<ShoppingBannerWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Auto-scroll if there are multiple banners
    if (widget.banners.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  Future<void> _onBannerTap(BannerData banner) async {
    if (banner.linkUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(banner.linkUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Error',
            'Cannot open this link',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Error launching URL: $e');
        Get.snackbar(
          'Error',
          'Invalid link format',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return _buildPlaceholderBanner();
    }

    return Container(
      margin: widget.margin,
      child: AspectRatio(
        aspectRatio: 16 / 9, // 16:9 aspect ratio (1280x720)
        child: Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Banner PageView
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.banners.length,
                itemBuilder: (context, index) {
                  final banner = widget.banners[index];
                  return _buildBannerItem(banner);
                },
              ),
              
              // Page indicators (if more than one banner)
              if (widget.banners.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: _buildPageIndicators(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerItem(BannerData banner) {
    return GestureDetector(
      onTap: () => _onBannerTap(banner),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          color: AppColors.primaryColor,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background image (if available)
            if (banner.fullImageUrl.isNotEmpty)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                  child: Image.network(
                    banner.fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Banner image load error: $error');
                      print('Banner image URL: ${banner.fullImageUrl}');
                      return _buildDefaultBannerContent(banner);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        print('Banner image loaded successfully: ${banner.fullImageUrl}');
                        return child;
                      }
                      return _buildLoadingBanner();
                    },
                  ),
                ),
              )
            else
              Positioned.fill(child: _buildDefaultBannerContent(banner)),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBannerContent(BannerData banner) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            banner.title.isNotEmpty ? banner.title : "Quick Bond Plush",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (banner.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              banner.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderBanner() {
    return Container(
      margin: widget.margin,
      child: AspectRatio(
        aspectRatio: 16 / 9, // 16:9 aspect ratio (1280x720)
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Quick Bond Plush",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "No banners available - Loading from API...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBanner() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.3),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.banners.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentPage == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index 
                ? Colors.white 
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
