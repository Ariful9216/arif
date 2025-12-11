import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/utils/image_utils.dart';

// For web platform
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// Enhanced cached image widgets for efficient image loading and caching
/// with improved error handling and placeholders
/// 
/// Usage examples:
/// 
/// ```dart
/// // Basic usage
/// CachedImageWidget(
///   imageUrl: 'https://example.com/image.jpg',
///   width: 100,
///   height: 100,
/// )
/// 
/// // For slider images
/// CachedSliderImage(
///   imageUrl: slider.imageUrl,
///   width: double.infinity,
///   height: 180,
/// )
/// ```

class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext context, String url)? placeholder;
  final Widget Function(BuildContext context, String url, dynamic error)? errorWidget;
  final Color? backgroundColor;
  final bool retryOnError;
  final int maxRetries;
  final Duration retryDuration;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.retryOnError = true,
    this.maxRetries = 3,
    this.retryDuration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION: Use cached URL (computed once, reused on rebuilds)
    final String fullUrl = ImageUtils.getFullImageUrl(imageUrl);
    
    if (fullUrl.isEmpty) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: fullUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder ?? (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) {
          // OPTIMIZATION: No logging in build - use error listener instead
          return errorWidget?.call(context, url, error) ?? _buildRetryableErrorWidget(context, url);
        },
        memCacheWidth: _getCacheWidth(),
        memCacheHeight: _getCacheHeight(),
        maxWidthDiskCache: 800,
        maxHeightDiskCache: 600,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        imageRenderMethodForWeb: ImageRenderMethodForWeb.HtmlImage,
        // OPTIMIZATION: Reduce error listener overhead
        errorListener: (error) {
          // Only log in debug mode and less frequently
          if (kDebugMode && error.toString().length < 100) {
            debugPrint('⚠️ Image load error');
          }
        },
        // OPTIMIZATION: Add network image headers for better performance
        httpHeaders: const {
          'Accept': 'image/*',
          'Connection': 'keep-alive',
        },
      ),
    );
  }

  int? _getCacheWidth() {
    if (width == null || width == double.infinity || !width!.isFinite) {
      return null;
    }
    return (width! * 2).toInt(); // 2x for high-res displays
  }

  int? _getCacheHeight() {
    if (height == null || height == double.infinity || !height!.isFinite) {
      return null;
    }
    return (height! * 2).toInt(); // 2x for high-res displays
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryColor.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.grey[400],
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRetryableErrorWidget(BuildContext context, String url) {
    if (!retryOnError) return _buildErrorWidget();

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            // Clear cache and retry loading
            CachedNetworkImage.evictFromCache(url);
            setState(() {});
          },
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.grey[200],
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  color: Colors.grey[400],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to retry',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Specialized widget for slider images with enhanced error handling
class CachedSliderImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool retryOnError;
  final Duration retryDelay;

  const CachedSliderImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.retryOnError = true,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  State<CachedSliderImage> createState() => _CachedSliderImageState();
}

class _CachedSliderImageState extends State<CachedSliderImage> {
  late String _cachedFullUrl;
  late String _lastImageUrl;

  @override
  void initState() {
    super.initState();
    _lastImageUrl = widget.imageUrl;
    _cachedFullUrl = ImageUtils.getFullImageUrl(widget.imageUrl);
  }

  @override
  void didUpdateWidget(CachedSliderImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the URL actually changed
    if (widget.imageUrl != _lastImageUrl) {
      _lastImageUrl = widget.imageUrl;
      _cachedFullUrl = ImageUtils.getFullImageUrl(widget.imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use cached URL to avoid recomputation
    final String fullUrl = _cachedFullUrl;
    
    if (fullUrl.isEmpty) {
      return _buildSliderErrorWidget(context);
    }

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: fullUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (context, url) => _buildSliderPlaceholder(),
        errorWidget: (context, url, error) {
          // OPTIMIZATION: No logging in build - use error listener instead
          return _buildSliderErrorWidget(context);
        },
        memCacheWidth: _getSliderCacheWidth(),
        memCacheHeight: _getSliderCacheHeight(),
        maxWidthDiskCache: 1200, // Higher resolution for sliders
        maxHeightDiskCache: 800,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        imageRenderMethodForWeb: ImageRenderMethodForWeb.HtmlImage,
        // OPTIMIZATION: Reduce error listener overhead
        errorListener: (error) {
          // Only log in debug mode and less frequently
          if (kDebugMode && error.toString().length < 100) {
            debugPrint('⚠️ Slider image load error');
          }
        },
        // OPTIMIZATION: Add network image headers for better performance
        httpHeaders: const {
          'Accept': 'image/*',
          'Connection': 'keep-alive',
        },
      ),
    );
  }

  Widget _buildSliderPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildSliderErrorWidget(BuildContext context) {
    return GestureDetector(
      onTap: widget.retryOnError ? () {
        CachedNetworkImage.evictFromCache(_cachedFullUrl);
        // Force rebuild
        (context as Element).markNeedsBuild();
      } : null,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.retryOnError ? Icons.refresh : Icons.image_not_supported,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              widget.retryOnError ? 'Tap to retry' : 'Image not available',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int? _getSliderCacheWidth() {
    if (widget.width == null || widget.width == double.infinity || !widget.width!.isFinite) {
      return 1200; // Default width for sliders
    }
    return (widget.width! * 2).toInt(); // 2x for high-res displays
  }

  int? _getSliderCacheHeight() {
    if (widget.height == null || widget.height == double.infinity || !widget.height!.isFinite) {
      return 800; // Default height for sliders
    }
    return (widget.height! * 2).toInt(); // 2x for high-res displays
  }
}
