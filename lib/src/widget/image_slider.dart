import 'package:flutter/material.dart';
import 'dart:async';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/slider_model.dart';
import 'package:arif_mart/src/widget/cached_image_widget.dart';

class ImageSlider extends StatefulWidget {
  final List<SliderItem> sliders;
  final Function(String)? onSliderTap;

  const ImageSlider({
    super.key,
    required this.sliders,
    this.onSliderTap,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider>
    with TickerProviderStateMixin {
  late PageController _pageController;
  Timer? _autoScrollTimer; // Changed to nullable
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Auto-scroll timer - use Timer instead of recursion to prevent memory leaks
    if (widget.sliders.length > 1) {
      _autoScrollTimer = Timer.periodic(
        const Duration(seconds: 5), // Increased from 3 to 5 seconds
        (_) {
          if (mounted && widget.sliders.length > 1) {
            int nextPage = (_currentPage + 1) % widget.sliders.length;
            if (_pageController.hasClients) {
              _pageController.animateToPage(
                nextPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel(); // Only cancel if timer was initialized
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sliders.isEmpty) {
      // Fallback to original logo if no sliders
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.asset('assets/logo.png', width: 120, height: 120),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9, // 16:9 aspect ratio (1280x720)
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image PageView
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.sliders.length,
                itemBuilder: (context, index) {
                  final slider = widget.sliders[index];
                  return GestureDetector(
                    onTap: () => widget.onSliderTap?.call(slider.link),
                    child: CachedSliderImage(
                      imageUrl: slider.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                },
              ),
            ),
          
          // Dots indicator (only show if more than 1 slider)
          if (widget.sliders.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.sliders.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
            
          // Gradient overlay for better text visibility
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
} 