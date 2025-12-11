
import 'package:arif_mart/core/utils/timezone_util.dart';

class ProductModel {
  final bool success;
  final String message;
  final ProductsData data;

  ProductModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ProductsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ProductsData {
  final List<ProductData> products;
  final PaginationData? pagination;

  ProductsData({
    required this.products,
    this.pagination,
  });

  factory ProductsData.fromJson(Map<String, dynamic> json) {
    return ProductsData(
      products: (json['products'] as List<dynamic>?)
          ?.map((item) => ProductData.fromJson(item))
          .toList() ?? [],
      pagination: json['pagination'] != null 
          ? PaginationData.fromJson(json['pagination']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((product) => product.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class ProductData {
  final String id;
  final String name;
  final String description;
  final num price;
  final int quantity;
  final String brand;
  final List<ProductPicture> pictures;
  final List<ProductCategory> categories;
  final List<String> tags;
  final Map<String, dynamic> attributes;
  final DeliveryCost deliveryCost;
  final FlashSale flashSale;
  final AffiliateProgram affiliateProgram;
  final ProductRating rating;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductData({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.brand,
    required this.pictures,
    required this.categories,
    required this.tags,
    required this.attributes,
    required this.deliveryCost,
    required this.flashSale,
    required this.affiliateProgram,
    required this.rating,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      brand: json['brand'] ?? '',
      pictures: (json['pictures'] as List<dynamic>?)
          ?.map((item) => ProductPicture.fromJson(item))
          .toList() ?? [],
      categories: (json['categories'] as List<dynamic>?)
          ?.map((item) => ProductCategory.fromJson(item))
          .toList() ?? [],
      tags: (json['tags'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ?? [],
      attributes: json['attributes'] ?? {},
      deliveryCost: json['deliveryCost'] != null 
          ? DeliveryCost.fromJson(json['deliveryCost']) 
          : DeliveryCost.empty(),
      flashSale: json['flashSale'] != null 
          ? FlashSale.fromJson(json['flashSale']) 
          : FlashSale.empty(),
      affiliateProgram: json['affiliateProgram'] != null 
          ? AffiliateProgram.fromJson(json['affiliateProgram']) 
          : AffiliateProgram.empty(),
      rating: json['rating'] != null 
          ? ProductRating.fromJson(json['rating']) 
          : ProductRating.empty(),
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'brand': brand,
      'pictures': pictures.map((picture) => picture.toJson()).toList(),
      'categories': categories.map((category) => category.toJson()).toList(),
      'tags': tags,
      'attributes': attributes,
      'deliveryCost': deliveryCost.toJson(),
      'flashSale': flashSale.toJson(),
      'affiliateProgram': affiliateProgram.toJson(),
      'rating': rating.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get primary image URL
  String get primaryImageUrl {
    final primaryPicture = pictures.firstWhere(
      (pic) => pic.isPrimary,
      orElse: () => pictures.isNotEmpty ? pictures.first : ProductPicture.empty(),
    );
    return primaryPicture.fullImageUrl;
  }

  // Get primary thumbnail URL (preferred for product cards)
  String get primaryThumbnailUrl {
    final primaryPicture = pictures.firstWhere(
      (pic) => pic.isPrimary,
      orElse: () => pictures.isNotEmpty ? pictures.first : ProductPicture.empty(),
    );
    return primaryPicture.fullThumbnailUrl;
  }

  // Get formatted price
  String get formattedPrice => '৳${price.toStringAsFixed(0)}';

  // Check if product is in stock
  bool get isInStock => quantity > 0;

  // Get discount percentage if on flash sale
  double get discountPercentage {
    if (flashSale.isCurrentlyActive && flashSale.discountPrice != null) {
      return ((price - flashSale.discountPrice!) / price * 100);
    }
    return 0.0;
  }

  // Get effective price (flash sale price if active, otherwise regular price)
  num get effectivePrice {
    if (flashSale.isCurrentlyActive && flashSale.discountPrice != null) {
      return flashSale.discountPrice!;
    }
    return price;
  }

  // Check if affiliate program is available for this product
  bool get hasAffiliateProgram => affiliateProgram.isEnabled;

  // Get cashback amount for this product
  double get cashbackAmount => affiliateProgram.calculateCashback(effectivePrice);

  // Get formatted cashback amount for this product
  String get formattedCashbackAmount => affiliateProgram.getFormattedCashbackAmount(effectivePrice);

  // Get formatted cashback rate
  String get formattedCashbackRate => affiliateProgram.formattedCashbackRate;
}

class ProductPicture {
  final String url;
  final String thumbnail;
  final bool isPrimary;
  final String alt;

  ProductPicture({
    required this.url,
    required this.thumbnail,
    required this.isPrimary,
    required this.alt,
  });

  factory ProductPicture.fromJson(Map<String, dynamic> json) {
    return ProductPicture(
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      alt: json['alt'] ?? '',
    );
  }

  factory ProductPicture.empty() {
    return ProductPicture(
      url: '',
      thumbnail: '',
      isPrimary: false,
      alt: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnail': thumbnail,
      'isPrimary': isPrimary,
      'alt': alt,
    };
  }

  // Get full image URL
  String get fullImageUrl {
    if (url.isEmpty) return '';
    
    if (url.startsWith('http')) {
      return url;
    }
    
    String cleanPath = url.startsWith('/') ? url.substring(1) : url;
    return 'https://ecommerce.arifmart.app/$cleanPath';
  }

  // Get full thumbnail URL
  String get fullThumbnailUrl {
    if (thumbnail.isEmpty) return fullImageUrl; // Fallback to main image
    
    if (thumbnail.startsWith('http')) {
      return thumbnail;
    }
    
    String cleanPath = thumbnail.startsWith('/') ? thumbnail.substring(1) : thumbnail;
    return 'https://ecommerce.arifmart.app/$cleanPath';
  }
}

class ProductCategory {
  final String id;
  final String name;
  final String description;

  ProductCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
    };
  }
}

class DeliveryCost {
  final num insideCity;
  final num outsideCity;

  DeliveryCost({
    required this.insideCity,
    required this.outsideCity,
  });

  factory DeliveryCost.empty() {
    return DeliveryCost(
      insideCity: 0,
      outsideCity: 0,
    );
  }

  factory DeliveryCost.fromJson(Map<String, dynamic> json) {
    return DeliveryCost(
      insideCity: json['insideCity'] ?? 0,
      outsideCity: json['outsideCity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'insideCity': insideCity,
      'outsideCity': outsideCity,
    };
  }
}

class FlashSale {
  final bool isActive;
  final num? discountPrice;
  final DateTime? endDate;
  final DateTime? startDate;

  FlashSale({
    required this.isActive,
    this.discountPrice,
    this.endDate,
    this.startDate,
  });

  factory FlashSale.empty() {
    return FlashSale(
      isActive: false,
      discountPrice: null,
      endDate: null,
      startDate: null,
    );
  }

  factory FlashSale.fromJson(Map<String, dynamic> json) {
    // Use the TimezoneUtil utility method to parse dates as local time
    
    // Parse the dates
    final DateTime? parsedStartDate = json['startTime'] != null ? 
        TimezoneUtil.parseAsLocalTime(json['startTime'].toString()) : 
        json['startDate'] != null ? TimezoneUtil.parseAsLocalTime(json['startDate'].toString()) : null;
        
    final DateTime? parsedEndDate = json['endTime'] != null ? 
        TimezoneUtil.parseAsLocalTime(json['endTime'].toString()) : 
        json['endDate'] != null ? TimezoneUtil.parseAsLocalTime(json['endDate'].toString()) : null;
    
    // Debug output to verify parsing
    // No debug logging here (parsing is done silently)
    
    return FlashSale(
      isActive: json['isActive'] ?? false,
      discountPrice: json['price'] ?? json['discountPrice'], // Try 'price' first, then 'discountPrice'
      endDate: parsedEndDate,
      startDate: parsedStartDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'discountPrice': discountPrice,
      'endDate': endDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
    };
  }

  // Check if flash sale is currently active (considering dates)
  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    // No debug logging: only perform time comparisons
    // Check if flash sale has started
    if (startDate != null && now.isBefore(startDate!)) {
      return false;
    }
    
    // Check if flash sale has ended
    if (endDate != null && now.isAfter(endDate!)) {
      return false;
    }
    
    // Flash sale is active if we reached here
    
    return true;
  }
  
  // Helper to format duration for debugging
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours}h ${minutes}m ${seconds}s';
  }

  // Get time remaining until flash sale ends
  Duration? get timeRemaining {
    if (!isCurrentlyActive || endDate == null) return null;
    final now = DateTime.now();
    final remaining = endDate!.difference(now);
    // No debug logging here
    return remaining;
  }

  // Format time remaining as string (e.g., "2d 5h 30m")
  String get timeRemainingFormatted {
    final remaining = timeRemaining;
    if (remaining == null || remaining.isNegative) return "Expired";
    
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    
    if (days > 0) {
      return "${days}d ${hours}h ${minutes}m";
    } else if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  // Calculate discount percentage
  double getDiscountPercentage(num originalPrice) {
    if (discountPrice == null || !isCurrentlyActive) return 0.0;
    if (originalPrice <= 0) return 0.0;
    
    final discount = (originalPrice - discountPrice!) / originalPrice * 100;
    return discount.clamp(0.0, 100.0);
  }
}

class AffiliateProgram {
  final bool isEnabled;
  final double cashbackRate;

  AffiliateProgram({
    required this.isEnabled,
    required this.cashbackRate,
  });

  factory AffiliateProgram.empty() {
    return AffiliateProgram(
      isEnabled: false,
      cashbackRate: 0.0,
    );
  }

  factory AffiliateProgram.fromJson(Map<String, dynamic> json) {
    return AffiliateProgram(
      isEnabled: json['isEnabled'] ?? false,
      cashbackRate: (json['cashbackRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'cashbackRate': cashbackRate,
    };
  }

  // Get formatted cashback rate as percentage
  String get formattedCashbackRate => '${cashbackRate.toStringAsFixed(1)}%';
  
  // Alias for formattedCashbackRate (used in controller)
  String get formattedRate => formattedCashbackRate;

  // Calculate cashback amount for a given price
  double calculateCashback(num price) {
    if (!isEnabled || cashbackRate <= 0) return 0.0;
    return (price * cashbackRate / 100);
  }

  // Get formatted cashback amount for a given price
  String getFormattedCashbackAmount(num price) {
    final amount = calculateCashback(price);
    return '৳${amount.toStringAsFixed(2)}';
  }
  
  // Alias for getFormattedCashbackAmount (used in controller)
  String getFormattedCashback(num price) {
    return getFormattedCashbackAmount(price);
  }
}

class ProductRating {
  final double average;
  final int count;

  ProductRating({
    required this.average,
    required this.count,
  });

  factory ProductRating.empty() {
    return ProductRating(
      average: 0.0,
      count: 0,
    );
  }

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      average: (json['average'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'count': count,
    };
  }

  // Get star rating as integer (0-5) based on average
  int get fullStars => average.floor().clamp(0, 5);
  
  // Check if there should be a half star
  bool get hasHalfStar => (average - fullStars) >= 0.5;
  
  // Get total filled stars (for simple star display)
  int get filledStars => average.round().clamp(0, 5);
  
  // Get formatted average rating text
  String get formattedAverage => average > 0 ? average.toStringAsFixed(1) : '0.0';
}

class PaginationData {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNext;
  final bool hasPrev;

  PaginationData({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      // Support both 'totalItems' and 'totalProducts' field names
      totalItems: json['totalItems'] ?? json['totalProducts'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
}
