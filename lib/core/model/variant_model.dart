class VariantModel {
  final bool success;
  final String message;
  final List<ProductVariant> data;

  VariantModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: List<ProductVariant>.from(
        json['data']?['variants']?.map((x) => ProductVariant.fromJson(x)) ?? [],
      ),
    );
  }
}

class ProductVariant {
  final String id;
  final String productId;
  final Map<String, dynamic> attributes;
  final num price;
  final int quantity;
  final bool isActive;
  final List<VariantImage> images;
  final DateTime createdAt;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.attributes,
    required this.price,
    required this.quantity,
    required this.isActive,
    required this.images,
    required this.createdAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id'] ?? '',
      productId: json['product'] is Map 
          ? json['product']['_id'] ?? '' 
          : json['product']?.toString() ?? '',
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      isActive: json['isActive'] ?? false,
      images: List<VariantImage>.from(
        json['images']?.map((x) => VariantImage.fromJson(x)) ?? [],
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'product': productId,
      'attributes': attributes,
      'price': price,
      'quantity': quantity,
      'isActive': isActive,
      'images': images.map((x) => x.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedPrice => '৳${price.toStringAsFixed(0)}';
  
  bool get isInStock => quantity > 0;
  
  // Get specific attribute value
  String getAttributeValue(String key) {
    return attributes[key]?.toString() ?? '';
  }
  
  // Get all attribute keys
  List<String> get attributeKeys => attributes.keys.toList();
  
  // Check if variant matches selected attributes
  bool matchesAttributes(Map<String, String> selectedAttributes) {
    for (String key in selectedAttributes.keys) {
      if (getAttributeValue(key) != selectedAttributes[key]) {
        return false;
      }
    }
    return true;
  }
}

class VariantImage {
  final String url;
  final bool isPrimary;
  final String alt;

  VariantImage({
    required this.url,
    required this.isPrimary,
    required this.alt,
  });

  factory VariantImage.fromJson(Map<String, dynamic> json) {
    return VariantImage(
      url: json['url'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      alt: json['alt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'isPrimary': isPrimary,
      'alt': alt,
    };
  }

  // Get full image URL
  String get fullImageUrl {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    
    String cleanPath = url.startsWith('/') ? url.substring(1) : url;
    return 'https://ecommerce.arifmart.app/$cleanPath';
  }
}
