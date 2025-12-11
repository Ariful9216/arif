import 'package:flutter/material.dart';

class OrderModel {
  final bool success;
  final String message;
  final List<OrderData>? data;

  OrderModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
      data: json['data'] != null 
          ? (json['data'] is Map && json['data']['orders'] != null
              ? List<OrderData>.from(
                  json['data']['orders'].map((x) => OrderData.fromJson(x))
                )
              : json['data'] is List
                  ? List<OrderData>.from(
                      json['data'].map((x) => OrderData.fromJson(x))
                    )
                  : null)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class OrderData {
  final String id;
  final String user;
  final String invoice;
  final List<OrderItem> items;
  final OrderAddress address;
  final double deliveryCost;
  final String status;
  final bool deliveryCostRefunded;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderData({
    required this.id,
    required this.user,
    required this.invoice,
    required this.items,
    required this.address,
    required this.deliveryCost,
    required this.status,
    required this.deliveryCostRefunded,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
    id: json['_id'] ?? '',
    user: json['user'] ?? '',
      invoice: json['invoice'] ?? '',
      items: json['items'] != null 
          ? List<OrderItem>.from(
              json['items'].map((x) => OrderItem.fromJson(x))
            )
          : [],
      address: json['address'] != null 
          ? (json['address'] is String 
              ? OrderAddress.fromId(json['address'])
              : OrderAddress.fromJson(json['address']))
          : OrderAddress.empty(),
      deliveryCost: (json['deliveryCost'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      deliveryCostRefunded: json['deliveryCostRefunded'] ?? false,
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
      'user': user,
      'invoice': invoice,
      'items': items.map((x) => x.toJson()).toList(),
      'address': address.toJson(),
      'deliveryCost': deliveryCost,
      'status': status,
      'deliveryCostRefunded': deliveryCostRefunded,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  double get totalAmount {
    double itemsTotal = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    return itemsTotal;
  }

  double get itemsSubtotal {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class OrderItem {
  final String product;
  final String? variant;
  final int quantity;
  final double price;
  final ProductDetails? productDetails;
  final VariantDetails? variantDetails; // Add this

  OrderItem({
    required this.product,
    this.variant,
    required this.quantity,
    required this.price,
    this.productDetails,
    this.variantDetails, // Add this
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: json['product'] is Map ? json['product']['_id'] as String : json['product'] as String,
      variant: json['variant'] is Map ? json['variant']['_id'] as String : json['variant'] as String?,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      productDetails: json['product'] is Map
          ? ProductDetails.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      variantDetails: json['variant'] is Map
          ? VariantDetails.fromJson(json['variant'] as Map<String, dynamic>)
          : null, // Add this
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'variant': variant,
      'quantity': quantity,
      'price': price,
    };
  }

  double get itemTotal => price * quantity;
}

class ProductDetails {
  final String id;
  final String name;
  final List<OrderProductPicture> pictures;

  ProductDetails({
    required this.id,
    required this.name,
    required this.pictures,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      id: json['_id'] as String,
      name: json['name'] as String,
      pictures: (json['pictures'] as List<dynamic>?)
          ?.map((e) => OrderProductPicture.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'pictures': pictures.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderProductPicture {
  final String url;
  final bool isPrimary;

  OrderProductPicture({
    required this.url,
    required this.isPrimary,
  });

  factory OrderProductPicture.fromJson(Map<String, dynamic> json) {
    return OrderProductPicture(
      url: json['url'] as String,
      isPrimary: json['isPrimary'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'isPrimary': isPrimary,
    };
  }

  String get fullImageUrl {
    // Add base URL if needed
    return url.startsWith('http') ? url : 'https://ecommerce.arifmart.app$url';
  }
}

class OrderAddress {
  final String id;
  final String name;
  final String phone;
  final String district;
  final String thana;
  final String village;
  final String fullAddress;
  final String landmark;
  final String postalCode;
  final String addressType;
  final bool isDefault;

  OrderAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.district,
    required this.thana,
    required this.village,
    required this.fullAddress,
    required this.landmark,
    required this.postalCode,
    required this.addressType,
    required this.isDefault,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
    id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      district: json['district'] ?? '',
      thana: json['thana'] ?? '',
      village: json['village'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      landmark: json['landmark'] ?? '',
      postalCode: json['postalCode'] ?? '',
      addressType: json['addressType'] ?? 'home',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'district': district,
      'thana': thana,
      'village': village,
      'fullAddress': fullAddress,
      'landmark': landmark,
      'postalCode': postalCode,
      'addressType': addressType,
      'isDefault': isDefault,
    };
  }

  factory OrderAddress.empty() {
    return OrderAddress(
      id: '',
      name: '',
      phone: '',
      district: '',
      thana: '',
      village: '',
      fullAddress: '',
      landmark: '',
      postalCode: '',
      addressType: 'home',
      isDefault: false,
    );
  }

  factory OrderAddress.fromId(String addressId) {
    return OrderAddress(
      id: addressId,
      name: 'Address',
      phone: '',
      district: '',
      thana: '',
      village: '',
      fullAddress: '',
      landmark: '',
      postalCode: '',
      addressType: 'home',
      isDefault: false,
    );
  }

  String get displayAddress {
    return '$fullAddress, $village, $thana, $district';
  }

  String get shortAddress {
    return '$village, $thana, $district';
  }

  String get addressTypeIcon {
    switch (addressType.toLowerCase()) {
      case 'home':
        return '🏠';
      case 'work':
        return '🏢';
      default:
        return '📍';
    }
  }

  String get addressTypeDisplay {
    switch (addressType.toLowerCase()) {
      case 'home':
        return 'Home';
      case 'work':
        return 'Work';
      default:
        return 'Other';
    }
  }
}

// Single order response model
class SingleOrderModel {
  final bool success;
  final String message;
  final OrderData? data;

  SingleOrderModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory SingleOrderModel.fromJson(Map<String, dynamic> json) {
    return SingleOrderModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? OrderData.fromJson(json['data']) : null,
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

// Order statistics model
class OrderStatsModel {
  final bool success;
  final String message;
  final OrderStatsData? data;

  OrderStatsModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory OrderStatsModel.fromJson(Map<String, dynamic> json) {
    return OrderStatsModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? OrderStatsData.fromJson(json['data']) : null,
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

class OrderStatsData {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int cancelledOrders;
  final double totalSpent;
  final double averageOrderValue;

  OrderStatsData({
    required this.totalOrders,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.cancelledOrders,
    required this.totalSpent,
    required this.averageOrderValue,
  });

  factory OrderStatsData.fromJson(Map<String, dynamic> json) {
    return OrderStatsData(
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      confirmedOrders: json['confirmedOrders'] ?? 0,
      cancelledOrders: json['cancelledOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'confirmedOrders': confirmedOrders,
      'cancelledOrders': cancelledOrders,
      'totalSpent': totalSpent,
      'averageOrderValue': averageOrderValue,
    };
  }
}

class VariantDetails {
  final String id;
  final String name;
  final String picture;
  final List<OrderVariantImage>? images;

  VariantDetails({
    required this.id,
    required this.name,
    required this.picture,
    this.images,
  });

  factory VariantDetails.fromJson(Map<String, dynamic> json) {
    return VariantDetails(
      id: json['_id'] as String,
      name: json['name'] as String? ?? 'Variant',
      picture: json['picture'] as String? ?? '',
      images: json['images'] != null
          ? (json['images'] as List<dynamic>?)
              ?.map((e) => OrderVariantImage.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'picture': picture,
      'images': images?.map((e) => e.toJson()).toList(),
    };
  }

  String get fullImageUrl {
    // If variant has images array, use the primary image
    if (images != null && images!.isNotEmpty) {
      final primaryImage = images!.firstWhere(
        (img) => img.isPrimary,
        orElse: () => images!.first,
      );
      return primaryImage.fullImageUrl;
    }
    // Fallback to picture field
    return picture.startsWith('http') ? picture : 'https://ecommerce.arifmart.app$picture';
  }
}

class OrderVariantImage {
  final String url;
  final String? alt;
  final bool isPrimary;

  OrderVariantImage({
    required this.url,
    this.alt,
    required this.isPrimary,
  });

  factory OrderVariantImage.fromJson(Map<String, dynamic> json) {
    return OrderVariantImage(
      url: json['url'] as String,
      alt: json['alt'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'alt': alt,
      'isPrimary': isPrimary,
    };
  }

  String get fullImageUrl {
    return url.startsWith('http') ? url : 'https://ecommerce.arifmart.app$url';
  }
}