import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/core/model/variant_model.dart';

class CartModel {
  final bool success;
  final String message;
  final CartData data;

  CartModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // Handle unusual API response structure where cart data is in 'message' field
    Map<String, dynamic>? cartData;
    
    if (json['message'] is Map<String, dynamic>) {
      // Cart data is in message field (unusual but actual API response)
      cartData = json['message'];
    } else if (json['data'] is Map<String, dynamic>) {
      // Standard expected structure
      cartData = json['data'];
    }
    
    return CartModel(
      success: json['success'] ?? false,
      message: json['data'] is String ? json['data'] : (json['message'] is String ? json['message'] : ''),
      data: cartData != null 
          ? CartData.fromJson(cartData)
          : CartData.empty(),
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

class CartData {
  final String id;
  final String user;
  final List<CartItem> items;
  final int totalItems;
  final int uniqueProducts;
  final double subtotal;
  final double totalSavings;
  final String createdAt;
  final String updatedAt;

  CartData({
    required this.id,
    required this.user,
    required this.items,
    required this.totalItems,
    required this.uniqueProducts,
    required this.subtotal,
    required this.totalSavings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartData.empty() {
    return CartData(
      id: '',
      user: '',
      items: [],
      totalItems: 0,
      uniqueProducts: 0,
      subtotal: 0.0,
      totalSavings: 0.0,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  factory CartData.fromJson(Map<String, dynamic> json) {
    // Calculate totalItems and uniqueProducts from items if not provided
    List<CartItem> items = json['items'] != null
        ? (json['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList()
        : [];
    
    int totalItems = json['totalItems'] ?? items.length;
    int uniqueProducts = json['uniqueProducts'] ?? items.map((item) => item.product.id).toSet().length;
    
    // Calculate subtotal and totalSavings from items if not provided
    double subtotal = (json['subtotal'] ?? 0).toDouble();
    double totalSavings = (json['totalSavings'] ?? 0).toDouble();
    
    if (subtotal == 0 && items.isNotEmpty) {
      subtotal = items.fold(0.0, (sum, item) => sum + item.itemTotal);
    }
    
    if (totalSavings == 0 && items.isNotEmpty) {
      totalSavings = items.fold(0.0, (sum, item) => sum + (item.discountAmount * item.quantity));
    }
    
    return CartData(
      id: json['_id'] ?? '',
      user: json['user'] is String 
          ? json['user'] 
          : (json['user'] is Map ? json['user']['_id'] ?? '' : ''),
      items: items,
      totalItems: totalItems,
      uniqueProducts: uniqueProducts,
      subtotal: subtotal,
      totalSavings: totalSavings,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'items': items.map((item) => item.toJson()).toList(),
      'totalItems': totalItems,
      'uniqueProducts': uniqueProducts,
      'subtotal': subtotal,
      'totalSavings': totalSavings,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class CartItem {
  final String id;
  final ProductData product;
  final ProductVariant? variant;
  final int quantity;
  final String addedAt;
  final double? effectivePrice; // Flash sale price
  final bool isFlashSaleActive; // Flash sale status
  final double? savings; // Amount saved due to flash sale
  final String? referrerId; // Affiliate referrer ID

  CartItem({
    required this.id,
    required this.product,
    this.variant,
    required this.quantity,
    required this.addedAt,
    this.effectivePrice,
    this.isFlashSaleActive = false,
    this.savings,
    this.referrerId,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Handle variant - it can be either a string ID or a full object
    ProductVariant? variant;
    if (json['variant'] != null) {
      if (json['variant'] is String) {
        // Variant is just an ID string, create a minimal variant object
        variant = ProductVariant(
          id: json['variant'],
          productId: '',
          attributes: {},
          price: 0,
          quantity: 0,
          isActive: true,
          images: [],
          createdAt: DateTime.now(),
        );
      } else if (json['variant'] is Map<String, dynamic>) {
        // Variant is a full object
        variant = ProductVariant.fromJson(json['variant']);
      }
    }
    
    return CartItem(
      id: json['_id'] ?? '',
      product: ProductData.fromJson(json['product'] ?? {}),
      variant: variant,
      quantity: json['quantity'] ?? 0,
      addedAt: json['addedAt'] ?? '',
      effectivePrice: json['effectivePrice']?.toDouble(),
      isFlashSaleActive: json['isFlashSaleActive'] ?? false,
      savings: json['savings']?.toDouble(),
      referrerId: json['referrerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'product': product.toJson(),
      'variant': variant?.toJson(),
      'quantity': quantity,
      'addedAt': addedAt,
      'effectivePrice': effectivePrice,
      'isFlashSaleActive': isFlashSaleActive,
      'savings': savings,
      'referrerId': referrerId,
    };
  }

  // Helper method to get the effective price (considering flash sale)
  double get calculatedEffectivePrice {
    // If variant exists, use variant price (variants don't have flash sales)
    if (variant != null) {
      return variant!.price.toDouble();
    }
    
    // Use product's effective price (which considers flash sale)
    return product.effectivePrice.toDouble();
  }

  // Helper method to get the original price (before any discounts)
  double get originalPrice {
    return variant?.price.toDouble() ?? product.price.toDouble();
  }

  // Check if item has active discount
  bool get hasDiscount {
    return variant == null && product.flashSale.isCurrentlyActive && product.flashSale.discountPrice != null;
  }

  // Get discount amount
  double get discountAmount {
    if (!hasDiscount) return 0.0;
    return originalPrice - calculatedEffectivePrice;
  }

  // Get discount percentage
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return (discountAmount / originalPrice) * 100;
  }

  // Helper method to get the item total
  double get itemTotal {
    return calculatedEffectivePrice * quantity;
  }

  // Helper method to get the product name with variant info
  String get displayName {
    String name = product.name;
    if (variant != null && variant!.attributes.isNotEmpty) {
      List<String> attributeStrings = [];
      variant!.attributes.forEach((key, value) {
        attributeStrings.add('$key: $value');
      });
      name += ' (${attributeStrings.join(', ')})';
    }
    return name;
  }

  // Helper method to get available stock
  int get availableStock {
    return variant?.quantity ?? product.quantity;
  }

  // Helper method to check if item is in stock
  bool get isInStock {
    return availableStock > 0;
  }

  // Helper method to check if current quantity exceeds available stock
  bool get exceedsStock {
    return quantity > availableStock;
  }
}

// Cart Count Model
class CartCountModel {
  final bool success;
  final String message;
  final CartCountData data;

  CartCountModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CartCountModel.fromJson(Map<String, dynamic> json) {
    return CartCountModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CartCountData.fromJson(json['data'] ?? {}),
    );
  }
}

class CartCountData {
  final int itemCount;
  final int totalQuantity;

  CartCountData({
    required this.itemCount,
    required this.totalQuantity,
  });

  factory CartCountData.fromJson(Map<String, dynamic> json) {
    return CartCountData(
      itemCount: json['itemCount'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
    );
  }
}

// Cart Total Model
class CartTotalModel {
  final bool success;
  final String message;
  final CartTotalData data;

  CartTotalModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CartTotalModel.fromJson(Map<String, dynamic> json) {
    return CartTotalModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CartTotalData.fromJson(json['data'] ?? {}),
    );
  }
}

class CartTotalData {
  final double subtotal;
  final double deliveryCost;
  final double total;
  final String currency;
  final int totalItems;
  final double totalSavings;
  final List<CartItemTotal> items;

  CartTotalData({
    required this.subtotal,
    required this.deliveryCost,
    required this.total,
    required this.currency,
    required this.totalItems,
    required this.totalSavings,
    required this.items,
  });

  factory CartTotalData.fromJson(Map<String, dynamic> json) {
    return CartTotalData(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryCost: (json['deliveryCost'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      totalItems: json['totalItems'] ?? 0,
      totalSavings: (json['totalSavings'] ?? 0).toDouble(),
      items: json['items'] != null
          ? (json['items'] as List).map((item) => CartItemTotal.fromJson(item)).toList()
          : [],
    );
  }
}

// Cart Item Total for detailed breakdown
class CartItemTotal {
  final String itemId;
  final String productId;
  final String? variantId;
  final int quantity;
  final double regularPrice;
  final double effectivePrice;
  final bool isFlashSaleActive;
  final double savings;
  final double total;

  CartItemTotal({
    required this.itemId,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.regularPrice,
    required this.effectivePrice,
    required this.isFlashSaleActive,
    required this.savings,
    required this.total,
  });

  factory CartItemTotal.fromJson(Map<String, dynamic> json) {
    return CartItemTotal(
      itemId: json['itemId'] ?? '',
      productId: json['productId'] ?? '',
      variantId: json['variantId'],
      quantity: json['quantity'] ?? 0,
      regularPrice: (json['regularPrice'] ?? 0).toDouble(),
      effectivePrice: (json['effectivePrice'] ?? 0).toDouble(),
      isFlashSaleActive: json['isFlashSaleActive'] ?? false,
      savings: (json['savings'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

// Cart Statistics Model
class CartStatsModel {
  final bool success;
  final String message;
  final CartStatsData data;

  CartStatsModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CartStatsModel.fromJson(Map<String, dynamic> json) {
    return CartStatsModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CartStatsData.fromJson(json['data'] ?? {}),
    );
  }
}

class CartStatsData {
  final int totalItems;
  final int uniqueProducts;
  final double totalValue;
  final double totalSavings;
  final bool hasFlashSaleItems;
  final int activeFlashSaleItems;

  CartStatsData({
    required this.totalItems,
    required this.uniqueProducts,
    required this.totalValue,
    required this.totalSavings,
    required this.hasFlashSaleItems,
    required this.activeFlashSaleItems,
  });

  factory CartStatsData.fromJson(Map<String, dynamic> json) {
    return CartStatsData(
      totalItems: json['totalItems'] ?? 0,
      uniqueProducts: json['uniqueProducts'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      totalSavings: (json['totalSavings'] ?? 0).toDouble(),
      hasFlashSaleItems: json['hasFlashSaleItems'] ?? false,
      activeFlashSaleItems: json['activeFlashSaleItems'] ?? 0,
    );
  }
}

// Cart Validation Model
class CartValidationModel {
  final bool success;
  final String message;
  final CartValidationData data;

  CartValidationModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CartValidationModel.fromJson(Map<String, dynamic> json) {
    return CartValidationModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CartValidationData.fromJson(json['data'] ?? {}),
    );
  }
}

class CartValidationData {
  final bool valid;
  final List<CartValidationIssue> issues;

  CartValidationData({
    required this.valid,
    required this.issues,
  });

  factory CartValidationData.fromJson(Map<String, dynamic> json) {
    return CartValidationData(
      valid: json['valid'] ?? false,
      issues: json['issues'] != null
          ? (json['issues'] as List).map((issue) => CartValidationIssue.fromJson(issue)).toList()
          : [],
    );
  }
}

class CartValidationIssue {
  final String itemId;
  final String productId;
  final String? variantId;
  final String issue;
  final String type;
  final int? available;
  final int? requested;

  CartValidationIssue({
    required this.itemId,
    required this.productId,
    this.variantId,
    required this.issue,
    required this.type,
    this.available,
    this.requested,
  });

  factory CartValidationIssue.fromJson(Map<String, dynamic> json) {
    return CartValidationIssue(
      itemId: json['itemId'] ?? '',
      productId: json['productId'] ?? '',
      variantId: json['variantId'],
      issue: json['issue'] ?? '',
      type: json['type'] ?? '',
      available: json['available'],
      requested: json['requested'],
    );
  }
}