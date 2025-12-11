import 'package:flutter/material.dart';

class OfferOrderModel {
  final bool success;
  final String message;
  final List<OfferOrderData>? data;

  OfferOrderModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory OfferOrderModel.fromJson(Map<String, dynamic> json) {
    return OfferOrderModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? List<OfferOrderData>.from(
              json['data'].map((x) => OfferOrderData.fromJson(x))
            )
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

class OfferOrderData {
  final String id;
  final String userId;
  final String phoneNo;
  final String stateDivision;
  final OfferOrderOfferData offer;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfferOrderData({
    required this.id,
    required this.userId,
    required this.phoneNo,
    required this.stateDivision,
    required this.offer,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OfferOrderData.fromJson(Map<String, dynamic> json) {
    return OfferOrderData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      stateDivision: json['stateDivision'] ?? '',
      offer: json['offer'] != null 
          ? OfferOrderOfferData.fromJson(json['offer'])
          : OfferOrderOfferData.empty(),
      status: json['status'] ?? 'pending',
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
      'userId': userId,
      'phoneNo': phoneNo,
      'stateDivision': stateDivision,
      'offer': offer.toJson(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class OfferOrderOfferData {
  final String id;
  final String title;
  final String description;
  final double price;
  final double discountAmount;
  final String offerType;
  final int validity;
  final DateTime createdAt;

  OfferOrderOfferData({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountAmount,
    required this.offerType,
    required this.validity,
    required this.createdAt,
  });

  factory OfferOrderOfferData.fromJson(Map<String, dynamic> json) {
    return OfferOrderOfferData(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      offerType: json['offerType'] ?? '',
      validity: json['validity'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'discountAmount': discountAmount,
      'offerType': offerType,
      'validity': validity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OfferOrderOfferData.empty() {
    return OfferOrderOfferData(
      id: '',
      title: '',
      description: '',
      price: 0.0,
      discountAmount: 0.0,
      offerType: '',
      validity: 0,
      createdAt: DateTime.now(),
    );
  }

  double get finalPrice => price - discountAmount;
  
  bool get hasDiscount => discountAmount > 0;
  
  String get formattedPrice => '৳${price.toStringAsFixed(0)}';
  
  String get formattedFinalPrice => '৳${finalPrice.toStringAsFixed(0)}';
  
  String get formattedDiscount => '৳${discountAmount.toStringAsFixed(0)}';
}
