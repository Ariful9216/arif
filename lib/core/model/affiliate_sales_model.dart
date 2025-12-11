class AffiliateSalesModel {
  final bool success;
  final String message;
  final AffiliateSalesData data;

  AffiliateSalesModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AffiliateSalesModel.fromJson(Map<String, dynamic> json) {
    return AffiliateSalesModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AffiliateSalesData.fromJson(json['data'] ?? {}),
    );
  }
}

class AffiliateSalesData {
  final List<AffiliateSale> sales;
  final AffiliatePaginationInfo pagination;
  final SalesSummary summary;

  AffiliateSalesData({
    required this.sales,
    required this.pagination,
    required this.summary,
  });

  factory AffiliateSalesData.fromJson(Map<String, dynamic> json) {
    return AffiliateSalesData(
      sales: (json['sales'] as List<dynamic>?)
          ?.map((sale) => AffiliateSale.fromJson(sale))
          .toList() ?? [],
      pagination: AffiliatePaginationInfo.fromJson(json['pagination'] ?? {}),
      summary: SalesSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class AffiliateSale {
  final String id;
  final ProductInfo productId;
  final String linkId;
  final String buyerId;
  final double amount;
  final double cashbackRate;
  final double cashbackAmount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AffiliateSale({
    required this.id,
    required this.productId,
    required this.linkId,
    required this.buyerId,
    required this.amount,
    required this.cashbackRate,
    required this.cashbackAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AffiliateSale.fromJson(Map<String, dynamic> json) {
    return AffiliateSale(
      id: json['_id'] ?? '',
      productId: ProductInfo.fromJson(json['productId'] ?? {}),
      linkId: json['linkId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      cashbackRate: (json['cashbackRate'] ?? 0).toDouble(),
      cashbackAmount: (json['cashbackAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ProductInfo {
  final String id;
  final String name;
  final double price;
  final List<ProductPicture> pictures;

  ProductInfo({
    required this.id,
    required this.name,
    required this.price,
    required this.pictures,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      pictures: (json['pictures'] as List<dynamic>?)
          ?.map((pic) => ProductPicture.fromJson(pic))
          .toList() ?? [],
    );
  }

  ProductPicture? get primaryPicture {
    try {
      return pictures.firstWhere((pic) => pic.isPrimary);
    } catch (e) {
      return pictures.isNotEmpty ? pictures.first : null;
    }
  }
}

class ProductPicture {
  final String url;
  final String thumbnail;
  final String alt;
  final bool isPrimary;
  final String id;

  ProductPicture({
    required this.url,
    required this.thumbnail,
    required this.alt,
    required this.isPrimary,
    required this.id,
  });

  factory ProductPicture.fromJson(Map<String, dynamic> json) {
    return ProductPicture(
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      alt: json['alt'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      id: json['_id'] ?? '',
    );
  }

  // Get full image URL
  String get fullImageUrl {
    if (url.isEmpty) return '';
    
    if (url.startsWith('http')) {
      return url;
    }
    
    // Construct full URL for ecommerce images
    return 'https://ecommerce.arifmart.app$url';
  }

  // Get full thumbnail URL
  String get fullThumbnailUrl {
    if (thumbnail.isEmpty) return fullImageUrl; // Fallback to main image
    
    if (thumbnail.startsWith('http')) {
      return thumbnail;
    }
    
    // Construct full URL for ecommerce thumbnails
    return 'https://ecommerce.arifmart.app$thumbnail';
  }
}

class AffiliatePaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalSales;
  final bool hasNext;
  final bool hasPrev;

  AffiliatePaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalSales,
    required this.hasNext,
    required this.hasPrev,
  });

  factory AffiliatePaginationInfo.fromJson(Map<String, dynamic> json) {
    return AffiliatePaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalSales: json['totalSales'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

class SalesSummary {
  final double totalSales;
  final double totalCommission;
  final int totalCount;

  SalesSummary({
    required this.totalSales,
    required this.totalCommission,
    required this.totalCount,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalCommission: (json['totalCommission'] ?? 0).toDouble(),
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

// Affiliate Statistics Model
class AffiliateStatisticsModel {
  final bool success;
  final String message;
  final AffiliateStatisticsData data;

  AffiliateStatisticsModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AffiliateStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AffiliateStatisticsModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AffiliateStatisticsData.fromJson(json['data'] ?? {}),
    );
  }
}

class AffiliateStatisticsData {
  final int totalClicks;
  final int totalShares;
  final int totalSales;
  final List<ProductStatistics> products;
  final AffiliatePaginationInfo pagination;

  AffiliateStatisticsData({
    required this.totalClicks,
    required this.totalShares,
    required this.totalSales,
    required this.products,
    required this.pagination,
  });

  factory AffiliateStatisticsData.fromJson(Map<String, dynamic> json) {
    return AffiliateStatisticsData(
      totalClicks: json['totalClicks'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      totalSales: json['totalSales'] ?? 0,
      products: (json['products'] as List<dynamic>?)
          ?.map((product) => ProductStatistics.fromJson(product))
          .toList() ?? [],
      pagination: AffiliatePaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class ProductStatistics {
  final String product;
  final int shares;
  final int clicks;
  final int sales;

  ProductStatistics({
    required this.product,
    required this.shares,
    required this.clicks,
    required this.sales,
  });

  factory ProductStatistics.fromJson(Map<String, dynamic> json) {
    return ProductStatistics(
      product: json['product'] ?? '',
      shares: json['shares'] ?? 0,
      clicks: json['clicks'] ?? 0,
      sales: json['sales'] ?? 0,
    );
  }
}
