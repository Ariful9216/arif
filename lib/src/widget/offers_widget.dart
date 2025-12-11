import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/banner_model.dart';

class OffersWidget extends StatefulWidget {
  final RxList<BannerData> offers;
  final RxBool isLoading;

  const OffersWidget({
    super.key,
    required this.offers,
    required this.isLoading,
  });

  @override
  State<OffersWidget> createState() => _OffersWidgetState();
}

class _OffersWidgetState extends State<OffersWidget> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.isLoading.value) {
        return _buildLoadingWidget();
      }

      if (widget.offers.isEmpty) {
        return _buildEmptyOffersWidget();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Special Offers",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Offers Carousel with 16:9 aspect ratio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: AspectRatio(
              aspectRatio: 16 / 9, // 16:9 aspect ratio (1280x720)
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.offers.length,
                itemBuilder: (context, index) {
                  final offer = widget.offers[index];
                  return _buildOfferCard(offer);
                },
              ),
            ),
          ),
          
          // Page Indicators (if more than one offer)
          if (widget.offers.length > 1) ...[
            const SizedBox(height: 12),
            _buildPageIndicators(),
          ],
        ],
      );
    });
  }

  Widget _buildOfferCard(BannerData offer) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image (if available)
          if (offer.fullImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                offer.fullImageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Offer image failed to load: ${offer.fullImageUrl}');
                  return _buildDefaultOfferContent(offer);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    print('Offer image loaded successfully: ${offer.fullImageUrl}');
                    return child;
                  }
                  return _buildDefaultOfferContent(offer);
                },
              ),
            )
          else
            _buildDefaultOfferContent(offer),
            
          // Gradient Overlay for better text readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          
          // Offer Content
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (offer.title.isNotEmpty)
                  Text(
                    offer.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                if (offer.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    offer.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultOfferContent(BannerData offer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Text(
              "Special\nOffer",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (offer.title.isNotEmpty)
                    Flexible(
                      child: Text(
                        offer.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  if (offer.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        offer.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.offers.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 16 / 9, // 16:9 aspect ratio (1280x720)
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
                const SizedBox(height: 12),
                Text(
                  "Loading offers...",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOffersWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 16 / 9, // 16:9 aspect ratio (1280x720)
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  "No special offers available",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Check back later for exciting deals!",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

