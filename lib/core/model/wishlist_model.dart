import 'package:arif_mart/core/model/product_model.dart';

/// Wishlist API Response Models
/// Based on the new Wishlist API documentation

class WishlistModel {
  final bool success;
  final String message;
  final WishlistData? data;

  WishlistModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? WishlistData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class WishlistData {
  final List<WishlistItem> wishlistItems;
  final WishlistPagination pagination;
  final WishlistSummary summary;

  WishlistData({
    required this.wishlistItems,
    required this.pagination,
    required this.summary,
  });

  factory WishlistData.fromJson(Map<String, dynamic> json) {
    return WishlistData(
      wishlistItems: (json['wishlistItems'] as List<dynamic>?)
          ?.map((item) => WishlistItem.fromJson(item))
          .toList() ?? [],
      pagination: WishlistPagination.fromJson(json['pagination'] ?? {}),
      summary: WishlistSummary.fromJson(json['summary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wishlistItems': wishlistItems.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
      'summary': summary.toJson(),
    };
  }
}

class WishlistItem {
  final String id;
  final String user;
  final ProductData product;
  final DateTime addedAt;
  final DateTime createdAt;

  WishlistItem({
    required this.id,
    required this.user,
    required this.product,
    required this.addedAt,
    required this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      product: ProductData.fromJson(json['product'] ?? {}),
      addedAt: json['addedAt'] != null 
          ? DateTime.parse(json['addedAt']) 
          : DateTime.now(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'product': product.toJson(),
      'addedAt': addedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class WishlistPagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  WishlistPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory WishlistPagination.fromJson(Map<String, dynamic> json) {
    return WishlistPagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}

class WishlistSummary {
  final int totalItems;
  final double totalValue;
  final double totalSavings;
  final double averagePrice;
  final int flashSaleItems;

  WishlistSummary({
    required this.totalItems,
    required this.totalValue,
    required this.totalSavings,
    required this.averagePrice,
    required this.flashSaleItems,
  });

  factory WishlistSummary.fromJson(Map<String, dynamic> json) {
    return WishlistSummary(
      totalItems: json['totalItems'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      totalSavings: (json['totalSavings'] ?? 0).toDouble(),
      averagePrice: (json['averagePrice'] ?? 0).toDouble(),
      flashSaleItems: json['flashSaleItems'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'totalValue': totalValue,
      'totalSavings': totalSavings,
      'averagePrice': averagePrice,
      'flashSaleItems': flashSaleItems,
    };
  }
}

/// Wishlist Status Models
class WishlistStatusModel {
  final bool success;
  final String message;
  final WishlistStatusData? data;

  WishlistStatusModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory WishlistStatusModel.fromJson(Map<String, dynamic> json) {
    return WishlistStatusModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? WishlistStatusData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class WishlistStatusData {
  final bool isInWishlist;
  final DateTime? addedAt;
  final String? wishlistItemId;

  WishlistStatusData({
    required this.isInWishlist,
    this.addedAt,
    this.wishlistItemId,
  });

  factory WishlistStatusData.fromJson(Map<String, dynamic> json) {
    return WishlistStatusData(
      isInWishlist: json['isInWishlist'] ?? false,
      addedAt: json['addedAt'] != null 
          ? DateTime.parse(json['addedAt']) 
          : null,
      wishlistItemId: json['wishlistItemId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isInWishlist': isInWishlist,
      'addedAt': addedAt?.toIso8601String(),
      'wishlistItemId': wishlistItemId,
    };
  }
}

/// Wishlist Count Models
class WishlistCountModel {
  final bool success;
  final String message;
  final WishlistCountData? data;

  WishlistCountModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory WishlistCountModel.fromJson(Map<String, dynamic> json) {
    return WishlistCountModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? WishlistCountData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class WishlistCountData {
  final int count;
  final double totalValue;
  final int activeItems;
  final int inactiveItems;
  final int flashSaleItems;
  final double totalSavings;

  WishlistCountData({
    required this.count,
    required this.totalValue,
    required this.activeItems,
    required this.inactiveItems,
    required this.flashSaleItems,
    required this.totalSavings,
  });

  factory WishlistCountData.fromJson(Map<String, dynamic> json) {
    return WishlistCountData(
      count: json['count'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      activeItems: json['activeItems'] ?? 0,
      inactiveItems: json['inactiveItems'] ?? 0,
      flashSaleItems: json['flashSaleItems'] ?? 0,
      totalSavings: (json['totalSavings'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'totalValue': totalValue,
      'activeItems': activeItems,
      'inactiveItems': inactiveItems,
      'flashSaleItems': flashSaleItems,
      'totalSavings': totalSavings,
    };
  }
}

/// Wishlist Statistics Models
class WishlistStatsModel {
  final bool success;
  final String message;
  final WishlistStatsData? data;

  WishlistStatsModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory WishlistStatsModel.fromJson(Map<String, dynamic> json) {
    return WishlistStatsModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? WishlistStatsData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class WishlistStatsData {
  final int totalItems;
  final double totalValue;
  final double averageItemPrice;
  final int activeItems;
  final int inactiveItems;
  final int flashSaleItems;
  final double totalSavingsAvailable;
  final List<CategoryBreakdown> categoriesBreakdown;
  final List<BrandBreakdown> brandsBreakdown;
  final List<PriceRange> priceRanges;
  final WishlistItemInfo oldestItem;
  final WishlistItemInfo newestItem;
  final WishlistItemInfo mostExpensiveItem;
  final WishlistItemInfo leastExpensiveItem;

  WishlistStatsData({
    required this.totalItems,
    required this.totalValue,
    required this.averageItemPrice,
    required this.activeItems,
    required this.inactiveItems,
    required this.flashSaleItems,
    required this.totalSavingsAvailable,
    required this.categoriesBreakdown,
    required this.brandsBreakdown,
    required this.priceRanges,
    required this.oldestItem,
    required this.newestItem,
    required this.mostExpensiveItem,
    required this.leastExpensiveItem,
  });

  factory WishlistStatsData.fromJson(Map<String, dynamic> json) {
    return WishlistStatsData(
      totalItems: json['totalItems'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      averageItemPrice: (json['averageItemPrice'] ?? 0).toDouble(),
      activeItems: json['activeItems'] ?? 0,
      inactiveItems: json['inactiveItems'] ?? 0,
      flashSaleItems: json['flashSaleItems'] ?? 0,
      totalSavingsAvailable: (json['totalSavingsAvailable'] ?? 0).toDouble(),
      categoriesBreakdown: (json['categoriesBreakdown'] as List<dynamic>?)
          ?.map((item) => CategoryBreakdown.fromJson(item))
          .toList() ?? [],
      brandsBreakdown: (json['brandsBreakdown'] as List<dynamic>?)
          ?.map((item) => BrandBreakdown.fromJson(item))
          .toList() ?? [],
      priceRanges: (json['priceRanges'] as List<dynamic>?)
          ?.map((item) => PriceRange.fromJson(item))
          .toList() ?? [],
      oldestItem: WishlistItemInfo.fromJson(json['oldestItem'] ?? {}),
      newestItem: WishlistItemInfo.fromJson(json['newestItem'] ?? {}),
      mostExpensiveItem: WishlistItemInfo.fromJson(json['mostExpensiveItem'] ?? {}),
      leastExpensiveItem: WishlistItemInfo.fromJson(json['leastExpensiveItem'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'totalValue': totalValue,
      'averageItemPrice': averageItemPrice,
      'activeItems': activeItems,
      'inactiveItems': inactiveItems,
      'flashSaleItems': flashSaleItems,
      'totalSavingsAvailable': totalSavingsAvailable,
      'categoriesBreakdown': categoriesBreakdown.map((item) => item.toJson()).toList(),
      'brandsBreakdown': brandsBreakdown.map((item) => item.toJson()).toList(),
      'priceRanges': priceRanges.map((item) => item.toJson()).toList(),
      'oldestItem': oldestItem.toJson(),
      'newestItem': newestItem.toJson(),
      'mostExpensiveItem': mostExpensiveItem.toJson(),
      'leastExpensiveItem': leastExpensiveItem.toJson(),
    };
  }
}

class CategoryBreakdown {
  final String category;
  final int count;
  final double value;
  final double percentage;

  CategoryBreakdown({
    required this.category,
    required this.count,
    required this.value,
    required this.percentage,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] ?? '',
      count: json['count'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'count': count,
      'value': value,
      'percentage': percentage,
    };
  }
}

class BrandBreakdown {
  final String brand;
  final int count;
  final double value;
  final double percentage;

  BrandBreakdown({
    required this.brand,
    required this.count,
    required this.value,
    required this.percentage,
  });

  factory BrandBreakdown.fromJson(Map<String, dynamic> json) {
    return BrandBreakdown(
      brand: json['brand'] ?? '',
      count: json['count'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'count': count,
      'value': value,
      'percentage': percentage,
    };
  }
}

class PriceRange {
  final String range;
  final int count;
  final double value;

  PriceRange({
    required this.range,
    required this.count,
    required this.value,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      range: json['range'] ?? '',
      count: json['count'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'range': range,
      'count': count,
      'value': value,
    };
  }
}

class WishlistItemInfo {
  final DateTime? addedAt;
  final String productName;
  final int? daysInWishlist;
  final double? price;

  WishlistItemInfo({
    this.addedAt,
    required this.productName,
    this.daysInWishlist,
    this.price,
  });

  factory WishlistItemInfo.fromJson(Map<String, dynamic> json) {
    return WishlistItemInfo(
      addedAt: json['addedAt'] != null 
          ? DateTime.parse(json['addedAt']) 
          : null,
      productName: json['productName'] ?? '',
      daysInWishlist: json['daysInWishlist'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addedAt': addedAt?.toIso8601String(),
      'productName': productName,
      'daysInWishlist': daysInWishlist,
      'price': price,
    };
  }
}


