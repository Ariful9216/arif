import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:arif_mart/core/constants/api.dart';
import 'dart:async';
import 'dart:io';

class ImageUtils {
  static final ImageUtils _instance = ImageUtils._internal();
  factory ImageUtils() => _instance;
  ImageUtils._internal();

  /// Base URL configuration - can be overridden for development/testing
  /// For Android emulator: http://10.0.2.2:5000
  /// For physical device/production: https://ecommerce.arifmart.app
  static String _baseUrl = Apis.ecommerceBaseUrl.replaceAll('/api/v1/', '');
  
  /// Cache for constructed URLs to avoid repeated computation
  static final Map<String, String> _urlCache = {};
  
  /// HTTP client pool to avoid creating multiple clients
  static HttpClient? _httpClient;
  static const Duration _httpClientTimeout = Duration(seconds: 10);
  
  /// Set custom base URL (useful for development and testing)
  static void setBaseUrl(String url) {
    _baseUrl = url;
    _urlCache.clear(); // Clear URL cache when base URL changes
    debugPrint('🔧 Base URL updated to: $_baseUrl');
  }
  
  /// Get current base URL
  static String getBaseUrl() => _baseUrl;

  /// Get full image URL with proper error handling and logging
  /// This is OPTIMIZED to avoid expensive operations - suitable for build() methods
  static String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    // Check cache first (FAST - no computation)
    if (_urlCache.containsKey(imageUrl)) {
      return _urlCache[imageUrl]!;
    }

    try {
      String resultUrl;
      
      // Return as is if already a full URL
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        resultUrl = imageUrl;
      } else {
        // Handle different image path patterns
        String cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
        
        // If path doesn't already have /images/, add it with the appropriate category
        if (!cleanPath.startsWith('images/')) {
          // Try to infer category from context or default to products
          if (cleanPath.contains('variant')) {
            cleanPath = 'images/variants/$cleanPath';
          } else if (cleanPath.contains('banner')) {
            cleanPath = 'images/banners/$cleanPath';
          } else {
            cleanPath = 'images/products/$cleanPath';
          }
        }
        
        resultUrl = '$_baseUrl/$cleanPath';
      }
      
      // Cache the result
      _urlCache[imageUrl] = resultUrl;
      return resultUrl;
    } catch (e) {
      debugPrint('❌ Error constructing image URL: $e');
      return '';
    }
  }

  /// Get cached image provider
  static ImageProvider<Object> getCachedImageProvider(String url) {
    return CachedNetworkImageProvider(
      getFullImageUrl(url),
      maxWidth: 800,
      maxHeight: 600,
      errorListener: (e) => debugPrint('❌ Error loading image: $e'),
    );
  }

  /// Clear image cache - NON-BLOCKING, runs in background
  static void clearCache() {
    // Run cache clearing in background to avoid blocking UI
    Future.microtask(() {
      try {
        imageCache.clear();
        imageCache.clearLiveImages();
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
        _urlCache.clear();
        debugPrint('✅ Image cache cleared');
      } catch (e) {
        debugPrint('⚠️ Error clearing cache: $e');
      }
    });
  }
  
  /// Preload images for smoother loading - RUN ASYNCHRONOUSLY (non-blocking)
  /// This should be called with await ONLY IF you specifically need to wait for completion
  /// Most of the time, just call it without await
  static Future<void> preloadImages(List<String> urls, {BuildContext? context}) async {
    // Run in background isolate to not block UI thread
    if (urls.isEmpty) return;
    
    final BuildContext? effectiveContext = context;
    
    // Limit concurrent preloads to avoid overwhelming network
    const maxConcurrent = 3;
    
    for (int i = 0; i < urls.length; i += maxConcurrent) {
      final batch = urls.sublist(
        i,
        (i + maxConcurrent).clamp(0, urls.length),
      );
      
      // Process batch concurrently with timeout protection
      await Future.wait(
        batch.map((url) => _preloadSingleImageSafe(url, effectiveContext)),
        eagerError: false, // Don't stop on first error
      );
    }
    debugPrint('✅ Preloaded ${urls.length} images');
  }
  
  /// Safely preload a single image with timeout
  static Future<void> _preloadSingleImageSafe(
    String url,
    BuildContext? context,
  ) async {
    try {
      final fullUrl = getFullImageUrl(url);
      if (fullUrl.isNotEmpty && context != null) {
        // Add timeout to prevent hanging
        await precacheImage(
          getCachedImageProvider(url),
          context,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () => debugPrint('⏱️ Image preload timeout: $url'),
        );
      }
    } catch (e) {
      // Silently ignore - don't block other preloads
      debugPrint('⚠️ Error preloading image $url: $e');
    }
  }

  /// Handle image loading errors
  static Future<bool> isImageLoadable(String url) async {
    try {
      final imageProvider = getCachedImageProvider(url);
      
      // Add timeout to prevent hanging on unreachable servers
      await imageProvider.obtainKey(ImageConfiguration.empty)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('Image load timeout'),
          );
      
      return true;
    } catch (e) {
      debugPrint('⚠️ Image not loadable: $url');
      return false;
    }
  }
  
  /// Get or create HTTP client pool (reuse instead of creating new)
  static HttpClient _getHttpClient() {
    if (_httpClient == null) {
      _httpClient = HttpClient()
        ..connectionTimeout = _httpClientTimeout
        ..maxConnectionsPerHost = 6; // Limit concurrent connections
    }
    return _httpClient!;
  }
  
  /// Close HTTP client to free resources
  static void _closeHttpClient() {
    _httpClient?.close(force: true);
    _httpClient = null;
  }
  
  /// Test connection to image server - NON-BLOCKING with timeout
  static Future<bool> testServerConnection() async {
    try {
      debugPrint('🔌 Testing connection to: $_baseUrl');
      final testUrl = Uri.parse(_baseUrl);
      final client = _getHttpClient();
      
      // Add timeout to prevent indefinite hanging
      final request = await client.headUrl(testUrl)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TimeoutException('Connection timeout'),
          );
      
      final response = await request.close()
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TimeoutException('Response timeout'),
          );
      
      debugPrint('🔌 Server response status: ${response.statusCode}');
      return response.statusCode < 500;
    } catch (e) {
      debugPrint('⚠️ Server connection failed: $e');
      return false;
    }
  }
  
  /// Batch test image URLs - NON-BLOCKING with controlled concurrency
  static Future<Map<String, bool>> testImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty) return {};
    
    debugPrint('🧪 Testing ${imageUrls.length} images...');
    final results = <String, bool>{};
    
    // Limit concurrent tests to avoid overwhelming network
    const maxConcurrent = 3;
    
    for (int i = 0; i < imageUrls.length; i += maxConcurrent) {
      final batch = imageUrls.sublist(
        i,
        (i + maxConcurrent).clamp(0, imageUrls.length),
      );
      
      // Test batch concurrently with error handling
      final batchResults = await Future.wait(
        batch.map((url) async {
          final loadable = await isImageLoadable(url);
          return MapEntry(url, loadable);
        }),
        eagerError: false,
      );
      
      results.addEntries(batchResults);
    }
    
    debugPrint('🧪 Test results: ${results.entries.map((e) => '${e.key}: ${e.value}').join(", ")}');
    return results;
  }
  
  /// Cleanup resources when app closes
  static void dispose() {
    _closeHttpClient();
    _urlCache.clear();
    debugPrint('🧹 ImageUtils cleaned up');
  }
}